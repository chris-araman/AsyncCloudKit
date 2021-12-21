//
//  CKContainerTests.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import AsyncCloudKit

final class CKContainerTests: AsyncCloudKitTests {
  func testAccountStatusIsAvailable() async throws {
    let status = try await container.accountStatus()
    XCTAssertEqual(status, .available)
  }
}
