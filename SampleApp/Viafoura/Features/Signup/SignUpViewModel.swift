//
//  SignUpViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 16/05/2022.
//

import Foundation
import ViafouraSDK

class SignUpViewModel{
    let auth = ViafouraSDK.auth()

    func signup(name: String, email: String, password: String, completion: @escaping ((Result<VFSignUpData, VFSignUpError>) -> ())){
        auth.signup(name: name, email: email, password: password, completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
}
