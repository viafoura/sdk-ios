//
//  SignUpViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 16/05/2022.
//

import Foundation
import UIKit
class SignUpViewController: UIViewController, StoryboardCreateable{
    static var storyboardName = "SignUp"

    let viewModel = SignUpViewModel()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var closeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStyling()
    }
    
    func updateStyling(){
        overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
    }
    
    func setupUI(){
        loadingView.color = .red
        
        if #available(iOS 13.0, *) {
            nameTextField.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
            passwordTextField.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
            emailTextField.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        }
        
        nameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        closeImage.isUserInteractionEnabled = true
        closeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))

        submitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitTapped)))
    }
    
    @objc
    func closeTapped(){
        self.dismiss(animated: true)
    }
    
    @objc
    func submitTapped(){
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else{
            return
        }
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else{
            return
        }
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else{
            return
        }
        
        if name.isEmpty || email.isEmpty || password.isEmpty {
            self.showAlert(title: "Error", message: "You must fill all the fields")
        }
        
        if password.count < 8 {
            self.showAlert(title: "Error", message: "The password must be at least 8 characters")
        }
        
        submitButton.isHidden = true
        loadingView.isHidden = false
        viewModel.signup(name: name, email: email, password: password, completion: { result in
            self.loadingView.isHidden = true
            self.submitButton.isHidden = false
            switch result {
            case .success(let string):
                self.dismiss(animated: true)
            case .failure(let error):
                self.showAlert(title: "Error", message: "The account could not be created")
            }
        })
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
