import XCTest
@testable import LayerKeys

final class CapsNavigationEngineTests: XCTestCase {
    func testSingleTapSchedulesPassThrough() {
        let engine = CapsNavigationEngine(doubleTapInterval: 0.25)

        XCTAssertEqual(engine.handleCapsEvent(isDown: true, at: 1.0), [])
        XCTAssertEqual(engine.handleCapsEvent(isDown: false, at: 1.1), [])

        XCTAssertEqual(engine.flushPendingSingleTap(at: 1.36), [.emitSingleCapsTap])
    }

    func testDoubleTapTogglesCapsLock() {
        let engine = CapsNavigationEngine(doubleTapInterval: 0.25)

        _ = engine.handleCapsEvent(isDown: true, at: 1.0)
        _ = engine.handleCapsEvent(isDown: false, at: 1.05)
        _ = engine.handleCapsEvent(isDown: true, at: 1.15)
        let actions = engine.handleCapsEvent(isDown: false, at: 1.20)

        XCTAssertEqual(actions, [.toggleCapsLock])
    }

    func testCapsWMapsToArrow() {
        let engine = CapsNavigationEngine(doubleTapInterval: 0.25)

        _ = engine.handleCapsEvent(isDown: true, at: 1.0)
        let actions = engine.handleKeyEvent(keyCode: 13, isDown: true, flags: [.maskShift], at: 1.02)

        XCTAssertEqual(actions, [.emitMappedKey(keyCode: 126, isDown: true, flags: [.maskShift])])
    }
}
