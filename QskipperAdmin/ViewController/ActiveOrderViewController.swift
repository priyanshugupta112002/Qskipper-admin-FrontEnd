import UIKit

class ActiveOrderViewController:UIViewController, UITableViewDataSource, UITableViewDelegate , ActiveOrderCellDelegate{
    
    // MARK: - Properties
    private var refreshControl = UIRefreshControl()
    private var refreshButton = UIButton()


    func didTapCompleteOrder(orderId: String, indexPath: Int) {
        // Optimistically disable the button
        if let cell = activeOrderTableView.cellForRow(at: IndexPath(row: indexPath, section: 0)) as? ActiveOrderTableViewCell {
            cell.OrderPlaced.isEnabled = false
            cell.OrderPlaced.alpha = 0.5
        }

        async {
            do {
                try await productApi.shared.OrderComplete(orderId: orderId)
                let updatedOrders = try await productApi.shared.getAllOrder()
                DataControlller.shared.set_orderResponse(getAllorder: updatedOrders)
                await MainActor.run {
                    self.activeOrderTableView.reloadData()
                }
            } catch {
                print("Error completing order:", error)
            }
        }
    }
    
    // MARK: - ActiveOrderCellDelegate
    func orderCompleted(updatedOrders: orderResponse) {
        // Update the data controller with the latest orders
        DataControlller.shared.set_orderResponse(getAllorder: updatedOrders)
        
        // Reload the table view to reflect changes
        activeOrderTableView.reloadData()
    }
    
    
    @IBOutlet var activeOrderTableView: UITableView!
    
    // MARK: - Setup Refresh Button
    private func setupRefreshButton() {
        // Create and configure button
        refreshButton.setTitle("Tap for new orders", for: .normal)
        refreshButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        refreshButton.layer.cornerRadius = 10
        refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        
        // Add to view and set constraints
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            refreshButton.widthAnchor.constraint(equalToConstant: 200),
            refreshButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Use the actual orders array count for reliability
        return DataControlller.shared.orderRes.order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveOrder", for: indexPath) as! ActiveOrderTableViewCell
        
        let order = DataControlller.shared.orderRes.order[indexPath.row]
        
        // Set cell properties
        cell.id = order.id
        cell.indexPath = indexPath.row
        cell.delegate = self
        
        // Set order details with better formatting
        cell.OrderAmount.text = "₹\(order.totalPrice)"
        cell.OrderStatus.text = order.status
        
        // Format the items text to match the screenshot
        let itemsCount = order.items.count
        var formattedText = "Total Items: \(itemsCount)\n\n"
        
        // Format each item with price in parentheses - matching screenshot
        for (i, item) in order.items.enumerated() {
            formattedText += "\(i+1). \(item.quantity) x \(item.product_name) (₹\(item.product_price))\n"
        }
        
        // Set the formatted text to the scrollable items list
        cell.setItemsText(formattedText)
        
        // Set button style based on order status
        // Always use green color for buttons, just change opacity when disabled
        cell.OrderPlaced.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        
        if order.status == "Completed" {
            cell.OrderPlaced.isEnabled = false
            cell.OrderPlaced.alpha = 0.5
            cell.OrderPlaced.setTitle("Order Completed", for: .normal)
        } else {
            cell.OrderPlaced.isEnabled = true
            cell.OrderPlaced.alpha = 1.0
            cell.OrderPlaced.setTitle("Order Completed", for: .normal)
        }

        return cell
    }
    
    // Use a fixed height for all cells with proper spacing
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 290  // Reduced height for more compact cells
    }
    
    // Add spacing between cells for better visual separation
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 // Space between cells
    }
    
    // MARK: - Fetch Orders
    private func fetchOrders() {
        async {
            do {
                let response = try await productApi.shared.getAllOrder()
                
                // Debug logging to see full order data
                print("Fetched \(response.order.count) orders")
                for (i, order) in response.order.enumerated() {
                    print("Order \(i+1): ID \(order.id), Status: \(order.status), Total: \(order.totalPrice)")
                    print("Items count: \(order.items.count)")
                    for (j, item) in order.items.enumerated() {
                        print("  Item \(j+1): \(item.quantity) x \(item.product_name) (₹\(item.product_price))")
                    }
                }
                
                DataControlller.shared.set_orderResponse(getAllorder: response)
                
                await MainActor.run {
                    self.activeOrderTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } catch {
                print("Error fetching orders:", error)
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        // Visual feedback for refresh button
        if refreshControl.isRefreshing == false {
            animateRefreshButton()
        }
        fetchOrders()
    }
    
    // Animate the refresh button to provide visual feedback
    private func animateRefreshButton() {
        // Change button appearance to show loading state
        let originalTitle = refreshButton.title(for: .normal)
        let originalBackgroundColor = refreshButton.backgroundColor
        
        // Create activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        // Add to button and position
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: 20),
            activityIndicator.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor)
        ])
        
        // Animation for visual feedback
        UIView.animate(withDuration: 0.2, animations: {
            self.refreshButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 0.7)
            self.refreshButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.refreshButton.setTitle("  Refreshing orders...", for: .normal)
        }, completion: { _ in
            // Reset button after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.refreshButton.backgroundColor = originalBackgroundColor
                    self.refreshButton.transform = .identity
                    self.refreshButton.setTitle(originalTitle, for: .normal)
                    activityIndicator.removeFromSuperview()
                })
            }
        })
    }
    
    // MARK: - Setup Methods
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        activeOrderTableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        // Create refresh button
        let refreshBarButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        
        // Create logout button
        let logoutBarButton = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutButtonTapped)
        )
        
        // Set both buttons
        navigationItem.rightBarButtonItems = [logoutBarButton, refreshBarButton]
    }
    
    @objc func logoutButtonTapped() {
        print("Logout button tapped in ActiveOrderViewController")
        
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
        print("Performing logout from ActiveOrderViewController...")
        
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
                if let tabBarController = self.tabBarController {
                    tabBarController.dismiss(animated: true) {
                        print("Dismissed to previous screen as fallback")
                    }
                } else {
                    self.dismiss(animated: true) {
                        print("Dismissed current controller as fallback")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        activeOrderTableView.delegate = self
        activeOrderTableView.dataSource = self
        
        // Improve table view appearance
        activeOrderTableView.separatorStyle = .none
        activeOrderTableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        activeOrderTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // Setup refresh control and navigation bar
        setupRefreshControl()
        setupNavigationBar()
        setupRefreshButton()
        
        // Initial data fetch
        fetchOrders()
    }
}
    


    
    

