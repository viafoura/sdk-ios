import UIKit

final class NetworkInspectorViewController: UITableViewController {
    private var records: [NetworkRecord] = []
    private let scopeControl = UISegmentedControl(items: ["Viafoura", "All"])
    private let searchController = UISearchController(searchResultsController: nil)
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    init() {
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Network"
        scopeControl.selectedSegmentIndex = 0
        scopeControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        navigationItem.titleView = scopeControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearPressed))

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter by URL"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.register(NetworkRecordCell.self, forCellReuseIdentifier: "record")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NetworkInspector.didChange, object: nil)
        reload()
    }

    @objc private func reload() {
        let viafouraOnly = scopeControl.selectedSegmentIndex == 0
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        records = NetworkInspector.shared.records.filter { record in
            if viafouraOnly && !record.isViafoura { return false }
            if query.isEmpty { return true }
            return (record.url?.absoluteString.lowercased().contains(query) ?? false)
        }
        tableView.reloadData()
    }

    @objc private func clearPressed() {
        NetworkInspector.shared.clear()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath) as! NetworkRecordCell
        cell.setup(record: records[indexPath.row], time: timeFormatter.string(from: records[indexPath.row].startedAt))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(NetworkRecordDetailViewController(recordID: records[indexPath.row].id), animated: true)
    }
}

extension NetworkInspectorViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reload()
    }
}

final class NetworkRecordCell: UITableViewCell {
    private let methodLabel = UILabel()
    private let statusLabel = UILabel()
    private let pathLabel = UILabel()
    private let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        methodLabel.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        statusLabel.font = .monospacedSystemFont(ofSize: 13, weight: .semibold)
        pathLabel.font = .systemFont(ofSize: 14)
        pathLabel.numberOfLines = 2
        pathLabel.lineBreakMode = .byTruncatingMiddle
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabel

        let topRow = UIStackView(arrangedSubviews: [methodLabel, statusLabel, UIView()])
        topRow.spacing = 8
        let stack = UIStackView(arrangedSubviews: [topRow, pathLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(record: NetworkRecord, time: String) {
        methodLabel.text = record.method
        pathLabel.text = record.path

        if let status = record.statusCode {
            statusLabel.text = "\(status)"
            statusLabel.textColor = Self.color(forStatus: status)
        } else if record.error != nil {
            statusLabel.text = "ERR"
            statusLabel.textColor = .systemRed
        } else {
            statusLabel.text = "…"
            statusLabel.textColor = .secondaryLabel
        }

        var details = [record.host, time]
        if let duration = record.duration {
            details.append(String(format: "%.0f ms", duration * 1000))
        }
        if let body = record.responseBody {
            details.append(ByteCountFormatter.string(fromByteCount: Int64(body.count), countStyle: .binary))
        }
        detailLabel.text = details.joined(separator: " · ")
    }

    static func color(forStatus status: Int) -> UIColor {
        switch status {
        case 200..<300: return .systemGreen
        case 300..<400: return .systemOrange
        default: return .systemRed
        }
    }
}
