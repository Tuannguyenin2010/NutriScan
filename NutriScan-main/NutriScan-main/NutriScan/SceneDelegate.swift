//
//  SceneDelegate.swift
//  NutriScan
//
//  Created by Guest-login on 2024-07-22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Set up the LoginViewController as the initial controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func switchToMainInterface() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Initialize each view controller for the tab bar
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        mainVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let historyVC = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), tag: 1)
        
        let scanVC = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        scanVC.tabBarItem = UITabBarItem(title: "Scan", image: UIImage(systemName: "barcode.viewfinder"), tag: 2)
        
        let analyticsVC = storyboard.instantiateViewController(withIdentifier: "AnalyticsViewController") as! AnalyticsViewController
        analyticsVC.tabBarItem = UITabBarItem(title: "Analytics", image: UIImage(systemName: "chart.bar"), tag: 3)
        
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        // Set up the tab bar controller with the view controllers
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mainVC, historyVC, scanVC, analyticsVC, userVC]
        
        // Transition to the tab bar controller as the new root view controller
        if let window = window {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
    }
    
    func navigateToProfileSetup(for userProfile: UserProfile) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.userProfile = userProfile
        
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(profileVC, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: profileVC)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    }

    // Other scene lifecycle methods remain unchanged
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
