//
//  ACKContainer.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

/// An extension that declares [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer)
/// conforms to the ``ACKContainer`` protocol provided by AsyncCloudKit.
///
/// - SeeAlso:[`CloudKit`](https://developer.apple.com/documentation/cloudkit)
extension CKContainer: ACKContainer {
}

/// A protocol used to abstract a [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer).
///
/// Invoke the async extension method on your [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer)
/// instances to fetch the account status asynchronously.
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
public protocol ACKContainer {
  /// Implemented by `CKContainer`.
  ///
  /// - SeeAlso: [`accountStatus`](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399180-accountstatus)
  func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void)
}

extension ACKContainer {
  private func asyncFrom<Output>(
    _ method: @escaping (@escaping (Output, Error?) -> Void) -> Void
  ) async throws -> Output {
    try await withCheckedThrowingContinuation { continuation in
      method { item, error in
        guard error == nil else {
          continuation.resume(throwing: error!)
          return
        }

        continuation.resume(returning: item)
      }
    }
  }

  /// Determines whether the system can access the user’s iCloud account.
  ///
  /// - Returns: The [`CKAccountStatus`](https://developer.apple.com/documentation/cloudkit/ckaccountstatus).
  /// - SeeAlso: [`accountStatus`](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399180-accountstatus)
  public func accountStatus() async throws -> CKAccountStatus {
    try await asyncFrom(accountStatus)
  }
}
