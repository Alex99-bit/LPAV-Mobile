import SwiftUI

struct CatalogGridView: View {
    let packages: [TravelPackage]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(packages) { package in
                NavigationLink(destination: PackageDetailView(package: package)) {
                    FlyerCardView(package: package, size: .full)
                }
            }
        }
    }
}
