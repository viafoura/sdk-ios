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
import GoogleMobileAds

class ArticleViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "Article"

    var articleViewModel: ArticleViewModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var commentsContainerView: UIView!
    @IBOutlet weak var commentsContainerViewHeight: NSLayoutConstraint!

    var settings: VFSettings?
    
    let darkBackgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.00)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func addComponents(){
        if UserDefaults.standard.bool(forKey: SettingsKeys.commentsContainerFullscreen) == true {
            commentsContainerViewHeight.constant = 120
            
            let button = UIButton()
            button.setTitle("See comments", for: .normal)
            button.backgroundColor = .red
            button.layer.cornerRadius = 4
            button.clipsToBounds = true
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeCommentsTapped)))
            button.translatesAutoresizingMaskIntoConstraints = false
            
            commentsContainerView.addSubview(button)

            button.widthAnchor.constraint(equalToConstant: 250).isActive = true
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            button.centerXAnchor.constraint(equalTo: self.commentsContainerView.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: self.commentsContainerView.centerYAnchor).isActive = true
        } else {
            addPreCommentViewController()
        }
    }
    
    @objc
    func seeCommentsTapped(){
        presentCommentsContainerViewController()
    }
    
    func setupUI(){
        if UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true {
            view.backgroundColor = darkBackgroundColor
        }

        self.title = articleViewModel.story.title
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        webView.configuration.allowsInlineMediaPlayback = true

        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "messageHandler")
        
        webView.scrollView.isScrollEnabled = false
        webView.allowsLinkPreview = false
        webView.load(URLRequest(url: URL(string: articleViewModel.story.link)!))
        
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        settings = VFSettings(colors: colors)
    }
    
    func addPreCommentViewController(){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .writeNewCommentPressed(let actionType):
                self?.presentNewCommentViewController(actionType: actionType)
            case .seeMoreCommentsPressed:
                break
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            case .trendingArticlePressed(let metadata, let containerId):
                self?.presentArticle(containerId: containerId, contentUUID: nil)
            default:
                break
            }
        }
        
        let preCommentsViewController = VFPreviewCommentsViewController.new(
            containerId: articleViewModel.story.containerId,
            containerType: articleViewModel.story.storyType == .reviews ? .reviews : .conversations,
            articleMetadata: articleViewModel.articleMetadata,
            loginDelegate: self,
            settings: settings,
            paginationSize: 10,
            defaultSort: articleViewModel.story.storyType == .reviews ? .mostLiked : .newest
        )
        
        preCommentsViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        preCommentsViewController.setCustomUIDelegate(customUIDelegate: self)
        preCommentsViewController.setActionCallbacks(callbacks: callbacks)
        preCommentsViewController.setAdDelegate(adDelegate: self)
        preCommentsViewController.setLayoutDelegate(layoutDelegate: self)
        preCommentsViewController.setAuthorsIds(authors: [articleViewModel.story.authorId] )

        if let contentUUID = articleViewModel.selectedContentUUID {
            preCommentsViewController.getContentScrollPosition(contentUUID: contentUUID, completion: { [weak self] yPosition in
                guard let strongSelf = self else {
                    return
                }

                let originY = strongSelf.scrollView.convert(CGPoint.zero, from: strongSelf.commentsContainerView).y
                strongSelf.scrollView.setContentOffset(CGPoint(x: 0, y: originY + yPosition), animated: true)
            })
        }

        addChild(preCommentsViewController)
        commentsContainerView.addSubview(preCommentsViewController.view)
        
        preCommentsViewController.view.frame = CGRect(x: 0, y: 0, width: commentsContainerView.frame.width, height: preCommentsViewController.view.frame.height)
        
        preCommentsViewController.willMove(toParent: self)
        preCommentsViewController.didMove(toParent: self)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if navigationAction.request.url?.absoluteString == articleViewModel.story.link {
            return .allow
        }
        
        return .cancel
    }
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .notificationPressed(let presentationType):
                switch presentationType {
                case .profile(let userUUID):
                    self?.presentProfileViewController(userUUID: userUUID, presentationType: .feed)
                    break
                case .content(let containerUUID, let contentUUID, let containerId):
                    self?.presentArticle(containerId: containerId, contentUUID: contentUUID)
                    break
                }
            default:
                break
            }
        }
        
        let profileViewController = VFProfileViewController.new(
            userUUID: userUUID,
            presentationType: presentationType,
            loginDelegate: self,
            settings: settings
        )
        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        profileViewController.setCustomUIDelegate(customUIDelegate: self)
        profileViewController.setActionCallbacks(callbacks: callbacks)
        self.present(profileViewController, animated: true)
    }
    
    func presentArticle(containerId: String, contentUUID: UUID?){
        guard let articleVC = ArticleViewController.new() else{
            return
        }
        
        if let content = defaultContents.filter({ $0.story?.containerId == containerId }).first, let story = content.story {
            articleVC.articleViewModel = ArticleViewModel(story: story)
            articleVC.articleViewModel.selectedContentUUID = contentUUID
            articleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(articleVC, animated: true)
        }
    }
    
    func presentNewCommentViewController(actionType: VFNewCommentActionType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .commentPosted(let contentUUID):
                break
            default:
                break
            }
        }
        
        let newCommentViewController = VFNewCommentViewController.new(
            newCommentActionType: actionType,
            containerType: articleViewModel.story.storyType == .reviews ? .reviews : .conversations,
            containerId: articleViewModel.story.containerId,
            articleMetadata: articleViewModel.articleMetadata,
            loginDelegate: self,
            settings: settings
        )
        newCommentViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        newCommentViewController.setCustomUIDelegate(customUIDelegate: self)
        newCommentViewController.setActionCallbacks(callbacks: callbacks)
        self.present(newCommentViewController, animated: true)
    }
    
    func presentCommentsContainerViewController(){
        guard let commentsVC = CommentsContainerViewController.new() else{
            return
        }
        commentsVC.viewModel = CommentsContainerViewModel(story: articleViewModel.story)
        
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }

    func addEngagementStarterListener(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.webView.evaluateJavaScript("""
             setTimeout(function() {
                                    document.querySelector('.vf-conversation-starter_link').onclick = function() {
                                       if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.messageHandler) {
                                            window.webkit.messageHandlers.messageHandler.postMessage({
                                                "action": "ENGAGEMENT_STARTER_CLICKED"
                                            });
                                        }
                                    };
            }, 2000);
            """)
        }
    }
}

extension ArticleViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.isHidden = true
        commentsContainerView.isHidden = false
        webView.isHidden = false
        
        if UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true {
            webView.evaluateJavaScript("document.documentElement.classList.add(\"dark\");")
        }

        addEngagementStarterListener()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webViewHeight.constant = webView.scrollView.contentSize.height
            self.view.layoutIfNeeded()
            
            self.addComponents()
        }
    }
}

extension ArticleViewController: WKUIDelegate{
    
}

extension ArticleViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}

extension ArticleViewController: VFCustomUIDelegate {
    func customizeView(theme: VFTheme, view: VFCustomizableView) {
        switch view {
        case .previewBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        case .trendingCarouselBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        case .trendingVerticalBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        default:
            break
        }
    }
}

extension ArticleViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        if viewController is VFPreviewCommentsViewController {
            self.commentsContainerViewHeight.constant = height
        }
    }
}

extension ArticleViewController: VFAdDelegate {
    func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView {
        if false {
            let adView = VFAdView()
            adView.translatesAutoresizingMaskIntoConstraints = false

            let adSponsoredLabel = UILabel()
            let adTitleLabel = UILabel()
            let adDescLabel = UILabel()
            let adImage = UIImageView()
            let adIndicatorImage = UIImageView()
            let adIndicatorLabel = UILabel()

            adTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            adTitleLabel.text = "Autos Nuevos | Enlaces Publicitarios"
            adTitleLabel.textColor = .black
            adTitleLabel.font = UIFont.boldSystemFont(ofSize: 13)
            adTitleLabel.numberOfLines = 0
            
            adDescLabel.translatesAutoresizingMaskIntoConstraints = false
            adDescLabel.text = "Ushuaia: Los autos sin vender de 2021 casi se regalan"
            adDescLabel.font = UIFont.systemFont(ofSize: 11)
            adDescLabel.textColor = .gray
            adDescLabel.numberOfLines = 0
            
            adSponsoredLabel.translatesAutoresizingMaskIntoConstraints = false
            adSponsoredLabel.text = "Sponsored"
            adSponsoredLabel.font = UIFont.boldSystemFont(ofSize: 11)
            adSponsoredLabel.textColor = UIColor(red: 0.33, green: 0.71, blue: 0.35, alpha: 1.00)
            
            adIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
            adIndicatorLabel.text = "AD"
            adIndicatorLabel.textColor = .white
            adIndicatorLabel.font = UIFont.boldSystemFont(ofSize: 13)
            
            adImage.translatesAutoresizingMaskIntoConstraints = false
            adImage.kf.setImage(with: URL(string: "https://images.outbrainimg.com/transform/v3/eyJpdSI6IjYwNjA2OWRiMjFiZTc0ODAyOWEzZDAwYTczM2E2YjkxNzM2ZWZmODczYWQ5NjcyMzQzN2YxOGU2YTJhYmQ3NGYiLCJ3IjozNzUsImgiOjEyNSwiZCI6MS41LCJjcyI6MCwiZiI6NH0.webp"))
            adImage.layer.cornerRadius = 4
            adImage.clipsToBounds = true
            
            let adIndicatorImageSize = 40.0
            adIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
            adIndicatorImage.backgroundColor = .lightGray
            adIndicatorImage.heightAnchor.constraint(equalToConstant: adIndicatorImageSize).isActive = true
            adIndicatorImage.widthAnchor.constraint(equalToConstant: adIndicatorImageSize).isActive = true
            adIndicatorImage.layer.cornerRadius = adIndicatorImageSize / 2
            adIndicatorImage.clipsToBounds = true
            adIndicatorImage.layer.masksToBounds = true
            
            adView.addSubview(adIndicatorImage)
            adView.addSubview(adTitleLabel)
            adView.addSubview(adDescLabel)
            adView.addSubview(adSponsoredLabel)
            adView.addSubview(adImage)
            adView.addSubview(adIndicatorLabel)

            adIndicatorLabel.centerYAnchor.constraint(equalTo: adIndicatorImage.centerYAnchor).isActive = true
            adIndicatorLabel.centerXAnchor.constraint(equalTo: adIndicatorImage.centerXAnchor).isActive = true
            
            adSponsoredLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 5).isActive = true
            adSponsoredLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true

            adIndicatorImage.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 5).isActive = true
            adIndicatorImage.topAnchor.constraint(equalTo: adView.topAnchor, constant: 5).isActive = true
            
            adTitleLabel.topAnchor.constraint(equalTo: adSponsoredLabel.bottomAnchor, constant: 5).isActive = true
            adTitleLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adTitleLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true

            adDescLabel.topAnchor.constraint(equalTo: adTitleLabel.bottomAnchor, constant: 5).isActive = true
            adDescLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adDescLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true

            adImage.topAnchor.constraint(equalTo: adDescLabel.bottomAnchor, constant: 10).isActive = true
            adImage.heightAnchor.constraint(equalToConstant: 120).isActive = true
            adImage.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -10).isActive = true
            adImage.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adImage.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true
            
            return adView
        } else {
            let size = GADAdSizeMediumRectangle
            
            let adView = VFAdView()
            adView.translatesAutoresizingMaskIntoConstraints = false
            adView.heightAnchor.constraint(equalToConstant: size.size.height).isActive = true

            let bannerView = GAMBannerView(adSize: size)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerView.adUnitID = "/6499/example/banner"
            bannerView.rootViewController = self
            bannerView.delegate = self
            adView.addSubview(bannerView)
            
            bannerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            bannerView.load(GAMRequest())
            return adView
        }
    }
    
    func getFirstAdPosition(viewController: VFUIViewController) -> Int {
        return 4
    }
    
    func getAdInterval(viewController: VFUIViewController) -> Int {
        return 5
    }
}

extension ArticleViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}

extension ArticleViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String : AnyObject] else {
            return
        }
        
        if data["action"] as? String == "ENGAGEMENT_STARTER_CLICKED" {
            let originY = scrollView.convert(CGPoint.zero, from: commentsContainerView).y
            scrollView.setContentOffset(CGPoint(x: 0, y: originY), animated: true)
        }
    }
}
