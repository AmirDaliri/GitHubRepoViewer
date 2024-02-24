//
//  FavoritesView.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 24.02.2024.
//

import UIKit
import SnapKit

class FavoritesView: UIView {

    lazy private(set) var tableView = UITableView()
    
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
        
        addSubview(tableView)
        setupTableView()
    }
    
    private func createConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupTableView() {
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.identifier)
    }
}


#if DEBUG
import SwiftUI

#Preview(body: {
    FavoritesView().showPreview()
})
#endif
