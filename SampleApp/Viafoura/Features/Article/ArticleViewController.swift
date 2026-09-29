import Foundation
import UIKit
import Kingfisher
import ViafouraSDK
import GoogleMobileAds

class ArticleViewController: UIViewController {
    let articleViewModel: ArticleViewModel
    
    let scrollView = UIScrollView()
    let contentStackView = UIStackView()

    let pictureImageView = UIImageView()
    let categoryLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let authorLabel = UILabel()
    
    let conversationStarterContainerView = UIView()
    var conversationStarterContainerViewHeight: NSLayoutConstraint!

    let commentsContainerView = UIView()
    var commentsContainerViewHeight: NSLayoutConstraint!

    var settings: VFSettings?
    
    let darkBackgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.00)

    init(viewModel: ArticleViewModel) {
        self.articleViewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupUI()
        addComponents()
    }

    func setupLayout(){
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 0
        scrollView.addSubview(contentStackView)

        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.clipsToBounds = true
        contentStackView.addArrangedSubview(pictureImageView)

        categoryLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        categoryLabel.textColor = AppStyle.tintColor
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 20)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        authorLabel.font = .systemFont(ofSize: 15, weight: .medium)
        authorLabel.textColor = .secondaryLabel

        let headerStackView = UIStackView(arrangedSubviews: [categoryLabel, titleLabel, descriptionLabel, authorLabel])
        headerStackView.axis = .vertical
        headerStackView.spacing = 8
        headerStackView.setCustomSpacing(12, after: descriptionLabel)
        headerStackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        contentStackView.addArrangedSubview(headerStackView)

        contentStackView.addArrangedSubview(makeBodyStackView(blocks: ArticleContent.blocks.prefix(ArticleContent.engagementStarterIndex)))

        conversationStarterContainerView.translatesAutoresizingMaskIntoConstraints = false
        conversationStarterContainerView.backgroundColor = .clear
        contentStackView.addArrangedSubview(conversationStarterContainerView)

        contentStackView.addArrangedSubview(makeBodyStackView(blocks: ArticleContent.blocks.dropFirst(ArticleContent.engagementStarterIndex)))

        commentsContainerView.translatesAutoresizingMaskIntoConstraints = false
        commentsContainerView.backgroundColor = .clear
        contentStackView.addArrangedSubview(commentsContainerView)
        contentStackView.setCustomSpacing(24, after: contentStackView.arrangedSubviews[contentStackView.arrangedSubviews.count - 2])

        conversationStarterContainerViewHeight = conversationStarterContainerView.heightAnchor.constraint(equalToConstant: 0)
        commentsContainerViewHeight = commentsContainerView.heightAnchor.constraint(equalToConstant: 0)

        let safeArea = view.safeAreaLayoutGuide
        let content = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            contentStackView.topAnchor.constraint(equalTo: content.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -100),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            pictureImageView.heightAnchor.constraint(equalTo: pictureImageView.widthAnchor, multiplier: 0.5),

            conversationStarterContainerViewHeight,
            commentsContainerViewHeight
        ])
    }

    private func makeBodyStackView(blocks: ArraySlice<ArticleContent.Block>) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)

        for block in blocks {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = .label
            switch block {
            case .heading(let text):
                label.text = text
                label.font = .systemFont(ofSize: 22, weight: .semibold)
            case .paragraph(let text):
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                label.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.label])
            }
            stackView.addArrangedSubview(label)
        }

        return stackView
    }
    
    func addComponents(){
        addConversationStarterViewController()

        if UserDefaults.standard.bool(forKey: SettingsKeys.commentsContainerFullscreen) == true {
            commentsContainerViewHeight.constant = 120
            
            let button = UIButton()
            button.setTitle("See comments", for: .normal)
            button.backgroundColor = .red
            button.layer.cornerRadius = 4
            button.clipsToBounds = true
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeCommentsTapped)))
            button.translatesAutoresizingMaskIntoConstraints = false
            
            commentsContainerView.addSubview(button)

            button.widthAnchor.constraint(equalToConstant: 250).isActive = true
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            button.centerXAnchor.constraint(equalTo: self.commentsContainerView.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: self.commentsContainerView.centerYAnchor).isActive = true
        } else {
            addPreCommentViewController()
        }
    }
    
    @objc
    func seeCommentsTapped(){
        presentCommentsContainerViewController()
    }
    
    func setupUI(){
        if UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true {
            view.backgroundColor = darkBackgroundColor
        }

        let story = articleViewModel.story
        self.title = story.title
        pictureImageView.kf.setImage(with: URL(string: story.pictureUrl))
        categoryLabel.text = story.category
        titleLabel.text = story.title
        descriptionLabel.text = story.description
        authorLabel.text = "By \(story.author)"
        
        let colors = VFColors(colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00), colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00))
        settings = VFSettings(colors: colors)
    }
    
    func addConversationStarterViewController(){
        guard let settings = settings else {
            return
        }

        let conversationStarterViewController = VFConversationStarterViewController.new(
            containerId: articleViewModel.story.containerId,
            articleMetadata: articleViewModel.articleMetadata,
            loginDelegate: self,
            settings: settings
        )

        conversationStarterViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        conversationStarterViewController.setCustomUIDelegate(customUIDelegate: self)
        conversationStarterViewController.setLayoutDelegate(layoutDelegate: self)
        conversationStarterViewController.setActionCallbacks(callbacks: conversationStarterCallbacks())

        addChild(conversationStarterViewController)
        conversationStarterContainerView.addSubview(conversationStarterViewController.view)

        // Pinned rather than manually framed so the widget resizes with the container
        // as it reports its measured height back through the layout delegate.
        conversationStarterViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            conversationStarterViewController.view.topAnchor.constraint(equalTo: conversationStarterContainerView.topAnchor),
            conversationStarterViewController.view.bottomAnchor.constraint(equalTo: conversationStarterContainerView.bottomAnchor),
            conversationStarterViewController.view.leadingAnchor.constraint(equalTo: conversationStarterContainerView.leadingAnchor),
            conversationStarterViewController.view.trailingAnchor.constraint(equalTo: conversationStarterContainerView.trailingAnchor)
        ])

        conversationStarterViewController.willMove(toParent: self)
        conversationStarterViewController.didMove(toParent: self)
    }

    private func conversationStarterCallbacks() -> VFActionsCallbacks {
        return { [weak self] type in
            switch type {
            case .seeMoreCommentsPressed:
                self?.conversationStarterActionPressed()
            case .writeNewCommentPressed(let actionType):
                self?.presentNewCommentViewController(actionType: actionType)
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            case .authPressed:
                self?.startLogin()
            default:
                break
            }
        }
    }

    // The web widget scrolls the page to its target element. On mobile the host owns
    // navigation, so scroll to the inline comments or open the fullscreen container.
    private func conversationStarterActionPressed(){
        if UserDefaults.standard.bool(forKey: SettingsKeys.commentsContainerFullscreen) == true {
            presentCommentsContainerViewController()
            return
        }

        let originY = scrollView.convert(CGPoint.zero, from: commentsContainerView).y
        scrollView.setContentOffset(CGPoint(x: 0, y: originY), animated: true)
    }

    func addPreCommentViewController(){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .writeNewCommentPressed(let actionType):
                self?.presentNewCommentViewController(actionType: actionType)
            case .seeMoreCommentsPressed:
                break
            case .openProfilePressed(let userUUID, let presentationType):
                self?.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
            case .trendingArticlePressed(let metadata, let containerId):
                self?.presentArticle(containerId: containerId, contentUUID: nil)
            default:
                break
            }
        }
        
        let preCommentsViewController = VFPreviewCommentsViewController.new(
            containerId: articleViewModel.story.containerId,
            containerType: articleViewModel.story.storyType == .reviews ? .reviews : .conversations,
            articleMetadata: articleViewModel.articleMetadata,
            loginDelegate: self,
            settings: settings,
            paginationSize: 10,
            defaultSort: articleViewModel.story.storyType == .reviews ? .mostLiked : .newest,
            focusedContentUUID: articleViewModel.focusedContentUUID
        )
        
        preCommentsViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        preCommentsViewController.setCustomUIDelegate(customUIDelegate: self)
        preCommentsViewController.setActionCallbacks(callbacks: callbacks)
        preCommentsViewController.setAdDelegate(adDelegate: self)
        preCommentsViewController.setLayoutDelegate(layoutDelegate: self)
        preCommentsViewController.setAuthorsIds(authors: [articleViewModel.story.authorId] )

        if let contentUUID = articleViewModel.selectedContentUUID {
            preCommentsViewController.getContentScrollPosition(contentUUID: contentUUID, completion: { [weak self] yPosition in
                guard let strongSelf = self else {
                    return
                }

                let originY = strongSelf.scrollView.convert(CGPoint.zero, from: strongSelf.commentsContainerView).y
                strongSelf.scrollView.setContentOffset(CGPoint(x: 0, y: originY + yPosition), animated: true)
            })
        }

        addChild(preCommentsViewController)
        commentsContainerView.addSubview(preCommentsViewController.view)
        
        preCommentsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preCommentsViewController.view.topAnchor.constraint(equalTo: commentsContainerView.topAnchor),
            preCommentsViewController.view.bottomAnchor.constraint(equalTo: commentsContainerView.bottomAnchor),
            preCommentsViewController.view.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor),
            preCommentsViewController.view.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor)
        ])
        
        preCommentsViewController.willMove(toParent: self)
        preCommentsViewController.didMove(toParent: self)
    }

    func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .notificationPressed(let presentationType):
                switch presentationType {
                case .profile(let userUUID):
                    self?.presentProfileViewController(userUUID: userUUID, presentationType: .feed)
                    break
                case .content(let containerUUID, let contentUUID, let containerId, let metadata):
                    self?.presentArticle(containerId: containerId, contentUUID: contentUUID)
                    break
                default:
                    break
                }
            default:
                break
            }
        }
        
        let profileViewController = VFProfileViewController.new(
            userUUID: userUUID,
            presentationType: presentationType,
            loginDelegate: self,
            settings: settings
        )
        profileViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        profileViewController.setCustomUIDelegate(customUIDelegate: self)
        profileViewController.setActionCallbacks(callbacks: callbacks)
        self.present(profileViewController, animated: true)
    }
    
    func presentArticle(containerId: String, contentUUID: UUID?){
        if let content = defaultContents.filter({ $0.story?.containerId == containerId }).first, let story = content.story {
            let viewModel = ArticleViewModel(story: story)
            viewModel.selectedContentUUID = contentUUID
            let articleVC = ArticleViewController(viewModel: viewModel)
            articleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(articleVC, animated: true)
        }
    }
    
    func presentNewCommentViewController(actionType: VFNewCommentActionType){
        guard let settings = settings else {
            return
        }

        let callbacks: VFActionsCallbacks = { [weak self] type in
            switch type {
            case .commentPosted(let contentUUID):
                break
            default:
                break
            }
        }
        
        let newCommentViewController = VFNewCommentViewController.new(
            newCommentActionType: actionType,
            containerType: articleViewModel.story.storyType == .reviews ? .reviews : .conversations,
            containerId: articleViewModel.story.containerId,
            articleMetadata: articleViewModel.articleMetadata,
            loginDelegate: self,
            settings: settings
        )
        newCommentViewController.setTheme(theme: UserDefaults.standard.bool(forKey: SettingsKeys.darkMode) == true ? .dark : .light)
        newCommentViewController.setCustomUIDelegate(customUIDelegate: self)
        newCommentViewController.setActionCallbacks(callbacks: callbacks)
        self.present(newCommentViewController, animated: true)
    }
    
    func presentCommentsContainerViewController(){
        let commentsVC = CommentsContainerViewController(viewModel: CommentsContainerViewModel(story: articleViewModel.story))
        
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }

}

extension ArticleViewController: VFLoginDelegate {
    func startLogin() {
        self.present(LoginViewController(), animated: true)
    }
}

extension ArticleViewController: VFCustomUIDelegate {
    func customizeView(theme: VFTheme, view: VFCustomizableView) {
        switch view {
        case .previewBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        case .trendingCarouselBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        case .trendingVerticalBackgroundView(let view):
            if theme == VFTheme.dark {
                view.backgroundColor = darkBackgroundColor
            }
        default:
            break
        }
    }
}

extension ArticleViewController: VFLayoutDelegate {
    func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
        if viewController is VFPreviewCommentsViewController {
            self.commentsContainerViewHeight.constant = height
        }

        if viewController is VFConversationStarterViewController {
            self.conversationStarterContainerViewHeight.constant = height
        }
    }
}

extension ArticleViewController: VFAdDelegate {
    func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView? {
        if false {
            let adView = VFAdView()
            adView.translatesAutoresizingMaskIntoConstraints = false

            let adSponsoredLabel = UILabel()
            let adTitleLabel = UILabel()
            let adDescLabel = UILabel()
            let adImage = UIImageView()
            let adIndicatorImage = UIImageView()
            let adIndicatorLabel = UILabel()

            adTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            adTitleLabel.text = "Autos Nuevos | Enlaces Publicitarios"
            adTitleLabel.textColor = .black
            adTitleLabel.font = UIFont.boldSystemFont(ofSize: 13)
            adTitleLabel.numberOfLines = 0
            
            adDescLabel.translatesAutoresizingMaskIntoConstraints = false
            adDescLabel.text = "Ushuaia: Los autos sin vender de 2021 casi se regalan"
            adDescLabel.font = UIFont.systemFont(ofSize: 11)
            adDescLabel.textColor = .gray
            adDescLabel.numberOfLines = 0
            
            adSponsoredLabel.translatesAutoresizingMaskIntoConstraints = false
            adSponsoredLabel.text = "Sponsored"
            adSponsoredLabel.font = UIFont.boldSystemFont(ofSize: 11)
            adSponsoredLabel.textColor = UIColor(red: 0.33, green: 0.71, blue: 0.35, alpha: 1.00)
            
            adIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
            adIndicatorLabel.text = "AD"
            adIndicatorLabel.textColor = .white
            adIndicatorLabel.font = UIFont.boldSystemFont(ofSize: 13)
            
            adImage.translatesAutoresizingMaskIntoConstraints = false
            adImage.kf.setImage(with: URL(string: "https://images.outbrainimg.com/transform/v3/eyJpdSI6IjYwNjA2OWRiMjFiZTc0ODAyOWEzZDAwYTczM2E2YjkxNzM2ZWZmODczYWQ5NjcyMzQzN2YxOGU2YTJhYmQ3NGYiLCJ3IjozNzUsImgiOjEyNSwiZCI6MS41LCJjcyI6MCwiZiI6NH0.webp"))
            adImage.layer.cornerRadius = 4
            adImage.clipsToBounds = true
            
            let adIndicatorImageSize = 40.0
            adIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
            adIndicatorImage.backgroundColor = .lightGray
            adIndicatorImage.heightAnchor.constraint(equalToConstant: adIndicatorImageSize).isActive = true
            adIndicatorImage.widthAnchor.constraint(equalToConstant: adIndicatorImageSize).isActive = true
            adIndicatorImage.layer.cornerRadius = adIndicatorImageSize / 2
            adIndicatorImage.clipsToBounds = true
            adIndicatorImage.layer.masksToBounds = true
            
            adView.addSubview(adIndicatorImage)
            adView.addSubview(adTitleLabel)
            adView.addSubview(adDescLabel)
            adView.addSubview(adSponsoredLabel)
            adView.addSubview(adImage)
            adView.addSubview(adIndicatorLabel)

            adIndicatorLabel.centerYAnchor.constraint(equalTo: adIndicatorImage.centerYAnchor).isActive = true
            adIndicatorLabel.centerXAnchor.constraint(equalTo: adIndicatorImage.centerXAnchor).isActive = true
            
            adSponsoredLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 5).isActive = true
            adSponsoredLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true

            adIndicatorImage.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 5).isActive = true
            adIndicatorImage.topAnchor.constraint(equalTo: adView.topAnchor, constant: 5).isActive = true
            
            adTitleLabel.topAnchor.constraint(equalTo: adSponsoredLabel.bottomAnchor, constant: 5).isActive = true
            adTitleLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adTitleLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true

            adDescLabel.topAnchor.constraint(equalTo: adTitleLabel.bottomAnchor, constant: 5).isActive = true
            adDescLabel.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adDescLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true

            adImage.topAnchor.constraint(equalTo: adDescLabel.bottomAnchor, constant: 10).isActive = true
            adImage.heightAnchor.constraint(equalToConstant: 120).isActive = true
            adImage.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -10).isActive = true
            adImage.leadingAnchor.constraint(equalTo: adIndicatorImage.trailingAnchor, constant: 20).isActive = true
            adImage.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20).isActive = true
            
            return adView
        } else {
            let size = GADAdSizeMediumRectangle
            
            let adView = VFAdView()
            adView.translatesAutoresizingMaskIntoConstraints = false
            adView.heightAnchor.constraint(equalToConstant: size.size.height).isActive = true

            let bannerView = GAMBannerView(adSize: size)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerView.adUnitID = "/6499/example/banner"
            bannerView.rootViewController = self
            bannerView.delegate = self
            adView.addSubview(bannerView)
            
            bannerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            bannerView.load(GAMRequest())
            return adView
        }
    }
    
    func getFirstAdPosition(viewController: VFUIViewController) -> Int {
        return 4
    }
    
    func getAdInterval(viewController: VFUIViewController) -> Int {
        return 5
    }
}

extension ArticleViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
