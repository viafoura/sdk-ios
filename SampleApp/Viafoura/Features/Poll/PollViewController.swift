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
    let scrollView = UIScrollView()
    var containerViewHeight: NSLayoutConstraint!
    var pollViewHeight: NSLayoutConstraint!

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

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        containerView.addSubview(scrollView)

        containerViewHeight = containerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeight.priority = .defaultHigh

        let centerY = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerY.priority = .defaultLow

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: safeArea.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -16),
            centerY,
            containerViewHeight,

            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
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
        
        scrollView.addSubview(pollVC.view)
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
        pollViewHeight = pollVC.view.heightAnchor.constraint(equalToConstant: 150)
        let content = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            pollVC.view.topAnchor.constraint(equalTo: content.topAnchor),
            pollVC.view.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            pollVC.view.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            pollVC.view.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            pollVC.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            pollViewHeight
        ])
        
        pollVC.willMove(toParent: self)
        pollVC.didMove(toParent: self)
    }
}

extension PollViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        containerViewHeight.constant = height
        pollViewHeight.constant = height
        
        UIView.animate(withDuration: 0.5, animations: {
             self.view.layoutIfNeeded()
        })
    }
}

extension PollViewController: VFLoginDelegate {
    func startLogin() {
        
    }
}
