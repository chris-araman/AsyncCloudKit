// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "AsyncCloudKit",
  // Concurrency for macOS 12, MacCatalyst 15, iOS 15, tvOS 15, or watchOS 8 requires Swift 5.5 or Xcode 13.
  // Concurrency for macOS 10.15, Mac Catalyst 13, iOS 13, tvOS 13, or watchOS 6 requires Swift 5.5.2 or Xcode 13.2.1.
  // XCTest requires watchOS 7.4.
  platforms: [
    .macCatalyst(.v13),
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS("7.4"),
  ],
  products: [
    .library(
      name: "AsyncCloudKit",
      targets: ["AsyncCloudKit"]
    )
  ],
  dependencies: [
    // Used by script/lint. Assumes current Swift tools.
    .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.5-branch"))
  ],
  targets: [
    .target(name: "AsyncCloudKit"),
    .testTarget(
      name: "AsyncCloudKitTests",
      dependencies: ["AsyncCloudKit"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
