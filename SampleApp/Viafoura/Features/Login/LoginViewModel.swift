//
//  LoginViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import ViafouraSDK

class LoginViewModel{
    let auth = ViafouraSDK.auth()
    
    func login(email: String, password: String, completion: @escaping ((Result<UserResponse, VFLoginError>) -> ())){
        auth.login(email: email, password: password, completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
    
    func passwordReset(email: String, completion: @escaping ((Result<Bool, VFPasswordResetError>) -> ())){
        auth.resetPassword(email: email, completion: completion)
    }
    
    func socialLogin(token: String, provider: VFSocialLoginProvider, completion: @escaping ((Result<UserResponse, VFSocialLoginError>) -> ())){
        auth.socialLogin(token: token, provider: provider, completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
}
