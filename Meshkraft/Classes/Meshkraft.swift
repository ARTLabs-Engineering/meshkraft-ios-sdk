//
//  Meshkraft.swift
//  Meshkraft
//
//  Created by ARTLabs
//  Copyright © 2021 ARTLabs. All rights reserved.
//

import Foundation
import QuickLook
import ARKit
import WebKit
import UIKit

public protocol MeshkraftDelegate: AnyObject {
    func modelLoadStarted()
    func modelLoadFailed(message: String)
    func modelLoadFinished()
}

public class Meshkraft : NSObject, QLPreviewControllerDataSource {
    
    static let shared = Meshkraft()
    static var apiKey = ""
    var modelURL: URL?
    static var testing = false
    public weak var delegate: MeshkraftDelegate?
    
    override init(){}
    
    public static func meshkraft() -> Meshkraft{
        return shared
    }
    
    public static func setApiKey(_ apiKey: String){
        Meshkraft.apiKey = apiKey
        MeshkraftStat.sdkInit()
    }
    
    public static func setTestMode(_ testing: Bool){
        self.testing = testing
    }
    
    public static func isARSupported() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
        return ARConfiguration.isSupported
    }
    
    public func startARSession(productSKU: String){
        delegate?.modelLoadStarted()
        if !Meshkraft.isARSupported() {
            delegate?.modelLoadFailed(message: "AR is not supported on this device.")
            return
        }
        MeshkraftStat.startARSession(productSKU: productSKU)
        self.getModelURL(productSKU: productSKU, completion: {(modelUrl, errorMessage) in
            if let message = errorMessage {
                DispatchQueue.main.async {
                    self.delegate?.modelLoadFailed(message: message)
                }
            } else if let modelUrl = modelUrl, let url = URL(string: modelUrl) {
                self.downloadFile(url: url, completion: {(errorMessage) in
                    DispatchQueue.main.async {
                        if let message = errorMessage {
                            self.delegate?.modelLoadFailed(message: message)
                        } else {
                            self.presentAR()
                            self.delegate?.modelLoadFinished()
                        }
                    }
                })
            }
        })
    }
    
    public func startVTOSession(productSKU: String) {
        let viewController = VTOWebViewController(productSKU: productSKU, apiKey: Meshkraft.apiKey)
        MeshkraftStat.startVTOSession(productSKU: productSKU)
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(viewController, animated: true, completion: nil)
        }
    }
    
    public func getModelURL(productSKU: String, completion: @escaping (_ modelUrl: String?, _ errorMessage: String?) -> Void) {
        if let url = URL(string: "https://" + (Meshkraft.testing ? "staging." : "") + "api.artlabs.ai/product/" + productSKU + "?token=" + Meshkraft.apiKey) {
        let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                var errorMessage: String? = nil
                if let error = error{
                    errorMessage = "Error: \(error)"
                }
                if let httpResponse = response as? HTTPURLResponse {
                    errorMessage = self.getHttpErrorMessage(statusCode: httpResponse.statusCode)
                }
                if errorMessage != nil {
                    completion(nil, errorMessage)
                    return
                }
                guard let data = data else {
                    completion(nil, "No data received")
                    return
                }
                
                guard let product = try? JSONDecoder().decode(MeshkraftProduct.self, from: data) else {
                    completion(nil, "Couldn't decode data")
                    return
                }
                
                completion(product.assets.usdz.url, nil)
                
            }
            task.resume()
        }
    }
    
    func getHttpErrorMessage(statusCode: Int) -> String? {
        if statusCode == 401 {
            return "Please check your API key"
        } else if statusCode == 404 {
            return "Product not found"
        }else if statusCode != 200 {
            return "Response error - code: \(statusCode)"
        }
        return nil
    }
    
    func downloadFile(url: URL, completion: @escaping (_ errorMessage: String?) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { [self] urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent("artlabs_3dmodel." + url.pathExtension/*url.lastPathComponent*/)
                removeFile(fileUrl: savedURL)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                self.modelURL = savedURL
                completion(nil)
            } catch {
                completion("File error: \(error)")
            }
        }
        downloadTask.resume()
    }
    
    func removeFile(fileUrl: URL){
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do{
                try FileManager.default.removeItem(atPath: fileUrl.path)
            } catch{
                print("Meshkraft - file manager cant removeitem")
            }
        }
    }
    
    func presentAR(){
        guard modelURL != nil else { return }
        let previewController = QLPreviewController()
        previewController.dataSource = self
        UIApplication.shared.keyWindow?.rootViewController?.present(previewController, animated: true, completion: nil)
    }
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = self.modelURL!
        return url as QLPreviewItem
    }
    
}

class VTOWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    private let productSKU: String
    private let apiKey: String

    init(productSKU: String, apiKey: String) {
        self.productSKU = productSKU
        self.apiKey = apiKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let contentController = WKUserContentController()

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webConfiguration.ignoresViewportScaleLimits = true
        webConfiguration.suppressesIncrementalRendering = true
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = false
        webConfiguration.allowsPictureInPictureMediaPlayback = false
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .audio
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "close-event")
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://viewer.artlabs.ai/embed/vto?sku=\(productSKU)&token=\(apiKey)"
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
            
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "close-event" {
            // Close the WebView
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Deinit

    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "close-event")
        webView.navigationDelegate = nil
    }
}

class WeakScriptMessageDelegate: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
