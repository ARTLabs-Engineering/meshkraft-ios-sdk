//
//  MeshkraftProduct.swift
//  Meshkraft
//
//  Created by Irmak Ozonay on 19.03.2021.
//

import Foundation

struct MeshkraftProduct: Decodable {
    let name: String?
    let assets: Asset
    
    struct Asset: Decodable {
        let glb: AssetObject
        let usdz: AssetObject
        
        struct AssetObject: Decodable {
            let size: Double
            let url: String
        }
    }
    
}
