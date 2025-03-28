//
//  ViewController.swift
//  Telegraph
//
//  Created by RK Adithya on 26/03/25.
//

import UIKit

class ProductListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var products : [Product] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProductList), name: NSNotification.Name("ProductUpdated"), object: nil)

        let rightButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(openAddProductScreen))
           navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(title: "🌍", style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()

    }
    
    @objc func refreshProductList() {
        print("🔄 Refreshing product list...")
        fetchProducts()
    }
    
    @objc func leftButtonTapped(){
        let webVC = WebViewController()
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc func openAddProductScreen() {
        performSegue(withIdentifier: "addScreenSegue", sender: nil)
    }
    
//    func fetchProducts() {
////        do{
////            products = try DatabaseManager.shared.fetchProducts()
////        }
////        
////        catch{
////            print("Error fetching products in VC")
////        }
//        ApiService.shared.fetchProducts { [weak self] fetchedProducts in
//            guard let self = self else { return }
//            if let fetchedProducts = fetchedProducts {
//                self.products = fetchedProducts
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            } else {
//                // Handle the error appropriately
//                print("Failed to fetch products.")
//            }
//        }
//    }
    func fetchProducts() {
        ApiService.shared.fetchProducts { [weak self] fetchedProducts in
            guard let self = self else { return }
            
            if let fetchedProducts = fetchedProducts {
                print("✅ Successfully fetched \(fetchedProducts.count) products.")
                self.products = fetchedProducts
                self.saveProductToDatabase(fetchedProducts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("❌ Failed to fetch products.")
            }
        }
    }


    func saveProductToDatabase(_ fetchedProduct : [Product]){
        for product in fetchedProduct {
            do{
                try DatabaseManager.shared.addProduct(product)
            }
            catch{
                print("Database error in save product")
            }
        }
        
    }
    
//    func deleteProduct(at index : Int){
//        let product = products[index]
//        do{
//            try DatabaseManager.shared.deleteProduct(product)
//            ApiService.shared.deleteProduct(product) { success in
//                if success{
//                    self.products.remove(at: index)
//                    self.tableView.reloadData()
//                }
//            }
//        }
//        catch{
//            print("Error deleting product")
//        }
//    }
    
    func deleteProduct(at index: Int) {
        let product = products[index]

        // Call API to delete from the server first
        ApiService.shared.deleteProduct(product) { [weak self] success in
            guard let self = self else { return }
            if success {
                do {
                    try DatabaseManager.shared.deleteProduct(product) // Now delete from local DB
                    self.products.remove(at: index) // Remove from array
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // Reload UI safely on main thread
                    }
                } catch {
                    print("Database error while deleting product")
                }
            } else {
                print("Failed to delete product from server")
            }
        }
    }

}

extension ProductListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = ("$\(product.price)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteProduct(at: indexPath.row)
        }
    }
    
}


//        let sampleProduct1 = Product(id: 0, name: "iPhone 15 Pro", price: 1499.99, qrCode: "123456789", imagePath: "image.jpg")
//
//        let sampleProduct2 = Product(id: 1, name: "Macbook m2", price: 2000, qrCode: "435634635", imagePath: "M2.jpg")
//
//        do {
//            try DatabaseManager.shared.addProduct(sampleProduct1)
//            try DatabaseManager.shared.addProduct(sampleProduct2)
//
//            let products = try DatabaseManager.shared.fetchProducts()
//            print(products) // Test Output
//        } catch {
//            print("DB Error: \(error)")
//        }
