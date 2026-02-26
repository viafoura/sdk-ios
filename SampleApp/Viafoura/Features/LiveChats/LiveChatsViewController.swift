//
//  LiveChatsViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation
import UIKit
import ViafouraSDK

class LiveChatsViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "LiveChats"

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = LiveChatsViewModel()
    private let defaultSectionUUIDString = "00000000-0000-4000-8000-c8cddfd7b365"
    
    struct CellIdentifier {
        static let liveChatCell = "liveChatCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Live Q&A", style: .plain, target: self, action: #selector(liveQuestionsTapped))
        setupUI()
    }
    
    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc
    private func liveQuestionsTapped() {
        let alert = UIAlertController(title: "Live Q&A", message: "Enter containerId and sectionUUID", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "containerId"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.text = UserDefaults.standard.string(forKey: SettingsKeys.liveQuestionsContainerId)
        }

        alert.addTextField { [weak self] textField in
            textField.placeholder = "sectionUUID"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.text = UserDefaults.standard.string(forKey: SettingsKeys.liveQuestionsSectionUUID) ?? self?.defaultSectionUUIDString
        }

        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak alert, weak self] _ in
            guard let self else { return }
            let containerId = (alert?.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let sectionUUIDString = (alert?.textFields?.dropFirst().first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                containerId.isEmpty == false,
                let sectionUUID = UUID(uuidString: sectionUUIDString)
            else { return }

            UserDefaults.standard.set(containerId, forKey: SettingsKeys.liveQuestionsContainerId)
            UserDefaults.standard.set(sectionUUIDString, forKey: SettingsKeys.liveQuestionsSectionUUID)

            let articleMetadata = VFArticleMetadata(
                url: URL(string: "https://viafoura-mobile-demo.vercel.app")!,
                title: "Title",
                subtitle: "Subtitle",
                thumbnailUrl: URL(string: "https://viafoura-mobile-demo.vercel.app")!
            )

            let settings = VFSettings(colors: VFColors())
            let vc = VFLiveQuestionsViewController.new(
                containerId: containerId,
                articleMetadata: articleMetadata,
                loginDelegate: self,
                settings: settings,
                sectionUUID: sectionUUID
            )
            vc.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        let settings = VFSettings(colors: colors)

        let profileViewController = VFProfileViewController.new(userUUID: userUUID, presentationType: presentationType, loginDelegate: self, settings: settings)
        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        self.present(profileViewController, animated: true)
    }
}

extension LiveChatsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liveChat = viewModel.liveChats[indexPath.row]
        let articleMetadata = VFArticleMetadata(url: URL(string: "https://viafoura-mobile-demo.vercel.app")!, title: "Title", subtitle: "Subtitle", thumbnailUrl: URL(string: "https://viafoura-mobile-demo.vercel.app")!)
        if liveChat.type == .portraitOverlay {
            guard let liveChatVC = LiveChatPortraitOverlayViewController.new() else{
                return
            }
            
            liveChatVC.modalPresentationStyle = .fullScreen
            liveChatVC.viewModel = LiveChatViewModel(containerId: liveChat.containerId, articleMetadata: articleMetadata)
            liveChatVC.hidesBottomBarWhenPushed = true
            self.present(liveChatVC, animated: true)
        } else if liveChat.type == .portrait {
            guard let liveChatVC = LiveChatPortraitViewController.new() else{
                return
            }
            
            liveChatVC.modalPresentationStyle = .pageSheet
            liveChatVC.viewModel = LiveChatViewModel(containerId: liveChat.containerId, articleMetadata: articleMetadata)
            liveChatVC.hidesBottomBarWhenPushed = true
            liveChatVC.title = liveChatVC.title
            self.present(liveChatVC, animated: true)
        } else {
            let callbacks: VFActionsCallbacks = { [weak self] type in
                switch type {
                case .openProfilePressed(let userUUID, let presentationType):
                    self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
                default:
                    break
                }
            }
            
            let settings = VFSettings(colors: VFColors())
            let liveChatVC = VFLiveChatViewController.new(
                containerId: liveChat.containerId,
                articleMetadata: articleMetadata,
                loginDelegate: self,
                settings: settings
            )
            
            liveChatVC.setActionCallbacks(callbacks: callbacks)
            liveChatVC.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
            liveChatVC.hidesBottomBarWhenPushed = true
            liveChatVC.title = liveChatVC.title
            self.navigationController?.pushViewController(liveChatVC, animated: true)
        }
    }
}

extension LiveChatsViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = LoginViewController.new() else{
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
