//
//  LiveChatsViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation
import UIKit
import ViafouraSDK

class LiveChatsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = LiveChatsViewModel()
    
    struct CellIdentifier {
        static let liveChatCell = "liveChatCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension LiveChatsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liveChat = viewModel.liveChats[indexPath.row]
        let articleMetadata = VFArticleMetadata(url: URL(string: "https://viafoura-mobile-demo.vercel.app")!, title: "Title", subtitle: "Subtitle", thumbnailUrl: URL(string: "https://viafoura-mobile-demo.vercel.app")!)
        if liveChat.isVideo {
            guard let liveChatVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.liveChatVC) as? LiveChatViewController else{
                return
            }
            
            liveChatVC.modalPresentationStyle = .fullScreen
            liveChatVC.viewModel = LiveChatViewModel(containerId: liveChat.containerId, articleMetadata: articleMetadata)
            liveChatVC.hidesBottomBarWhenPushed = true
            self.present(liveChatVC, animated: true)
        } else {
            let settings = VFSettings(colors: VFColors())
            guard let liveChatVC = VFLiveChatViewController.new(containerId: liveChat.containerId, articleMetadata: articleMetadata, loginDelegate: self, settings: settings) else {
                return
            }
            
            liveChatVC.hidesBottomBarWhenPushed = true
            liveChatVC.title = liveChatVC.title
            self.navigationController?.pushViewController(liveChatVC, animated: true)
        }
    }
}

extension LiveChatsViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}

extension LiveChatsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.liveChatCell) as! LiveChatTableViewCell
        cell.setup(forChat: viewModel.liveChats[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.liveChats.count
    }
}
