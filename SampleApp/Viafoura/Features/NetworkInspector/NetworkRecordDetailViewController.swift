import UIKit

final class NetworkRecordDetailViewController: UITableViewController {
    private struct Row {
        let title: String
        let value: String
        var monospaced = false
    }

    private struct Section {
        let title: String
        let rows: [Row]
    }

    private let recordID: UUID
    private var record: NetworkRecord?
    private var sections: [Section] = []

    init(recordID: UUID) {
        self.recordID = recordID
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NetworkInspector.didChange, object: nil)
        reload()
    }

    @objc private func reload() {
        guard let record = NetworkInspector.shared.record(id: recordID) else { return }
        self.record = record
        title = record.path.components(separatedBy: "?").first

        var overview = [
            Row(title: "URL", value: record.url?.absoluteString ?? ""),
            Row(title: "Method", value: record.method),
            Row(title: "Status", value: record.statusCode.map(String.init) ?? (record.error == nil ? "Pending" : "Failed"))
        ]
        if let duration = record.duration {
            overview.append(Row(title: "Duration", value: String(format: "%.0f ms", duration * 1000)))
        }
        overview.append(Row(title: "Started", value: record.startedAt.formatted(date: .omitted, time: .standard)))
        if let error = record.error {
            overview.append(Row(title: "Error", value: error))
        }
        overview.append(Row(title: "cURL", value: record.curl, monospaced: true))

        sections = [
            Section(title: "Overview", rows: overview),
            Section(title: "Request headers", rows: Self.headerRows(record.requestHeaders)),
            Section(title: "Request body", rows: Self.bodyRows(record.requestBody)),
            Section(title: "Response headers", rows: Self.headerRows(record.responseHeaders)),
            Section(title: "Response body", rows: Self.bodyRows(record.responseBody))
        ]
        tableView.reloadData()
    }

    private static func headerRows(_ headers: [String: String]) -> [Row] {
        guard !headers.isEmpty else { return [Row(title: "", value: "None")] }
        return headers.sorted { $0.key < $1.key }.map { Row(title: $0.key, value: $0.value) }
    }

    private static func bodyRows(_ data: Data?) -> [Row] {
        let text = NetworkBodyFormatter.text(for: data)
        return [Row(title: "", value: text.isEmpty ? "Empty" : text, monospaced: true)]
    }

    @objc private func sharePressed() {
        guard let record else { return }
        let dump = """
        \(record.method) \(record.url?.absoluteString ?? "")
        Status: \(record.statusCode.map(String.init) ?? record.error ?? "Pending")

        \(record.curl)

        --- Request headers ---
        \(record.requestHeaders.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))

        --- Request body ---
        \(NetworkBodyFormatter.text(for: record.requestBody, limit: .max))

        --- Response headers ---
        \(record.responseHeaders.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))

        --- Response body ---
        \(NetworkBodyFormatter.text(for: record.responseBody, limit: .max))
        """
        let activity = UIActivityViewController(activityItems: [dump], applicationActivities: nil)
        activity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activity, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = row.title.isEmpty ? nil : row.title
        content.textProperties.font = .systemFont(ofSize: 13, weight: .semibold)
        content.textProperties.color = .secondaryLabel
        content.secondaryText = row.value
        content.secondaryTextProperties.font = row.monospaced ? .monospacedSystemFont(ofSize: 12, weight: .regular) : .systemFont(ofSize: 14)
        content.secondaryTextProperties.color = .label
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIPasteboard.general.string = sections[indexPath.section].rows[indexPath.row].value
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
}
