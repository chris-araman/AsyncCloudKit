//
//  ACKDatabase+CKSubscription.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension ACKDatabase {
  /// Saves a single subscription.
  ///
  /// - Parameters:
  ///   - subscription: The subscription to save.
  /// - Note: AsyncCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: The saved [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription).
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449102-save)
  public func saveAtBackgroundPriority(subscription: CKSubscription) async throws -> CKSubscription {
    try await asyncAtBackgroundPriorityFrom(save, with: subscription)
  }

  /// Saves a single subscription.
  ///
  /// - Parameters:
  ///   - subscription: The subscription to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The saved [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription).
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func save(
    subscription: CKSubscription,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKSubscription {
    try await save(
      subscriptions: [subscription],
      withConfiguration: configuration
    ).single()
  }

  /// Saves multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptions: The subscriptions to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func save(
    subscriptions: [CKSubscription],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKSubscription> {
    modify(subscriptionsToSave: subscriptions, withConfiguration: configuration).compactMap {
      saved, _ in
      saved
    }.eraseToAsyncCloudKitSequence()
  }

  /// Deletes a single subscription.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to delete.
  /// - Note: AsyncCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: The deleted [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id).
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003590-delete)
  public func deleteAtBackgroundPriority(subscriptionID: CKSubscription.ID) async throws -> CKSubscription.ID {
    try await asyncAtBackgroundPriorityFrom(delete, with: subscriptionID)
  }

  /// Deletes a single subscription.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The deleted [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id).
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func delete(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKSubscription.ID {
    try await delete(
      subscriptionIDs: [subscriptionID],
      withConfiguration: configuration
    ).single()
  }

  /// Deletes multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionIDs: The IDs of the subscriptions to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id)s.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func delete(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKSubscription.ID> {
    modify(subscriptionIDsToDelete: subscriptionIDs, withConfiguration: configuration).compactMap {
      _, deleted in
      deleted
    }.eraseToAsyncCloudKitSequence()
  }

  /// Modifies one or more subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionsToSave: The subscriptions to save.
  ///   - subscriptionsToDelete: The IDs of the subscriptions to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s and the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id)s.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func modify(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<(CKSubscription?, CKSubscription.ID?)> {
    let operation = operationFactory.createModifySubscriptionsOperation(
      subscriptionsToSave: subscriptionsToSave,
      subscriptionIDsToDelete: subscriptionIDsToDelete
    )
    return asyncFromModify(operation, configuration) { completion in
      operation.modifySubscriptionsCompletionBlock = completion
    }
  }

  /// Fetches the subscription with the specified ID.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to fetch.
  /// - Note: AsyncCloudKit executes the fetch with a low priority. Use this method when you don’t require the
  /// subscription immediately.
  /// - Returns: The [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription).
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003591-fetch)
  public func fetchAtBackgroundPriority(withSubscriptionID subscriptionID: CKSubscription.ID) async throws -> CKSubscription {
    try await asyncAtBackgroundPriorityFrom(fetch, with: subscriptionID)
  }

  /// Fetches the subscription with the specified ID.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: The [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription).
  /// - SeeAlso: [CKFetchSubscriptionsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation)
  public func fetch(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) async throws -> CKSubscription {
    try await fetch(
      subscriptionIDs: [subscriptionID],
      withConfiguration: configuration
    ).single()
  }

  /// Fetches multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionIDs: The IDs of the subscriptions to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s.
  /// - SeeAlso: [CKFetchSubscriptionsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation)
  public func fetch(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKSubscription> {
    let operation = operationFactory.createFetchSubscriptionsOperation(
      subscriptionIDs: subscriptionIDs)
    return asyncFromFetch(operation, configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }

  /// Fetches the database's subscriptions.
  ///
  /// - Note: AsyncCloudKit executes the fetch with a low priority. Use this method when you don’t require the
  /// subscriptions immediately.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s.
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449110-fetchallsubscriptions)
  public func fetchAllSubscriptionsAtBackgroundPriority() -> AsyncCloudKitSequence<CKSubscription> {
    asyncFromFetchAll(fetchAllSubscriptions)
  }

  /// Fetches the database's subscriptions.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: An ``AsyncCloudKitSequence`` that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s.
  /// - SeeAlso:
  /// [fetchAllSubscriptionsOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation/1515282-fetchallsubscriptionsoperation)
  public func fetchAllSubscriptions(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AsyncCloudKitSequence<CKSubscription> {
    let operation = operationFactory.createFetchAllSubscriptionsOperation()
    return asyncFromFetch(operation, configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }
}
