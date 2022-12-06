//
//  ViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import ViafouraSDK

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = HomeViewModel()
        
    struct CellIdentifier {
        static let storyCell = "storyCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getAuthState()
    }

    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
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
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
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
        guard let articleVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.articleVC) as? ArticleViewController else{
            return
        }
        
        articleVC.articleViewModel = ArticleViewModel(story: viewModel.stories[indexPath.row])
        articleVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(articleVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.storyCell) as! StoryTableViewCell
        let story = viewModel.stories[indexPath.row]
        cell.setup(forStory: story)
        return cell
    }
}

