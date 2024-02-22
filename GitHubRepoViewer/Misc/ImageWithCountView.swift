//
//  ImageWithCountView.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit
import SnapKit

class ImageWithCountView: UIView {
    
    private let starImageView = UIImageView()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeUI() {
        // Add subviews
        addSubview(starImageView)
        addSubview(countLabel)
    }
    
    private func createConstraints() {
        // Define constraints with SnapKit
        starImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20) // Adjust the size as needed
        }
        
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(starImageView.snp.right).offset(5) // Adjust the spacing as needed
            make.right.equalToSuperview()
            make.centerY.equalTo(starImageView)
        }
    }
    
    // Public method to set the count externally
    func config(icon: UIImage, count: Int) {
        // Set up the star image view
        starImageView.image = icon
        starImageView.contentMode = .scaleAspectFit
        starImageView.tintColor = .systemGray
        
        // Set up the count label
        countLabel.text = "\(count)"
        countLabel.textColor = .systemGray
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
}

#if DEBUG
import SwiftUI

#Preview(body: {
    ImageWithCountView().showPreview()
})
#endif
