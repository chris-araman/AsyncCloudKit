//
//  ACKFetchRecordsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchRecordsOperation: ACKFetchRecordsOperation {
}

protocol ACKFetchRecordsOperation: ACKDatabaseOperation {
  var desiredKeys: [CKRecord.FieldKey]? { get set }
  var perRecordProgressBlock: ((CKRecord.ID, Double) -> Void)? { get set }
  var perRecordCompletionBlock: ((CKRecord?, CKRecord.ID?, Error?) -> Void)? { get set }
  var fetchRecordsCompletionBlock: (([CKRecord.ID: CKRecord]?, Error?) -> Void)? { get set }
}
