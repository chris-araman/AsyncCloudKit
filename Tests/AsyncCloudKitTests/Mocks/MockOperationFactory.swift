//
//  MockOperationFactory.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import AsyncCloudKit

public class MockOperationFactory: OperationFactory {
  let database: MockDatabase
  var space: DecisionSpace?

  init(_ database: MockDatabase, _ space: DecisionSpace? = nil) {
    self.database = database
    self.space = space
  }

  public func createFetchAllRecordZonesOperation() -> ACKFetchRecordZonesOperation {
    MockFetchRecordZonesOperation(database, space)
  }

  public func createFetchAllSubscriptionsOperation() -> ACKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database, space)
  }

  public static let currentUserRecordID = CKRecord.ID(recordName: "CurrentUserRecord")

  public func createFetchCurrentUserRecordOperation() -> ACKFetchRecordsOperation {
    MockFetchRecordsOperation(database, space, [MockOperationFactory.currentUserRecordID])
  }

  public func createFetchRecordsOperation(recordIDs: [CKRecord.ID]) -> ACKFetchRecordsOperation {
    MockFetchRecordsOperation(database, space, recordIDs)
  }

  public func createFetchRecordZonesOperation(recordZoneIDs: [CKRecordZone.ID])
    -> ACKFetchRecordZonesOperation
  {
    MockFetchRecordZonesOperation(database, space, recordZoneIDs)
  }

  public func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> ACKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database, space, subscriptionIDs)
  }

  public func createModifyRecordsOperation(
    recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?
  ) -> ACKModifyRecordsOperation {
    MockModifyRecordsOperation(database, space, recordsToSave, recordIDsToDelete)
  }

  public func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZone.ID]?
  ) -> ACKModifyRecordZonesOperation {
    MockModifyRecordZonesOperation(database, space, recordZonesToSave, recordZoneIDsToDelete)
  }

  public func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) -> ACKModifySubscriptionsOperation {
    MockModifySubscriptionsOperation(database, space, subscriptionsToSave, subscriptionIDsToDelete)
  }

  public func createQueryOperation() -> ACKQueryOperation {
    MockQueryOperation(database, space)
  }
}
