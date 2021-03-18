//
//  ViewController.swift
//  Meshkraft
//
//  Created by 10302731 on 03/17/2021.
//  Copyright (c) 2021 10302731. All rights reserved.
//

import UIKit
import Meshkraft

class ViewController: UIViewController, MeshkraftDelegate {

    @IBOutlet weak var startARButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Meshkraft.setApiKey("M3QGD6HHBNLRDZQMBP")
        Meshkraft.meshkraft().delegate = self
    }

    @IBAction func startAR(_ sender: UIButton){
        Meshkraft.meshkraft().startARSession(productSKU: "")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

