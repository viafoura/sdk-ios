//
//  LiveChatViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import AVKit
import UIKit
import ViafouraSDK

class LiveChatPortraitOverlayViewController: UIViewController {
    let viewModel: LiveChatViewModel

    let videoContainerView = UIView()
    let containerView = UIView()
    let closeImage = UIImageView(image: UIImage(systemName: "xmark.circle"))

    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var gradientLayer: CAGradientLayer?

    init(viewModel: LiveChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupVideo()
        setupUI()
        setupClose()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer?.frame = videoContainerView.bounds

        // The gradient and fade mask are sized from the container bounds, which are
        // only known once Auto Layout has run.
        if gradientLayer == nil, containerView.bounds.isEmpty == false {
            createGradientBackground()
        }
        gradientLayer?.frame = containerView.bounds
        containerView.layer.mask?.frame = containerView.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupLayout(){
        view.backgroundColor = .black

        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.backgroundColor = .clear
        view.addSubview(videoContainerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        view.addSubview(containerView)

        closeImage.translatesAutoresizingMaskIntoConstraints = false
        closeImage.contentMode = .scaleAspectFit
        closeImage.tintColor = .white
        view.addSubview(closeImage)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 600),

            closeImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            closeImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            closeImage.widthAnchor.constraint(equalToConstant: 35),
            closeImage.heightAnchor.constraint(equalToConstant: 35)
        ])
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
        self.gradientLayer = gradientLayer
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
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        vc.willMove(toParent: self)
        vc.didMove(toParent: self)
        
        vc.setTheme(theme: .dark)
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
        self.playerLayer = playerLayer
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
        self.present(LoginViewController(), animated: true)
    }
}
