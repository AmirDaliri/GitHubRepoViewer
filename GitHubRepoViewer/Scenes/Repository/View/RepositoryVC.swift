//
//  RepositoryVC.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 22.02.2024.
//

import UIKit
import Combine

class RepositoryVC: UIViewController, Loading {

    // MARK: - Properties
    
    /// Reference to the spinner view used for indicating loading state.
    private var viewModel: RepositoryViewModel
    private var cancellables = Set<AnyCancellable>()
    var spinner: UIView?
    
    /// Returns the view of this controller as RepositoriesView.
    var contentView: RepositoryView {
        return view as! RepositoryView
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = RepositoryView()
    }

    /// Initializes the view controller with the specified view model.
    /// - Parameter viewModel: The view model to use.
    init(viewModel: RepositoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    private func setupBindings() {
        // Existing binding setup remains unchanged
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        // Documented ViewModel bindings
        viewModel.$repository
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self else { return }
                self.contentView.configure(with: response)
                self.title = response.name
            }
            .store(in: &cancellables)
        
        viewModel.$readme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self else { return }
                if let markdown = response, !markdown.isEmpty {
                    self.contentView.setReadme(markDown: markdown)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$networkError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self else { return }
                error.handleNetworkError(on: self)
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
                    self.hideSpinner()
                }
            }
            .store(in: &cancellables)
    }
}
