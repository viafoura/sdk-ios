//
//  LoginViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
import ViafouraSDK

class LoginViewController: UIViewController {
    let loginViewModel = LoginViewModel()

    let logoImageView = UIImageView(image: UIImage(named: "logo"))

    let emailTextField = UITextField()
    let passwordTextField = UITextField()

    let submitButton = UIButton(type: .system)
    let signupButton = UIButton(type: .system)
    
    let socialContainerView = UIView()
    let facebookView = LoginViewController.makeSocialView(imageName: "facebook", tintColor: UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0))
    let googleView = LoginViewController.makeSocialView(imageName: "google", tintColor: .white)
    let linkedinView = LoginViewController.makeSocialView(imageName: "linkedin", tintColor: .white)
    let twitterView = LoginViewController.makeSocialView(imageName: "twitter", tintColor: .white)
    let appleView = LoginViewController.makeSocialView(imageName: "apple", tintColor: .white)
    
    let passwordResetLabel = UILabel()
    
    let loadingView = UIActivityIndicatorView(style: .medium)
    
    let closeImage = UIImageView(image: UIImage(systemName: "xmark"))
    
    var onDoneBlock: ((Bool) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
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

    private static func makeSocialView(imageName: String, tintColor: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 30
        container.clipsToBounds = true

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 60),
            container.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private static func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        return textField
    }

    func setupLayout(){
        view.backgroundColor = .systemBackground

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.clipsToBounds = true
        view.addSubview(logoImageView)

        let configuredEmail = LoginViewController.makeTextField(placeholder: "E-mail")
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.borderStyle = configuredEmail.borderStyle
        emailTextField.placeholder = configuredEmail.placeholder
        emailTextField.font = configuredEmail.font
        emailTextField.backgroundColor = configuredEmail.backgroundColor
        emailTextField.textContentType = .emailAddress
        view.addSubview(emailTextField)

        let configuredPassword = LoginViewController.makeTextField(placeholder: "Password")
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.borderStyle = configuredPassword.borderStyle
        passwordTextField.placeholder = configuredPassword.placeholder
        passwordTextField.font = configuredPassword.font
        passwordTextField.backgroundColor = configuredPassword.backgroundColor
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)

        var submitConfiguration = UIButton.Configuration.plain()
        submitConfiguration.title = "Login"
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.configuration = submitConfiguration
        view.addSubview(submitButton)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.isHidden = true
        loadingView.startAnimating()
        view.addSubview(loadingView)

        var signupConfiguration = UIButton.Configuration.plain()
        signupConfiguration.title = "Sign-up"
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.configuration = signupConfiguration
        view.addSubview(signupButton)

        socialContainerView.translatesAutoresizingMaskIntoConstraints = false
        socialContainerView.backgroundColor = .clear
        view.addSubview(socialContainerView)
        [appleView, googleView, facebookView, linkedinView, twitterView].forEach { socialContainerView.addSubview($0) }

        closeImage.translatesAutoresizingMaskIntoConstraints = false
        closeImage.contentMode = .scaleAspectFit
        view.addSubview(closeImage)

        passwordResetLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordResetLabel.text = "Reset my password"
        passwordResetLabel.font = .systemFont(ofSize: 15)
        passwordResetLabel.textColor = UIColor(white: 0.58, alpha: 1)
        view.addSubview(passwordResetLabel)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 300),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),

            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 60),
            emailTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            submitButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            loadingView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 55),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            signupButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            signupButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            socialContainerView.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 40),
            socialContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            socialContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            socialContainerView.heightAnchor.constraint(equalToConstant: 60),

            facebookView.centerXAnchor.constraint(equalTo: socialContainerView.centerXAnchor),
            facebookView.centerYAnchor.constraint(equalTo: socialContainerView.centerYAnchor),
            googleView.trailingAnchor.constraint(equalTo: facebookView.leadingAnchor, constant: -20),
            googleView.centerYAnchor.constraint(equalTo: socialContainerView.centerYAnchor),
            appleView.trailingAnchor.constraint(equalTo: googleView.leadingAnchor, constant: -20),
            appleView.centerYAnchor.constraint(equalTo: socialContainerView.centerYAnchor),
            linkedinView.leadingAnchor.constraint(equalTo: facebookView.trailingAnchor, constant: 20),
            linkedinView.centerYAnchor.constraint(equalTo: socialContainerView.centerYAnchor),
            twitterView.leadingAnchor.constraint(equalTo: linkedinView.trailingAnchor, constant: 20),
            twitterView.centerYAnchor.constraint(equalTo: socialContainerView.centerYAnchor),

            closeImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            closeImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            closeImage.widthAnchor.constraint(equalToConstant: 30),
            closeImage.heightAnchor.constraint(equalToConstant: 30),

            passwordResetLabel.topAnchor.constraint(equalTo: socialContainerView.bottomAnchor, constant: 30),
            passwordResetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
            $0.isUserInteractionEnabled = false
            $0.isHidden = true
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
            presentingVC?.present(SignUpViewController(), animated: true)
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
            case .success:
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
