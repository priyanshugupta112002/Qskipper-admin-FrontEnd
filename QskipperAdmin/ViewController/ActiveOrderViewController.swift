

import UIKit

class ActiveOrderViewController:UIViewController, UITableViewDataSource, UITableViewDelegate , ActiveOrderCellDelegate{
    
    



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
    
    
    
    @IBOutlet var activeOrderTableView: UITableView!
    


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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activeOrderTableView.delegate = self
        activeOrderTableView.dataSource = self
        
        async {
            do {
                let response = try await productApi.shared.getAllOrder()
                
                debugPrint("order placed")
                debugPrint(DataControlller.shared.orderRes)
                debugPrint(response)
                
                DataControlller.shared.set_orderResponse(getAllorder: response)
               
                
                
                await MainActor.run {
                    self.activeOrderTableView?.reloadData()
                }
            } catch {
                print("Error fetching orders:", error)
            }
        }
    }
    
    
    
        
    }
    


    
    

