//
//  ActiveOrderTableViewCell.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 13/06/24.
//

import UIKit


protocol ActiveOrderCellDelegate: AnyObject {
    func didTapCompleteOrder(orderId: String, indexPath: Int)
}
class ActiveOrderTableViewCell: UITableViewCell {
    
 

    
    
    @IBOutlet var OrderItem: UILabel!
    @IBOutlet var OrderAmount: UILabel!
    @IBOutlet var OrderPacked: UILabel!
    @IBOutlet var OrderStatus: UILabel!
    @IBOutlet var OrderPlaced: UIButton!
    var id :String = ""
    var indexPath: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var delegate: ActiveOrderCellDelegate?

    @IBAction func OrderPlaced(_ sender: UIButton) {
        
        
//        if let indexPath = indexPath {
//                delegate?.didTapCompleteOrder(orderId: id, indexPath: indexPath)
//            }
        
        async {
            do {
                try await productApi.shared.OrderComplete(orderId:self.id)
                
                let updatedOrders = try await productApi.shared.getAllOrder()
                DataControlller.shared.set_orderResponse(getAllorder: updatedOrders)

                debugPrint("order Complete")
               
                await MainActor.run {
                    OrderStatus.text = "Completed"
                    OrderPlaced.isHidden = true
                    
                }
            } catch {
                print("Error fetching orders:", error)
            }
        }
        
        
        
        
    }
    
}

