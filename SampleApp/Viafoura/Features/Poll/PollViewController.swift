//
//  PollViewController.swift
//  Viafoura
//
//  Created by Martin De Simone on 19/07/2023.
//

import UIKit
import ViafouraSDK

class PollViewController: UIViewController {
    let pollViewModel: PollViewModel

    let backgroundView = UIView()
    let containerView = UIView()
    var containerViewHeight: NSLayoutConstraint!

    init(viewModel: PollViewModel) {
        self.pollViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        
        addPollViewController()
    }

    func setupLayout(){
        view.backgroundColor = .clear

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.4
        view.addSubview(backgroundView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        view.addSubview(containerView)

        containerViewHeight = containerView.heightAnchor.constraint(equalToConstant: 150)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerViewHeight
        ])
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
        
        pollVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pollVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pollVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pollVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pollVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
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
