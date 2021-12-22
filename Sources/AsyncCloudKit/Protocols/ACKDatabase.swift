//
//  ACKDatabase.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

/// An extension that declares [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase)
/// conforms to the ``ACKDatabase`` protocol provided by AsyncCloudKit.
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
extension CKDatabase: ACKDatabase {
}

/// A protocol used to abstract a [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase).
///
/// Invoke the async extension methods on your
/// [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase)
/// instances to process records, record zones, and subscriptions asynchronously.
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
public protocol ACKDatabase {
  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449122-delete)
  func delete(
    withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord.ID?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449118-delete)
  func delete(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone.ID?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003590-delete)
  func delete(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (String?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449126-fetch)
  func fetch(
    withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449104-fetch)
  func fetch(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003591-fetch)
  func fetch(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (CKSubscription?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllRecordZones](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones)
  func fetchAllRecordZones(completionHandler: @escaping ([CKRecordZone]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449110-fetchallsubscriptions)
  func fetchAllSubscriptions(completionHandler: @escaping ([CKSubscription]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449127-perform)
  func perform(
    _ query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID?,
    completionHandler: @escaping ([CKRecord]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449114-save)
  func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449108-save)
  func save(_ zone: CKRecordZone, completionHandler: @escaping (CKRecordZone?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449102-save)
  func save(
    _ subscription: CKSubscription, completionHandler: @escaping (CKSubscription?, Error?) -> Void)
}

extension ACKDatabase {
  func add(_ operation: ACKDatabaseOperation) {
    guard let database = self as? CKDatabase, let dbOperation = operation as? CKDatabaseOperation
    else {
      // TODO: Use an OperationQueue.
      operation.start()
      return
    }

    database.add(dbOperation)
  }

  func asyncAtBackgroundPriorityFrom<Input, Output>(
    _ method: @escaping (Input, @escaping (Output?, Error?) -> Void) -> Void,
    with input: Input
  ) async throws -> Output {
    try await withCheckedThrowingContinuation { continuation in
      method(input) { output, error in
        guard let output = output, error == nil else {
          continuation.resume(throwing: error!)
          return
        }

        continuation.resume(returning: output)
      }
    }
  }

  func asyncFromFetch<Output, Ignored>(
    _ operation: ACKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Ignored: Output]?, Error?) -> Void) -> Void
  ) -> ACKSequence<Output> {
    if configuration != nil {
      operation.configuration = configuration
    }
    return AsyncThrowingStream { continuation in
      continuation.onTermination = { @Sendable termination in
        operation.cancel()
      }
      setCompletion { outputs, error in
        guard let outputs = outputs, error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        for output in outputs.values {
          continuation.yield(output)
        }

        continuation.finish()
      }

      self.add(operation)
    }.erase()
  }

  func asyncFromFetchAll<Output>(
    _ method: @escaping (@escaping ([Output]?, Error?) -> Void) -> Void
  ) -> ACKSequence<Output> {
    AsyncThrowingStream { continuation in
      method { outputs, error in
        guard let outputs = outputs, error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        for output in outputs {
          continuation.yield(output)
        }

        continuation.finish()
      }
    }.erase()
  }

  func asyncFromModify<Output, OutputID>(
    _ operation: ACKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Output]?, [OutputID]?, Error?) -> Void) -> Void
  ) -> ACKSequence<(Output?, OutputID?)> {
    if configuration != nil {
      operation.configuration = configuration
    }
    return AsyncThrowingStream { continuation in
      continuation.onTermination = { @Sendable termination in
        operation.cancel()
      }
      setCompletion { saved, deleted, error in
        guard error == nil else {
          continuation.finish(throwing: error!)
          return
        }

        if let saved = saved {
          for output in saved {
            continuation.yield((output, nil))
          }
        }

        if let deleted = deleted {
          for outputID in deleted {
            continuation.yield((nil, outputID))
          }
        }

        continuation.finish()
      }

      self.add(operation)
    }.erase()
  }
}
