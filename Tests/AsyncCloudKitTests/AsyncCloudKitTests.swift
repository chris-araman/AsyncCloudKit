//
//  AsyncCloudKitTests.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

class AsyncCloudKitTests: XCTestCase {
  #if SWIFT_PACKAGE || COCOAPODS
    // Unit tests with mocks
    let container: ACKContainer = MockContainer()
    let database: ACKDatabase = MockDatabase()
    override func setUp() {
      AsyncCloudKit.operationFactory = MockOperationFactory(database as! MockDatabase)
    }
  #else
    // Integration tests with CloudKit
    let container: ACKContainer
    let database: ACKDatabase
    override init() {
      let container = CKContainer(
        identifier: "iCloud.dev.hiddenplace.AsyncCloudKit.Tests")
      self.container = container
      self.database = container.privateCloudDatabase
      super.init()
    }
  #endif
}
