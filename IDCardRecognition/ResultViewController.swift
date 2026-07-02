
//
//  CameraViewController.swift
//  TTVFaceDemo
//
//  Created by user on 10/28/21.
//

import UIKit
import AVKit

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
       
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var frontImg: UIImageView!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var overviewBtn: UIButton!
    @IBOutlet weak var extractedBtn: UIButton!

    @IBOutlet weak var extractedUnderline: UIView!
    @IBOutlet weak var overviewUnderLine: UIView!
    
    let cellReuseIdentifier = "cell"
    let ocrStr = "OCR Result"
    let mrzStr = "MRZ Result"
    var result: NSDictionary? = nil
    var parsedResult: [String: [String: String]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        overView.isHidden = false
        resultView.isHidden = true
        overviewUnderLine.backgroundColor = .black
        extractedUnderline.backgroundColor = .white
        overviewBtn.setTitleColor(.black, for: .normal)
        extractedBtn.setTitleColor(.darkGray, for: .normal)
        
        parsedResult = self.parseResult(result: self.result!)
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        if let vc = self.presentingViewController as? CameraViewController {
            vc.setCameraRunning(state: true)
        }
    }

    func parseResult(result: NSDictionary) -> [String: [String: String]]{
        var parsedData: [String: [String: String]] = [:]
        parsedData[ocrStr] = [:]
        if(result != nil) {
            for (key, value) in result {
                
                let keyStr = key as! String
                if(keyStr == "Quality" || keyStr == "Position") {
                    continue
                }
                
                if(keyStr == "Full Name") {
                    self.nameLbl.text = value as? String
                }
                
                if(keyStr == "Document Name") {
                    if let stateCode = self.result?["Issuing State Code"] as? String {
                        self.typeLbl.text = "\(stateCode) - \(value as? String ?? "")"
                    } else {
                        self.typeLbl.text = value as? String
                    }
                }
                
                if(keyStr == "Images") {
                    let imageValues = value as! NSDictionary
                    for(imageKey, imageValue) in imageValues {

                        do {
                            let imageStr = imageValue as! String
                            let dataDecoded: Data = Data(base64Encoded: imageStr)!
                            let decodedImage: UIImage = UIImage(data: dataDecoded)!
                            if (imageKey as! String == "Portrait") {
                                self.profileImg.image = decodedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 150, height: 150))
                            }

                            if (imageKey as! String == "Document") {
                                self.frontImg.image = decodedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 150, height: 150))
                            }
                        } catch {
                        }
                    }
                } else {
                    if(keyStr == "MRZ") {
                        do {
                            let mrzData: Data = try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                            if let mrzDict = try JSONSerialization.jsonObject(with: mrzData, options: []) as? NSDictionary {
                                parsedData[mrzStr] = [:]
                                for (subKey, subValue) in mrzDict {
                                    if let stringValue = subValue as? String {
                                        parsedData[mrzStr]?[subKey as! String] = stringValue
                                    }
                                }
                            }

                        } catch {
                        }
                    } else {
                        if let stringValue = value as? String {
                            parsedData[ocrStr]?[keyStr] = stringValue
                        }
                    }
                }
            }
        }
        return parsedData
    }
    
    @IBAction func selectOverview(_ sender: Any) {
        overView.isHidden = false
        resultView.isHidden = true
        overviewUnderLine.backgroundColor = .black
        extractedUnderline.backgroundColor = .white
        overviewBtn.setTitleColor(.black, for: .normal)
        extractedBtn.setTitleColor(.darkGray, for: .normal)
    }
    
    @IBAction func selectExtract(_ sender: Any) {
        overView.isHidden = true
        resultView.isHidden = false
        overviewUnderLine.backgroundColor = .white
        extractedUnderline.backgroundColor = .black
        extractedBtn.setTitleColor(.black, for: .normal)
        overviewBtn.setTitleColor(.darkGray, for: .normal)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return parsedResult.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = Array(parsedResult.keys)[section]
        
        // Return the number of rows in this section (the count of key-value pairs in the inner dictionary)
        return parsedResult[sectionKey]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a custom UIView for the header
        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightGray // Set background color
        
        // Add a UILabel for the section title
        let titleLabel = UILabel()
        titleLabel.text = Array(parsedResult.keys)[section] // Customize section title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout

        // Add the label to the header view
        headerView.addSubview(titleLabel)

        // Set Auto Layout constraints for the label
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseIdentifier)
        
        let sectionKey = Array(parsedResult.keys)[indexPath.section]
                
        // Get the key-value pairs in this section
        let sectionData = parsedResult[sectionKey]
        
        
        // Get the specific key for this row in the section (e.g., "name", "sex")
        let key = Array(sectionData!.keys)[indexPath.row]
        let value = sectionData?[key]
        
        // Set the cell's text
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        cell.textLabel?.textColor = .lightGray
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }
}
