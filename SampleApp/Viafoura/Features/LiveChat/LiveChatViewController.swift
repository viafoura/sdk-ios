//
//  LiveChatViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import AVKit
import UIKit
import ViafouraSDK

class LiveChatViewController: UIViewController {
    var viewModel: LiveChatViewModel!

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideo()
        setupUI()
    }
    
    func createGradientBackground(){
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor
                     
         let gradientLayer = CAGradientLayer()
         gradientLayer.colors = [colorTop, colorBottom, colorBottom]
         gradientLayer.locations = [0.0, 0.5, 1.0]
         gradientLayer.frame = self.containerView.bounds
                 
         self.containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupUI(){
        let colors = VFColors(colorPrimary: .red, colorPrimaryLight: .red, colorBackground: .clear)
        let settings = VFSettings(colors: colors)
        guard let vc = VFLiveChatViewController.new(containerId: viewModel.containerId, articleMetadata: viewModel.articleMetadata, loginDelegate: self, settings: settings) else {
            return
        }
        
        addChild(vc)
        containerView.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        
        vc.willMove(toParent: self)
        vc.didMove(toParent: self)
        
        vc.setTheme(theme: .dark)
        
        createGradientBackground()
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
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }
}

extension LiveChatViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginVC = UIStoryboard.defaultStoryboard().instantiateViewController(withIdentifier: VCIdentifier.loginVC) as? LoginViewController else{
            return
        }
        
        self.present(loginVC, animated: true)
    }
}
