//
//  BookmarksViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation
import UIKit
import ViafouraSDK

class BookmarksViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = BookmarksViewModel()
    
    struct VCIdentifier {
        static let loginVC = "LoginViewController"
    }
    
    struct CellIdentifier {
        static let bookmarkCell = "bookmarkCell"
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

extension BookmarksViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}

extension BookmarksViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = viewModel.bookmarks[indexPath.row]
        let metadata = VFArticleMetadata(url: URL(string: "https://www.viafoura-mobile-demo.vercel.app")!, title: bookmark.title, subtitle: "Summar", thumbnailUrl: URL(string: "https://www.viafoura-mobile-demo.vercel.app")!)
        let settings = VFSettings(colors: VFColors())
        guard let vc = VFLiveChatViewController.new(containerId: bookmark.title, articleMetadata: metadata, loginDelegate: self, settings: settings) else {
            return
        }
        vc.title = bookmark.title
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BookmarksViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.bookmarkCell) as! BookmarksTableViewCell
        cell.setup(forBookmark: viewModel.bookmarks[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }
    
}
