// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "NowPlayingReporter",
  platforms: [
    .macOS(.v12)
  ],
  dependencies: [
    // Dev dependencies:
    .package(url: "https://github.com/apple/swift-format.git", branch: ("release/5.10"))
  ],
  targets: [
    .executableTarget(
      name: "NowPlayingReporter",
      dependencies: []
    )
  ],
  swiftLanguageVersions: [.v5]
)
