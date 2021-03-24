//
//  MeshkraftStat.swift
//  Meshkraft
//
//  Created by Irmak Ozonay on 24.03.2021.
//

import Foundation

struct MeshkraftEvent: Encodable {
    let key: String
    let count = 1
    let segmentation: Segmentation
    
    struct Segmentation: Encodable {
        let api_key = Meshkraft.apiKey
        let sku: String?
        let platform = "iOS"
    }
}

class MeshkraftStat : NSObject {
    
    static func sdkInit(){
        sendStat(MeshkraftEvent(key: "SDK_INIT", segmentation: MeshkraftEvent.Segmentation(sku: nil)))
    }
    
    static func startARSession(productSKU: String){
        sendStat(MeshkraftEvent(key: "AR_SESSION_START", segmentation: MeshkraftEvent.Segmentation(sku: productSKU)))
    }
    
    static func getModelURL(productSKU: String){
        sendStat(MeshkraftEvent(key: "RETURN_MODEL", segmentation: MeshkraftEvent.Segmentation(sku: productSKU)))
    }
    
    static func sendStat(_ event: MeshkraftEvent){
        
        guard let eventJsonData = try? JSONEncoder().encode([event]) else {
            return
        }
        if let eventJson = String(data: eventJsonData, encoding: .utf8) {
            let urlString = "https://countly.artlabs.ai?app_key=aa62f3a1ade0c9026201c819a6450d5e0edd84f3&device_id=x&events=" + eventJson
            print(urlString)
            if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    guard let data = data else { return }
                    print(String(data: data, encoding: .utf8)!)
                }
                task.resume()
            }
        }
    }
    
}
