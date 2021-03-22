//
//  Meshkraft.swift
//  Meshkraft
//
//  Created by Irmak Ozonay on 17.03.2021.
//

import Foundation
import QuickLook
import ARKit

public protocol MeshkraftDelegate {
    func modelLoadStarted()
    func modelLoadFinished()
}

public class Meshkraft : NSObject, QLPreviewControllerDataSource {
    
    static let shared = Meshkraft()
    static var apiKey = ""
    var modelURL: URL?
    public var delegate : MeshkraftDelegate?
    
    override init(){}
    
    public static func meshkraft() -> Meshkraft{
        return shared
    }
    
    public static func setApiKey(_ apiKey: String){
        Meshkraft.apiKey = apiKey
    }
    public func startARSession(productSKU: String){
        delegate?.modelLoadStarted()
        self.getModelURL(productSKU: productSKU, completion: {(modelUrl) in
            if let modelUrl = modelUrl, let url = URL(string: modelUrl) {
                self.downloadUSDZFile(url: url, finished: {() in
                    DispatchQueue.main.async {
                        self.presentAR()
                        self.delegate?.modelLoadFinished()
                    }
                })
            }
        })
    }
    
    public func getModelURL(productSKU: String, completion: @escaping (_ modelUrl: String?) -> Void) {
        if let url = URL(string: "https://staging.api.artlabs.ai/secure/product/" + productSKU) {
        var request = URLRequest(url: url)
        request.setValue(Meshkraft.apiKey, forHTTPHeaderField: "x-api-key")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("No data")
                    return
                }
                guard let product = try? JSONDecoder().decode(MeshkraftProduct.self, from: data) else {
                    print("Error: Couldn't decode data")
                    return
                }
                print(product.name)
                if let productModel = product.models.first(where: { $0.file.ext == ".usdz" }) {
                    completion(productModel.file.url)
                }
            }
            task.resume()
        }
    }
    
    func downloadUSDZFile(url: URL, finished: @escaping () -> Void) {
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
                finished()
            } catch {
                print ("file error: \(error)")
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
