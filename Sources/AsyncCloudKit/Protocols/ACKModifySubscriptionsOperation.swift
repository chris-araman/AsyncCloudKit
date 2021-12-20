//
//  ACKModifySubscriptionsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifySubscriptionsOperation: ACKModifySubscriptionsOperation {
}

protocol ACKModifySubscriptionsOperation: ACKDatabaseOperation {
  var modifySubscriptionsCompletionBlock:
    (([CKSubscription]?, [CKSubscription.ID]?, Error?) -> Void)?
  { get set }
}
