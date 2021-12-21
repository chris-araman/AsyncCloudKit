//
//  MockContainer.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/20/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import AsyncCloudKit

public class MockContainer: ACKContainer {
  var space: DecisionSpace?

  init(_ space: DecisionSpace? = nil) {
    self.space = space
  }

  public func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
    if let space = space, space.decide() {
      completionHandler(.couldNotDetermine, MockError.simulated)
      return
    }

    completionHandler(.available, nil)
  }
}
