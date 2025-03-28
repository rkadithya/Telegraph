//
//  Product.swift
//  Telegraph
//
//  Created by RK Adithya on 26/03/25.
//

import Foundation

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let qrCode: String
    let imagePath: String

    enum CodingKeys: String, CodingKey {
        case id, name, price, qrCode, imagePath
    }

    init(id: String, name: String, price: Double, qrCode: String, imagePath: String) {
        self.id = id
        self.name = name
        self.price = price
        self.qrCode = qrCode
        self.imagePath = imagePath
    }

    // Custom decoding to handle both String and Int for `id`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)  // Convert Int to String
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(Double.self, forKey: .price)
        self.qrCode = try container.decode(String.self, forKey: .qrCode)
        self.imagePath = try container.decode(String.self, forKey: .imagePath)
    }
}

