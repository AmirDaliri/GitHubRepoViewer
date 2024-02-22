//
//  UITableViewController+Extensions.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit
import SnapKit

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
