//
//  MeshkraftProduct.swift
//  Meshkraft
//
//  Created by Irmak Ozonay on 19.03.2021.
//

import Foundation

struct MeshkraftProduct: Decodable {
    let category: String
    let name: String
    let models: [Model]
    
    struct Model: Decodable {
        let status: String
        let name: String
        let file: File
        
        struct File: Decodable {
            let ext: String
            let url: String
        }
    }
}
