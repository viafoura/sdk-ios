//
//  PollViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 19/07/2023.
//

import UIKit
import ViafouraSDK

class PollViewController: UIViewController, StoryboardCreateable {
    static var storyboardName = "Poll"

    var pollViewModel: PollViewModel!

    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        
        addPollViewController()
    }
    
    @objc
    func backgroundTapped(){
        self.dismiss(animated: true)
    }
    
    func addPollViewController(){
        let settings = VFSettings(colors: VFColors())
        let pollVC = VFPollViewController.new(contentContainerUUID: pollViewModel.poll.contentContainerUUID, loginDelegate: self, settings: settings)
        
        pollVC.setLayoutDelegate(layoutDelegate: self)
        pollVC.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        
        addChild(pollVC)
        
        containerView.addSubview(pollVC.view)
        containerView.clipsToBounds = true
        containerView.layer.cornerCurve = .continuous
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.rasterizationScale = UIScreen.main.scale
        containerView.layer.shouldRasterize = true
        
        pollVC.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: pollVC.view.frame.height)
        
        pollVC.willMove(toParent: self)
        pollVC.didMove(toParent: self)
    }
}

extension PollViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        containerViewHeight.constant = height
        
        UIView.animate(withDuration: 0.5, animations: {
             self.view.layoutIfNeeded()
        })
    }
}

extension PollViewController: VFLoginDelegate {
    func startLogin() {
        
    }
}
