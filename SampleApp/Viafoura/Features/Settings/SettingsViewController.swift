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

        view.backgroundColor = .white

        doneBarItem.target = self
        doneBarItem.action = #selector(donePressed)
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
