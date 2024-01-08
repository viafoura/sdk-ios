//
//  LiveBlogViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/03/2023.
//

import UIKit
import ViafouraSDK

class LiveBlogViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "LiveBlog"

    var viewModel: LiveBlogViewModel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var settings: VFSettings!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        settings = VFSettings(colors: colors)
        
        let callbacks: VFActionsCallbacks = { type in
            switch type {
            case .openProfilePressed(let userUUID, let presentationType):
                self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            default:
                break
            }
        }
        
        let vc = VFLiveBlogViewController.new(containerId: viewModel.story.containerId, articleMetadata: viewModel.articleMetadata, loginDelegate: self, settings: settings)
        vc.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        vc.setLayoutDelegate(layoutDelegate: self)
        vc.setActionCallbacks(callbacks: callbacks)
        
        addChild(vc)
        containerView.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: vc.view.frame.height)
        
        vc.willMove(toParent: self)
        vc.didMove(toParent: self)
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
        
        let profileViewController = VFProfileViewController.new(
            userUUID: userUUID,
            presentationType: presentationType,
            loginDelegate: self,
            settings: settings
        )

        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        profileViewController.setActionCallbacks(callbacks: callbacks)
        self.present(profileViewController, animated: true)
    }
}

extension LiveBlogViewController: VFLayoutDelegate {
    public func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        containerViewHeight.constant = height
    }
}

extension LiveBlogViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}
