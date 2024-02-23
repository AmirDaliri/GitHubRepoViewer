//
//  ViewController.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import UIKit
import Combine
import SnapKit

/// View Controller responsible for displaying repositories.
final class RepositoriesVC: UIViewController, Loading {
    
    // MARK: - Properties
    
    /// Reference to the spinner view used for indicating loading state.
    var spinner: UIView?
    private var viewModel: RepositoriesViewModel
    private var cancellables = Set<AnyCancellable>()

    /// Returns the view of this controller as RepositoriesView.
    var contentView: RepositoriesView {
        return view as! RepositoriesView
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = RepositoriesView()
    }
    
    /// Initializes the view controller with the specified view model.
    /// - Parameter viewModel: The view model to use.
    init(viewModel: RepositoriesViewModel = RepositoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadRepositories(organization: getOrganizationBySegmentIndex())
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setTabBarVisible(visible: true, animated: true)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // UI setup that doesn't involve asynchronous operations
        contentView.addSearchBar(navigationItem: navigationItem, delegate: self, searchResultsUpdater: self)
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.prefetchDataSource = self
        contentView.segmentController.addTarget(self, action: #selector(segmentCtrlValueChanged(_:)), for: .valueChanged)
        contentView.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private func setupBindings() {
        // Existing binding setup remains unchanged
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Documented ViewModel bindings
        viewModel.$repositories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.contentView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$networkError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleNetworkError(error)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    // Show loading indicator
                    self.showSpinner()
                } else {
                    self.contentView.refreshControl.endRefreshing()
                    self.hideSpinner()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$showEmptyState
            .receive(on: RunLoop.main)
            .sink { [weak self] showEmptyState in
                guard let self else { return }
                if showEmptyState {
                    self.contentView.tableView.setEmptyMessage("Not Found!")
                } else {
                    self.contentView.tableView.restore()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Retrieves the organization based on the selected segment index.
    /// - Returns: The organization corresponding to the selected segment index.
    private func getOrganizationBySegmentIndex() -> Organization {
        Organization.getValueFromInt(int: contentView.segmentController.selectedSegmentIndex)
    }
    
    // MARK: - Action Methods
    
    /// Handles the value change event of the segment control.
    /// - Parameter sender: The segment control that triggered the event.
    @objc private func segmentCtrlValueChanged(_ sender: UISegmentedControl) {
        viewModel.repositories.removeAll()
        let organization = getOrganizationBySegmentIndex()
        if contentView.searchController.isActive {
            viewModel.search(with: organization, searchTerm: contentView.searchController.searchBar.text ?? "")
            return
        }
        viewModel.loadRepositories(organization: organization)
    }
    
    /// Handles the refresh action triggered by the refresh control.
    /// - Parameter sender: The refresh control that triggered the action.
    @objc private func refreshData(_ sender: Any) {
        let organization = getOrganizationBySegmentIndex()
        viewModel.loadRepositories(organization: organization)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RepositoriesVC: UITableViewDataSource, UITableViewDelegate {
    // Documented UITableViewDataSource, UITableViewDelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.identifier, for: indexPath) as! RepositoryTableViewCell
        cell.configure(with: viewModel.repositories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = RepositoryVC(viewModel: RepositoryViewModel.init(repository: viewModel.repositories[indexPath.row]))
        detailViewController.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension RepositoriesVC: UITableViewDataSourcePrefetching {
    // Documented UITableViewDataSourcePrefetching methods
    
    /// Prefetches data for the table view.
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - indexPaths: An array of index paths for the rows to prefetch.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last else { return }
        let totalItems = tableView.numberOfRows(inSection: 0)
        if lastIndexPath.row == totalItems - 1 {
            // Load the next page of repositories
            if contentView.searchController.isActive {
                viewModel.loadSearchRepositoriesNextPage(organization: getOrganizationBySegmentIndex(), searchTerm: contentView.searchController.searchBar.text ?? "")
            } else {
                viewModel.loadNextPage(organization: getOrganizationBySegmentIndex())
            }
        }
    }
}

// MARK: - Error Handler
extension RepositoriesVC {
    // Documented error handling methods
    /// Handles the given network error.
    /// - Parameter error: The network error to handle.
    private func handleNetworkError(_ error: NetworkError) {
        // Handle the error, e.g., show an alert
        let message = viewModel.determineErrorMessage(for: error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension RepositoriesVC: UISearchResultsUpdating {
    // Documented UISearchResultsUpdating methods
    /// Updates the search results based on the search bar text.
    /// - Parameter searchController: The search controller.
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count >= 3 {
            let organization = getOrganizationBySegmentIndex()
            viewModel.search(with: organization, searchTerm: searchText)
        }
    }
}

// MARK: - UISearchControllerDelegate
extension RepositoriesVC: UISearchControllerDelegate {
    // Documented UISearchControllerDelegate methods
    /// Dismisses the search controller and refreshes the data.
    /// - Parameter searchController: The search controller.
    func didDismissSearchController(_ searchController: UISearchController) {
        refreshData(searchController)
    }
}
