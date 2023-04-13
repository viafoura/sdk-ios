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
        
    struct CellIdentifier {
        static let storyCell = "storyCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStyling()
        getAuthState()
    }
    
    func updateStyling(){
        navigationController?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
        parent?.parent?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light
    }

    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.darkModeChanged(notification:)), name: Notification.Name(SettingsKeys.darkMode), object: nil)
    }
    
    @objc func darkModeChanged(notification: Notification) {
        updateStyling()
    }
    
    func getAuthState(){
        viewModel.getAuthState(completion: { loginStatus in
            if loginStatus == .loggedIn {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutTapped))
            } else if loginStatus == .notLoggedIn {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginTapped))
            }
        })
    }
    
    @objc
    func loginTapped(){
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        loginVC.onDoneBlock = { result in
            self.getAuthState()
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
        return viewModel.stories.count
    }
}

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = viewModel.stories[indexPath.row]
        if story.storyType == .comments {
            guard let articleVC = ArticleViewController.new() else{
                return
            }
            
            articleVC.articleViewModel = ArticleViewModel(story: viewModel.stories[indexPath.row])
            articleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(articleVC, animated: true)
        } else if story.storyType == .blog {
            guard let liveBlogVC = LiveBlogViewController.new() else{
                return
            }
            
            liveBlogVC.viewModel = LiveBlogViewModel(story: viewModel.stories[indexPath.row])
            liveBlogVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(liveBlogVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.storyCell) as! StoryTableViewCell
        let story = viewModel.stories[indexPath.row]
        cell.setup(forStory: story)
        return cell
    }
}

