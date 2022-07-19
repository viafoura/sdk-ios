//
//  ArticleViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import Foundation
import UIKit
import WebKit
import ViafouraSDK

class ArticleViewController: UIViewController {
    var articleViewModel: ArticleViewModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var commentsContainerView: UIView!
    @IBOutlet weak var commentsContainerViewHeight: NSLayoutConstraint!
        
    struct VCIdentifier {
        static let loginVC = "LoginViewController"
    }

    var settings: VFSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addPreCommentViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    func setupUI(){
        self.title = articleViewModel.story.title
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        webView.configuration.allowsInlineMediaPlayback = true
        
        webView.scrollView.isScrollEnabled = false
        webView.allowsLinkPreview = false
        webView.load(URLRequest(url: URL(string: articleViewModel.story.link)!))
        
        let fonts = VFFonts()
        let colors = VFColors(colorPrimary: UIColor(red: 1, green: 0, blue: 0, alpha: 1), colorPrimaryLight: UIColor(red: 1, green: 0.95, blue: 0.95, alpha: 1))
        settings = VFSettings(colors: colors, fonts: fonts)
    }
    
    func addPreCommentViewController(){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { type in
            switch type {
            case .writeNewCommentPressed(let actionType):
                self.presentNewCommentViewController(actionType: actionType)
            case .seeMoreCommentsPressed:
                break
            case .openProfilePressed(let userUUID):
                self.presentProfileViewController(userUUID: userUUID)
            default:
                break
            }
        }
        
        guard let preCommentsViewController = VFPreviewCommentsViewController.new(containerId: articleViewModel.story.containerId, articleMetadata: articleViewModel.articleMetadata, loginDelegate: self, settings: settings) else {
            return
        }
        
        preCommentsViewController.setCustomUIDelegate(customUIDelegate: self)
        preCommentsViewController.setActionCallbacks(callbacks: callbacks)
        preCommentsViewController.setAdDelegate(adDelegate: self)
        preCommentsViewController.setLayoutDelegate(layoutDelegate:  self)
                
        addChild(preCommentsViewController)
        commentsContainerView.addSubview(preCommentsViewController.view)
        
        preCommentsViewController.view.frame = CGRect(x: 0, y: 0, width: commentsContainerView.frame.width, height: preCommentsViewController.view.frame.height)
        
        preCommentsViewController.willMove(toParent: self)
        preCommentsViewController.didMove(toParent: self)
    }
    
    func presentProfileViewController(userUUID: UUID){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { type in
            switch type {
            default:
                break
            }
        }
        
        guard let profileViewController = VFProfileViewController.new(userUUID: userUUID, loginDelegate: self, settings: settings) else{
            return
        }
        profileViewController.setCustomUIDelegate(customUIDelegate: self)
        profileViewController.setActionCallbacks(callbacks: callbacks)
        self.present(profileViewController, animated: true)
    }
    
    
    func presentNewCommentViewController(actionType: VFNewCommentActionType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { type in
            switch type {
            default:
                break
            }
        }
        
        guard let newCommentViewController = VFNewCommentViewController.new(newCommentActionType: actionType, containerId: articleViewModel.story.containerId, articleMetadata: articleViewModel.articleMetadata, loginDelegate: self, settings: settings) else{
            return
        }
        newCommentViewController.setCustomUIDelegate(customUIDelegate: self)
        newCommentViewController.setActionCallbacks(callbacks: callbacks)
        self.present(newCommentViewController, animated: true)
    }
}

extension ArticleViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.isHidden = true
        commentsContainerView.isHidden = false
        webView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webViewHeight.constant = webView.scrollView.contentSize.height - 6000
        }
    }
}

extension ArticleViewController: WKUIDelegate{
    
}

extension ArticleViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}

extension ArticleViewController: VFCustomUIDelegate {
    func customizeView(view: VFCustomizableView) {
        switch view {
        case .postButton(let button):
            break
        default:
            break
        }
    }
}

extension ArticleViewController: VFLayoutDelegate {
    func containerHeightUpdated(height: CGFloat) {
        self.commentsContainerViewHeight.constant = height
    }
}

extension ArticleViewController: VFAdDelegate {
    func generateAd(adPosition: Int) -> UIView {
        return UIView()
    }
    
    func getAdInterval() -> Int {
        return 5
    }
}
