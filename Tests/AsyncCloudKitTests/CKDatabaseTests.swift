//
//  CKDatabaseTests.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit
@testable import enum AsyncCloudKit.Progress

final class CKDatabaseTests: AsyncCloudKitTests {
  func testDeleteRecordFailsWhenDoesNotExist() async throws {
    let record = CKRecord(recordType: "Test")
    await assertThrowsError(try await database.delete(recordID: record.recordID))
  }

  func testDeleteRecordZoneFailsWhenDoesNotExist() async throws {
    let zone = CKRecordZone(zoneName: "Test")
    await assertThrowsError(try await database.delete(recordZoneID: zone.zoneID))
  }

  func testDeleteSubscriptionFailsWhenDoesNotExist() async throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    await assertThrowsError(try await database.delete(subscriptionID: subscription.subscriptionID))
  }

  func testDeleteRecordAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let record = CKRecord(recordType: "Test")
    await assertThrowsError(try await database.deleteAtBackgroundPriority(recordID: record.recordID))
  }

  func testDeleteRecordZoneAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let zone = CKRecordZone(zoneName: "Test")
    await assertThrowsError(try await database.deleteAtBackgroundPriority(recordZoneID: zone.zoneID))
  }

  func testDeleteSubscriptionAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    await assertThrowsError(try await database.deleteAtBackgroundPriority(subscriptionID: subscription.subscriptionID))
  }

  func testFetchRecordFailsWhenDoesNotExist() async throws {
    let record = CKRecord(recordType: "Test")
    await assertThrowsError(try await database.fetch(recordID: record.recordID))
  }

  func testFetchRecordWithProgressFailsWhenDoesNotExist() async throws {
    let record = CKRecord(recordType: "Test")
    await assertThrowsError(try await database.fetchWithProgress(recordID: record.recordID).collect())
  }

  func testFetchRecordZoneFailsWhenDoesNotExist() async throws {
    let zone = CKRecordZone(zoneName: "Test")
    await assertThrowsError(try await database.fetch(recordZoneID: zone.zoneID))
  }

  func testFetchSubscriptionFailsWhenDoesNotExist() async throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    await assertThrowsError(try await database.fetch(subscriptionID: subscription.subscriptionID))
  }

  func testFetchRecordAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let record = CKRecord(recordType: "Test")
    await assertThrowsError(try await database.fetchAtBackgroundPriority(withRecordID: record.recordID))
  }

  func testFetchRecordZoneAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let zone = CKRecordZone(zoneName: "Test")
    await assertThrowsError(try await database.fetchAtBackgroundPriority(withRecordZoneID: zone.zoneID))
  }

  func testFetchSubscriptionAtBackgroundPriorityFailsWhenDoesNotExist() async throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    await assertThrowsError(try await database.fetchAtBackgroundPriority(
      withSubscriptionID: subscription.subscriptionID))
  }

  func testFetchRecordsIncludesOnlyRequestedRecords() async throws {
    let records = (1...3).map { CKRecord(recordType: "Test\($0)") }
    _ = try await database.save(records: records).collect()
    let fetched = try await database.fetch(recordIDs: [records[0].recordID, records[1].recordID]).collect()
    XCTAssertEqual(Set(fetched), Set(records[0...1]))
  }

  func testFetchRecordZonesIncludesOnlyRequestedRecordZones() async throws {
    let zones = (1...3).map { CKRecordZone(zoneName: "Test\($0)") }
    _ = try await database.save(recordZones: zones).collect()
    let fetched = try await database.fetch(recordZoneIDs: [zones[0].zoneID, zones[1].zoneID]).collect()
    XCTAssertEqual(Set(fetched), Set(zones[0...1]))
  }

  func testFetchSubscriptionsIncludesOnlyRequestedSubscriptions() async throws {
    let subscriptions = (1...3).map { CKDatabaseSubscription(subscriptionID: "Test\($0)") }
    let saved = try await database.save(subscriptions: subscriptions).collect()
    XCTAssertEqual(Set(saved), Set(subscriptions[0...2]))

    let fetched = try await database.fetch(subscriptionIDs: [
      subscriptions[0].subscriptionID,
      subscriptions[1].subscriptionID,
    ]).collect()
    XCTAssertEqual(Set(fetched), Set(subscriptions[0...1]))
  }

  func testSaveFetchAndDeleteRecord() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecord(recordType: "Test") },
      { record in record.recordID },
      { record in try await database.save(record: record) },
      { recordID in try await database.fetch(recordID: recordID) },
      { recordID in try await database.delete(recordID: recordID) }
    )
  }

  func testSaveFetchAndDeleteRecordAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecord(recordType: "Test") },
      { $0.recordID },
      database.saveAtBackgroundPriority,
      database.fetchAtBackgroundPriority,
      database.deleteAtBackgroundPriority)
  }

  func testSaveFetchAndDeleteRecordWithProgress() async throws {
    let configuration = CKOperation.Configuration()
    let record = CKRecord(recordType: "Test")
    let save = database.saveWithProgress(record: record, withConfiguration: configuration)
    let saved = try await validateSaveProgressOfSingleRecord(from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetchWithProgress(
      recordID: saved.recordID, withConfiguration: configuration)
    let fetched = try await validateFetchProgressOfSingleRecord(from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let deleted = try await database.delete(recordID: saved.recordID, withConfiguration: configuration)
    XCTAssertEqual(deleted, record.recordID)
  }

  func testSaveFetchAndDeleteRecordZone() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      database.save,
      database.fetch,
      database.delete)
  }

  func testSaveFetchAndDeleteRecordZoneAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      database.saveAtBackgroundPriority,
      database.fetchAtBackgroundPriority,
      database.deleteAtBackgroundPriority)
  }

  func testSaveFetchAndDeleteSubscription() async throws {
    try await validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
      database.save,
      database.fetch,
      database.delete)
  }

  func testSaveFetchAndDeleteSubscriptionAtBackgroundPriority() async throws {
    try await validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
      database.saveAtBackgroundPriority,
      database.fetchAtBackgroundPriority,
      database.deleteAtBackgroundPriority)
  }

  private func validateSaveProgressOfSingleRecord(
    from sequence: AsyncCloudKitSequence<(CKRecord, Progress)>
  ) async throws -> CKRecord {
    let records = try await validateSaveProgress(from: sequence)
    XCTAssertEqual(records.count, 1)
    return try XCTUnwrap(records.first)
  }

  private func validateFetchProgressOfSingleRecord(
    from sequence: AsyncCloudKitSequence<((CKRecord.ID, Progress)?, CKRecord?)>
  ) async throws -> CKRecord {
    let records = try await validateFetchProgress(from: sequence)
    XCTAssertEqual(records.count, 1)
    return try XCTUnwrap(records.first)
  }

  private func validateSaveProgress(
    from sequence: AsyncCloudKitSequence<(CKRecord, Progress)>
  ) async throws -> [CKRecord] {
    var recordProgress: [CKRecord: Progress] = [:]
    let elements = try await sequence.collect()
    for (recordID, progress) in elements {
      if let latest = recordProgress[recordID] {
        XCTAssertGreaterThan(
          progress, latest,
          "Received a progress update that was not more complete than a previous update.")
      }

      recordProgress[recordID] = progress
    }

    for (recordID, progress) in recordProgress {
      XCTAssertEqual(progress, .complete, "Record was not complete: \(recordID)")
    }

    return Array(recordProgress.keys)
  }

  private func validateFetchProgress(
    from sequence: AsyncCloudKitSequence<((CKRecord.ID, Progress)?, CKRecord?)>
  ) async throws -> [CKRecord]
  {
    var records: [CKRecord] = []
    var recordProgress: [CKRecord.ID: Progress] = [:]
    let elements = try await sequence.collect()
    for (update, record) in elements {
      guard let record = record else {
        let (recordID, progress) = try XCTUnwrap(update)
        if let latest = recordProgress[recordID] {
          XCTAssertGreaterThan(
            progress, latest,
            "Received a progress update that was not more complete than a previous update.")
        }

        recordProgress[recordID] = progress
        continue
      }

      records.append(record)
    }

    for (recordID, progress) in recordProgress {
      XCTAssertEqual(progress, .complete, "Record was not complete: \(recordID)")
    }

    XCTAssertEqual(
      Set(records.map({ $0.recordID })),
      Set(recordProgress.keys),
      "Progress was reported for a different set of records than was output.")

    return records
  }

  private func validateSaveFetchAndDelete<T, ID>(
    _ create: () -> T,
    _ id: (T) -> ID,
    _ save: (T, CKOperation.Configuration?) async throws -> T,
    _ fetch: (ID, CKOperation.Configuration?) async throws -> T,
    _ delete: (ID, CKOperation.Configuration?) async throws -> ID
  ) async throws where ID: Equatable {
    let configuration = CKOperation.Configuration()
    try await validateSaveFetchAndDelete(
      create,
      id,
      { item in try await save(item, configuration) },
      { itemID in try await fetch(itemID, configuration) },
      { itemID in try await delete(itemID, configuration) }
    )
  }

  private func validateSaveFetchAndDelete<T, ID>(
    _ create: () -> T,
    _ id: (T) -> ID,
    _ save: (T) async throws -> T,
    _ fetch: (ID) async throws -> T,
    _ delete: (ID) async throws -> ID
  ) async throws where ID: Equatable {
    let item = create()
    let itemID = id(item)
    let saved = try await save(item)
    XCTAssertEqual(id(saved), itemID)

    let fetched = try await fetch(itemID)
    XCTAssertEqual(id(fetched), itemID)

    let deleted = try await delete(itemID)
    XCTAssertEqual(deleted, itemID)
  }

  func testFetchAllRecordZones() async throws {
    let configuration = CKOperation.Configuration()
    try await validateFetchAll(
      (1...3).map { CKRecordZone(zoneName: "\($0)") },
      database.save,
      { () in database.fetchAllRecordZones(withConfiguration: configuration) }
    )
  }

  func testFetchAllRecordZonesAtBackgroundPriority() async throws {
    try await validateFetchAll(
      (1...3).map { CKRecordZone(zoneName: "\($0)") },
      database.save,
      database.fetchAllRecordZonesAtBackgroundPriority
    )
  }

  func testFetchCurrentUserRecord() async throws {
    let userRecord = CKRecord(
      recordType: "CurrentUserRecord", recordID: MockOperationFactory.currentUserRecordID)
    _ = try await database.save(record: userRecord)

    let configuration = CKOperation.Configuration()
    let desiredKeys = ["Key"]
    let fetched = try await database.fetchCurrentUserRecord(
      desiredKeys: desiredKeys, withConfiguration: configuration)
    XCTAssertEqual(fetched, userRecord)
  }

  func testFetchAllSubscriptions() async throws {
    let configuration = CKOperation.Configuration()
    try await validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      database.save,
      { () in database.fetchAllSubscriptions(withConfiguration: configuration) }
    )
  }

  func testFetchAllSubscriptionsAtBackgroundPriority() async throws {
    try await validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      database.save,
      database.fetchAllSubscriptionsAtBackgroundPriority
    )
  }

  private func validateFetchAll<T>(
    _ items: [T],
    _ save: ([T], CKOperation.Configuration?) -> AsyncCloudKitSequence<T>,
    _ fetch: () -> AsyncCloudKitSequence<T>
  ) async throws where T: Hashable {
    let configuration = CKOperation.Configuration()
    _ = try await save(items, configuration).collect()
    let fetched = try await fetch().collect()
    XCTAssertEqual(Set(fetched), Set(items))
  }

  func testQueryWithNoRecordsReturnsNoResults() async throws {
    for try await _ in database.performQuery(ofType: "Test") {
      XCTFail("Expected query to return no results.")
    }
  }

  func testQueryWithNoMatchingRecordsReturnsNoResults() async throws {
    _ = try await database.save(record: CKRecord(recordType: "Test"))
    for try await _ in database.performQuery(ofType: "NonMatching") {
      XCTFail("Expected query to return no results.")
    }
  }

  func testQueryReturnsExpectedResults() async throws {
    let configuration = CKOperation.Configuration()
    let records = (0...9).map {
      CKRecord(recordType: "Test", recordID: CKRecord.ID(recordName: "\($0)"))
    }
    _ = try await database.save(records: records, withConfiguration: configuration).collect()

    // MockQueryOperation returns every second record of matching type, sorted by ID.recordName.
    let results = try await database.performQuery(ofType: "Test", withConfiguration: configuration).collect()
    XCTAssertEqual(Set(results), Set(stride(from: 0, to: 9, by: 2).map { records[$0 + 1] }))
  }

  // TODO:
  // func testTerminatingSequenceEarlyCancelsSave() async throws {
  // }
  // func testTerminatingSequenceEarlyCancelsFetch() async throws {
  // }
  // func testTerminatingSequenceEarlyCancelsDelete() async throws {
  // }
  // func testTerminatingSequenceEarlyCancelsQuery() async throws {
  // }

  func testCKOperationFactory() {
    let factory = CKOperationFactory()
    _ = factory.createFetchAllRecordZonesOperation()
    _ = factory.createFetchAllSubscriptionsOperation()
    _ = factory.createFetchCurrentUserRecordOperation()
    _ = factory.createFetchRecordsOperation(recordIDs: [])
    _ = factory.createFetchRecordZonesOperation(recordZoneIDs: [])
    _ = factory.createFetchSubscriptionsOperation(subscriptionIDs: [])
    _ = factory.createModifyRecordsOperation(
      recordsToSave: nil,
      recordIDsToDelete: nil
    )
    _ = factory.createModifyRecordZonesOperation(
      recordZonesToSave: nil,
      recordZoneIDsToDelete: nil
    )
    _ = factory.createModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: nil
    )
    _ = factory.createQueryOperation()
  }

  // XCTAssertThrowsError, but async
  private func assertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      XCTFail(message(), file: file, line: line)
    } catch {
      errorHandler(error)
    }
  }
}
