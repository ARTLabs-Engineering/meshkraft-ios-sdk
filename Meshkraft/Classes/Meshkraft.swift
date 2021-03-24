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

public protocol MeshkraftDelegate {
    func modelLoadStarted()
    func modelLoadFailed(message: String)
    func modelLoadFinished()
}

public class Meshkraft : NSObject, QLPreviewControllerDataSource {
    
    static let shared = Meshkraft()
    static var apiKey = ""
    var modelURL: URL?
    static var testing = false
    public var delegate : MeshkraftDelegate?
    
    override init(){}
    
    public static func meshkraft() -> Meshkraft{
        return shared
    }
    
    public static func setApiKey(_ apiKey: String){
        Meshkraft.apiKey = apiKey
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
    
    public func getModelURL(productSKU: String, completion: @escaping (_ modelUrl: String?, _ errorMessage: String?) -> Void) {
        if let url = URL(string: "https://" + (Meshkraft.testing ? "staging." : "") + "api.artlabs.ai/secure/product/" + productSKU) {
        var request = URLRequest(url: url)
            print(url)
        request.setValue(Meshkraft.apiKey, forHTTPHeaderField: "x-api-key")
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
                if let productModel = product.models.first(where: { $0.file.ext == ".usdz" }) {
                    completion(productModel.file.url, nil)
                }
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
