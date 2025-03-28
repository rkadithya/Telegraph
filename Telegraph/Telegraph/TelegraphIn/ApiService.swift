//
//  ApiService.swift
//  Telegraph
//
//  Created by RK Adithya on 27/03/25.
//

import Foundation

class ApiService {
    
    static let shared = ApiService()
    private let baseUrl = "http://localhost:3000/products"
    func fetchProducts(completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: baseUrl) else {
            print("❌ Invalid API URL: \(baseUrl)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ No data received from API.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            print("📦 Raw JSON Response: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")

            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    completion(products)
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    func addProduct(_ product: Product, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(product)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
    
    func updateProduct(_ product: Product, completion: @escaping (Bool) -> Void) {
        let id = product.id // Convert UUID to String
        guard let url = URL(string: "\(baseUrl)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(product)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
    
    func deleteProduct(_ product: Product, completion: @escaping (Bool) -> Void) {
        let id = product.id
        guard let url = URL(string: "\(baseUrl)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" // Fix casing
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }

}
