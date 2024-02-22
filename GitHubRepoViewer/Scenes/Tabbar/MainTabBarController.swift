//
//  MainTabBarController.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 22.02.2024.
//

import UIKit


class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBarAppearance()
    }

    private func setupTabs() {
        let firstVC = UINavigationController(rootViewController: RepositoriesVC())
        firstVC.tabBarItem = UITabBarItem(title: "Repositories", image: UIImage(systemName: "list.bullet.indent"), tag: 0)
        
        let secondVC = UINavigationController(rootViewController: FavoritesVC())
        secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        viewControllers = [firstVC, secondVC]
    }

    private func customizeTabBarAppearance() {
        // Tab Bar Background Color
        tabBar.barTintColor = .darkGray
        tabBar.backgroundColor = .darkGray
        
        // Selected Tab Color
        tabBar.tintColor = .white
        
        // Unselected Tab Color
        tabBar.unselectedItemTintColor = .lightGray
        
        // Tab Bar Item Text Attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        // Optional: Tab Bar Shadow
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 8
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
    }
}
