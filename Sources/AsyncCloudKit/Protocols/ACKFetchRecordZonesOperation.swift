//
//  ACKFetchRecordZonesOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchRecordZonesOperation: ACKFetchRecordZonesOperation {
}

protocol ACKFetchRecordZonesOperation: ACKDatabaseOperation {
  var fetchRecordZonesCompletionBlock: (([CKRecordZone.ID: CKRecordZone]?, Error?) -> Void)? {
    get set
  }
}
