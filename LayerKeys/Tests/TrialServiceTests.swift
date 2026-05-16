import XCTest
@testable import LayerKeys

final class TrialServiceTests: XCTestCase {
    func testTrialExpiresAfterSevenDays() {
        let start = Date(timeIntervalSince1970: 0)
        let state = TrialState(startedAt: start)
        let almostExpired = start.addingTimeInterval((7 * 86_400) - 10)
        let expired = start.addingTimeInterval(7 * 86_400)

        XCTAssertFalse(state.isExpired(referenceDate: almostExpired))
        XCTAssertTrue(state.isExpired(referenceDate: expired))
    }

    func testRemainingDaysRoundsUp() {
        let start = Date(timeIntervalSince1970: 0)
        let state = TrialState(startedAt: start)
        let reference = start.addingTimeInterval((6 * 86_400) + 1)

        XCTAssertEqual(state.remainingDays(referenceDate: reference), 1)
    }
}
