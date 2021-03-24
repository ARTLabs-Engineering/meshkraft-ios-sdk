//
//  ViewController.swift
//  Meshkraft
//
//  Created by ARTLabs
//  Copyright © 2021 ARTLabs. All rights reserved.
//

import UIKit
import Meshkraft

class ViewController: UIViewController, MeshkraftDelegate {

    @IBOutlet weak var startARButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skuTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Meshkraft.meshkraft().delegate = self
    }

    @IBAction func startAR(_ sender: UIButton){
        errorMessageLabel.isHidden = true
        if let sku = skuTextField.text, !sku.isEmpty {
            Meshkraft.meshkraft().startARSession(productSKU: sku)
        } else {
            Meshkraft.meshkraft().startARSession(productSKU: "nike-jester")
        }
    }
    
    @IBAction func getModelUrl(_ sender: UIButton){
        Meshkraft.meshkraft().getModelURL(productSKU: "nike-jester", completion: {(modelUrl, errorMessage) in
            print("modelUrl: \(modelUrl ?? "")")
            print("errorMessage: \(errorMessage ?? "")")
        })
    }
    
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
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

