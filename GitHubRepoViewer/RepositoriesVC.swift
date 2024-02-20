//
//  ViewController.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var viewModel: RepositoriesViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: RepositoriesViewModel = RepositoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        viewModel.loadRepositories()
    }
    
    private func bindViewModel() {
        viewModel.$repositories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                
                let repositories = response
                print("Received repositories: \(repositories)")
//                self?.hideSpinner()
//                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$networkError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
//                self?.hideSpinner()
                self?.handleNetworkError(error)
            }
            .store(in: &cancellables)
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        // Handle the error, e.g., show an alert
        let message = determineErrorMessage(for: error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func determineErrorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidURL, .invalidResponse, .noData:
            return "A network error occurred. Please try again."
        case .underlyingError(let underlyingError):
            return underlyingError.localizedDescription
        case .decodingError(let decodingError):
            return decodingError.localizedDescription
        case .notFound:
            return "not Found"
        case .otherError(let message):
            return message
        case .serverError(let statusCode):
            return "server error with \(statusCode) status code."
        case .unauthorizedAccess:
            return "unauthorized access to the GitHub API."
        case .rateLimitExceeded:
            return "rate limit exceeded error."
        }
    }

}

