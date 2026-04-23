//
//  LoginViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
import ViafouraSDK
import OneSignalFramework

class LoginViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "Login"

    let loginViewModel = LoginViewModel()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var linkedinView: UIView!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var appleView: UIView!
    
    @IBOutlet weak var passwordResetLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var closeImage: UIImageView!
    
    var onDoneBlock: ((Bool) -> Void)?
    
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
            passwordTextField.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
            emailTextField.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        }
    
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        closeImage.isUserInteractionEnabled = true
        closeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))
        
        passwordResetLabel.isUserInteractionEnabled = true
        passwordResetLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordResetTapped)))
        
        signupButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signupTapped)))
        submitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitTapped)))

        // Social login via LoginRadius has been removed from the SampleApp.
        [facebookView, googleView, linkedinView, twitterView, appleView].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.isHidden = true
        }
    }

    @objc
    func closeTapped(){
        self.dismiss(animated: true)
    }

    @objc
    func passwordResetTapped(){
        let alert = UIAlertController(title: "Reset your password", message: "Enter your e-mail", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { _ in
            guard let alertTextFields = alert.textFields, let textField = alertTextFields.first, let emailText = textField.text, self.loginViewModel.isValidEmail(emailText) else {
                return
            }
             
            self.loginViewModel.passwordReset(email: emailText, completion: { result in
                switch result {
                case .success(let result):
                    break
                case .failure(let error):
                    print(error)
                }
            })
        }))

        self.present(alert, animated: true, completion: nil)
    }

    @objc
    func signupTapped(){
        let presentingVC = self.presentingViewController
        self.dismiss(animated: true, completion: {
            guard let signUpVC = SignUpViewController.new() else{
                return
            }
                    
            presentingVC?.present(signUpVC, animated: true)
        })
    }
    
    @objc
    func submitTapped(){
        guard let email = emailTextField.text, self.loginViewModel.isValidEmail(email) else{
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        loadingView.isHidden = false
        submitButton.isHidden = true
        loginViewModel.login(email: email, password: password, completion: { result in
            self.loadingView.isHidden = true
            self.submitButton.isHidden = false
            switch result {
            case .success(let user):
                OneSignal.login(String(user.id))
                self.onDoneBlock?(true)
                self.dismiss(animated: true)
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        })
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
