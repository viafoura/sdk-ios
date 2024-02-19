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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bellChanged(notification:)), name: Notification.Name(SettingsKeys.showNotificationBellInTopBar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.darkModeChanged(notification:)), name: Notification.Name(SettingsKeys.darkMode), object: nil)
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
            if story.storyType == .comments || story.storyType == .reviews {
                guard let articleVC = ArticleViewController.new() else{
                    return
                }
                
                articleVC.articleViewModel = ArticleViewModel(story: story)
                articleVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(articleVC, animated: true)
            } else if story.storyType == .blog {
                guard let liveBlogVC = LiveBlogViewController.new() else{
                    return
                }
                
                liveBlogVC.viewModel = LiveBlogViewModel(story: story)
                liveBlogVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(liveBlogVC, animated: true)
            }
        } else if let poll = content.poll {
            guard let pollVC = PollViewController.new() else{
                return
            }
            pollVC.pollViewModel = PollViewModel(poll: poll)
            pollVC.modalPresentationStyle = .overCurrentContext

            self.present(pollVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = viewModel.contents[indexPath.row]
        return content.type == .poll ? 90 : 280
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = viewModel.contents[indexPath.row]
        if content.type == .story, let story = content.story {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.storyCell) as! StoryTableViewCell
            cell.setup(forStory: story)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.pollCell) as! PollTableViewCell
            cell.setup(forPoll: content.poll!)
            return cell
        }
    }
}

extension HomeViewController: VFLoginDelegate {
    func startLogin() {
        loginTapped()
    }
}
