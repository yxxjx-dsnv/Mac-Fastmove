import XCTest
@testable import LayerKeys

final class LicenseServiceTests: XCTestCase {
    func testPlausiblePurchaseTokenValidation() {
        XCTAssertTrue(LicenseService.isPlausiblePurchaseToken("gumroad-ABCD1234"))
        XCTAssertTrue(LicenseService.isPlausiblePurchaseToken("LAYERKEYS_12345678"))
        XCTAssertFalse(LicenseService.isPlausiblePurchaseToken("short"))
        XCTAssertFalse(LicenseService.isPlausiblePurchaseToken("contains spaces"))
    }
}
