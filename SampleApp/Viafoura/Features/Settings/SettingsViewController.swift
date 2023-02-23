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
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingCell
        cell.setup(setting: viewModel.settings[indexPath.row])
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings.count
    }
}
