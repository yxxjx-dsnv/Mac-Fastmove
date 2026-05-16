import Foundation
import IOKit.hidsystem

final class CapsLockStateController {
    private let handle: NXEventHandle

    init?() {
        let openedHandle = NXOpenEventStatus()
        guard openedHandle != 0 else {
            return nil
        }
        handle = openedHandle
    }

    deinit {
        NXCloseEventStatus(handle)
    }

    func isCapsLockEnabled() -> Bool {
        var state = false
        let result = IOHIDGetModifierLockState(handle, Int32(kIOHIDCapsLockState), &state)
        return result == KERN_SUCCESS && state
    }

    func toggleCapsLock() {
        let newState = !isCapsLockEnabled()
        _ = IOHIDSetModifierLockState(handle, Int32(kIOHIDCapsLockState), newState)
    }
}
