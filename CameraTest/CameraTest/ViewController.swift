//
//  ViewController.swift
//  CameraTest
//
//  Created by Irmak Ozonay on 20.08.2021.
//

import UIKit
import NextLevel

class ViewController: UIViewController/*, NextLevelDelegate, NextLevelDeviceDelegate, NextLevelPhotoDelegate*/{

    override func viewDidLoad() {
        super.viewDidLoad()
//        NextLevel.shared.delegate = self
//        NextLevel.shared.deviceDelegate = self
//        NextLevel.shared.photoDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try NextLevel.shared.start()
        } catch {
            print("NextLevel, failed to start camera session")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NextLevel.shared.stop()
    }

}

