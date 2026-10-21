import Foundation

struct NetworkRecord {
    let id: UUID
    let startedAt: Date
    let method: String
    let url: URL?
    let requestHeaders: [String: String]
    let requestBody: Data?
    var statusCode: Int?
    var responseHeaders: [String: String] = [:]
    var responseBody: Data?
    var error: String?
    var duration: TimeInterval?

    var isFinished: Bool {
        statusCode != nil || error != nil
    }

    var host: String {
        url?.host ?? ""
    }

    var path: String {
        guard let url else { return "" }
        let path = url.path.isEmpty ? "/" : url.path
        guard let query = url.query, !query.isEmpty else { return path }
        return path + "?" + query
    }

    var isViafoura: Bool {
        NetworkInspector.viafouraHostSuffixes.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    var curl: String {
        var parts = ["curl -X \(method)"]
        for (key, value) in requestHeaders.sorted(by: { $0.key < $1.key }) {
            parts.append("-H '\(key): \(value.replacingOccurrences(of: "'", with: "'\\''"))'")
        }
        if let body = requestBody, let text = String(data: body, encoding: .utf8), !text.isEmpty {
            parts.append("--data-raw '\(text.replacingOccurrences(of: "'", with: "'\\''"))'")
        }
        parts.append("'\(url?.absoluteString ?? "")'")
        return parts.joined(separator: " \\\n  ")
    }
}

final class NetworkInspector {
    static let shared = NetworkInspector()
    static let didChange = Notification.Name("NetworkInspector.didChange")
    static let viafouraHostSuffixes = ["viafoura.co", "viafoura.io", "viafoura.com"]

    private let lock = NSLock()
    private var storage: [NetworkRecord] = []
    private let limit = 500

    static func enable() {
        URLProtocol.registerClass(NetworkInspectorProtocol.self)
        URLSessionConfiguration.installNetworkInspector()
    }

    var records: [NetworkRecord] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func record(id: UUID) -> NetworkRecord? {
        lock.lock()
        defer { lock.unlock() }
        return storage.first { $0.id == id }
    }

    func add(_ record: NetworkRecord) {
        lock.lock()
        storage.insert(record, at: 0)
        if storage.count > limit {
            storage.removeLast(storage.count - limit)
        }
        lock.unlock()
        notify()
    }

    func update(id: UUID, _ change: (inout NetworkRecord) -> Void) {
        lock.lock()
        if let index = storage.firstIndex(where: { $0.id == id }) {
            change(&storage[index])
        }
        lock.unlock()
        notify()
    }

    func clear() {
        lock.lock()
        storage.removeAll()
        lock.unlock()
        notify()
    }

    private func notify() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.didChange, object: nil)
        }
    }
}

extension URLSessionConfiguration {
    private static let installOnce: Void = {
        swap(NSSelectorFromString("defaultSessionConfiguration"), #selector(getter: inspectorDefault))
        swap(NSSelectorFromString("ephemeralSessionConfiguration"), #selector(getter: inspectorEphemeral))
    }()

    static func installNetworkInspector() {
        _ = installOnce
    }

    private static func swap(_ original: Selector, _ replacement: Selector) {
        guard let originalMethod = class_getClassMethod(URLSessionConfiguration.self, original),
              let replacementMethod = class_getClassMethod(URLSessionConfiguration.self, replacement) else {
            return
        }
        method_exchangeImplementations(originalMethod, replacementMethod)
    }

    @objc private class var inspectorDefault: URLSessionConfiguration {
        let configuration = inspectorDefault
        configuration.addNetworkInspector()
        return configuration
    }

    @objc private class var inspectorEphemeral: URLSessionConfiguration {
        let configuration = inspectorEphemeral
        configuration.addNetworkInspector()
        return configuration
    }

    private func addNetworkInspector() {
        var classes = protocolClasses ?? []
        if !classes.contains(where: { $0 == NetworkInspectorProtocol.self }) {
            classes.insert(NetworkInspectorProtocol.self, at: 0)
        }
        protocolClasses = classes
    }
}

enum NetworkBodyFormatter {
    static func text(for data: Data?, limit: Int = 50_000) -> String {
        guard let data, !data.isEmpty else { return "" }
        let text: String
        if let object = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
           let prettyText = String(data: pretty, encoding: .utf8) {
            text = prettyText
        } else if let raw = String(data: data, encoding: .utf8) {
            text = raw
        } else {
            return "\(data.count) bytes of binary data"
        }
        guard text.count > limit else { return text }
        return String(text.prefix(limit)) + "\n… truncated (\(data.count) bytes total)"
    }
}
