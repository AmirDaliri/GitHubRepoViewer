//
//  FavoritesVC.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 22.02.2024.
//

import UIKit
import Combine

final class FavoritesVC: UIViewController {
    
    // MARK: - Properties
    private var viewModel: FavoritesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    /// Returns the view of this controller as FavoritesView.
    var contentView: FavoritesView {
        return view as! FavoritesView
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = FavoritesView()
    }
    
    /// Initializes the view controller with the specified view model.
    /// - Parameter viewModel: The view model to use.
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        setupBindings()
        viewModel.checkEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        // Print the repositories saved from UserDefaults
        print("Here is the result that saved from `UserDefaults`")
        print("🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻🔻")
        let loadedRepositories = UserDefaults.standard.loadRepositories()
        print(loadedRepositories)
        print("🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺")
    }
    
    // MARK: - Private Methods
       
    /// Sets up bindings between the view model and the view controller's UI elements.
    private func setupBindings() {
        viewModel.repositoriesPublisher
            .sink { [weak self] repositories in
                self?.contentView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.insertPublisher
            .sink { [weak self] indexPath in
                self?.contentView.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            .store(in: &cancellables)
        
        viewModel.deletePublisher
            .sink { [weak self] indexPath in
                self?.contentView.tableView.deleteRows(at: [indexPath], with: .automatic)
                RepositoryDB.updateFavoritesBadge(tabbar: self?.tabBarController?.tabBar)
            }
            .store(in: &cancellables)
        
        viewModel.updatePublisher
            .sink { [weak self] indexPath in
                self?.contentView.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            .store(in: &cancellables)
        
        viewModel.contentWillChangePublisher
            .sink { [weak self] in
                self?.contentView.tableView.beginUpdates()
            }
            .store(in: &cancellables)
        
        viewModel.contentDidChangePublisher
            .sink { [weak self] in
                self?.contentView.tableView.endUpdates()
            }
            .store(in: &cancellables)
        
        viewModel.isEmptyPublisher
            .sink { [weak self] isEmpty in
                self?.setupEmptyState(isEmpty)
            }
            .store(in: &cancellables)
    }
    
    /// Sets up the empty state based on whether the repositories array is empty.
    /// - Parameter isEmpty: A boolean indicating whether the repositories array is empty.
    private func setupEmptyState(_ isEmpty: Bool) {
        if isEmpty {
            contentView.tableView.setEmptyMessage("No favorites found.")
            self.title = "Favorites"
        } else {
            self.title = "Favorites (\(viewModel.repositories.count))"
            contentView.tableView.restore()
        }
    }

}

// MARK: - Table Delegate Datasource
extension FavoritesVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.identifier, for: indexPath) as! RepositoryTableViewCell
        let repository = viewModel.repositories[indexPath.row]
        cell.configure(with: repository.toRepository())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel.repositories[indexPath.row].toRepository()
        let detailViewController = RepositoryVC(viewModel: RepositoryViewModel(repository: repository))
        detailViewController.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (_, _, boolValue) in
            self?.viewModel.deleteRepository(at: indexPath)
            boolValue(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
}
