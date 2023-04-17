// MeshkraftStat.swift
// Meshkraft
//
// Created by Irmak Ozonay on 24.03.2021.
//

import Foundation

let now = Date()
let calendar = Calendar.current

struct StatPayload: Encodable {
    let source = "ar-sdk"
    let token = Meshkraft.apiKey
    let event: MeshkraftEvent
    let device_id = UUID().uuidString
    
    struct MeshkraftEvent: Encodable {
        let key: String
        let count = 1
        let segmentation: Segmentation
        
        struct Segmentation: Encodable {
            let token = Meshkraft.apiKey
            let sku: String?
            let platform = "iOS"
            let dow = calendar.component(.weekday, from: now)
            let hour = calendar.component(.hour, from: now)
        }
    }
    
}

class MeshkraftStat : NSObject {
    static let sessionId = UUID().uuidString
    static let eventApiUrl = "https://events.artlabs.ai"
    static let eventApiKey = "zzkZ58VcHc&xH%#"
    
    static func sdkInit() {
        sendStat(StatPayload(event: StatPayload.MeshkraftEvent(key: "INIT", segmentation: StatPayload.MeshkraftEvent.Segmentation(sku: nil))))
    }
    
    static func startARSession(productSKU: String) {
        sendStat(StatPayload(event: StatPayload.MeshkraftEvent(key: "START_AR", segmentation: StatPayload.MeshkraftEvent.Segmentation(sku: productSKU))))
    }
    
    static func getModelURL(productSKU: String) {
        sendStat(StatPayload(event: StatPayload.MeshkraftEvent(key: "RETURN_MODEL", segmentation: StatPayload.MeshkraftEvent.Segmentation(sku: productSKU))))
    }
    
    static func sendStat(_ event: StatPayload) {
        guard let requestData = try? JSONEncoder().encode(event) else { return }
        
        let url = URL(string: eventApiUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(eventApiKey, forHTTPHeaderField: "X-Custom-PSK")
        request.httpBody = requestData
        
        if let sentUserAgent = request.value(forHTTPHeaderField: "User-Agent") {
            print("Sent User-Agent: \(sentUserAgent)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("MeshkraftAR :: Couldn't send event: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
