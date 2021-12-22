//
//  ACKDatabase+CKRecordZone.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension ACKDatabase {
  /// Saves a single record zone.
  ///
  /// - Parameters:
  ///   - recordZone: The record zone to save.
  /// - Note: AsyncCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: The saved [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone).
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449108-save)
  public func saveAtBackgroundPriority(recordZone: CKRecordZone) async throws -> CKRecordZone {
    try await asyncAtBackgroundPriorityFrom(save, with: recordZone)
  }

  /// Saves a single record zone.
  ///
  /// - Parameters:
  ///   - recordZone: The record zone to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The saved [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone).
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func save(
    recordZone: CKRecordZone,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecordZone {
    try await save(
      recordZones: [recordZone],
      withConfiguration: configuration
    ).single()
  }

  /// Saves multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZones: The record zones to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``ACKSequence`` that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func save(
    recordZones: [CKRecordZone],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> ACKSequence<CKRecordZone> {
    modify(recordZonesToSave: recordZones, withConfiguration: configuration).compactMap {
      saved, _ in
      saved
    }.erase()
  }

  /// Deletes a single record zone.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to delete.
  /// - Note: AsyncCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: The deleted [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id).
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449118-delete)
  public func deleteAtBackgroundPriority(recordZoneID: CKRecordZone.ID) async throws
    -> CKRecordZone.ID
  {
    try await asyncAtBackgroundPriorityFrom(delete, with: recordZoneID)
  }

  /// Deletes a single record zone.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The deleted [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id).
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func delete(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecordZone.ID {
    try await delete(
      recordZoneIDs: [recordZoneID],
      withConfiguration: configuration
    ).single()
  }

  /// Deletes multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZoneIDs: The IDs of the record zones to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``ACKSequence`` that emits the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id)s.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func delete(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> ACKSequence<CKRecordZone.ID> {
    modify(recordZoneIDsToDelete: recordZoneIDs, withConfiguration: configuration).compactMap {
      _, deleted in
      deleted
    }.erase()
  }

  /// Modifies one or more record zones.
  ///
  /// - Parameters:
  ///   - recordZonesToSave: The record zones to save.
  ///   - recordZonesToDelete: The IDs of the record zones to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``ACKSequence`` that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s and the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id)s.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func modify(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> ACKSequence<(CKRecordZone?, CKRecordZone.ID?)> {
    let operation = operationFactory.createModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
    return asyncFromModify(operation, configuration) { completion in
      operation.modifyRecordZonesCompletionBlock = completion
    }
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to fetch.
  /// - Note: AsyncCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// zone immediately.
  /// - Returns: The [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone).
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449104-fetch)
  public func fetchAtBackgroundPriority(withRecordZoneID recordZoneID: CKRecordZone.ID) async throws
    -> CKRecordZone
  {
    try await asyncAtBackgroundPriorityFrom(fetch, with: recordZoneID)
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone).
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public func fetch(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecordZone {
    try await fetch(
      recordZoneIDs: [recordZoneID],
      withConfiguration: configuration
    ).single()
  }

  /// Fetches multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZoneIDs: The IDs of the record zones to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``ACKSequence`` that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s.
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public func fetch(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> ACKSequence<CKRecordZone> {
    let operation = operationFactory.createFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
    return asyncFromFetch(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }

  /// Fetches the database's record zones.
  ///
  /// - Note: AsyncCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// zones immediately.
  /// - Returns: An ``ACKSequence`` that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s.
  /// - SeeAlso: [fetchAllRecordZones](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones)
  public func fetchAllRecordZonesAtBackgroundPriority() -> ACKSequence<CKRecordZone> {
    asyncFromFetchAll(fetchAllRecordZones)
  }

  /// Fetches the database's record zones.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``ACKSequence`` that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s.
  /// - SeeAlso:
  /// [fetchAllRecordZonesOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation/1514890-fetchallrecordzonesoperation)
  public func fetchAllRecordZones(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> ACKSequence<CKRecordZone> {
    let operation = operationFactory.createFetchAllRecordZonesOperation()
    return asyncFromFetch(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }
}
