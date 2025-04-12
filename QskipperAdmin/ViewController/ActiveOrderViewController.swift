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
        refreshButton.backgroundColor = .systemBlue
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
//        return DataControlller.shared.order.order. Using actual count of data
        return DataControlller.shared.orderRes.length
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveOrder", for: indexPath) as! ActiveOrderTableViewCell
        
        let cuisineTypeForThisCell = DataControlller.shared.orderRes.order[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        debugPrint( cuisineTypeForThisCell)
        cell.id = cuisineTypeForThisCell.id
        cell.indexPath = indexPath.row
        cell.delegate = self  // Set the delegate to this view controller
        cell.OrderAmount.text = "\(cuisineTypeForThisCell.totalPrice)"
        cell.OrderStatus.text = cuisineTypeForThisCell.status
        let orderText  = DataControlller.shared.orderRes.order[indexPath.row].items.map{"\(String(describing: $0.quantity)) x \($0.product_name)"}
        
        cell.OrderItem.text = orderText.joined(separator: "\n")
        if cell.OrderStatus.text == "Completed" {
                    cell.OrderPlaced.isEnabled = false
                    cell.OrderPlaced.alpha = 0.5  // Optional: visually indicate the disabled state.
        } else {
                    cell.OrderPlaced.isEnabled = true
                    cell.OrderPlaced.alpha = 1.0
        }

                return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
    
    // MARK: - Fetch Orders
    private func fetchOrders() {
        async {
            do {
                let response = try await productApi.shared.getAllOrder()
                
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
            self.refreshButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activeOrderTableView.delegate = self
        activeOrderTableView.dataSource = self
        
        // Setup refresh control and navigation bar
        setupRefreshControl()
        setupNavigationBar()
        setupRefreshButton()
        
        // Initial data fetch
        fetchOrders()
    }
}
    


    
    

