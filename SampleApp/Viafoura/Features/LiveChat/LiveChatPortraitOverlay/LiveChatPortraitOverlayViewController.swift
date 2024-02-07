//
//  LiveChatViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import AVKit
import UIKit
import ViafouraSDK

class LiveChatPortraitOverlayViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "LiveChatPortraitOverlay"

    var viewModel: LiveChatViewModel!

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeImage: UIImageView!

    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideo()
        setupUI()
        setupClose()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupClose(){
        closeImage.isUserInteractionEnabled = true
        closeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))
    }
    
    @objc
    func closeTapped(){
        self.dismiss(animated: true)
    }
    
    func createGradientBackground(){
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor
                     
         let gradientLayer = CAGradientLayer()
         gradientLayer.colors = [colorTop, colorBottom, colorBottom]
         gradientLayer.locations = [0.0, 0.5, 1.0]
         gradientLayer.frame = self.containerView.bounds
                 
         self.containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.fadeView(style: .top, percentage: 0.1)
    }
    
    func setupUI(){
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00), colorBackground: .clear)
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
        
        vc.setTheme(theme: .dark)
        vc.setActionCallbacks(callbacks: callbacks)
        
        createGradientBackground()
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
        guard let path = Bundle.main.path(forResource: "video-example", ofType: "mp4") else {
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        
        guard let player = player else {
            return
        }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoContainerView.bounds
        self.videoContainerView.layer.addSublayer(playerLayer)
        player.isMuted = true
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        videoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTapped)))
    }

    @objc
    func videoTapped(){
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = self.containerView.alpha == 0 ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
}

extension LiveChatPortraitOverlayViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = LoginViewController.new() else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}
