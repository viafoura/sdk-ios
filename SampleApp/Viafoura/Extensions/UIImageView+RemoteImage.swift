import UIKit

private let remoteImageCache = NSCache<NSURL, UIImage>()
private var remoteImageURLKey = 0

extension UIImageView {
    private var currentRemoteURL: URL? {
        get { objc_getAssociatedObject(self, &remoteImageURLKey) as? URL }
        set { objc_setAssociatedObject(self, &remoteImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setImage(from url: URL?) {
        currentRemoteURL = url
        guard let url else {
            image = nil
            return
        }
        if let cached = remoteImageCache.object(forKey: url as NSURL) {
            image = cached
            return
        }
        image = nil
        Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url), let loaded = UIImage(data: data) else { return }
            remoteImageCache.setObject(loaded, forKey: url as NSURL)
            await MainActor.run {
                guard let self, self.currentRemoteURL == url else { return }
                self.image = loaded
            }
        }
    }
}
