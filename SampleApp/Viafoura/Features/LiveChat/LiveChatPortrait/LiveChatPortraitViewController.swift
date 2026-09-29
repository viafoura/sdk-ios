//
//  LiveChatViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import AVKit
import UIKit
import ViafouraSDK

class LiveChatPortraitViewController: UIViewController {
    let viewModel: LiveChatViewModel

    let videoContainerView = UIView()
    let liveBadgeView = UIView()
    let chatHeaderView = UIView()
    let containerView = UIView()

    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer?.frame = videoContainerView.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupLayout(){
        view.backgroundColor = .black

        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.backgroundColor = .clear
        view.addSubview(videoContainerView)

        liveBadgeView.translatesAutoresizingMaskIntoConstraints = false
        liveBadgeView.backgroundColor = .systemRed
        liveBadgeView.layer.cornerRadius = 3
        liveBadgeView.clipsToBounds = true
        view.addSubview(liveBadgeView)

        let liveLabel = UILabel()
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        liveLabel.text = "LIVE"
        liveLabel.font = .systemFont(ofSize: 17)
        liveLabel.textColor = .white
        liveBadgeView.addSubview(liveLabel)

        chatHeaderView.translatesAutoresizingMaskIntoConstraints = false
        chatHeaderView.backgroundColor = .white
        view.addSubview(chatHeaderView)

        let chatLabel = UILabel()
        chatLabel.translatesAutoresizingMaskIntoConstraints = false
        chatLabel.text = "CHAT"
        chatLabel.font = .boldSystemFont(ofSize: 17)
        chatLabel.textColor = .black
        chatHeaderView.addSubview(chatLabel)

        let liveDotView = UIView()
        liveDotView.translatesAutoresizingMaskIntoConstraints = false
        liveDotView.backgroundColor = .systemRed
        liveDotView.layer.cornerRadius = 2.5
        liveDotView.clipsToBounds = true
        chatHeaderView.addSubview(liveDotView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        view.addSubview(containerView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            videoContainerView.heightAnchor.constraint(equalTo: videoContainerView.widthAnchor, multiplier: 9.0 / 16.0),

            liveBadgeView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            liveBadgeView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            liveBadgeView.heightAnchor.constraint(equalToConstant: 30),

            liveLabel.topAnchor.constraint(equalTo: liveBadgeView.topAnchor, constant: 5),
            liveLabel.bottomAnchor.constraint(equalTo: liveBadgeView.bottomAnchor, constant: -5),
            liveLabel.leadingAnchor.constraint(equalTo: liveBadgeView.leadingAnchor, constant: 10),
            liveLabel.trailingAnchor.constraint(equalTo: liveBadgeView.trailingAnchor, constant: -10),

            chatHeaderView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            chatHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatHeaderView.heightAnchor.constraint(equalToConstant: 50),

            chatLabel.leadingAnchor.constraint(equalTo: chatHeaderView.leadingAnchor, constant: 20),
            chatLabel.centerYAnchor.constraint(equalTo: chatHeaderView.centerYAnchor),

            liveDotView.leadingAnchor.constraint(equalTo: chatLabel.trailingAnchor, constant: 10),
            liveDotView.centerYAnchor.constraint(equalTo: chatHeaderView.centerYAnchor),
            liveDotView.widthAnchor.constraint(equalToConstant: 5),
            liveDotView.heightAnchor.constraint(equalToConstant: 5),

            containerView.topAnchor.constraint(equalTo: chatHeaderView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
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
        self.present(LoginViewController(), animated: true)
    }
}
