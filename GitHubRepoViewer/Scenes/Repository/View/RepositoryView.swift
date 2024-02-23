//
//  RepositoryView.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 23.02.2024.
//

import UIKit
import SnapKit
import SwiftyMarkdown

class RepositoryView: UIView {

    lazy private(set) var scrollView = UIScrollView()
    lazy private(set) var contentView = UIView()
    
    lazy private(set) var ownerAvatar = UIImageView()
    lazy private(set) var ownerName = UILabel()
    lazy private(set) var nameLabel = UILabel()

    lazy private(set) var descriptionLabel = UILabel()
    
    lazy private(set) var optionsStackView = UIStackView()
    lazy private(set) var starView = ImageWithCountView()
    lazy private(set) var forkView = ImageWithCountView()
    lazy private(set) var watchView = ImageWithCountView()
    
    lazy private(set) var circleLabel = UILabel()
    lazy private(set) var languageLabel = UILabel()
    
    lazy private(set) var topicsLabel = UILabel()
    lazy private(set) var topicsView = TagListView()
    
    lazy private(set) var readmeTitleLabel = UILabel()
    lazy private(set) var readmeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeUI() {
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(ownerAvatar)
        scrollView.addSubview(ownerName)
        setupOwnerName()
        scrollView.addSubview(nameLabel)
        setupNameLabel()
        contentView.addSubview(descriptionLabel)
        setupDescriptionLabel()
        contentView.addSubview(topicsLabel)
        contentView.addSubview(topicsView)
        setupTopics()
        contentView.addSubview(optionsStackView)
        contentView.addSubview(circleLabel)
        contentView.addSubview(languageLabel)
        setupOptionsStackView()
        contentView.addSubview(readmeTitleLabel)
        contentView.addSubview(readmeLabel)
        setuoReadme()
    }

    private func createConstraints() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(scrollView)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }

        ownerAvatar.snp.makeConstraints { make in
            make.leading.equalTo(topicsView)
            make.top.equalTo(contentView).offset(20)
            make.width.height.equalTo(30)
        }
        
        ownerName.snp.makeConstraints { make in
            make.centerY.equalTo(ownerAvatar)
            make.leading.equalTo(ownerAvatar.snp.trailing).offset(8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(ownerAvatar.snp.bottom).offset(8)
            make.leading.equalTo(ownerAvatar)
        }
                
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(20)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)       
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(24)
        }
        
        circleLabel.snp.makeConstraints { make in
            make.leading.equalTo(optionsStackView.snp.trailing).offset(16)
            make.centerY.equalTo(watchView)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.leading.equalTo(circleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(circleLabel)
        }
                
        topicsLabel.snp.makeConstraints { make in
            make.top.equalTo(optionsStackView.snp.bottom).offset(24)
            make.leading.equalTo(descriptionLabel)
        }
        
        topicsView.snp.makeConstraints { make in
            make.top.equalTo(topicsLabel.snp.bottom).offset(8)
            make.trailing.leading.equalTo(contentView).inset(24)
        }
        
        readmeTitleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(contentView).inset(20)
            make.top.equalTo(topicsView.snp.bottom).offset(20)
        }
        
        readmeLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(contentView).inset(20)
            make.top.equalTo(readmeTitleLabel.snp.bottom).offset(20)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
    
    func setupOwnerName() {
        ownerName.font = .systemFont(ofSize: 14, weight: .regular)
        ownerName.textColor = .systemGray
    }
    
    func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.numberOfLines = 0
    }
    
    func setupTopics() {
        topicsLabel.text = "Topics"
        topicsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        topicsLabel.textColor = .lightGray
        
        topicsView.alignment = .center
        topicsView.cornerRadius = 4.0
        topicsView.tagBackgroundColor = .systemGray2
        topicsView.textFont = .systemFont(ofSize: 12, weight: .medium)
        topicsView.paddingX = 8.0
    }
    
    func setupOptionsStackView() {
        optionsStackView.addArrangedSubview(starView)
        optionsStackView.addArrangedSubview(forkView)
        optionsStackView.addArrangedSubview(watchView)
        optionsStackView.axis = .horizontal
        optionsStackView.distribution = .fillEqually
        optionsStackView.spacing = 20
    }
    
    func setuoReadme() {
        readmeTitleLabel.text = "📖 Readme.md"
        readmeTitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        readmeTitleLabel.textColor = .lightGray
        
        readmeLabel.numberOfLines = 0
    }
    
    // MARK: - Config Method
    func configure(with repository: Repository) {
        ownerAvatar.loadImage(from: repository.owner?.avatarURL)
        ownerName.text = repository.owner?.login
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        topicsView.addTags(repository.topics ?? [])
        starView.config(icon: UIImage(systemName: "star")!, count: repository.stargazersCount ?? 0)
        forkView.config(icon: UIImage(named: "fork_icon")!, count: repository.forksCount ?? 0)
        watchView.config(icon: UIImage(systemName: "eye")!, count: repository.watchersCount ?? 0)
        languageLabel.text = repository.language
        circleLabel.text = ((repository.language ?? "").isEmpty) ? "" : "●"
        circleLabel.textColor = repository.language?.languageColor()
    }
    
    func setReadme(markDown: String) {
        let md = SwiftyMarkdown(string: markDown)
        readmeLabel.attributedText = md.attributedString()
    }
}


#if DEBUG
import SwiftUI

#Preview(body: {
    RepositoryView().showPreview()
})
#endif
