//
//  AsyncCloudKitSequence.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

/// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
/// of results from an AsyncCloudKit operation. If this sequence is iterated twice,
/// no operation is queued, and no results are returned.
public struct AsyncCloudKitSequence<Element>: AsyncSequence {
  public typealias AsyncIterator = AsyncCloudKitIterator<Element>
  public typealias Element = Element

  /// An [`AsyncIteratorProtocol`](https://developer.apple.com/documentation/swift/asynciteratorprotocol)
  /// of results from an AsyncCloudKit operation.
  /// - SeeAlso: [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
  public struct AsyncCloudKitIterator<Element>: AsyncIteratorProtocol {

    /// The type of result from an AsyncCloudKit operation to iterate over.
    public typealias Element = Element

    private let upstreamNext: () async throws -> Element?

    init<UpstreamIterator: AsyncIteratorProtocol>(_ iterator: UpstreamIterator)
    where UpstreamIterator.Element == Element {
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

  let makeAsyncCloudKitIterator: () -> AsyncCloudKitIterator<Element>

  init<Upstream: AsyncSequence>(_ upstream: Upstream) where Upstream.Element == Element {
    makeAsyncCloudKitIterator = {
      AsyncCloudKitIterator(upstream.makeAsyncIterator())
    }
  }

  /// Creates an ``AsyncCloudKitIterator`` of results from an AsyncCloudKit operation.
  /// - Returns: The ``AsyncCloudKitIterator``.
  /// - SeeAlso: [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence)
  public func makeAsyncIterator() -> AsyncCloudKitIterator<Element> {
    makeAsyncCloudKitIterator()
  }

  /// Collects all of the results from the sequence and returns them as a single array.
  /// - Returns: An array of the results.
  public func collect() async throws -> [Element] {
    try await reduce(into: [Element]()) { $0.append($1) }
  }
}

extension AsyncSequence {
  func eraseToAsyncCloudKitSequence() -> AsyncCloudKitSequence<Element> {
    AsyncCloudKitSequence(self)
  }
}
