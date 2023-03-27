//
//  SettingCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var settingLabel: UILabel!
    
    var setting: Setting!
    
    func setup(setting: Setting){
        self.setting = setting

        selectionStyle = .none
        
        settingLabel.text = setting.title
        settingSwitch.isOn = UserDefaults.standard.bool(forKey: setting.key) == true
        settingSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = settingSwitch.isOn
        UserDefaults.standard.set(value, forKey: setting.key)
        NotificationCenter.default.post(name: NSNotification.Name(setting.key), object: self, userInfo: ["value": mySwitch.isOn])
    }
}
