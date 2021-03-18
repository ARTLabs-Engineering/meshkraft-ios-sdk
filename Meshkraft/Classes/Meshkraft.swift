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
        downloadSampleUSDZ()
    }
    
    func downloadSampleUSDZ() {
        delegate?.modelLoadStarted()
        let url = URL(string: "https://artlabs-3d.s3.eu-central-1.amazonaws.com/2a17bd30_2fe4_4202_81ad_b6cb3929e767_3e3ffd43d4.usdz")!
        let downloadTask = URLSession.shared.downloadTask(with: url) { [self] urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent("artlabs_3dmodel." + url.pathExtension)
                removeFile(fileUrl: savedURL)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                self.modelURL = savedURL
                DispatchQueue.main.async {
                    delegate?.modelLoadFinished()
                    self.presentAR()
                }
            } catch {
                print ("Meshkraft - file save error: \(error)")
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
