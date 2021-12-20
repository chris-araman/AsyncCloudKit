//
//  ACKFetchSubscriptionsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchSubscriptionsOperation: ACKFetchSubscriptionsOperation {
}

protocol ACKFetchSubscriptionsOperation: ACKDatabaseOperation {
  var fetchSubscriptionCompletionBlock: (([CKSubscription.ID: CKSubscription]?, Error?) -> Void)? {
    get set
  }
}
