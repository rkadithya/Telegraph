//
//  AddProductViewController.swift
//  Telegraph
//
//  Created by RK Adithya on 27/03/25.
//

import UIKit

class AddProductViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtName: UITextField!
    var selectedImagePath: String?

    @IBOutlet weak var txtQrCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imgProduct.isUserInteractionEnabled = true
        imgProduct.addGestureRecognizer(tapGesture)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let image = info[.originalImage] as? UIImage {
              imgProduct.image = image
              saveImageLocally(image)
          }
          dismiss(animated: true)
      }

    
    
    func saveImageLocally(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: filename)
            selectedImagePath = filename.path
        }
    }
    @IBAction func btnSaveTapped(_ sender: Any) {
        guard let name = txtName.text,
              let priceText = txtPrice.text, let price = Double(priceText),
              let qrText = txtQrCode.text,
              let imagePath = selectedImagePath else {
            print("Missing fields: Name, Price, QR Code, or Image")
            return
        }
        
        let newProduct = Product(
            id: UUID().uuidString, // String
            name: name, // String
            price: price, // Double
            qrCode: qrText, // String
            imagePath: imagePath // String
        )
        
        do {
            try DatabaseManager.shared.addProduct(newProduct)
        } catch {
            print("Error inserting new product in btnSaveTapped()")
        }
        
        ApiService.shared.addProduct(newProduct) { success in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }


    
    
}
