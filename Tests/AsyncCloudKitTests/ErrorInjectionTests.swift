//
//  ErrorInjectionTests.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

class ErrorInjectionTests: AsyncCloudKitTests {
  func testAccountStatusPropagatesErrors() async throws {
    try await verifyErrorPropagation { container, _ in
      _ = try await container.accountStatus()
    }
  }

  func testSaveFetchAndDeleteRecords() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecord(recordType: "Test") },
      { $0.recordID },
      { database in { record in try await database.save(record: record) } },
      { database in { recordID in try await database.fetch(recordID: recordID) } },
      { database in { recordID in try await database.delete(recordID: recordID) } }
    )
  }

  func testSaveFetchAndDeleteRecordZones() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      { database in { zone in try await database.save(recordZone: zone) } },
      { database in { zoneID in try await database.fetch(recordZoneID: zoneID) } },
      { database in { zoneID in try await database.delete(recordZoneID: zoneID) } }
    )
  }

  func testSaveFetchAndDeleteSubscriptions() async throws {
    try await validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
      { database in { subscription in try await database.save(subscription: subscription) } },
      { database in { subscriptionID in try await database.fetch(subscriptionID: subscriptionID) }
      },
      { database in { subscriptionID in try await database.delete(subscriptionID: subscriptionID) }
      }
    )
  }

  func testSaveFetchAndDeleteRecordsAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecord(recordType: "Test") },
      { $0.recordID },
      { $0.saveAtBackgroundPriority },
      { $0.fetchAtBackgroundPriority },
      { $0.deleteAtBackgroundPriority }
    )
  }

  func testSaveFetchAndDeleteRecordZonesAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      { $0.saveAtBackgroundPriority },
      { $0.fetchAtBackgroundPriority },
      { $0.deleteAtBackgroundPriority }
    )
  }

  func testSaveFetchAndDeleteSubscriptionsAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
      { $0.saveAtBackgroundPriority },
      { $0.fetchAtBackgroundPriority },
      { $0.deleteAtBackgroundPriority }
    )
  }

  private func validateSaveFetchAndDelete<T, ID>(
    _ create: () -> T,
    _ id: (T) -> ID,
    _ save: (ACKDatabase) -> ((T) async throws -> T),
    _ fetch: (ACKDatabase) -> ((ID) async throws -> T),
    _ delete: (ACKDatabase) -> ((ID) async throws -> ID)
  ) async throws where ID: Equatable {
    try await verifyErrorPropagation { _, database in
      let item = create()
      let itemID = id(item)
      _ = try await save(database)(item)
      _ = try await fetch(database)(itemID)
      _ = try await delete(database)(itemID)
    }
  }

  func testFetchAllRecordZones() async throws {
    try await validateFetchAll(
      (1...3).map { CKRecordZone(zoneName: "\($0)") },
      { $0.save },
      { database in { database.fetchAllRecordZones() } }
    )
  }

  func testFetchAllRecordZonesAtBackgroundPriority() async throws {
    try await validateFetchAll(
      (1...3).map { CKRecordZone(zoneName: "\($0)") },
      { $0.save },
      { $0.fetchAllRecordZonesAtBackgroundPriority }
    )
  }

  func testFetchCurrentUserRecord() async throws {
    try await verifyErrorPropagation(
      prepare: { _, database in
        let userRecord = CKRecord(
          recordType: "Test", recordID: MockOperationFactory.currentUserRecordID)
        _ = try await database.save(record: userRecord)
      },
      simulation: { _, database in
        _ = try await database.fetchCurrentUserRecord()
      }
    )
  }

  func testFetchAllSubscriptions() async throws {
    try await validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      { $0.save },
      { database in { database.fetchAllSubscriptions() } }
    )
  }

  func testFetchAllSubscriptionsAtBackgroundPriority() async throws {
    try await validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      { $0.save },
      { $0.fetchAllSubscriptionsAtBackgroundPriority }
    )
  }

  private func validateFetchAll<T>(
    _ items: [T],
    _ save: (ACKDatabase) -> (([T], CKOperation.Configuration?) -> ACKSequence<T>),
    _ fetch: (ACKDatabase) -> (() -> ACKSequence<T>)
  ) async throws where T: Hashable {
    try await verifyErrorPropagation(
      prepare: { _, database in
        _ = try await save(database)(items, nil).collect()
      },
      simulation: { _, database in
        _ = try await fetch(database)().collect()
      }
    )
  }

  func testQueryPropagatesErrors() async throws {
    try await verifyErrorPropagation(
      prepare: { _, database in
        let record = CKRecord(recordType: "Test")
        _ = try await database.save(record: record)
      },
      simulation: { _, database in
        _ = try await database.performQuery(ofType: "Test").collect()
      }
    )
  }

  private func verifyErrorPropagation(
    prepare: ((ACKContainer, ACKDatabase) async throws -> Void) = { _, _ in },
    simulation: ((ACKContainer, ACKDatabase) async throws -> Void)
  ) async rethrows {
    let space = DecisionSpace()
    repeat {
      let container = MockContainer()
      let database = MockDatabase()
      let factory = MockOperationFactory(database)
      AsyncCloudKit.operationFactory = factory

      // Prepare without error injection.
      // An error thrown here indicates a test defect.
      try await prepare(container, database)

      container.space = space
      database.space = space
      factory.space = space

      // Simulate the test scenario with error injection.
      // An error thrown here should have been injected or else the test has failed.
      do {
        try await simulation(container, database)
        XCTAssertFalse(
          space.hasDecidedAffirmatively(), "Simulation was expected to fail with injected error.")
      } catch {
        guard let mockError = error as? MockError,
          case MockError.simulated = mockError,
          space.hasDecidedAffirmatively()
        else {
          XCTFail("Simulation failed with unexpected error: \(error.localizedDescription)")
          break
        }
      }

      if !space.hasDecided() {
        XCTFail("Simulation did not make any decisions.")
        break
      }
    } while space.next()
  }
}
