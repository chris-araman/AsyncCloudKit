//
//  OperationFactory.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

/// Allows dependency injection for testing.
var operationFactory: OperationFactory = CKOperationFactory()

protocol OperationFactory {
  func createFetchAllRecordZonesOperation() -> ACKFetchRecordZonesOperation

  func createFetchAllSubscriptionsOperation() -> ACKFetchSubscriptionsOperation

  func createFetchCurrentUserRecordOperation() -> ACKFetchRecordsOperation

  func createFetchRecordsOperation(
    recordIDs: [CKRecord.ID]
  ) -> ACKFetchRecordsOperation

  func createFetchRecordZonesOperation(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> ACKFetchRecordZonesOperation

  func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> ACKFetchSubscriptionsOperation

  func createModifyRecordsOperation(
    recordsToSave: [CKRecord]?,
    recordIDsToDelete: [CKRecord.ID]?
  ) -> ACKModifyRecordsOperation

  func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]?,
    recordZoneIDsToDelete: [CKRecordZone.ID]?
  ) -> ACKModifyRecordZonesOperation

  func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]?,
    subscriptionIDsToDelete: [CKSubscription.ID]?
  ) -> ACKModifySubscriptionsOperation

  func createQueryOperation() -> ACKQueryOperation
}

class CKOperationFactory: OperationFactory {
  func createFetchAllRecordZonesOperation() -> ACKFetchRecordZonesOperation {
    CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
  }

  func createFetchAllSubscriptionsOperation() -> ACKFetchSubscriptionsOperation {
    CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
  }

  func createFetchCurrentUserRecordOperation() -> ACKFetchRecordsOperation {
    CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
  }

  func createFetchRecordsOperation(
    recordIDs: [CKRecord.ID]
  ) -> ACKFetchRecordsOperation {
    CKFetchRecordsOperation(recordIDs: recordIDs)
  }

  func createFetchRecordZonesOperation(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> ACKFetchRecordZonesOperation {
    CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
  }

  func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> ACKFetchSubscriptionsOperation {
    CKFetchSubscriptionsOperation(subscriptionIDs: subscriptionIDs)
  }

  func createModifyRecordsOperation(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil
  ) -> ACKModifyRecordsOperation {
    CKModifyRecordsOperation(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete
    )
  }

  func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil
  ) -> ACKModifyRecordZonesOperation {
    CKModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
  }

  func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) -> ACKModifySubscriptionsOperation {
    CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptionsToSave,
      subscriptionIDsToDelete: subscriptionIDsToDelete
    )
  }

  func createQueryOperation() -> ACKQueryOperation {
    CKQueryOperation()
  }
}
