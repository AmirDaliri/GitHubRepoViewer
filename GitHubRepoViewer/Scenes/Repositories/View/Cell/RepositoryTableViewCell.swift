//
//  RepositoryTableViewCell.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
    
    lazy private(set) var nameLabel = UILabel()
    lazy private(set) var descriptionLabel = UILabel()
    lazy private(set) var starView = ImageWithCountView()
    lazy private(set) var forkView = ImageWithCountView()
    lazy private(set) var watchView = ImageWithCountView()
    lazy private(set) var circleLabel = UILabel()
    lazy private(set) var languageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        initializeUI()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starView)
        contentView.addSubview(forkView)
        contentView.addSubview(watchView)
        contentView.addSubview(circleLabel)
        contentView.addSubview(languageLabel)
        
        setupNameLabel()
        setupDescriptionLabel()
        setupLanguageLabel()
    }

    private func createConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(32)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        starView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        forkView.snp.makeConstraints { make in
            make.leading.equalTo(starView.snp.trailing).offset(16)
            make.height.equalTo(24)
            make.centerY.equalTo(starView)
        }
        
        watchView.snp.makeConstraints { make in
            make.leading.equalTo(forkView.snp.trailing).offset(16)
            make.height.equalTo(24)
            make.centerY.equalTo(forkView)
        }
        
        circleLabel.snp.makeConstraints { make in
            make.leading.equalTo(watchView.snp.trailing).offset(16)
            make.centerY.equalTo(watchView)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.leading.equalTo(circleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(circleLabel)
        }
    }
    
    private func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
    }

    private func setupDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupLanguageLabel() {
        languageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        languageLabel.textColor = .systemGray
    }
    
    func configure(with repository: Repository) {
        // Configure cell with repository data
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        starView.config(icon: UIImage(systemName: "star")!, count: repository.stargazersCount ?? 0)
        forkView.config(icon: UIImage(named: "fork_icon")!, count: repository.forksCount ?? 0)
        watchView.config(icon: UIImage(systemName: "eye")!, count: repository.watchersCount ?? 0)
        languageLabel.text = repository.language
        circleLabel.text = ((repository.language ?? "").isEmpty) ? "" : "●"
        circleLabel.textColor = (repository.language ?? "").languageColor()
    }
}
