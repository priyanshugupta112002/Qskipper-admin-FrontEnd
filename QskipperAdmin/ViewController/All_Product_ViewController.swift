//
//  All_Product_ViewController.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 28/05/24.
//

import UIKit
import MultipartFormDataKit

class All_Product_ViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    

    

    @IBOutlet var All_ProductCollectionView: UICollectionView!
    
    
    override func viewDidLoad()  {
        
        super.viewDidLoad()
        
        
        async {
            
            do{
                 let response = try await productApi.shared.getAllProduct()
                debugPrint(response)
                    DataControlller.shared.set_all_product(product: response)
                    
                    await MainActor.run {
                        // Update the UI with the response
                        self.All_ProductCollectionView.reloadData()

                    }
            
            }
            catch{
                await MainActor.run {
                    // Handle errors on the main thread
                    print("Registration failed: \(error)")
                }
            }
           
        }
        
        
      
        
        var firstNib = UINib(nibName: "All_Products", bundle: nil)
        All_ProductCollectionView.register(firstNib, forCellWithReuseIdentifier: "All_Products")
        
        All_ProductCollectionView.dataSource = self
        All_ProductCollectionView.delegate = self
        
        All_ProductCollectionView.setCollectionViewLayout(generateLayout(), animated: true)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        All_ProductCollectionView.reloadData()
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        debugPrint(DataControlller.shared.get_all_product.count)
        return DataControlller.shared.get_all_product.count
        
        
     
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "All_Products", for: indexPath) as! All_Product_CollectionViewCell
//        cell.Product_Image.image = DataControlller.shared.get_all_product[indexPath.row].
        Task{
            if let url = URL(string: "https://qskipperbackend.onrender.com/get_product_photo/\(DataControlller.shared.get_product_row(index: indexPath.row)._id)"){
                
                if let image = try? await productApi.shared.fetchImage(from: url){
                    debugPrint(image)
                    DataControlller.shared.set_product_image(index: indexPath.row, image: image)
                    
                    cell.Product_Image.image = image
                    
                    debugPrint(cell)
                }
            }
                
        }
        cell.Product_Price.text = "\(DataControlller.shared.get_all_product[indexPath.row].product_price)"
        cell.Product_Name.text = "\(DataControlller.shared.get_all_product[indexPath.row].product_name)"
            

        
        return cell
        
    }
    
    
   
    
//    func generateLayout () -> UICollectionViewLayout{
//
//        let layout = UICollectionViewCompositionalLayout{
//            (section,env) -> NSCollectionLayoutSection? in
//
//
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.9))
//
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3 )
//
//            let secction = NSCollectionLayoutSection(group: group)
//            return secction
//
//        }
//        return layout
//
//    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            
            let itemSpacing: CGFloat = 20 // Define the spacing between items
            let itemsPerRow: CGFloat = 4
            let totalSpacing = itemSpacing * (itemsPerRow - 1)
            
            let itemWidth = (env.container.effectiveContentSize.width - totalSpacing) / itemsPerRow
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemWidth))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemWidth))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(itemsPerRow))
            group.interItemSpacing = .fixed(itemSpacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = itemSpacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            return section
        }
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UpdateAndDelete") as! UpdateAndDeleteViewController
        
        
        let product = DataControlller.shared.get_product_row(index: indexPath.row)
        
        viewController.currentProduct = product
        viewController.index = indexPath.row
        
        
        let viewNavController = UINavigationController(rootViewController: viewController)
        
        viewNavController.modalPresentationStyle = .fullScreen
        present(viewNavController, animated: true, completion: nil)
        
        
        
        
        
        
        
    }
    @IBAction func unwindtoVc(segue:UIStoryboardSegue){
        
        guard segue.identifier == "Donesegue" else {
            return
        }
        var newProduct = Product()
        var index: Int = -1
        guard let sourceVC = segue.source as? UpdateAndDeleteViewController  else { return }
            var currentProduct = sourceVC.currentProduct
            index = sourceVC.index
            currentProduct.product_name = sourceVC.Product_Name.text!
            currentProduct.product_price = Int(sourceVC.Product_Price.text!)!
            
            currentProduct.description = sourceVC.Product_Description.text!
            currentProduct.food_category = sourceVC.Product_Category.text!
            
            currentProduct.extraTime = Int(sourceVC.Product_ExtraTime.text!)!
            
            if(sourceVC.Product_featured.isOn){
                currentProduct.featured = true
            }else{
                currentProduct.featured = false
            }
            if(sourceVC.Product_IsAvailable.isOn){
                currentProduct.availability = true
            }else{
                currentProduct.availability = false
            }
        
            
            newProduct = currentProduct
            
        
        debugPrint("changing data")
        debugPrint(newProduct)
        DataControlller.shared.removeProduct( index: index)
        DataControlller.shared.appendProduct(product: newProduct, index: index)
        
        
        
        
        
        if let formData = updateFormAppData(image:sourceVC.currentProduct.product_photo!, ProductName: sourceVC.Product_Name.text! , prepTime: Int(sourceVC.Product_ExtraTime.text!)! ,productPrice: Int(sourceVC.Product_Price.text!)! , ProductCategory: sourceVC.Product_Category.text! , ProductDescription: sourceVC.Product_Description.text!   , restaurant_id: sourceVC.currentProduct.restaurant_id , featured_Item: (sourceVC.Product_featured != nil)) {
            
        debugPrint("done button")
            var request = URLRequest(url: URL(string: "https://queueskipperbackend.onrender.com/update-food/\(currentProduct._id)")!)
              request.httpMethod = "PUT"
        
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")

            request.httpBody = formData.body

              URLSession.shared.dataTask(with: request) { (data, response, error) in
                  if let error = error {
                      print("Error: \(error.localizedDescription)")
                      return
                  }
                  // Handle response
                  if let data = data, let responseString = String(data: data, encoding: .utf8) {
                      print("Response: \(responseString)")
                  }
              }.resume()
          } else {
              print("Failed to create form data.")
          }
      }
        
        

        
   
           
    func updateFormAppData(image: UIImage ,  ProductName: String, prepTime: Int , productPrice:Int , ProductCategory:String ,ProductDescription :String ,restaurant_id :String  ,featured_Item :Bool ) -> MultipartFormData.BuildResult? {


        let multipartFormData = try? MultipartFormData.Builder.build(
            with: [
                (
                    name: "product_name",
                    filename: nil,
                    mimeType: nil,
                    data: ProductName.data(using: .utf8)!
                ),
                (
                    name: "description",
                    filename: nil,
                    mimeType: nil,
                    data: ProductDescription.data(using: .utf8)!
                ),
                (
                    name: "food_category",
                    filename: nil,
                    mimeType: nil,
                    data: ProductCategory.data(using: .utf8)!
                ),
                (
                    name: "restaurant_id",
                    filename: nil,
                    mimeType: nil,
                    data: restaurant_id.data(using: .utf8)!
                ),
                (
                    name: "extraTime",
                    filename: nil,
                    mimeType: nil,
                    data: "\(prepTime)".data(using: .utf8)!
                ),
                (
                    name: "featured_Item",
                    filename: nil,
                    mimeType: nil,
                    data: "\(featured_Item)".data(using: .utf8)!
                ),
                (
                    name: "product_price",
                    filename: nil,
                    mimeType: nil,
                    data: "\(productPrice)".data(using: .utf8)!
                ),
                (
                    name: "product_photo64Image",
                    filename: "example.jpeg",
                    mimeType: MIMEType.imageJpeg,
                    data: image.jpegData(compressionQuality: 0.1)!
                ),
                
            ],
            willSeparateBy: RandomBoundaryGenerator.generate()
        )
        
        return multipartFormData
    }

        
        
        
        
        
        
    }
    
    
    
    
    






