//
//  CommentsContainerViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import UIKit
import ViafouraSDK

class CommentsContainerViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

    var viewModel: CommentsContainerViewModel!
    var settings: VFSettings!

    let darkBackgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.00)

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true {
            view.backgroundColor = darkBackgroundColor
        }
        
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        settings = VFSettings(colors: colors)
        
        addPreCommentViewController()
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
        
        guard let preCommentsViewController = VFPreviewCommentsViewController.new(containerId: viewModel.story.containerId, articleMetadata: viewModel.articleMetadata, loginDelegate: self, settings: settings, paginationSize: 10, defaultSort: .mostLiked) else {
            return
        }
        
        preCommentsViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        preCommentsViewController.setCustomUIDelegate(customUIDelegate: self)
        preCommentsViewController.setActionCallbacks(callbacks: callbacks)
        preCommentsViewController.setAdDelegate(adDelegate: self)
        preCommentsViewController.setLayoutDelegate(layoutDelegate:  self)
                
        addChild(preCommentsViewController)
        containerView.addSubview(preCommentsViewController.view)
        
        preCommentsViewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: preCommentsViewController.view.frame.height)
        
        preCommentsViewController.willMove(toParent: self)
        preCommentsViewController.didMove(toParent: self)
    }
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { type in
            switch type {
            case .notificationPressed(let presentationType):
                switch presentationType {
                case .profile(let userUUID):
                    self.presentProfileViewController(userUUID: userUUID, presentationType: .feed)
                    break
                default:
                    break
                }
            default:
                break
            }
        }
        
        guard let profileViewController = VFProfileViewController.new(userUUID: userUUID, presentationType: presentationType, loginDelegate: self, settings: settings) else{
            return
        }

        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
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
        
        guard let newCommentViewController = VFNewCommentViewController.new(newCommentActionType: actionType, containerId: viewModel.story.containerId, articleMetadata: viewModel.articleMetadata, loginDelegate: self, settings: settings) else{
            return
        }
        newCommentViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        newCommentViewController.setCustomUIDelegate(customUIDelegate: self)
        newCommentViewController.setActionCallbacks(callbacks: callbacks)
        self.present(newCommentViewController, animated: true)
    }
}

extension CommentsContainerViewController: VFAdDelegate {
    func getAdInterval(viewController: VFUIViewController) -> Int {
        return 0
    }
    
    func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView {
        return VFAdView()
    }
}

extension CommentsContainerViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}

extension CommentsContainerViewController: VFCustomUIDelegate {
    func customizeView(theme: VFTheme, view: VFCustomizableView) {
        switch view {
        case .previewBackgroundView(let view):
            if theme == .dark {
                view.backgroundColor = darkBackgroundColor
            }
            break
        default:
            break
        }
    }
}

extension CommentsContainerViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        if viewController is VFPreviewCommentsViewController {
            self.containerViewHeight.constant = height
        }
    }
}
