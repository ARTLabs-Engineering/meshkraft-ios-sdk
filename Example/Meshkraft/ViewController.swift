//
//  ViewController.swift
//  Meshkraft
//
//  Created by ARTLabs
//  Copyright © 2021 ARTLabs. All rights reserved.
//

import UIKit
import Meshkraft

class ViewController: UIViewController {

    @IBOutlet weak var startARButton: UIButton!
    @IBOutlet weak var startVTOButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skuTextField: UITextField!
    @IBOutlet weak var errorMessageView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Meshkraft.meshkraft().delegate = self
    }

    @IBAction func startAR(_ sender: UIButton){
        errorMessageView.isHidden = true
        if let sku = skuTextField.text, !sku.isEmpty {
            Meshkraft.meshkraft().startARSession(productSKU: sku)
        } else {
            Meshkraft.meshkraft().startARSession(productSKU: "000000400245234")
        }
    }
    @IBAction func startVTO(_ sender: UIButton) {
        errorMessageView.isHidden = true
        if let sku = skuTextField.text, !sku.isEmpty {
            Meshkraft.meshkraft().startVTOSession(productSKU: sku)
        } else {
            Meshkraft.meshkraft().startVTOSession(productSKU: "1127893-RYEP")
        }
    }
    
    @IBAction func getModelUrl(_ sender: UIButton){
        Meshkraft.meshkraft().getModelURL(productSKU: "1127893-RYEP", completion: {(modelUrl, errorMessage) in
            print("modelUrl: \(modelUrl ?? "")")
            print("errorMessage: \(errorMessage ?? "")")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController: MeshkraftDelegate {
    
    func modelLoadStarted() {
        print("load started")
        startARButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func modelLoadFinished() {
        print("load finished")
        startARButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func modelLoadFailed(message: String) {
        print("load failed message: \(message)")
        startARButton.isEnabled = true
        activityIndicator.stopAnimating()
        errorMessageView.text = message
        errorMessageView.isHidden = false
    }
    
}

