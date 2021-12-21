//
//  MockDatabaseOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import AsyncCloudKit

public class MockDatabaseOperation: MockOperation, ACKDatabaseOperation {
  let mockDatabase: MockDatabase
  let space: DecisionSpace?

  init(_ database: MockDatabase, _ space: DecisionSpace?) {
    self.mockDatabase = database
    self.space = space
  }

  public var database: CKDatabase?
}
