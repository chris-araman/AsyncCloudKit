//
//  ACKOperation.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKOperation: ACKOperation {
}

protocol ACKOperation: Operation {
  var configuration: CKOperation.Configuration! { get set }
}
