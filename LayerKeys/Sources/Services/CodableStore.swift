import Foundation

final class CodableStore {
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(directoryName: String = "Mac Fastmove") {
        let appSupportRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directoryURL = appSupportRoot.appendingPathComponent(directoryName, isDirectory: true)

        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load<T: Decodable>(_ type: T.Type, fileName: String) -> T? {
        let url = directoryURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func save<T: Encodable>(_ value: T, fileName: String) throws {
        let url = directoryURL.appendingPathComponent(fileName)
        let data = try encoder.encode(value)
        try data.write(to: url, options: [.atomic])
    }

    func remove(fileName: String) {
        let url = directoryURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
}
