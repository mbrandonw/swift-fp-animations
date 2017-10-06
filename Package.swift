// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Animations",
  products: [
    .library(
      name: "AnimationsCore",
      targets: ["AnimationsCore"]),
    ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "AnimationsCore",
      dependencies: []),
    .testTarget(
      name: "AnimationsCoreTests",
      dependencies: ["AnimationsCore"]),
    ]
)
