//
//  AsyncSequence.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/17/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

extension AsyncSequence {
  func erase() -> ACKSequence<Element> {
    ACKSequence(self)
  }

  /// Collects all of the results from the sequence and returns them as a single array.
  /// - Returns: An array of the results.
  func collect() async throws -> [Element] {
    try await reduce(into: [Element]()) { $0.append($1) }
  }

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
