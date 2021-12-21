//
//  AsyncCloudKitSequence.swift
//  AsyncCloudKit
//
//  Created by Chris Araman on 12/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

public struct AsyncCloudKitSequence<Element>: AsyncSequence {
  public typealias AsyncIterator = AsyncCloudKitIterator<Element>
  public typealias Element = Element

  public struct AsyncCloudKitIterator<Element>: AsyncIteratorProtocol {
    public typealias Element = Element

    private let upstreamNext: () async throws -> Element?

    init<UpstreamIterator: AsyncIteratorProtocol>(_ iterator: UpstreamIterator)
    where UpstreamIterator.Element == Element {
      var iterator = iterator
      self.upstreamNext = {
        try await iterator.next()
      }
    }

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

  public func makeAsyncIterator() -> AsyncCloudKitIterator<Element> {
    makeAsyncCloudKitIterator()
  }

  public func collect() async throws -> [Element] {
    try await reduce(into: [Element]()) { $0.append($1) }
  }
}

extension AsyncSequence {
  func eraseToAsyncCloudKitSequence() -> AsyncCloudKitSequence<Element> {
    AsyncCloudKitSequence(self)
  }
}
