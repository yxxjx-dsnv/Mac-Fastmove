import Foundation
import IOKit.hid

final class KeyboardDeviceMonitor {
    func refresh() -> [KeyboardDevice] {
        let options = IOOptionBits(0)
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, options)
        let matching: [String: Int] = [
            kIOHIDDeviceUsagePageKey: Int(kHIDPage_GenericDesktop),
            kIOHIDDeviceUsageKey: Int(kHIDUsage_GD_Keyboard)
        ]

        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
        IOHIDManagerOpen(manager, options)

        guard let rawSet = IOHIDManagerCopyDevices(manager) else {
            return []
        }

        let devices = (rawSet as NSSet) as? Set<IOHIDDevice> ?? []

        return devices.compactMap { device in
            let vendorID = intProperty(kIOHIDVendorIDKey as CFString, device: device)
            let productID = intProperty(kIOHIDProductIDKey as CFString, device: device)
            let productName = stringProperty(kIOHIDProductKey as CFString, device: device)

            guard let vendorID, let productID, let productName else {
                return nil
            }

            let transport = stringProperty(kIOHIDTransportKey as CFString, device: device) ?? "Unknown"
            let isBuiltIn = boolProperty(kIOHIDBuiltInKey as CFString, device: device) ?? false

            return KeyboardDevice(
                id: "\(vendorID)-\(productID)-\(productName)-\(transport)",
                vendorID: vendorID,
                productID: productID,
                productName: productName,
                transport: transport,
                isBuiltIn: isBuiltIn
            )
        }
        .sorted { $0.productName.localizedCaseInsensitiveCompare($1.productName) == .orderedAscending }
    }

    private func intProperty(_ key: CFString, device: IOHIDDevice) -> Int? {
        (IOHIDDeviceGetProperty(device, key) as? NSNumber)?.intValue
    }

    private func boolProperty(_ key: CFString, device: IOHIDDevice) -> Bool? {
        (IOHIDDeviceGetProperty(device, key) as? NSNumber)?.boolValue
    }

    private func stringProperty(_ key: CFString, device: IOHIDDevice) -> String? {
        IOHIDDeviceGetProperty(device, key) as? String
    }
}
