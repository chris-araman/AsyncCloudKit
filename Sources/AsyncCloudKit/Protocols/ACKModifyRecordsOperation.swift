//
//  ACKModifyRecordsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifyRecordsOperation: ACKModifyRecordsOperation {
}

protocol ACKModifyRecordsOperation: ACKDatabaseOperation {
  var isAtomic: Bool { get set }
  var savePolicy: CKModifyRecordsOperation.RecordSavePolicy { get set }
  var clientChangeTokenData: Data? { get set }
  var perRecordProgressBlock: ((CKRecord, Double) -> Void)? { get set }
  var perRecordCompletionBlock: ((CKRecord, Error?) -> Void)? { get set }
  var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)? { get set }
}
