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
    static let sessionId = UUID().uuidString
    
    static func sdkInit(){
        sendStat(MeshkraftEvent(key: "SDK_INIT", segmentation: MeshkraftEvent.Segmentation(sku: nil)))
    }
    
    static func startARSession(productSKU: String){
        sendStat(MeshkraftEvent(key: "AR_SESSION_START", segmentation: MeshkraftEvent.Segmentation(sku: productSKU)))
    }
    
    static func startVTOSession(productSKU: String){
        sendStat(MeshkraftEvent(key: "VTO_SESSION_START", segmentation: MeshkraftEvent.Segmentation(sku: productSKU)))
    }
    
    static func getModelURL(productSKU: String){
        sendStat(MeshkraftEvent(key: "RETURN_MODEL", segmentation: MeshkraftEvent.Segmentation(sku: productSKU)))
    }
    
    static func sendStat(_ event: MeshkraftEvent){
        guard let eventJsonData = try? JSONEncoder().encode([event]) else { return }
        guard let eventJson = String(data: eventJsonData, encoding: .utf8) else { return }
        if let encodedEventJson = eventJson.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let urlString = "https://countly.artlabs.ai/i?app_key=aa62f3a1ade0c9026201c819a6450d5e0edd84f3&device_id=" + sessionId + "&events=" + encodedEventJson
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url).resume()
            }
        }
    }
    
}
