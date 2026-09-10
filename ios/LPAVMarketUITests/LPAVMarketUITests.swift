import XCTest

final class LPAVMarketUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testLoginScreenElements() {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)

        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)

        let googleButton = app.buttons["Google"]
        XCTAssertTrue(googleButton.exists)
    }

    func testLoginWithEmail() {
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")

        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.isEnabled)
    }
}
