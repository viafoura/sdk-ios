//
//  SettingCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import UIKit

class SettingCell: UITableViewCell {
    let settingSwitch = UISwitch()
    let settingLabel = UILabel()
    
    var setting: Setting!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(){
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        settingLabel.translatesAutoresizingMaskIntoConstraints = false
        settingLabel.font = .systemFont(ofSize: 17)
        settingLabel.numberOfLines = 0
        contentView.addSubview(settingLabel)

        settingSwitch.translatesAutoresizingMaskIntoConstraints = false
        settingSwitch.isOn = true
        settingSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        contentView.addSubview(settingSwitch)

        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            settingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingLabel.widthAnchor.constraint(equalToConstant: 250),
            settingLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 3),
            settingLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -3),
            settingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            settingSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setup(setting: Setting){
        self.setting = setting

        selectionStyle = .none
        
        settingLabel.text = setting.title
        settingSwitch.isOn = UserDefaults.standard.bool(forKey: setting.key) == true
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = settingSwitch.isOn
        UserDefaults.standard.set(value, forKey: setting.key)
        NotificationCenter.default.post(name: NSNotification.Name(setting.key), object: self, userInfo: ["value": mySwitch.isOn])
    }
}
