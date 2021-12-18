//
//  Publisher.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension Publisher {
  func propagateCancellationTo(_ operation: CCKOperation) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveCancel: { operation.cancel() }).eraseToAnyPublisher()
  }

#if compiler(>=5.5.2)
  // TODO: Exclude this code when compiling for macOS 12, iOS 15, tvOS 15, watchOS 8 or later.
  var values: AsyncThrowingStream<Output, Error> {
    // TODO: Handle back pressure.
    AsyncThrowingStream { continuation in
      var cancellable: AnyCancellable?
      let cancel = {
        cancellable?.cancel()
      }
      continuation.onTermination = { @Sendable _ in
        cancel()
      }
      cancellable = sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            continuation.finish()
          case .failure(let error):
            continuation.finish(throwing: error)
          }
        },
        receiveValue: { output in
          continuation.yield(output)
        }
      )
    }
  }
#endif
}
