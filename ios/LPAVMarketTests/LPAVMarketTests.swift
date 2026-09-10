import XCTest
@testable import LPAVMarket

final class LPAVMarketTests: XCTestCase {

    func testCartItemTotalPrice() {
        let item = CartItem(
            id: UUID(),
            packageId: "pkg-1",
            packageTitle: "Test Package",
            coverImageUrl: nil,
            region: "Caribbean",
            priceMxn: 5000,
            pointsPrice: 500,
            quantity: 2
        )
        XCTAssertEqual(item.totalPrice, 10000)
    }

    func testCartItemFormattedPrice() {
        let item = CartItem(
            id: UUID(),
            packageId: "pkg-1",
            packageTitle: "Test Package",
            coverImageUrl: nil,
            region: "Caribbean",
            priceMxn: 5000,
            pointsPrice: 500,
            quantity: 1
        )
        XCTAssertEqual(item.formattedPrice, "$5,000 MXN")
    }

    func testCartStorageAddItem() {
        let storage = CartStorage.shared
        storage.clear()

        let item = CartItem(
            id: UUID(),
            packageId: "pkg-test-1",
            packageTitle: "Test Package",
            coverImageUrl: nil,
            region: "Caribbean",
            priceMxn: 5000,
            pointsPrice: 500,
            quantity: 1
        )
        storage.addItem(item)
        XCTAssertEqual(storage.itemCount, 1)
        storage.clear()
    }

    func testCartStorageRemoveItem() {
        let storage = CartStorage.shared
        storage.clear()

        let item = CartItem(
            id: UUID(),
            packageId: "pkg-test-2",
            packageTitle: "Test Package",
            coverImageUrl: nil,
            region: "Caribbean",
            priceMxn: 5000,
            pointsPrice: 500,
            quantity: 1
        )
        storage.addItem(item)
        XCTAssertEqual(storage.itemCount, 1)

        storage.removeItem(packageId: "pkg-test-2")
        XCTAssertEqual(storage.itemCount, 0)
    }

    func testTravelPackageFormattedPrice() {
        let package = TravelPackage(
            id: "1",
            tenantId: "t1",
            title: "Test",
            slug: "test",
            description: nil,
            coverImageUrl: nil,
            region: "Caribbean",
            departureCity: "Mexico City",
            destination: nil,
            durationDays: 5,
            durationNights: 4,
            priceMxn: 15000,
            originalPriceMxn: nil,
            pointsPrice: 1500,
            currency: .mxn,
            includedItems: nil,
            excludedItems: nil,
            maxGroupSize: 10,
            availableSpots: 5,
            status: .published,
            rating: 4.5,
            reviewCount: 12,
            departureDate: nil,
            returnDate: nil,
            createdAt: Date(),
            updatedAt: nil
        )
        XCTAssertEqual(package.formattedPrice, "$15,000")
        XCTAssertEqual(package.durationText, "5D/4N")
        XCTAssertFalse(package.hasDiscount)
    }

    func testTravelPackageDiscount() {
        let package = TravelPackage(
            id: "1",
            tenantId: "t1",
            title: "Test",
            slug: "test",
            description: nil,
            coverImageUrl: nil,
            region: "Caribbean",
            departureCity: "Mexico City",
            destination: nil,
            durationDays: 5,
            durationNights: 4,
            priceMxn: 10000,
            originalPriceMxn: 15000,
            pointsPrice: 1000,
            currency: .mxn,
            includedItems: nil,
            excludedItems: nil,
            maxGroupSize: 10,
            availableSpots: 5,
            status: .published,
            rating: 4.5,
            reviewCount: 12,
            departureDate: nil,
            returnDate: nil,
            createdAt: Date(),
            updatedAt: nil
        )
        XCTAssertTrue(package.hasDiscount)
        XCTAssertEqual(package.discountPercentage, 33.333333333333336, accuracy: 0.01)
    }

    func testWalletTransactionFormattedAmount() {
        let transaction = WalletTransaction(
            id: "1",
            walletId: "w1",
            type: .purchase,
            amount: 500,
            balanceAfter: 1000,
            description: "Test purchase",
            referenceId: nil,
            createdAt: Date()
        )
        XCTAssertEqual(transaction.formattedAmount, "-500 pts")
    }

    func testWalletTransactionPositive() {
        let transaction = WalletTransaction(
            id: "1",
            walletId: "w1",
            type: .bonus,
            amount: 200,
            balanceAfter: 1200,
            description: "Test bonus",
            referenceId: nil,
            createdAt: Date()
        )
        XCTAssertEqual(transaction.formattedAmount, "+200 pts")
    }

    func testUserWalletEstimatedMxn() {
        let wallet = UserWallet(
            id: "1",
            userId: "u1",
            balance: 1000,
            totalEarned: 2000,
            totalRedeemed: 1000,
            createdAt: Date(),
            updatedAt: nil
        )
        XCTAssertEqual(wallet.estimatedMxnValue, 100.0)
    }

    func testCurrencySymbols() {
        XCTAssertEqual(Currency.mxn.symbol, "$")
        XCTAssertEqual(Currency.usd.symbol, "US$")
        XCTAssertEqual(Currency.points.symbol, "Pts")
    }

    func testUserRoleDisplayNames() {
        XCTAssertEqual(UserRole.traveler.displayName, "Traveler")
        XCTAssertEqual(UserRole.agencyAdmin.displayName, "Agency Admin")
        XCTAssertEqual(UserRole.superAdmin.displayName, "Super Admin")
    }

    func testPaymentStatusDisplayNames() {
        XCTAssertEqual(PaymentStatus.pending.displayName, "Pending")
        XCTAssertEqual(PaymentStatus.completed.displayName, "Completed")
        XCTAssertEqual(PaymentStatus.failed.displayName, "Failed")
    }

    func testWalletTransactionTypeIsPositive() {
        XCTAssertFalse(WalletTransactionType.purchase.isPositive)
        XCTAssertFalse(WalletTransactionType.redemption.isPositive)
        XCTAssertTrue(WalletTransactionType.refund.isPositive)
        XCTAssertTrue(WalletTransactionType.bonus.isPositive)
        XCTAssertTrue(WalletTransactionType.commission.isPositive)
    }

    func testProfileRoleChecks() {
        let agencyProfile = Profile(
            id: "1",
            email: "test@agency.com",
            fullName: "Test Agency",
            tenantId: "t1",
            roleName: "agency_admin",
            avatarUrl: nil,
            phone: nil,
            censorshipStrikes: 0,
            createdAt: Date()
        )
        XCTAssertTrue(agencyProfile.isAgency)
        XCTAssertFalse(agencyProfile.isTraveler)

        let travelerProfile = Profile(
            id: "2",
            email: "test@traveler.com",
            fullName: "Test Traveler",
            tenantId: nil,
            roleName: "traveler",
            avatarUrl: nil,
            phone: nil,
            censorshipStrikes: 0,
            createdAt: Date()
        )
        XCTAssertFalse(travelerProfile.isAgency)
        XCTAssertTrue(travelerProfile.isTraveler)
    }
}
