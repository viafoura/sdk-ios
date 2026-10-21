import Foundation

final class NetworkInspectorProtocol: URLProtocol {
    private static let handledKey = "NetworkInspectorHandled"

    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        return URLSession(configuration: configuration)
    }()

    private var dataTask: URLSessionDataTask?
    private var isStopped = false

    override class func canInit(with task: URLSessionTask) -> Bool {
        guard !(task is URLSessionWebSocketTask), let request = task.currentRequest else {
            return false
        }
        return canInit(with: request)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme?.lowercased(), scheme == "http" || scheme == "https",
              request.value(forHTTPHeaderField: "Upgrade")?.lowercased() != "websocket" else {
            return false
        }
        return property(forKey: handledKey, in: request) == nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let body = Self.bodyData(from: request)
        let forwarded = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        Self.setProperty(true, forKey: Self.handledKey, in: forwarded)
        if forwarded.httpBody == nil, let body {
            forwarded.httpBodyStream = nil
            forwarded.httpBody = body
        }

        let id = UUID()
        let startedAt = Date()
        NetworkInspector.shared.add(NetworkRecord(
            id: id,
            startedAt: startedAt,
            method: request.httpMethod ?? "GET",
            url: request.url,
            requestHeaders: request.allHTTPHeaderFields ?? [:],
            requestBody: body
        ))

        dataTask = Self.session.dataTask(with: forwarded as URLRequest) { [weak self] data, response, error in
            let duration = Date().timeIntervalSince(startedAt)
            NetworkInspector.shared.update(id: id) { record in
                record.duration = duration
                record.responseBody = data
                if let http = response as? HTTPURLResponse {
                    record.statusCode = http.statusCode
                    record.responseHeaders = http.allHeaderFields.reduce(into: [:]) { result, pair in
                        result["\(pair.key)"] = "\(pair.value)"
                    }
                }
                if let error {
                    record.error = error.localizedDescription
                } else if response == nil {
                    record.error = "No response"
                }
            }

            guard let self, !self.isStopped else { return }
            if let response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            if let error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        dataTask?.resume()
    }

    override func stopLoading() {
        isStopped = true
        dataTask?.cancel()
    }

    private static func bodyData(from request: URLRequest) -> Data? {
        if let body = request.httpBody {
            return body
        }
        guard let stream = request.httpBodyStream else {
            return nil
        }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 64 * 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        }
        return data
    }
}
