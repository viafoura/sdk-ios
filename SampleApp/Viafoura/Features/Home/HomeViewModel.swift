//
//  HomeViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import Foundation
import ViafouraSDK

class HomeViewModel {
    var contents = defaultContents
    let auth = ViafouraSDK.auth()

    func getAuthState(completion: @escaping (VFLoginStatus) -> Void){
        auth.getUserLoginStatus(completion: { result in
            switch result {
            case .success(let loginStatus):
                DispatchQueue.main.async {
                    completion(loginStatus)
                }
                break
            case .failure(let error):
                break
            }
        })
    }
    
    func logout(){
        auth.logout()
    }
}
