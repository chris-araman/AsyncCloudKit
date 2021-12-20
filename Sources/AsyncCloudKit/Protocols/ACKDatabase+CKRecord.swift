//
//  ACKDatabase+CKRecord.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension ACKDatabase {
  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: The saved [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func save(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) async throws -> CKRecord {
    try await save(
      records: [record],
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).single()
  }

  /// Saves multiple records.
  ///
  /// - Parameters:
  ///   - records: The records to save to the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t save one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AsyncCloudKitSequence<CKRecord> {
    modify(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { saved, _ in
      saved
    }.eraseToAsyncCloudKitSequence()
  }

  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Note: AsyncCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: The saved [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449114-save)
  public func saveAtBackgroundPriority(record: CKRecord) async throws -> CKRecord {
    try await asyncAtBackgroundPriorityFrom(save, with: record)
  }

  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func saveWithProgress(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AsyncCloudKitSequence<(CKRecord, Progress)> {
    saveWithProgress(
      records: [record],
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData)
  }

  /// Saves multiple records.
  ///
  /// - Parameters:
  ///   - records: The records to save to the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t save one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func saveWithProgress(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AsyncCloudKitSequence<(CKRecord, Progress)> {
    modifyWithProgress(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { progress, _ in
      progress
    }.eraseToAsyncCloudKitSequence()
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The deleted [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id).
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func delete(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecord.ID {
    try await delete(
      recordIDs: [recordID],
      withConfiguration: configuration
    ).single()
  }

  /// Deletes multiple records.
  ///
  /// - Parameters:
  ///   - recordIDs: The IDs of the records to delete permanently from the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t delete one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKRecord.ID> {
    modify(
      recordsToSave: nil,
      recordIDsToDelete: recordIDs,
      atomically: isAtomic,
      withConfiguration: configuration
    ).compactMap { _, deleted in
      deleted
    }.eraseToAsyncCloudKitSequence()
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  /// - Note: AsyncCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: The deleted [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id).
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449122-delete)
  public func deleteAtBackgroundPriority(recordID: CKRecord.ID) async throws -> CKRecord.ID {
    try await asyncAtBackgroundPriorityFrom(delete, with: recordID)
  }

  /// Modifies one or more records.
  ///
  /// - Parameters:
  ///   - recordsToSave: The records to save to the database.
  ///   - recordsToDelete: The IDs of the records to delete permanently from the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t update one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s and the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AsyncCloudKitSequence<(CKRecord?, CKRecord.ID?)> {
    modifyWithProgress(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { saved, deleted in
      if let deleted = deleted {
        return (nil, deleted)
      }

      if let saved = saved,
        case (let record, let progress) = saved,
        case .complete = progress
      {
        return (record, nil)
      }

      return nil
    }.eraseToAsyncCloudKitSequence()
  }

  /// Modifies one or more records.
  ///
  /// - Parameters:
  ///   - recordsToSave: The records to save to the database.
  ///   - recordsToDelete: The IDs of the records to delete permanently from the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t update one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, and the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func modifyWithProgress(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AsyncCloudKitSequence<((CKRecord, Progress)?, CKRecord.ID?)> {
    AsyncThrowingStream { continuation in
      let operation = operationFactory.createModifyRecordsOperation(
        recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
      )
      if configuration != nil {
        operation.configuration = configuration
      }
      operation.savePolicy = savePolicy
      operation.clientChangeTokenData = clientChangeTokenData
      operation.isAtomic = isAtomic
      continuation.onTermination = { @Sendable _ in
        operation.cancel()
      }
      operation.perRecordProgressBlock = { record, rawProgress in
        let progress = Progress(rawValue: rawProgress)
        if progress != .complete {
          continuation.yield(((record, progress), nil))
        }
      }
      operation.perRecordCompletionBlock = { record, error in
        guard error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        continuation.yield(((record, .complete), nil))
      }
      operation.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
        guard error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        if let deletedRecordIDs = deletedRecordIDs {
          for recordID in deletedRecordIDs {
            continuation.yield((nil, recordID))
          }
        }

        continuation.finish()
      }

      self.add(operation)
    }.eraseToAsyncCloudKitSequence()
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  ///   - desiredKeys: The fields of the record to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for the record. When CloudKit returns the record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     the record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The fetched [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetch(
    recordID: CKRecord.ID,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecord {
    try await fetch(
      recordIDs: [recordID],
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    ).single()
  }

  /// Fetches multiple records.
  ///
  /// - Parameters:
  ///   - recordIDs: The record IDs of the records to fetch.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKRecord> {
    fetchWithProgress(
      recordIDs: recordIDs,
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    ).compactMap { _, record in
      record
    }.eraseToAsyncCloudKitSequence()
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  /// - Note: AsyncCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// immediately.
  /// - Returns: The [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449126-fetch)
  public func fetchAtBackgroundPriority(withRecordID recordID: CKRecord.ID) async throws -> CKRecord {
    try await asyncAtBackgroundPriorityFrom(fetch, with: recordID)
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  ///   - desiredKeys: The fields of the record to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for the record. When CloudKit returns the record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     the record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits ``Progress`` and the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord) on completion.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetchWithProgress(
    recordID: CKRecord.ID,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<((CKRecord.ID, Progress)?, CKRecord?)> {
    fetchWithProgress(
      recordIDs: [recordID],
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    )
  }

  /// Fetches multiple records.
  ///
  /// - Parameters:
  ///   - recordIDs: The record IDs of the records to fetch.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the ``Progress`` of the fetched
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s and the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetchWithProgress(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<((CKRecord.ID, Progress)?, CKRecord?)> {
    AsyncThrowingStream { continuation in
      let operation = operationFactory.createFetchRecordsOperation(recordIDs: recordIDs)
      if configuration != nil {
        operation.configuration = configuration
      }
      operation.desiredKeys = desiredKeys
      continuation.onTermination = { @Sendable _ in
        operation.cancel()
      }
      operation.perRecordProgressBlock = { recordID, rawProgress in
        let progress = Progress(rawValue: rawProgress)
        continuation.yield(((recordID, progress), nil))
      }
      operation.perRecordCompletionBlock = { record, _, error in
        guard let record = record, error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        continuation.yield((nil, record))
      }
      operation.fetchRecordsCompletionBlock = { _, error in
        guard error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        continuation.finish()
      }

      // TODO: Ensure we only add the operation once, for every place we create an AsyncThrowingStream.
      self.add(operation)
    }.eraseToAsyncCloudKitSequence()
  }

  /// Fetches the current user record.
  ///
  /// - Parameters:
  ///   - desiredKeys: The fields of the record to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for the record. When CloudKit returns the record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     the record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord).
  /// - SeeAlso:
  /// [fetchCurrentUserRecordOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation/1476070-fetchcurrentuserrecordoperation)
  public func fetchCurrentUserRecord(
    desiredKeys _: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKRecord {
    let operation = operationFactory.createFetchCurrentUserRecordOperation()
    return try await asyncFromFetch(operation, configuration) { completion in
      operation.fetchRecordsCompletionBlock = completion
    }.single()
  }

  /// Fetches records that match the specified query.
  ///
  /// - Parameters:
  ///   - recordType: The record type to search.
  ///   - predicate: The predicate to use for matching records.
  ///   - sortDescriptors: The sort descriptors for organizing the query’s results.
  ///   - zoneID: The ID of the record zone that contains the records to search. The value of this parameter limits the
  ///     scope of the search to only the records in the specified record zone. If you don’t specify a record zone, the
  ///     search includes all record zones.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits any matching
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
  public func performQuery(
    ofType recordType: CKRecord.RecordType,
    where predicate: NSPredicate = NSPredicate(value: true),
    orderBy sortDescriptors: [NSSortDescriptor]? = nil,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKRecord> {
    let query = CKQuery(recordType: recordType, predicate: predicate)
    query.sortDescriptors = sortDescriptors
    return perform(
      query,
      inZoneWith: zoneID,
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    )
  }

  /// Fetches records that match the specified query.
  ///
  /// - Parameters:
  ///   - query: The query for the search.
  ///   - zoneID: The ID of the record zone that contains the records to search. The value of this parameter limits the
  ///     scope of the search to only the records in the specified record zone. If you don’t specify a record zone, the
  ///     search includes all record zones.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - resultsLimit: The maximum number of records to buffer at a time.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits any matching
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
  public func perform(
    _ query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    resultsLimit: Int = CKQueryOperation.maximumResults
  ) -> AsyncCloudKitSequence<CKRecord> {
    var operation = operationFactory.createQueryOperation()
    operation.query = query
    return AsyncThrowingStream { continuation in
      func addOperation() {
        operation.desiredKeys = desiredKeys
        operation.zoneID = zoneID
        operation.resultsLimit = resultsLimit

        if configuration != nil {
          operation.configuration = configuration
        }

        operation.recordFetchedBlock = { record in
          continuation.yield(record)
        }

        operation.queryCompletionBlock = { cursor, error in
          guard error == nil else {
            continuation.finish(throwing: error!)
            return
          }

          guard let cursor = cursor else {
            // We've fetched all the results.
            continuation.finish()
            return
          }

          // Prepare to fetch the next page of results.
          operation = operationFactory.createQueryOperation()
          operation.cursor = cursor
          addOperation()
        }

        let onTermination = {
          operation.cancel()
        }
        continuation.onTermination = { @Sendable _ in
          onTermination()
        }

        self.add(operation)
      }

      addOperation()
    }.eraseToAsyncCloudKitSequence()
  }
}
