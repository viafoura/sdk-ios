//
//  LoginViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
import LoginRadiusSDK
import ViafouraSDK

class LoginViewController: UIViewController{
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
        
        let googleViewRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(googleTapped))
        googleViewRecognizer.minimumPressDuration = 0
        googleView.addGestureRecognizer(googleViewRecognizer)
        
        let linkedinViewRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(linkedinTapped))
        linkedinViewRecognizer.minimumPressDuration = 0
        linkedinView.addGestureRecognizer(linkedinViewRecognizer)
        
        let appleViewRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(appleTapped))
        appleViewRecognizer.minimumPressDuration = 0
        appleView.addGestureRecognizer(appleViewRecognizer)
        
        let twitterViewRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(twitterTapped))
        twitterViewRecognizer.minimumPressDuration = 0
        twitterView.addGestureRecognizer(twitterViewRecognizer)
    }
    
    @objc
    func closeTapped(){
        self.dismiss(animated: true)
    }
    
    @objc
    func twitterTapped(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.twitterView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.twitterView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            self.performSocialLogin(loginType: .twitter)
        }
    }
    
    @objc
    func appleTapped(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.appleView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.appleView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            self.performSocialLogin(loginType: .apple)
        }
    }
    
    @objc
    func linkedinTapped(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.linkedinView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.linkedinView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            self.performSocialLogin(loginType: .linkedin)
        }
    }
    
    @objc
    func googleTapped(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.googleView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.googleView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            self.performSocialLogin(loginType: .google)
        }
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
            
            self.performSocialLogin(loginType: .facebook)
        }
    }
    
    func performSocialLogin(loginType: VFSocialLoginProvider){
        LoginRadiusSocialLoginManager.sharedInstance().login(withProvider: loginType.rawValue, in: self, completionHandler: { result, error in
            if let token = result?["access_token"] as? String {
                self.loginViewModel.socialLogin(token: token, provider: loginType, completion: { result in
                    switch result {
                    case .success(_):
                        self.onDoneBlock?(true)
                        self.dismiss(animated: true)
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                })
            }
        })
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
            case .success(_):
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
