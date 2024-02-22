//
//  Loading.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 21.02.2024.
//

import UIKit

/// Protocol for adding loading spinner functionality to any class, typically view controllers.
protocol Loading: AnyObject {
    /// An optional UIView property to hold the spinner view.
    var spinner: UIView? { get set }
}

/// Enum representing the base view options for displaying the spinner.
enum LoadingBaseView {
    case controllerView    // Spinner will be shown on the controller's view.
    case controllerFull    // Spinner will be shown on the entire controller, possibly including navigation and tab bars.
    case window            // Spinner will be shown on the entire application window.
}

/// Extension to the Loading protocol specifically for UIViewControllers.
extension Loading where Self: UIViewController {

    /// Creates and returns a new spinner view with specified frame.
    /// - Parameter frame: The frame for the new spinner view.
    /// - Returns: A configured UIView containing the spinner.
    func newSpinner(frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = .black
        view.alpha = 0.3  // Semi-transparent background
        
        // Creating a background view for the spinner with custom styling.
        let spinnerBackground = UIView(frame: .zero)
        spinnerBackground.backgroundColor = .clear // Transparent background
        spinnerBackground.layer.cornerRadius = 8
        spinnerBackground.layer.masksToBounds = true
        spinnerBackground.center = view.center
        spinnerBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerBackground)
        
        // Setting constraints for the spinner's background view.
        NSLayoutConstraint.activate([
            spinnerBackground.widthAnchor.constraint(equalToConstant: 120),
            spinnerBackground.heightAnchor.constraint(equalToConstant: 120),
            spinnerBackground.centerXAnchor.constraint(equalTo: spinnerBackground.superview!.centerXAnchor),
            spinnerBackground.centerYAnchor.constraint(equalTo: spinnerBackground.superview!.centerYAnchor)
        ])
        
        // Creating and configuring the spinner (activity indicator).
        let spinner: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            spinner = UIActivityIndicatorView(style: .whiteLarge) // Fallback for earlier iOS versions.
        }
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        
        // Setting constraints for the spinner.
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: spinner.superview!.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: spinner.superview!.centerYAnchor)
        ])
        
        return view
    }
    
    /// Shows the spinner on the specified view.
    /// - Parameter fromView: An enum value representing where to display the spinner.
    func showSpinner(fromView: LoadingBaseView = .window) {
        DispatchQueue.main.async {
            if self.spinner == nil {
                self.spinner = self.newSpinner(frame: self.view.bounds)
                
                var baseView: UIView?
                switch fromView {
                case .controllerView:
                    baseView = self.view
                case .controllerFull:
                    baseView = self.tabBarController?.view ?? self.navigationController?.view ?? self.view
                case .window:
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        baseView = window
                    }
                }
                
                baseView?.addSubview(self.spinner!)
                
                // Setting constraints for the spinner to fill the base view.
                if let spinner = self.spinner {
                    spinner.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        spinner.topAnchor.constraint(equalTo: spinner.superview!.topAnchor),
                        spinner.leadingAnchor.constraint(equalTo: spinner.superview!.leadingAnchor),
                        spinner.trailingAnchor.constraint(equalTo: spinner.superview!.trailingAnchor),
                        spinner.bottomAnchor.constraint(equalTo: spinner.superview!.bottomAnchor)
                    ])
                }
            }
        }
    }
    
    /// Hides and removes the spinner from the view.
    func hideSpinner() {
        DispatchQueue.main.async {
            if self.spinner != nil {
                self.spinner?.removeFromSuperview()
                self.spinner = nil
            }
        }
    }
}
