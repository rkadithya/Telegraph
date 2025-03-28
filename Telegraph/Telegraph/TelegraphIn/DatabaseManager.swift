//
//  DatabaseManager.swift
//  Telegraph
//
//  Created by RK Adithya on 26/03/25.
//

import Foundation
import SQLite
class DatabaseManager{
    
    static let shared = DatabaseManager()
    private var db : Connection!
    private let products = Table("products")
    private let id = SQLite.Expression<String>("id")
    private let name = SQLite.Expression<String>("name")
    private let price = SQLite.Expression<Double>("price")
    private let qrCode = SQLite.Expression<String>("qrCode")
    private let imagePath = SQLite.Expression<String>("imagePath")
    
    private init() {
        setupDatabase()
    }
    
    
    private func setupDatabase(){
        do{
            
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dbPath = documentDirectory.appendingPathComponent("products.sqlite3").path
            db = try Connection(dbPath)
            try createTable()
        }catch{
            print("Db create error in db manager - \(error.localizedDescription)")
        }
    }
    
    private func createTable() throws{
        try db.run(products.create(ifNotExists: true)  { table in
            table.column(id, primaryKey: true) // UUID as primary key
            table.column(name)
            table.column(price)
            table.column(qrCode)
            table.column(imagePath)
        })
    }
    
   func addProduct(_ product : Product) throws{
        let insert = products.insert(
            id <- product.id,
            name <- product.name,
            price <- product.price,
            qrCode <- product.qrCode,
            imagePath <- product.imagePath

        )
        
        try db.run(insert)
    }
    func fetchProducts() throws -> [Product] {
        var productList = [Product]()
        for productRow in try db.prepare(products) {
            let product = Product(
                id: productRow[id], // ✅ Use String directly
                name: productRow[name],
                price: productRow[price],
                qrCode: productRow[qrCode],
                imagePath: productRow[imagePath]
            )
            productList.append(product)
        }
        return productList
    }

    
    func updateProduct(_ product: Product) throws {
        let targetProduct = products.filter(id == product.id)
        try db.run(targetProduct.update(
            name <- product.name,
            price <- product.price,
            qrCode <- product.qrCode,
            imagePath <- product.imagePath
        ))
    }

    func deleteProduct(_ product: Product) throws {
        let targetProduct = products.filter(id == product.id)
        try db.run(targetProduct.delete())
    }


}
