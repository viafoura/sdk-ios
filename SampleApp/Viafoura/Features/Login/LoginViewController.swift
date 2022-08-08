//
//  LoginViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
class LoginViewController: UIViewController{
    let loginViewModel = LoginViewModel()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var facebookView: UIView!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var closeImage: UIImageView!
    
    var onDoneBlock: ((Bool) -> Void)?

    struct VCIdentifier {
        static let signupVC = "SignUpViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        loadingView.color = .red

        if #available(iOS 13.0, *) {
            passwordTextField.overrideUserInterfaceStyle = .light
            emailTextField.overrideUserInterfaceStyle = .light
        }
        
        closeImage.isUserInteractionEnabled = true
        closeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))
        
        signupButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signupTapped)))
        submitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitTapped)))
        
        let facebookViewRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(facebookTapped))
        facebookViewRecognizer.minimumPressDuration = 0
        facebookView.addGestureRecognizer(facebookViewRecognizer)
        facebookView.isHidden = true
    }
    
    @objc
    func closeTapped(){
        self.dismiss(animated: true)
    }
    
    @objc
    func facebookTapped(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.facebookView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.facebookView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    @objc
    func signupTapped(){
        let presentingVC = self.presentingViewController
        self.dismiss(animated: true, completion: {
            guard let signUpVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.signupVC) as? SignUpViewController else{
                return
            }
                    
            presentingVC?.present(signUpVC, animated: true)
        })
    }
    
    @objc
    func submitTapped(){
        guard let email = emailTextField.text else{
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
            case .success(let string):
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
