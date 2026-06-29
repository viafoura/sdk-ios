import SwiftUI
import WebKit
import ViafouraSDK

struct ArticleView: View {
    let story: Story
    let articleMetadata: VFArticleMetadata
    let settings: VFSettings
    let isDark: Bool
    let onOpenArticle: (String) -> Void

    @State private var webHeight: CGFloat = 1
    @State private var newCommentItem: NewCommentItem?
    @State private var profileTarget: ProfileTarget?
    @State private var showLogin = false

    private var theme: VFTheme { isDark ? .dark : .light }
    private var containerType: VFCommentsContainerType { story.storyType == .reviews ? .reviews : .conversations }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ArticleWebView(url: URL(string: story.link)!, isDark: isDark, height: $webHeight)
                    .frame(height: webHeight)

                VFPreviewCommentsView(
                    containerId: story.containerId,
                    containerType: containerType,
                    articleMetadata: articleMetadata,
                    settings: settings,
                    paginationSize: 10,
                    defaultSort: story.storyType == .reviews ? .mostLiked : .newest,
                    authorsIds: [story.authorId],
                    theme: theme,
                    autoSize: true,
                    onLogin: { showLogin = true },
                    onAction: handleAction,
                    onCustomizeView: customizeView
                )
            }
        }
        .sheet(item: $newCommentItem) { item in
            VFNewCommentView(
                actionType: item.action,
                containerType: containerType,
                containerId: story.containerId,
                articleMetadata: articleMetadata,
                settings: settings,
                theme: theme,
                onLogin: { showLogin = true },
                onCustomizeView: customizeView
            )
        }
        .sheet(item: $profileTarget) { target in
            VFProfileView(
                userUUID: target.userUUID,
                presentationType: target.presentationType,
                settings: settings,
                theme: theme,
                onLogin: { showLogin = true },
                onCustomizeView: customizeView
            )
        }
        .sheet(isPresented: $showLogin) { LoginView() }
    }

    private func handleAction(_ type: VFActionCallbackType) {
        switch type {
        case .writeNewCommentPressed(let actionType):
            newCommentItem = NewCommentItem(action: actionType)
        case .openProfilePressed(let userUUID, let presentationType):
            profileTarget = ProfileTarget(userUUID: userUUID, presentationType: presentationType)
        case .trendingArticlePressed(_, let containerId):
            onOpenArticle(containerId)
        default:
            break
        }
    }

    private func customizeView(theme: VFTheme, view: VFCustomizableView) {
        guard theme == .dark else { return }
        switch view {
        case .previewBackgroundView(let view),
             .trendingCarouselBackgroundView(let view),
             .trendingVerticalBackgroundView(let view):
            view.backgroundColor = UIColor(red: 0.16, green: 0.15, blue: 0.17, alpha: 1.0)
        default:
            break
        }
    }

    struct NewCommentItem: Identifiable {
        let id = UUID()
        let action: VFNewCommentActionType
    }

    struct ProfileTarget: Identifiable {
        let id = UUID()
        let userUUID: UUID
        let presentationType: VFProfilePresentationType
    }
}

private struct ArticleWebView: UIViewRepresentable {
    let url: URL
    let isDark: Bool
    @Binding var height: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.allowsLinkPreview = false
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ArticleWebView

        init(_ parent: ArticleWebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if parent.isDark {
                webView.evaluateJavaScript("document.documentElement.classList.add(\"dark\");")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak webView] in
                guard let webView else { return }
                let contentHeight = webView.scrollView.contentSize.height
                if abs(contentHeight - self.parent.height) > 0.5 {
                    self.parent.height = contentHeight
                }
            }
        }
    }
}

private struct LoginView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        LoginViewController.new() ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
