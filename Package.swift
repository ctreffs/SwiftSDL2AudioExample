// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SDLAudioExample",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "SDLAudioExample",
                    targets: ["SDLAudioExample"])
    ],
    dependencies: [
        .package(name: "SDL2", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.1.0")
    ],
    targets: [
        .target(name: "SDLAudioExample",
                dependencies: ["SDL2"],
                resources: [.copy("Resources/")])
    ]
)
