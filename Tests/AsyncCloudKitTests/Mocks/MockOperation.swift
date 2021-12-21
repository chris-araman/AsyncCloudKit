//
//  MockOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import AsyncCloudKit

public class MockOperation: Operation, ACKOperation {
  public var configuration: CKOperation.Configuration!
}
