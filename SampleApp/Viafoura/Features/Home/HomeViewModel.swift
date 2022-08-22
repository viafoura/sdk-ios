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
        stories.append(Story(pictureUrl: "https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856", title: "Moving Staff to Cover the Coronavirus", description: "Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload", author: "Norman Phillips", category: "ECONOMIA", link: "https://demo.viafoura.com/posts/here-are-what-media-companies-are-doing-with-covid-19-overload", containerId: "101113541"))
        stories.append(Story(pictureUrl: "https://www.datocms-assets.com/55856/1636663477-blognewheights.jpg?fit=crop&fm=webp&h=428&w=856", title: "Grow civility", description: "Don't shut out your community, instead guide them towards civility", author: "Tom Hardington", category: "ECONOMIA", link: "https://demo.viafoura.com/posts/dont-shut-out-your-community-guide-them-to-civility", containerId: "101113531"))
        stories.append(Story(pictureUrl: "https://www.datocms-assets.com/55856/1639925068-brexit-to-cost-the-uk.jpg?fit=crop&fm=webp&h=428&w=856", title: "Brexit cost", description: "Brexit to cost £1,200 for each person in UK", author: "Tom Hardington", category: "ECONOMIA", link: "https://demo.viafoura.com/posts/brexit-to-cost-gbp1-200-for-each-person-in-uk", containerId: "101113509"))

        /*
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2022/07/12/la-vicepresidenta-cristina-kirchner-el___kqSYcyHGL_1256x620__1.jpg", title: "Recursos públicos", description: "Cristina Kirchner ya cobra $ 4.000.000 mensuales por su doble pensión: equivale a 110 jubilaciones mínimas", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/politica/cristina-kirchner-cobra-4-000-000-mensuales-doble-pension-equivale-110-jubilaciones-minimas_0_xF1FCoAHdc.html", containerId: "xF1FCoAHdc"))
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2021/03/20/carlos-savanz-en-marzo-de___x8iiGxrUC_1256x620__1.jpg", title: "Robo de chicos", description: "Caso de la niña M.: condenaron a 22 años de prisión al cartonero que la secuestró en Villa Lugano y la retuvo tres días", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/policiales/caso-nina-m-condenaron-22-anos-prision-cartonero-secuestro-villa-lugano-retuvo-dias_0_Gymdt9Kepq.html", containerId: "Gymdt9Kepq"))
        stories.append(Story(pictureUrl: "https://www.clarin.com/img/2021/02/16/tarifas-de-luz-y-gas___4w43EXrPo_1256x620__1.jpg", title: "Se habilita el próximo viernes", description: "Subsidios a la luz y el gas: qué datos deberá poner el usuario en el formulario y qué pasa si no se completa", author: "Lucía Salinas", category: "ECONOMIA", link: "https://www.clarin.com/economia/subsidios-luz-gas-datos-debera-poner-usuario-formulario-pasa-completa_0_26AdcpbayH.html", containerId: "26AdcpbayH"))
         */
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
