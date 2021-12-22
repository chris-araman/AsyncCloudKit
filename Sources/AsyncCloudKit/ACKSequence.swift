//
//  ACKSequence.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

/// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
/// of results from an AsyncCloudKit operation. If this sequence is iterated twice,
/// no second operation is queued, and no results are returned.
public struct ACKSequence<Element>: AsyncSequence {
  /// An [`AsyncIteratorProtocol`](https://developer.apple.com/documentation/swift/asynciteratorprotocol)
  /// of results from an AsyncCloudKit operation.
  /// - SeeAlso: [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
  public struct Iterator: AsyncIteratorProtocol {
    private let upstreamNext: () async throws -> Element?

    init<Upstream: AsyncIteratorProtocol>(_ iterator: Upstream)
    where Upstream.Element == Element {
      var iterator = iterator
      self.upstreamNext = {
        try await iterator.next()
      }
    }

    /// Asynchronously advances to the next result and returns it, or ends the
    /// sequence if there is no next result.
    /// - Returns: The next result, if it exists, or `nil` to signal the end of
    ///   the sequence.
    public mutating func next() async throws -> Element? {
      try await upstreamNext()
    }
  }

  let makeIterator: () -> Iterator

  init<Upstream: AsyncSequence>(_ upstream: Upstream)
  where Upstream.Element == Element {
    makeIterator = {
      Iterator(upstream.makeAsyncIterator())
    }
  }

  /// Creates an ``Iterator`` of record zones from an AsyncCloudKit operation.
  /// - Returns: The ``Iterator``.
  /// - SeeAlso: [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
  public func makeAsyncIterator() -> Iterator {
    makeIterator()
  }
}
