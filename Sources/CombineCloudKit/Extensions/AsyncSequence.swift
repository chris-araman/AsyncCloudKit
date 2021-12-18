//
//  AsyncSequence.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

extension AsyncSequence {
  func single() async throws -> Element {
    var first: Element?
    for try await element in self {
      precondition(first == nil, "The sequence yielded more than one element.")
      first = element
    }

    precondition(first != nil, "The sequence yielded no elements.")
    return first!
  }
}
