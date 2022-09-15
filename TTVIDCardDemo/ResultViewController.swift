
//
//  CameraViewController.swift
//  TTVFaceDemo
//
//  Created by user on 10/28/21.
//

import UIKit
import AVKit

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
       
    @IBOutlet weak var tableView: UITableView!
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    let cellReuseIdentifier = "cell"
    var result: NSDictionary? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("result view conroller")
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        if let vc = self.presentingViewController as? CameraViewController {
            vc.setCameraRunning(state: true)
        }
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.animals.count
        var tableCount = 0
        if(self.result != nil) {
            for (key, value) in self.result! {
                
                let keyStr = key as! String
                if(keyStr == "image" || keyStr == "ocr" || keyStr == "barcode" || keyStr == "mrz" || keyStr == "nation") {
                    if(keyStr == "image") {
                        let imageValues = value as! NSDictionary
                        tableCount += imageValues.count
                    } else {
                        tableCount += 1
                    }
                }
            }
        }
        
        return tableCount;
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! UITableViewCell

        var itemCount: Int = 0
        if(self.result != nil) {
            for (key, value) in self.result! {
                
                let keyStr = key as! String
                if(keyStr == "mrz") {
                    if(indexPath.row == itemCount) {
                        do {
                            let jsonData: Data = try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                            
                            let repStr = jsonString!.replacingOccurrences(of: "\\", with: "")
                            cell.textLabel?.text = keyStr + ":" + repStr
                            cell.textLabel?.numberOfLines = 0
                        } catch {
                        }
                    }
                    
                    itemCount += 1
                }
            }
            for (key, value) in self.result! {
                
                let keyStr = key as! String
                if(keyStr == "image" || keyStr == "position") {
                    continue
                } else if(keyStr == "score") {
                    continue
                }

                if(keyStr == "ocr" || keyStr == "barcode" || keyStr == "nation") {
                    if(indexPath.row == itemCount) {
                        do {
                            let jsonData: Data = try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                            
                            let repStr = jsonString!.replacingOccurrences(of: "\\", with: "")
                            cell.textLabel?.text = keyStr + ":" + repStr
                            cell.textLabel?.numberOfLines = 0
                        } catch {
                        }
                    }
                    
                    itemCount += 1
                }
            }
            
            for (key, value) in self.result! {
                
                let keyStr = key as! String
                if(keyStr == "image") {
                    let imageValues = value as! NSDictionary
                    for(imageKey, imageValue) in imageValues {
                        
                        if(indexPath.row == itemCount) {
                            do {
                                let imageStr = imageValue as! String
                                cell.textLabel?.text = imageKey as! String
                                cell.textLabel?.numberOfLines = 0
                                
                                let dataDecoded: Data = Data(base64Encoded: imageStr)!
                                let decodedImage: UIImage = UIImage(data: dataDecoded)!
                                
                                cell.imageView?.image = decodedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 150, height: 150))
                            } catch {
                            }
                        }
                        
                        itemCount += 1
                    }
                }
            }
        }
        
//        // set the text from the data model
//        if(indexPath.row == 0) {
////            if(self.result != nil) {
////                cell.textLabel?.text = String(self.result!.count)
////            }
//        } else {
//            cell.textLabel?.text = self.animals[indexPath.row]
//        }

        return cell
    }
}
