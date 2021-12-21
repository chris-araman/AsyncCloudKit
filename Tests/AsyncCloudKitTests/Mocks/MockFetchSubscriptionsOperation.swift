//
//  MockFetchSubscriptionsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

public class MockFetchSubscriptionsOperation: MockFetchOperation<CKSubscription, CKSubscription.ID>,
  ACKFetchSubscriptionsOperation
{
  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ subscriptionIDs: [CKSubscription.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { database, operation in operation(&database.subscriptions) },
      subscriptionIDs
    )
    super.fetchItemsCompletionBlock = { [unowned self] items, error in
      let completion = try! XCTUnwrap(self.fetchSubscriptionCompletionBlock)
      completion(items, error)
    }
  }

  public var fetchSubscriptionCompletionBlock:
    (([CKSubscription.ID: CKSubscription]?, Error?) -> Void)?
}
