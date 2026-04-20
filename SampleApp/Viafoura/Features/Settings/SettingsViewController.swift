//
//  SettingsViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import UIKit
class SettingsViewController: UITableViewController {
    let viewModel = SettingsViewModel()
    
    @IBOutlet weak var doneBarItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        doneBarItem.target = self
        doneBarItem.action = #selector(donePressed)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.darkModeChanged(notification:)), name: Notification.Name(SettingsKeys.darkMode), object: nil)
    }
    
    @objc func darkModeChanged(notification: Notification) {
        updateStyling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStyling()
    }
    
    func updateStyling(){
        navigationController?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
    }
    
    @objc func donePressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "Site"
            cell.detailTextLabel?.text = currentSiteDomain()
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingCell
        cell.setup(setting: viewModel.settings[indexPath.row - 1])
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings.count + 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row == 0 else { return }
        presentSiteSwitcher(sourceIndexPath: indexPath)
    }

    private func currentSiteDomain() -> String {
        let stored = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (stored?.isEmpty == false ? stored! : SiteDefaults.siteDomain)
    }

    private func presentSiteSwitcher(sourceIndexPath: IndexPath) {
        let sheet = UIAlertController(title: "Select site", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Demo (\(SiteDefaults.siteDomain))", style: .default) { [weak self] _ in
            self?.setSiteAndRestart(siteUUID: SiteDefaults.siteUUID, siteDomain: SiteDefaults.siteDomain)
        })

        sheet.addAction(UIAlertAction(title: "Custom…", style: .default) { [weak self] _ in
            self?.presentCustomSitePrompt()
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = sheet.popoverPresentationController,
           let cell = tableView.cellForRow(at: sourceIndexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(sheet, animated: true)
    }

    private func presentCustomSitePrompt() {
        let alert = UIAlertController(title: "Custom site", message: "Changing site will restart the app.", preferredStyle: .alert)

        let existingUUID = UserDefaults.standard.string(forKey: SettingsKeys.siteUUID) ?? SiteDefaults.siteUUID
        let existingDomain = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain) ?? SiteDefaults.siteDomain

        alert.addTextField { field in
            field.placeholder = "Site UUID"
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.text = existingUUID
        }

        alert.addTextField { field in
            field.placeholder = "Site domain"
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.keyboardType = .URL
            field.text = existingDomain
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save & Restart", style: .destructive) { [weak self, weak alert] _ in
            let uuid = alert?.textFields?.first?.text
            let domain = alert?.textFields?.dropFirst().first?.text
            self?.setSiteAndRestart(siteUUID: uuid, siteDomain: domain)
        })

        present(alert, animated: true)
    }

    private func setSiteAndRestart(siteUUID: String?, siteDomain: String?) {
        let uuid = (siteUUID ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let domain = (siteDomain ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if uuid.isEmpty {
            UserDefaults.standard.removeObject(forKey: SettingsKeys.siteUUID)
        } else {
            UserDefaults.standard.set(uuid, forKey: SettingsKeys.siteUUID)
        }

        if domain.isEmpty {
            UserDefaults.standard.removeObject(forKey: SettingsKeys.siteDomain)
        } else {
            UserDefaults.standard.set(domain, forKey: SettingsKeys.siteDomain)
        }

        UserDefaults.standard.synchronize()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            exit(0)
        }
    }
}
