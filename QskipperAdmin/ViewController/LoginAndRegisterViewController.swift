//
//  LoginAndRegisterViewController.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 28/05/24.
//

import UIKit

class LoginAndRegisterViewController: UIViewController {
    
//    static let shared = LoginAndRegisterViewController()

    @IBOutlet var UserLogin_id: UITextField!
    @IBOutlet var userLoginPassword: UITextField!


    
    @IBOutlet var userRegisterEmailId: UITextField!
    @IBOutlet var userRegisterPassword: UITextField!
    @IBOutlet var userRegisterSecurityCode: UITextField!
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Check if user is already logged in
        if let savedUserId = UserDefaults.standard.string(forKey: "userId"),
           let savedEmail = UserDefaults.standard.string(forKey: "userEmail"),
           let savedPassword = UserDefaults.standard.string(forKey: "userPassword") {
            
            UserLogin_id.text = savedEmail
            userLoginPassword.text = savedPassword
            
            // Auto login
            Task {
                let currentUser = user(email: savedEmail, password: savedPassword)
                
                do {
                    if let response = try await Networking.shared.loginUser(currentUser: currentUser) {
                        if (response.restaurantid != "") {
                            DataControlller.shared.set_Restaurant_Id(id: response.id)
                            DataControlller.shared.set_restaurant_cuisine(cuisine: response.resturantCusine)
                            DataControlller.shared.set_restaurant_estimatedTime(estimatedTime: response.resturantEstimateTime)
                            DataControlller.shared.set_restaurant(name: response.restaurantName)
                        }
                        DataControlller.shared.setID(id: response.id)
                        navigateToHomeScreen()
                    }
                } catch {
                    print("Auto-login failed: \(error)")
                }
            }
        }
    }

    @IBAction func RegisterNewUser(_ sender: UIButton) {
        
        Task {
             // Get user input
             let email = userRegisterEmailId.text!
             let password = userRegisterPassword.text!
             let securityCode = userRegisterSecurityCode.text!
            
             // Create a User instance
            let currentUser = user(email: email, password: password, securityCode: securityCode)
            
             do {
                 if let response = try await Networking.shared.registerUser(currentUser: currentUser) {
                     DataControlller.shared.setID(id: response.id)
                     navigateToHomeScreen()
                     await MainActor.run {
                         // Update the UI with the response

                     }
                 }
                 
             } catch {
                 await MainActor.run {
                     // Handle errors on the main thread
                     print("Registration failed: \(error)")
                 }
             }
         }
     }
    
    @IBAction func SubmitNameUser(_ sender: UIButton) {
        
        Task{
            
            let userName = UserLogin_id.text!
            let userPassword = userLoginPassword.text!
            
            let currentUser = user(email: userName , password: userPassword)
    
            do {
                // login  user
              
                if let response = try await Networking.shared.loginUser(currentUser: currentUser) {
                    if (response.restaurantid != ""){
                        DataControlller.shared.set_Restaurant_Id(id: response.id)
                        DataControlller.shared.set_restaurant_cuisine(cuisine: response.resturantCusine)
                        DataControlller.shared.set_restaurant_estimatedTime(estimatedTime: response.resturantEstimateTime)
                        DataControlller.shared.set_restaurant(name: response.restaurantName)
                        
                        // Save restaurant data
                        UserDefaults.standard.set(response.id, forKey: "restaurantId")
                        UserDefaults.standard.set(response.restaurantName, forKey: "restaurantName")
                        UserDefaults.standard.set(response.resturantCusine, forKey: "restaurantCuisine")
                        UserDefaults.standard.set(response.resturantEstimateTime, forKey: "restaurantEstimatedTime")
                    }
                    DataControlller.shared.setID(id: response.id)
                    
                    // Save login credentials
                    UserDefaults.standard.set(response.id, forKey: "userId")
                    UserDefaults.standard.set(userName, forKey: "userEmail")
                    UserDefaults.standard.set(userPassword, forKey: "userPassword")
                    
                    debugPrint("after login")
                    debugPrint(DataControlller.shared.Currentuser)
                    debugPrint(DataControlller.shared.restaurant)
                    navigateToHomeScreen()
                    await MainActor.run {
                        
                    }
                    debugPrint(DataControlller.shared.restaurant)
                    
//                    show(viewController, sender: self)
                    
                }
            } catch {
                await MainActor.run {
                    
                    let alert = UIAlertController(
                        title: "Invalid Credentials",
                        message: "You entered an incorrect email or password. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    
                                print("Login failed: \(error)")
                    
                    // Present the alert
                    if let topController = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?
                        .rootViewController {
                        
                        // Present from the top-most visible view controller
                        var current = topController
                        while let presented = current.presentedViewController {
                            current = presented
                        }
                        current.present(alert, animated: true, completion: nil)
                    }
                    
                    
                    
                    
                    }
              
            
                
      
            }
            
//            do{
//                var baseUrl = URL(string: "https://queueskipperbackend.onrender.com/update-food/")!
//                let productUrl = baseUrl.appendingPathComponent("check-user/\(DataControlller.shared.Currentuser.id)")
//                    let request = URLRequest(url:productUrl)
//                    
//                    let(data , response) = try await URLSession.shared.data(for: request)
//                    
//                    if let string = String(data: data, encoding: .utf8)
//                    {
//                        debugPrint(string)
//                        debugPrint("get all product")
//                    }
//                    
//                    guard let httpResponse = response as? HTTPURLResponse,
//                          httpResponse.statusCode == 200 else{
//                        
//                        print("not exist")
//                        return
//                        
//                    }
//                    let decoder = JSONDecoder()
//                    let userResponse = try decoder.decode(ProductResponse.self, from: data)
//                    
//                
//            }catch {
//                await MainActor.run {
//                    // Handle errors on the main thread
//                    print("login failed: \(error)")
//                }
//            }
            
            
        }
    }
    
    
    func navigateToHomeScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! MainTabBarViewController
//        
//        let navVC = UINavigationController(rootViewController: viewController)
        
//        navVC.tabBarItem = UITabBarItem(title: "Active Order", image: UIImage(systemName: "bag"),selectedImage: UIImage(systemName: "bag.fill"))
//        navVC.tabBarItem = UITabBarItem(title: "Restaurant Info", image: UIImage(systemName: "info"), tag: 1)
//        navVC.tabBarItem = UITabBarItem(title: "All Prducts", image:UIImage(systemName: "list.bullet.clipboard") , tag: 2)
        
        
//        let tabBarController = UITabBarController()
//        
//        tabBarController.viewControllers = [viewController]
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
        print("hehe")
        
    }
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        DataControlller.shared.reset()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userPassword")
        UserDefaults.standard.removeObject(forKey: "restaurantId")
        UserDefaults.standard.removeObject(forKey: "restaurantName")
        UserDefaults.standard.removeObject(forKey: "restaurantCuisine")
        UserDefaults.standard.removeObject(forKey: "restaurantEstimatedTime")
    }
    
    
}

