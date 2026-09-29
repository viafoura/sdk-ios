//
//  SignUpViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 16/05/2022.
//

import Foundation
import UIKit
class SignUpViewController: UIViewController{
    let viewModel = SignUpViewModel()

    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let loadingView = UIActivityIndicatorView(style: .medium)
    let submitButton = UIButton(type: .system)
    
    let closeImage = UIImageView(image: UIImage(systemName: "xmark"))

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

    private func configure(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 14)
        textField.backgroundColor = .clear
        view.addSubview(textField)
    }

    func setupLayout(){
        view.backgroundColor = .systemBackground

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.clipsToBounds = true
        view.addSubview(logoImageView)

        configure(nameTextField, placeholder: "Name")
        nameTextField.textContentType = .name

        configure(emailTextField, placeholder: "E-mail")
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress

        configure(passwordTextField, placeholder: "Password")
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true

        var submitConfiguration = UIButton.Configuration.plain()
        submitConfiguration.title = "Sign-up"
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.configuration = submitConfiguration
        view.addSubview(submitButton)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.isHidden = true
        loadingView.startAnimating()
        view.addSubview(loadingView)

        closeImage.translatesAutoresizingMaskIntoConstraints = false
        closeImage.contentMode = .scaleAspectFit
        view.addSubview(closeImage)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 300),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),

            nameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 60),
            nameTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            nameTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            submitButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            loadingView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 55),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            closeImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            closeImage.widthAnchor.constraint(equalToConstant: 30),
            closeImage.heightAnchor.constraint(equalToConstant: 30)
        ])
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
