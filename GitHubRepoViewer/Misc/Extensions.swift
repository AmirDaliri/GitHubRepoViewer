//
//  UITableViewController+Extensions.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit
import SnapKit

extension UIViewController {
    func setTabBarVisible(visible: Bool, animated: Bool) {
        guard let tabBarController = self.tabBarController else { return }

        if (tabBarController.tabBar.isHidden == !visible) { return }

        let frame = tabBarController.tabBar.frame
        let offsetY = (visible ? -frame.height : frame.height)

        // animate the tabBar
        if animated {
            UIView.animate(withDuration: 0.3) {
                tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
                tabBarController.tabBar.isHidden = !visible
            }
        } else {
            tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
            tabBarController.tabBar.isHidden = !visible
        }
    }
}

extension UITableView {
    /// Sets a message to display when the table view is empty.
    ///
    /// - Parameter message: The message to display.
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.center = self.center
        messageLabel.text = message
        messageLabel.textColor = UIColor(red: 0.424, green: 0.424, blue: 0.49, alpha: 1)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        /// Restores the table view to its default state.
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UITableViewCell {
    /// Returns the identifier for the cell class.
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIView {
    /// Provides access to the safe area layout guide using SnapKit constraints.
    var safeArea : ConstraintLayoutGuideDSL {
        return safeAreaLayoutGuide.snp
    }
}

extension String {
    /// Returns the color associated with the programming language name.
    func languageColor() -> UIColor {
        switch self.lowercased() {
        case "swift":
            return #colorLiteral(red: 0.9411764741, green: 0.3176470697, blue: 0.2196078449, alpha: 1)
        case "javascript":
            return #colorLiteral(red: 0.9450980425, green: 0.8784313798, blue: 0.3529411852, alpha: 1)
        case "python":
            return #colorLiteral(red: 0.2078431398, green: 0.4470588267, blue: 0.6470588446, alpha: 1)
        case "ruby":
            return #colorLiteral(red: 0.4392156899, green: 0.08235294312, blue: 0.08627451211, alpha: 1)
        case "java":
            return #colorLiteral(red: 0.6901960969, green: 0.4470588267, blue: 0.09803921729, alpha: 1)
        case "go":
            return #colorLiteral(red: 0, green: 0.6784313917, blue: 0.8470588326, alpha: 1)
        case "c":
            return #colorLiteral(red: 0.3019607961, green: 0.5647059083, blue: 0.9960784316, alpha: 1)
        case "rust":
            return #colorLiteral(red: 0.870588243, green: 0.6470588446, blue: 0.5176470876, alpha: 1)
        case "typescript":
            return #colorLiteral(red: 0.1686274558, green: 0.4549019635, blue: 0.5372549295, alpha: 1)
        case "kotlin":
            return #colorLiteral(red: 0.9450980425, green: 0.5568627715, blue: 0.200000003, alpha: 1)
        case "jinja":
            return #colorLiteral(red: 0.5411764979, green: 0.3725490272, blue: 0.2313725501, alpha: 1)
        default:
            return .lightGray
        }
    }
}

/// An extension for `UIImageView` to asynchronously load and display an image from a URL string.
/// It also provides options to show a loading indicator while the image is being downloaded
/// and to make the image view circular in shape.
extension UIImageView {
    
    /// Loads an image from a specified URL string and optionally displays it as a circle.
    /// - Parameters:
    ///   - urlString: The URL string of the image to load. If nil or invalid, the operation is aborted.
    ///   - showLoadingIndicator: A Boolean value indicating whether a loading indicator should be shown while the image is loading. Defaults to `true`.
    ///   - makeCircle: A Boolean value indicating whether the image view should be made circular. Defaults to `true`.
    ///
    /// This function first checks if the image is cached and uses the cached image if available.
    /// If the image is not in the cache, it proceeds to download the image from the URL,
    /// optionally displaying a loading indicator during the download.
    /// After the image is downloaded, it is cached for future use.
    /// If `makeCircle` is set to true, the image view is made circular after the image is set.
    func loadImage(from urlString: String?, showLoadingIndicator: Bool = true, makeCircle: Bool = true) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("Invalid URL or nil urlString")
            return
        }

        let cache = URLCache.shared
        let request = URLRequest(url: url)

        // Check if the image is already cached
        if let cachedResponse = cache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            self.image = image
            if makeCircle {
                self.makeCircular()
            }
            return
        }

        // Optionally, add a loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        if showLoadingIndicator {
            DispatchQueue.main.async {
                self.addSubview(activityIndicator)
                activityIndicator.startAnimating()
            }
        }

        // Asynchronously download the image
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                        if makeCircle {
                            self.makeCircular()
                        }
                        if showLoadingIndicator {
                            activityIndicator.stopAnimating()
                            activityIndicator.removeFromSuperview()
                        }
                    }
                    // Cache the downloaded data
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                } else {
                    print("Error: Data could not be converted to UIImage")
                }
            } catch {
                print("Error downloading image: \(error.localizedDescription)")
            }
        }
    }
    
    /// Makes the image view circular by setting its `cornerRadius` to half of its height.
    /// This method should be called after the view's layout has been updated to ensure
    /// the corner radius is correctly calculated.
    private func makeCircular() {
        self.setNeedsLayout()
        self.layoutIfNeeded() // Force layout update to get accurate frame size
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
