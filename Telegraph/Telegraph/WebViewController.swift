//
//  WebViewController.swift
//  Telegraph
//
//  Created by RK Adithya on 27/03/25.
//


import UIKit
import WebKit
import SocketIO

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Auto-layout
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Load Telegraph Web App
        if let url = URL(string: "http://localhost:3000") {
            webView.load(URLRequest(url: url))
        }
        
        // Setup WebSocket Listener
        setupSocketConnection()
    }
    
    // MARK: - WebSocket Setup
    func setupSocketConnection() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        
        // Listen for product updates
        socket.on("productUpdated") { (dataArray, ack) in
            if let data = dataArray.first as? [String: Any] {
                print("Product Updated: \(data)")
                self.fetchLatestProducts()
            }
        }
        
        socket.connect()
    }
    
    // MARK: - Fetch Latest Products
    func fetchLatestProducts() {
        guard let url = URL(string: "http://localhost:3000/products") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            if let data = data {
                do {
                    let products = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Latest Products: \(products)")
                } catch {
                    print("JSON Parsing Error: \(error)")
                }
            }
        }.resume()
    }
}



