//
//  MainTabBarViewController.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 04/06/24.
//

import UIKit
 
class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add logout button to each view controller in the tab bar
        setupLogoutButtons()
    }
    
    private func setupLogoutButtons() {
        // Set up logout button for each view controller in the tab bar
        for (index, viewController) in (viewControllers ?? []).enumerated() {
            if let navController = viewController as? UINavigationController,
               let topVC = navController.topViewController {
                // Add logout button to navigation bar
                let logoutButton = UIBarButtonItem(
                    title: "Logout",
                    style: .plain,
                    target: self,
                    action: #selector(logoutButtonTapped)
                )
                topVC.navigationItem.rightBarButtonItem = logoutButton
                print("Added logout button to tab \(index)")
            } else {
                // If the view controller isn't in a navigation controller,
                // add it directly to the view controller
                let logoutButton = UIBarButtonItem(
                    title: "Logout",
                    style: .plain,
                    target: self,
                    action: #selector(logoutButtonTapped)
                )
                viewController.navigationItem.rightBarButtonItem = logoutButton
                print("Added logout button to tab \(index) (no nav controller)")
            }
        }
    }
    
    @objc func logoutButtonTapped() {
        print("Logout button tapped")
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        print("Performing logout...")
        
        // Reset data controller
        DataControlller.shared.reset()
        
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "userEmail")
        defaults.removeObject(forKey: "userPassword")
        defaults.removeObject(forKey: "restaurantId")
        defaults.removeObject(forKey: "restaurantName")
        defaults.removeObject(forKey: "restaurantCuisine")
        defaults.removeObject(forKey: "restaurantEstimatedTime")
        
        // Set manual logout flag to prevent auto-login
        defaults.set(true, forKey: "manualLogout")
        defaults.synchronize()
        
        // Use SceneDelegate helper to return to login screen
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            print("Using SceneDelegate helper to reset to login screen")
            sceneDelegate.resetToLoginScreen()
        } else {
            print("ERROR: Could not access SceneDelegate")
            // Fallback to direct reset
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                UIApplication.shared.windows.first?.rootViewController = initialViewController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                print("Manually reset to login screen")
            } else {
                // Last resort
                self.dismiss(animated: true) {
                    print("Dismissed to previous screen as fallback")
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
