//
//  LiveQuestionsViewController.swift
//  Viafoura
//

import UIKit
import ViafouraSDK

final class LiveQuestionsViewController: UIViewController {
    private let liveQuestions: LiveQuestions
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var containerViewHeight: NSLayoutConstraint!
    private lazy var liveQuestionsViewController = makeLiveQuestionsViewController()

    private var isDarkMode: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true
    }

    private var theme: VFTheme {
        isDarkMode ? .dark : .light
    }

    init(liveQuestions: LiveQuestions) {
        self.liveQuestions = liveQuestions
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = liveQuestions.title
        if isDarkMode {
            view.backgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.00)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Change ID",
            image: nil,
            primaryAction: UIAction { [weak self] _ in
                self?.showContainerIdAlert()
            },
            menu: nil
        )

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

private extension LiveQuestionsViewController {
    func articleMetadata() -> VFArticleMetadata {
        let storedDomain = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteDomain = (storedDomain?.isEmpty == false ? storedDomain : nil) ?? SiteDefaults.siteDomain
        let url = URL(string: "https://\(siteDomain)")!
        return VFArticleMetadata(url: url, title: "Title", subtitle: "Subtitle", thumbnailUrl: url)
    }

    func makeLiveQuestionsViewController() -> VFLiveQuestionsViewController {
        let settings = VFSettings(colors: VFColors())
        let viewController = VFLiveQuestionsViewController.new(
            containerId: liveQuestions.containerId,
            articleMetadata: articleMetadata(),
            loginDelegate: self,
            settings: settings,
            focusedContentUUID: liveQuestions.focusedContentUUID
        )

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfile(userUUID: userUUID, presentationType: presentationType)
            case .writeNewQuestionPressed(let actionType):
                self?.presentComposer(actionType: actionType)
            default:
                break
            }
        }

        viewController.setActionCallbacks(callbacks: callbacks)
        viewController.setTheme(theme: theme)

        return viewController
    }

    func presentComposer(actionType: VFNewQuestionActionType) {
        let settings = VFSettings(colors: VFColors())

        let composerViewController = VFLiveQuestionsComposerViewController.new(
            newQuestionActionType: actionType,
            containerId: liveQuestions.containerId,
            articleMetadata: articleMetadata(),
            loginDelegate: self,
            settings: settings
        )
        composerViewController.setTheme(theme: theme)

        let navigationController = UINavigationController(rootViewController: composerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        topmostPresentedViewController().present(navigationController, animated: true)
    }

    func presentProfile(userUUID: UUID, presentationType: VFProfilePresentationType) {
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        let settings = VFSettings(colors: colors)

        let profileViewController = VFProfileViewController.new(userUUID: userUUID, presentationType: presentationType, loginDelegate: self, settings: settings)
        profileViewController.setTheme(theme: theme)
        present(profileViewController, animated: true)
    }

    func topmostPresentedViewController() -> UIViewController {
        var presenter: UIViewController = self
        while let presented = presenter.presentedViewController, presented.isBeingDismissed == false {
            presenter = presented
        }
        return presenter
    }

    func showContainerIdAlert() {
        let alert = UIAlertController(title: "Live Q&A container ID", message: "Enter a container ID for Live Q&A", preferredStyle: .alert)

        alert.addTextField { [liveQuestions] textField in
            textField.placeholder = "ID"
            textField.text = liveQuestions.containerId
        }

        alert.addTextField { [liveQuestions] textField in
            textField.placeholder = "focusedContentUUID (optional)"
            textField.text = liveQuestions.focusedContentUUID?.uuidString
        }

        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self, weak alert] _ in
            guard let self else { return }
            let value = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard value.isEmpty == false else { return }

            let focusedValue = alert?.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let focusedContentUUID = UUID(uuidString: focusedValue)
            let updated = LiveQuestions(title: self.liveQuestions.title, containerId: value, focusedContentUUID: focusedContentUUID)
            self.replaceSelf(with: LiveQuestionsViewController(liveQuestions: updated))
        }))

        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func replaceSelf(with viewController: LiveQuestionsViewController) {
        guard let navigationController else { return }
        var viewControllers = navigationController.viewControllers
        if viewControllers.last === self {
            viewControllers.removeLast()
        }
        viewControllers.append(viewController)
        navigationController.setViewControllers(viewControllers, animated: false)
    }
}

extension LiveQuestionsViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        if viewController is VFLiveQuestionsViewController {
            containerViewHeight.constant = height
        }
    }
}

extension LiveQuestionsViewController: VFLoginDelegate {
    func startLogin() {
        guard let loginViewController = LoginViewController.new() else { return }
        topmostPresentedViewController().present(loginViewController, animated: true)
    }
}
