//
//  CKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKContainer {
  public final func accountStatus() -> AnyPublisher<CKAccountStatus, Error> {
    publisherFrom(method: accountStatus)
  }
}
