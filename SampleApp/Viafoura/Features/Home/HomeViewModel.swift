//
//  HomeViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import Foundation
import ViafouraSDK

class HomeViewModel {
    var stories = [Story]()
    let auth = ViafouraSDK.auth()

    init(){
        loadStories()
    }
    
    func loadStories(){
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2022/07/12/la-vicepresidenta-cristina-kirchner-el___kqSYcyHGL_1256x620__1.jpg", title: "Recursos públicos", description: "Cristina Kirchner ya cobra $ 4.000.000 mensuales por su doble pensión: equivale a 110 jubilaciones mínimas", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/politica/cristina-kirchner-cobra-4-000-000-mensuales-doble-pension-equivale-110-jubilaciones-minimas_0_xF1FCoAHdc.html", containerId: "xF1FCoAHdc"))
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2021/03/20/carlos-savanz-en-marzo-de___x8iiGxrUC_1256x620__1.jpg", title: "Robo de chicos", description: "Caso de la niña M.: condenaron a 22 años de prisión al cartonero que la secuestró en Villa Lugano y la retuvo tres días", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/policiales/caso-nina-m-condenaron-22-anos-prision-cartonero-secuestro-villa-lugano-retuvo-dias_0_Gymdt9Kepq.html", containerId: "Gymdt9Kepq"))
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2021/02/16/tarifas-de-luz-y-gas___4w43EXrPo_1256x620__1.jpg", title: "Se habilita el próximo viernes", description: "Subsidios a la luz y el gas: qué datos deberá poner el usuario en el formulario y qué pasa si no se completa", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/economia/subsidios-luz-gas-datos-debera-poner-usuario-formulario-pasa-completa_0_26AdcpbayH.html", containerId: "26AdcpbayH"))
    }
    
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
