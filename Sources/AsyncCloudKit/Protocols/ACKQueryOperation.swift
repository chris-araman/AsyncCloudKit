//
//  ACKQueryOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKQueryOperation: ACKQueryOperation {
}

protocol ACKQueryOperation: ACKDatabaseOperation {
  var query: CKQuery? { get set }
  var cursor: CKQueryOperation.Cursor? { get set }
  var desiredKeys: [CKRecord.FieldKey]? { get set }
  var zoneID: CKRecordZone.ID? { get set }
  var resultsLimit: Int { get set }
  var recordFetchedBlock: ((CKRecord) -> Void)? { get set }
  var queryCompletionBlock: ((CKQueryOperation.Cursor?, Error?) -> Void)? { get set }
}
