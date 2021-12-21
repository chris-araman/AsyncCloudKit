//
//  MockModifySubscriptionsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

public class MockModifySubscriptionsOperation:
  MockModifyOperation<CKSubscription, CKSubscription.ID>,
  ACKModifySubscriptionsOperation
{
  public var modifySubscriptionsCompletionBlock:
    (([CKSubscription]?, [CKSubscription.ID]?, Error?) -> Void)?

  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ subscriptionsToSave: [CKSubscription]? = nil,
    _ subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { mockDatabase, operation in operation(&mockDatabase.subscriptions) },
      { $0.subscriptionID },
      subscriptionsToSave,
      subscriptionIDsToDelete
    )
    super.modifyItemsCompletionBlock = { [unowned self] itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifySubscriptionsCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }
}
