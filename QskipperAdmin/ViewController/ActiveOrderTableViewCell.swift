//
//  ActiveOrderTableViewCell.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 13/06/24.
//

import UIKit


protocol ActiveOrderCellDelegate: AnyObject {
    func didTapCompleteOrder(orderId: String, indexPath: Int)
    func orderCompleted(updatedOrders: orderResponse)
}
class ActiveOrderTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet var OrderItem: UILabel!
    @IBOutlet var OrderAmount: UILabel!
    @IBOutlet var OrderPacked: UILabel!
    @IBOutlet var OrderStatus: UILabel!
    @IBOutlet var OrderPlaced: UIButton!
    
    // MARK: - Properties
    var id: String = ""
    var indexPath: Int?
    weak var delegate: ActiveOrderCellDelegate?
    
    // Scrollview components
    private var scrollView: UIScrollView?
    private var itemsLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add rounded corners and shadow to the entire cell for a card-like appearance
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Style the Amount display
        OrderAmount.layer.cornerRadius = 8
        OrderAmount.clipsToBounds = true
        OrderAmount.textAlignment = .center
        OrderAmount.backgroundColor = UIColor.white
        OrderAmount.layer.borderWidth = 0.5
        OrderAmount.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        OrderAmount.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        // Style the Status display
        OrderStatus.layer.cornerRadius = 8
        OrderStatus.clipsToBounds = true
        OrderStatus.textAlignment = .center
        OrderStatus.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        OrderStatus.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Style the Order button
        OrderPlaced.layer.cornerRadius = 8
        OrderPlaced.clipsToBounds = true
        OrderPlaced.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        OrderPlaced.setTitleColor(.white, for: .normal)
        OrderPlaced.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Apply standard configuration to the OrderItem label (used as fallback)
        OrderItem.numberOfLines = 0
        OrderItem.lineBreakMode = .byWordWrapping
        OrderItem.font = UIFont.systemFont(ofSize: 15)
        
        // Add padding to the content
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Setup scrollable area
        setupScrollView()
    }
    
    private func setupScrollView() {
        // Create a scroll view to contain the items
        let scroll = UIScrollView(frame: CGRect.zero)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        scroll.backgroundColor = UIColor.white
        scroll.layer.cornerRadius = 10
        scroll.layer.borderWidth = 0.5
        scroll.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentView.addSubview(scroll)
        
        // Create a label inside the scroll view
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .left
        scroll.addSubview(label)
        
        // Set constraints for scroll view - position it where OrderItem is
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: OrderItem.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: OrderItem.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: OrderItem.trailingAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        // Set constraints for label inside scroll view
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -10),
            label.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -24)
        ])
        
        // Store references
        self.scrollView = scroll
        self.itemsLabel = label
        
        // Hide the original label
        OrderItem.isHidden = true
    }
    
    // Method to set the text for items
    func setItemsText(_ text: String) {
        itemsLabel?.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func OrderPlaced(_ sender: UIButton) {
        // Immediately disable button to prevent double taps
        OrderPlaced.isEnabled = false
        OrderPlaced.alpha = 0.5
        
        async {
            do {
                try await productApi.shared.OrderComplete(orderId:self.id)
                
                let updatedOrders = try await productApi.shared.getAllOrder()
                DataControlller.shared.set_orderResponse(getAllorder: updatedOrders)

                debugPrint("order Complete")
               
                await MainActor.run {
                    // Update UI in this cell
                    OrderStatus.text = "Completed"
                    OrderPlaced.isHidden = true
                    
                    // Notify the view controller of the update
                    delegate?.orderCompleted(updatedOrders: updatedOrders)
                }
            } catch {
                print("Error completing order:", error)
                // Re-enable button if there was an error
                await MainActor.run {
                    OrderPlaced.isEnabled = true
                    OrderPlaced.alpha = 1.0
                }
            }
        }
    }
}

