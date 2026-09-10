// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LPAVMarket",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "LPAVMarket", targets: ["LPAVMarket"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn.git", from: "8.0.0"),
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "23.0.0")
    ],
    targets: [
        .target(
            name: "LPAVMarket",
            path: "LPAVMarket",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                "Kingfisher",
                "GoogleSignIn",
                .product(name: "StripePayments", package: "stripe-ios")
            ]
        ),
        .testTarget(
            name: "LPAVMarketTests",
            path: "../LPAVMarketTests",
            dependencies: ["LPAVMarket"]
        ),
        .testTarget(
            name: "LPAVMarketUITests",
            path: "../LPAVMarketUITests",
            dependencies: ["LPAVMarket"]
        )
    ]
)
