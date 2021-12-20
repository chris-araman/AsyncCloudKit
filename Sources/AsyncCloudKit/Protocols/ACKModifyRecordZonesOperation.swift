//
//  ACKModifyRecordZonesOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifyRecordZonesOperation: ACKModifyRecordZonesOperation {
}

protocol ACKModifyRecordZonesOperation: ACKDatabaseOperation {
  var modifyRecordZonesCompletionBlock: (([CKRecordZone]?, [CKRecordZone.ID]?, Error?) -> Void)? {
    get set
  }
}
