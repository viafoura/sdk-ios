//
//  CommentsContainerViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import UIKit
import ViafouraSDK

class CommentsContainerViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let containerView = UIView()
    var containerViewHeight: NSLayoutConstraint!

    let viewModel: CommentsContainerViewModel
    var settings: VFSettings!

    let darkBackgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.00)

    init(viewModel: CommentsContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        if UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true {
            view.backgroundColor = darkBackgroundColor
        }
        
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        settings = VFSettings(colors: colors)
        
        addPreCommentViewController()
    }
    
    func setupLayout(){
        title = "Conversation"
        view.backgroundColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        contentView.addSubview(containerView)

        containerViewHeight = containerView.heightAnchor.constraint(equalToConstant: 300)

        let contentViewHeight = contentView.heightAnchor.constraint(equalTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentViewHeight,

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerViewHeight
        ])
    }

    func addPreCommentViewController(){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            guard let strongSelf = self else {
                return
            }

            switch type {
            case .writeNewCommentPressed(let actionType):
                strongSelf.presentNewCommentViewController(actionType: actionType)
            case .seeMoreCommentsPressed:
                break
            case .openProfilePressed(let userUUID, let presentationType):
                strongSelf.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            default:
                break
            }
        }
        
        let preCommentsViewController = VFPreviewCommentsViewController.new(
            containerId: viewModel.story.containerId,
            articleMetadata: viewModel.articleMetadata,
            loginDelegate: self,
            settings: settings,
            paginationSize: 10,
            defaultSort: .newest
        )

        preCommentsViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        preCommentsViewController.setCustomUIDelegate(customUIDelegate: self)
        preCommentsViewController.setActionCallbacks(callbacks: callbacks)
        preCommentsViewController.setAdDelegate(adDelegate: self)
        preCommentsViewController.setLayoutDelegate(layoutDelegate:  self)
                
        addChild(preCommentsViewController)
        containerView.addSubview(preCommentsViewController.view)
        
        preCommentsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preCommentsViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            preCommentsViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            preCommentsViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            preCommentsViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        preCommentsViewController.willMove(toParent: self)
        preCommentsViewController.didMove(toParent: self)
    }
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            guard let strongSelf = self else {
                return
            }

            switch type {
            case .notificationPressed(let presentationType):
                switch presentationType {
                case .profile(let userUUID):
                    strongSelf.presentProfileViewController(userUUID: userUUID, presentationType: .feed)
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
        
        let newCommentViewController = VFNewCommentViewController.new(
            newCommentActionType: actionType,
            containerId: viewModel.story.containerId,
            articleMetadata: viewModel.articleMetadata,
            loginDelegate: self,
            settings: settings
        )
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
    
    func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView? {
        return VFAdView()
    }
}

extension CommentsContainerViewController: VFLoginDelegate {
    func startLogin() {
        self.present(LoginViewController(), animated: true)
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
