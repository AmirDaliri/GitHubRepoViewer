//
//  RepositoriesView.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit
import SnapKit

class RepositoriesView: UIView {

    lazy private(set) var segmentController = UISegmentedControl()
    lazy private(set) var tableView = UITableView()
    lazy private(set) var searchController = UISearchController(searchResultsController: nil)
    lazy private(set) var refreshControl = UIRefreshControl()
    
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
        
        addSubview(segmentController)
        addSubview(tableView)
        
        setupSegmentController()
        setupTableView()
    }
    
    private func createConstraints() {
        segmentController.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(safeArea.top).offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentController.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeArea.bottom)
        }
    }
    
    func setupSegmentController() {
        segmentController.insertSegment(withTitle: Organization.algorand.rawValue, at: 0, animated: false)
        segmentController.insertSegment(withTitle: Organization.perawallet.rawValue, at: 1, animated: false)
        segmentController.insertSegment(withTitle: Organization.algorandFoundation.rawValue, at: 2, animated: false)
        segmentController.selectedSegmentIndex = 0
        segmentController.setWidth(150, forSegmentAt: 2)
    }
    
    func setupTableView() {
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.identifier)
        tableView.refreshControl = refreshControl
    }
    
    func addSearchBar(navigationItem: UINavigationItem, delegate: UISearchControllerDelegate, searchResultsUpdater: UISearchResultsUpdating) {
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.delegate = delegate
        // Add the search bar to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // Hide search bar initially
        navigationItem.searchController?.isActive = false
        
        // Make sure to set navigationItem.searchController before calling this line
        navigationItem.title = "Repositories"
    }

}


#if DEBUG
import SwiftUI

#Preview(body: {
    RepositoriesView().showPreview()
})
#endif
