//
//  MockModifyRecordsOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

public class MockModifyRecordsOperation:
  MockModifyOperation<CKRecord, CKRecord.ID>,
  ACKModifyRecordsOperation
{
  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ recordsToSave: [CKRecord]? = nil,
    _ recordIDsToDelete: [CKRecord.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { mockDatabase, operation in operation(&mockDatabase.records) },
      { $0.recordID },
      recordsToSave,
      recordIDsToDelete
    )
    super.perItemCompletionBlock = { [unowned self] record, error in
      if let perRecordProgressBlock = self.perRecordProgressBlock, error == nil {
        perRecordProgressBlock(record, 0.7)
        perRecordProgressBlock(record, 1.0)
      }

      if let perRecordCompletionBlock = self.perRecordCompletionBlock {
        perRecordCompletionBlock(record, error)
      }
    }
    super.modifyItemsCompletionBlock = { [unowned self] itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifyRecordsCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }

  public var isAtomic = true

  public var savePolicy = CKModifyRecordsOperation.RecordSavePolicy.ifServerRecordUnchanged

  public var clientChangeTokenData: Data?

  public var perRecordProgressBlock: ((CKRecord, Double) -> Void)?

  public var perRecordCompletionBlock: ((CKRecord, Error?) -> Void)?

  public var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)?
}
