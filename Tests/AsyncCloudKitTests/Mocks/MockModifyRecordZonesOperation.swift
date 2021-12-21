//
//  MockModifyRecordZonesOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

public class MockModifyRecordZonesOperation:
  MockModifyOperation<CKRecordZone, CKRecordZone.ID>,
  ACKModifyRecordZonesOperation
{
  public var modifyRecordZonesCompletionBlock:
    (([CKRecordZone]?, [CKRecordZone.ID]?, Error?) -> Void)?

  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ recordZonesToSave: [CKRecordZone]? = nil,
    _ recordZoneIDsToDelete: [CKRecordZone.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { mockDatabase, operation in operation(&mockDatabase.recordZones) },
      { $0.zoneID },
      recordZonesToSave,
      recordZoneIDsToDelete
    )
    super.modifyItemsCompletionBlock = { [unowned self] itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifyRecordZonesCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }
}
