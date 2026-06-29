//
//  LiveQuestionsContainerViewController.swift
//  Viafoura
//

import UIKit
import ViafouraSDK

final class LiveQuestionsContainerViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var containerViewHeight: NSLayoutConstraint!
    private let liveQuestionsViewController: VFLiveQuestionsViewController

    init(liveQuestionsViewController: VFLiveQuestionsViewController) {
        self.liveQuestionsViewController = liveQuestionsViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        containerViewHeight = containerView.heightAnchor.constraint(equalToConstant: 1)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            containerViewHeight,
        ])

        liveQuestionsViewController.setLayoutDelegate(layoutDelegate: self)

        addChild(liveQuestionsViewController)
        let child = liveQuestionsViewController.view!
        child.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: containerView.topAnchor),
            child.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        liveQuestionsViewController.didMove(toParent: self)
    }
}

extension LiveQuestionsContainerViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        if viewController is VFLiveQuestionsViewController {
            containerViewHeight.constant = height
        }
    }
}
