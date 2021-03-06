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
    
    func login(email: String, password: String, completion: @escaping ((Result<VFLoginData, VFLoginError>) -> ())){
        auth.login(email: email, password: password, completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
}
