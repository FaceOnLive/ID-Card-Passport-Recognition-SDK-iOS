//
//  ViewController.swift
//  IDCardRecognition
//
//  Created by user on 4/9/22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Replace with your license key. Get a free trial key at https://faceonlive.com
        var ret = IDSDK.setActivation("<YOUR_LICENSE_KEY>")
        print("set activation: ", ret)
        if(ret == SDK_SUCCESS.rawValue) {
            ret = IDSDK.initSDK()
            print("init sdk: ", ret)
        }

    }


    @IBAction func camera_clicked(_ sender: Any) {
        performSegue(withIdentifier: "showCamera", sender: 0)
    }
    
    @IBAction func photo_clicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        let fixed_image = image.fixOrientation()
        let result = IDSDK.idcardRecognition(fixed_image) as NSDictionary
        
        if result.count > 0 {
            do {
                if let documentName = result["Document Name"] as? String, documentName != "Unknown" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let resultVC = storyboard.instantiateViewController(withIdentifier: "resultViewController") as? ResultViewController {
                        resultVC.result = result // Replace with actual result
                        self.navigationController?.pushViewController(resultVC, animated: true)
                    }
                } else {
                    showToast(message: "Failed to recognize!")
                }
            }
        } else {
            // Show failure message
            showToast(message: "Failed to recognize!")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.frame = CGRect(x: self.view.frame.size.width / 2 - 150, y: self.view.frame.size.height - 100, width: 300, height: 50)
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    }
}

