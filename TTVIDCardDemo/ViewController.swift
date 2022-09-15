//
//  ViewController.swift
//  TTVIDCardDemo
//
//  Created by user on 4/9/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let ret = TTVIDCardEngine.getInstance().createSDK()
        print("ret: ", ret)
    }


    @IBAction func camera_clicked(_ sender: Any) {
        performSegue(withIdentifier: "showCamera", sender: 0)
    }
}

