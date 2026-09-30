import SwiftUI
import Kingfisher
import ViafouraSDK

struct ArticleView: View {
    let story: Story
    let articleMetadata: VFArticleMetadata
    let settings: VFSettings
    let isDark: Bool
    let onOpenArticle: (String) -> Void
    var focusedContentUUID: UUID? = nil

    @State private var newCommentItem: NewCommentItem?
    @State private var profileTarget: ProfileTarget?
    @State private var showLogin = false

    private static let commentsAnchor = "comments"

    private var theme: VFTheme { isDark ? .dark : .light }
    private var containerType: VFCommentsContainerType { story.storyType == .reviews ? .reviews : .conversations }

    private var bodyBeforeEngagementStarter: ArraySlice<ArticleContent.Block> { ArticleContent.blocks.prefix(ArticleContent.engagementStarterIndex) }
    private var bodyAfterEngagementStarter: ArraySlice<ArticleContent.Block> { ArticleContent.blocks.dropFirst(ArticleContent.engagementStarterIndex) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    articleBlocks(bodyBeforeEngagementStarter)

                    VFConversationStarterView(
                        containerId: story.containerId,
                        articleMetadata: articleMetadata,
                        settings: settings,
                        theme: theme,
                        onLogin: { showLogin = true },
                        onAction: { action in
                            if case .seeMoreCommentsPressed = action {
                                withAnimation { proxy.scrollTo(Self.commentsAnchor, anchor: .top) }
                            } else {
                                handleAction(action)
                            }
                        },
                        onCustomizeView: customizeView
                    )
                    .padding(.vertical, 16)

                    articleBlocks(bodyAfterEngagementStarter)

                    VFPreviewCommentsView(
                        containerId: story.containerId,
                        containerType: containerType,
                        articleMetadata: articleMetadata,
                        settings: settings,
                        paginationSize: 10,
                        defaultSort: story.storyType == .reviews ? .mostLiked : .newest,
                        authorsIds: [story.authorId],
                        focusedContentUUID: focusedContentUUID,
                        theme: theme,
                        autoSize: true,
                        onLogin: { showLogin = true },
                        onAction: handleAction,
                        onCustomizeView: customizeView
                    )
                    .padding(.top, 24)
                    .id(Self.commentsAnchor)
                }
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            KFImage(URL(string: story.pictureUrl))
                .resizable()
                .aspectRatio(2, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(story.category)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(AppStyle.tintColor))

                Text(story.title)
                    .font(.title.weight(.bold))
                    .foregroundColor(.primary)

                Text(story.description)
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text("By \(story.author)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    private func articleBlocks(_ blocks: ArraySlice<ArticleContent.Block>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading(let text):
                    Text(text)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                case .paragraph(let text):
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
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
             .conversationStarterBackgroundView(let view),
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

private struct LoginView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        LoginViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

enum ArticleContent {
    enum Block {
        case heading(String)
        case paragraph(String)
    }

    static var engagementStarterIndex: Int { blocks.count / 2 }

    static let blocks: [Block] = [
        .paragraph("With COVID-19 disrupting the world, the demand for news has never been greater. Newsrooms are being pushed to their limits as they test the most time-saving yet effective methods to sift through an infinite amount of coronavirus information, craft story after story and keep their teams safe."),
        .paragraph("According to Therese Bottomly, the editor of a U.S.-based local paper, the \u{201C}coronavirus will strain even the largest newsrooms as news breaks continuously and into the nights and weekends.\u{201D}"),
        .paragraph("So what could be a better way to ease the enormous pressures on your media company than by understanding how other companies are maneuvering through this infodemic?"),
        .paragraph("Read on to discover useful ways you can prevent your newsroom staff from burning out while keeping up with the demand for top-quality news."),
        .heading("Moving Staff to Cover the Coronavirus"),
        .paragraph("It\u{2019}s no surprise that this health crisis has encouraged consumers to rely on trustworthy news companies for credible coronavirus information. As a result, traffic to news platforms has been soaring over the past few weeks."),
        .paragraph("Some media companies are meeting this high demand for news by shifting the focus of all content creators towards the pandemic."),
        .paragraph("For example, The Seattle Times is leveraging almost all 58 of its reporters \u{2014} who typically focus on different verticals \u{2014} to prioritize covering COVID-19 in some way or form."),
        .paragraph("Even entertainment-focused brands like Bustle, People.com and BuzzFeed are incorporating coronavirus content across its verticals."),
        .paragraph("By encouraging more staff to focus on coronavirus coverage, your newsroom can keep your community informed without burning out."),
        .heading("Promoting Content Across News Platforms"),
        .paragraph("Before the pandemic hit, it was typically every media company for themselves in the endless pursuit of higher revenue. But priorities have since changed."),
        .paragraph("Now, companies are more focused on keeping their newsrooms functional while maintaining an informed and safe audience\u{2026} even if that means collaborating with competitors."),
        .paragraph("To provide readers with relevant content and prevent editorial teams from being overworked, different media organizations in the U.S. have started repromoting each other\u{2019}s articles."),
        .paragraph("\u{201C}The collaboration will allow newsrooms to pick up good information from other sources, so they will not need to re-report the same story,\u{201D} Bottomly explains. \u{201C}We can cover more angles this way.\u{201D}")
    ]
}
