//
//  ViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import ViafouraSDK

class HomeViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "Home"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customAddView: UIView!
    
    let viewModel = HomeViewModel()
        
    let notificationBellTag = 5
    
    struct CellIdentifier {
        static let storyCell = "storyCell"
        static let pollCell = "pollCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStyling()
        setNotificationBell()
    }
    
    func setNotificationBell(){
        for view in view.subviews where view.tag == notificationBellTag {
            view.removeFromSuperview()
        }

        let settings = VFSettings(colors: VFColors())
        let bellView = VFNotificationBellView(settings: settings, loginDelegate: self, onBellClicked: { userUUID in
            let vc = VFProfileViewController.new(
                userUUID: userUUID,
                presentationType: .profile,
                loginDelegate: self,
                settings: settings
            )
            self.present(vc, animated: true)
        })
        
        bellView.tag = notificationBellTag
        bellView.translatesAutoresizingMaskIntoConstraints = false
        bellView.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)

        if UserDefaults.standard.bool(forKey: SettingsKeys.showNotificationBellInTopBar) {
            bellView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            bellView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            let bellBarButtonItem = UIBarButtonItem(customView: bellView)
            navigationItem.rightBarButtonItem = bellBarButtonItem
        } else {
            view.addSubview(bellView)
            
            bellView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            bellView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            bellView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -20).isActive = true
            bellView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20).isActive = true
            bellView.layoutIfNeeded()
            
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func updateStyling(){
        navigationController?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        parent?.parent?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
    }

    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        
        customAddView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCustomContainerAlert)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bellChanged(notification:)), name: Notification.Name(SettingsKeys.showNotificationBellInTopBar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.darkModeChanged(notification:)), name: Notification.Name(SettingsKeys.darkMode), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.customContainerIDsChanged(notification:)), name: Notification.Name(SettingsKeys.customContainerIDs), object: nil)
    }
    
    @objc func customContainerIDsChanged(notification: Notification) {
        customAddView.isHidden = UserDefaults.standard.bool(forKey: SettingsKeys.customContainerIDs) == false
    }
    
    @objc func bellChanged(notification: Notification) {
        getAuthState()
        setNotificationBell()
    }
    
    @objc func darkModeChanged(notification: Notification) {
        updateStyling()
    }
    
    func getAuthState(){
        if UserDefaults.standard.bool(forKey: SettingsKeys.showNotificationBellInTopBar) {
            return
        }

        viewModel.getAuthState(completion: { loginStatus in
            if case .loggedIn(let userUUID) = loginStatus {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutTapped))
            } else if case .notLoggedIn = loginStatus {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginTapped))
            }
        })
    }
    
    @objc
    func loginTapped(){
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        loginVC.onDoneBlock = { [weak self] result in
            self?.getAuthState()
        }
        
        self.present(loginVC, animated: true)
    }
    
    @objc
    func logoutTapped(){
        viewModel.logout()
        getAuthState()
    }
    
    @objc
    func showCustomContainerAlert(){
        let alert = UIAlertController(title: "Custo container ID", message: "Enter a container ID for the article", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "ID"
        }

        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak alert, self] (_) in
            let textField = alert?.textFields![0]
            guard let value = textField?.text, value.isEmpty == false else {
                return
            }
            
            guard let articleVC = ArticleViewController.new() else{
                return
            }
            
            articleVC.articleViewModel = ArticleViewModel(story: Story.randomWithContainerId(containerId: value))
            articleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(articleVC, animated: true)
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contents.count
    }
}

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = viewModel.contents[indexPath.row]
        if let story = content.story {
            guard let articleVC = ArticleViewController.new() else{
                return
            }
            
            articleVC.articleViewModel = ArticleViewModel(story: story)
            articleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(articleVC, animated: true)
        } else if let poll = content.poll {
            guard let pollVC = PollViewController.new() else{
                return
            }
            pollVC.pollViewModel = PollViewModel(poll: poll)
            pollVC.modalPresentationStyle = .overCurrentContext

            self.present(pollVC, animated: true)
        } else if let liveChat = content.liveChat {
            presentLiveChat(liveChat)
        } else if let liveQuestions = content.liveQuestions {
            presentLiveQuestions(liveQuestions)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = viewModel.contents[indexPath.row]
        return content.type == .story ? 280 : 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = viewModel.contents[indexPath.row]
        if content.type == .story, let story = content.story {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.storyCell) as! StoryTableViewCell
            cell.setup(forStory: story)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.pollCell) as! PollTableViewCell
            if let poll = content.poll {
                cell.setup(forPoll: poll)
            } else if let liveChat = content.liveChat {
                cell.setup(title: liveChat.title, image: liveChat.image)
            } else if let liveQuestions = content.liveQuestions {
                cell.setup(title: liveQuestions.title, image: "questionmark.circle.fill")
            }
            return cell
        }
    }
}

private extension HomeViewController {
    func articleMetadata() -> VFArticleMetadata {
        let storedDomain = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteDomain = (storedDomain?.isEmpty == false ? storedDomain : nil) ?? SiteDefaults.siteDomain
        let url = URL(string: "https://\(siteDomain)")!
        return VFArticleMetadata(url: url, title: "Title", subtitle: "Subtitle", thumbnailUrl: url)
    }

    func presentLiveChat(_ liveChat: LiveChat) {
        if liveChat.type == .portraitOverlay {
            guard let liveChatVC = LiveChatPortraitOverlayViewController.new() else{
                return
            }

            liveChatVC.modalPresentationStyle = .fullScreen
            liveChatVC.viewModel = LiveChatViewModel(containerId: liveChat.containerId, articleMetadata: articleMetadata())
            liveChatVC.hidesBottomBarWhenPushed = true
            present(liveChatVC, animated: true)
        } else if liveChat.type == .portrait {
            guard let liveChatVC = LiveChatPortraitViewController.new() else{
                return
            }

            liveChatVC.modalPresentationStyle = .pageSheet
            liveChatVC.viewModel = LiveChatViewModel(containerId: liveChat.containerId, articleMetadata: articleMetadata())
            liveChatVC.hidesBottomBarWhenPushed = true
            present(liveChatVC, animated: true)
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
                articleMetadata: articleMetadata(),
                loginDelegate: self,
                settings: settings
            )

            liveChatVC.setActionCallbacks(callbacks: callbacks)
            liveChatVC.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
            liveChatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(liveChatVC, animated: true)
        }
    }

    func presentLiveQuestions(_ liveQuestions: LiveQuestions) {
        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            default:
                break
            }
        }

        let settings = VFSettings(colors: VFColors())
        let liveQuestionsVC = VFLiveQuestionsViewController.new(
            containerId: liveQuestions.containerId,
            articleMetadata: articleMetadata(),
            loginDelegate: self,
            settings: settings
        )

        liveQuestionsVC.setActionCallbacks(callbacks: callbacks)
        liveQuestionsVC.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        liveQuestionsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(liveQuestionsVC, animated: true)
    }

    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        let settings = VFSettings(colors: colors)

        let profileViewController = VFProfileViewController.new(userUUID: userUUID, presentationType: presentationType, loginDelegate: self, settings: settings)
        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        present(profileViewController, animated: true)
    }
}

extension HomeViewController: VFLoginDelegate {
    func startLogin() {
        loginTapped()
    }
}
