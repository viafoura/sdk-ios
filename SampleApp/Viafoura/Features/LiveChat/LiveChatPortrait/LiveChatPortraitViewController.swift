//
//  LiveChatViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import AVKit
import UIKit
import ViafouraSDK

class LiveChatPortraitViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "LiveChatPortrait"

    var viewModel: LiveChatViewModel!

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!

    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideo()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI(){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        let settings = VFSettings(colors: colors)
        
        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            default:
                break
            }
        }
        
        let vc = VFLiveChatViewController.new(
            containerId: viewModel.containerId,
            articleMetadata: viewModel.articleMetadata,
            loginDelegate: self,
            settings: settings
        )
        
        addChild(vc)
        containerView.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        
        vc.willMove(toParent: self)
        vc.didMove(toParent: self)
        
        vc.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        vc.setActionCallbacks(callbacks: callbacks)
    }
    
    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        let settings = VFSettings(colors: colors)
        let profileViewController = VFProfileViewController.new(
            userUUID: userUUID,
            presentationType: presentationType,
            loginDelegate: self,
            settings: settings
        )
        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        self.present(profileViewController, animated: true)
    }
    
    func setupVideo(){
        guard let path = Bundle.main.path(forResource: "video-cnn", ofType: "mp4") else {
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        
        guard let player = player else {
            return
        }
        
        self.videoContainerViewHeight.constant = view.frame.width / (16 / 9)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoContainerView.bounds
        self.videoContainerView.layer.addSublayer(playerLayer)
        player.isMuted = true
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension LiveChatPortraitViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}
