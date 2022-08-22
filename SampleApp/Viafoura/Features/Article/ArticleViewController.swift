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
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
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
            case .openProfilePressed(let userUUID, let presentationType):
                self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
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
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { type in
            switch type {
            case .notificationPressed:
                print("Notification pressed")
            default:
                break
            }
        }
        
        guard let profileViewController = VFProfileViewController.new(userUUID: userUUID, presentationType: presentationType, loginDelegate: self, settings: settings) else{
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
            self.webViewHeight.constant = webView.scrollView.contentSize.height - 1000
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
    func generateAd(adPosition: Int) -> VFAdView {
        if articleViewModel.story.title == "Recursos públicos" {
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
            let size = GADAdSizeBanner
            
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
    
    func getAdInterval() -> Int {
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
