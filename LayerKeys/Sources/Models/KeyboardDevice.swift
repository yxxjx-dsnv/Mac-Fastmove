import Foundation

struct KeyboardDevice: Codable, Hashable, Identifiable {
    let id: String
    let vendorID: Int
    let productID: Int
    let productName: String
    let transport: String
    let isBuiltIn: Bool

    var shortDescription: String {
        "\(productName) (\(vendorID):\(productID))"
    }
}
