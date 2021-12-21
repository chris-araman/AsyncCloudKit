# ⛅️ AsyncCloudKit

Swift extensions for asynchronous CloudKit record processing. Designed for simplicity.

[![Swift](https://img.shields.io/endpoint?label=swift&logo=swift&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FAsyncCloudKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/chris-araman/AsyncCloudKit)
[![Platforms](https://img.shields.io/endpoint?label=platforms&logo=apple&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FAsyncCloudKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/chris-araman/AsyncCloudKit)
[![License](https://img.shields.io/github/license/chris-araman/AsyncCloudKit?style=flat-square&color=informational)](https://github.com/chris-araman/AsyncCloudKit/blob/main/LICENSE.md)
[![Release](https://img.shields.io/github/v/tag/chris-araman/AsyncCloudKit?style=flat-square&color=informational&label=release&sort=semver)](https://github.com/chris-araman/AsyncCloudKit/releases)

[![Lint | Build | Test](https://img.shields.io/github/workflow/status/chris-araman/AsyncCloudKit/Continuous%20Integration/main?style=flat-square&logo=github&label=lint%20%7C%20build%20%7C%20test)](https://github.com/chris-araman/AsyncCloudKit/actions/workflows/ci.yml?query=branch%3Amain)
[![Coverage](https://img.shields.io/codecov/c/github/chris-araman/AsyncCloudKit/main?style=flat-square&color=informational)](https://app.codecov.io/gh/chris-araman/AsyncCloudKit/)

AsyncCloudKit exposes [CloudKit](https://developer.apple.com/documentation/cloudkit) operations as
[async functions](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html#ID639) and
[AsyncSequences](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html#ID640).

## 📦 Adding AsyncCloudKit to Your Project

AsyncCloudKit is a [Swift Package](https://developer.apple.com/documentation/swift_packages).
Add a dependency on AsyncCloudKit to your
[`Package.swift`](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html) using
[Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or the
[Swift Package Manager](https://swift.org/package-manager/). Optionally, specify a
[version requirement](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#package-dependency-requirement).

```swift
dependencies: [
  .package(url: "https://github.com/chris-araman/AsyncCloudKit.git", from: "1.0.0")
]
```

Then resolve the dependency:

```bash
swift package resolve
```

To update to the latest AsyncCloudKit version compatible with your version requirement:

```bash
swift package update AsyncCloudKit
```

## 🌤 Using AsyncCloudKit in Your Project

Swift concurrency allows you to process CloudKit records asynchronously, without writing a lot of boilerplate code involving
[`CKOperation`](https://developer.apple.com/documentation/cloudkit/ckoperation/)s and completion blocks.
Here, we perform a query on our
[`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase), then process the results
asynchronously. As each [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord) is read from the
database, we print its `name` field.

```swift
import CloudKit
import AsyncCloudKit

func queryDueItems(database: CKDatabase, due: Date) async throws {
  for try await record in database
    .performQuery(ofType: "ToDoItem", where: NSPredicate(format: "due >= %@", due)) { (record: CKRecord) in
    print("\(record.name)")
  })
}
```

### Cancellation

AsyncCloudKit functions that return an `AsyncCloudKitSequence` queue an operation immediately. Iterating
the sequence allows you to inspect the results of the operation. If you stop iterating the sequence early,
the operation may be cancelled.

Note that because the `atBackgroundPriority` functions are built on `CKDatabase` methods that do not provide means of
cancellation, they cannot be canceled. If you need operations to respond to requests for cooperative cancellation,
please use the publishers that do not have `atBackgroundPriority` in their names. You can still specify
[`QualityOfService.background`](https://developer.apple.com/documentation/foundation/qualityofservice/background)
by passing in a
[`CKOperation.Configuration`](https://developer.apple.com/documentation/cloudkit/ckoperation/configuration).

## 📘 Documentation

💯% [documented](https://asynccloudkit.hiddenplace.dev) using [Jazzy](https://github.com/realm/jazzy).
Hosted by [GitHub Pages](https://pages.github.com).

## ❤️ Contributing

[Contributions](https://github.com/chris-araman/AsyncCloudKit/blob/main/CONTRIBUTING.md) are welcome!

## 📚 Further Reading

To learn more about Swift Concurrency and CloudKit, watch these videos from WWDC:

- [Explore structured concurrency in Swift](https://developer.apple.com/videos/play/wwdc2021/10134/)
- [Discover concurrency in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10019/)
- [Swift concurrency: Behind the scenes](https://developer.apple.com/videos/play/wwdc2021/10254/)

...or review Apple's documentation:

- [CloudKit Overview](https://developer.apple.com/icloud/cloudkit/)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Swift Language Features for Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Apple Concurrency Module](https://developer.apple.com/documentation/swift/swift_standard_library/concurrency)

## 📜 License

AsyncCloudKit was created by [Chris Araman](https://github.com/chris-araman). It is published under the
[MIT license](https://github.com/chris-araman/AsyncCloudKit/blob/main/LICENSE.md).
