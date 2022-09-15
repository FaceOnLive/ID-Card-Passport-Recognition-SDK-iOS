//
//  CameraViewController.swift
//  TTVFaceDemo
//
//  Created by user on 10/28/21.
//

import UIKit
import AVKit

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
       
    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var resultView: FaceView!
    
    var mode: Int = 0
    var captureDevice: AVCaptureDevice? = nil
    var captureSession: AVCaptureSession? = nil
    var cameraInited: Bool = false
    var processingDone: Int = 0
    var cameraRunning: Bool = false
    var startTime: Double = 0
    var mrzValidCount = -1
    
    static var registerTemplates = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.backgroundColor = UIColor.clear
        self.resultView.backgroundColor = UIColor.clear
        
        self.cameraInited = false
        setupCamera()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            if let viewController = segue.destination as? ResultViewController {
                if let result = sender as? NSDictionary {
                    viewController.result = result
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraRunning = true
        startTime = Date().timeIntervalSince1970
    }	
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraRunning = false
    }
    
    func setCameraRunning(state: Bool) {
        cameraRunning = state
        self.mrzValidCount = -1
        startTime = Date().timeIntervalSince1970
    }
    
    
    fileprivate func setupCamera() {
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        self.captureDevice = captureDevice
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraView.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        print("camera running: ", self.cameraRunning)
        if(self.cameraRunning == false) {
            return
        }
        
        if(Date().timeIntervalSince1970 - startTime <= 1) {
            return
        }

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
               
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
        
        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(image, from: image.extent) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            return
        }

        let capturedImage = UIImage(cgImage: cg, scale: 1.0, orientation: .upMirrored).fixOrientation()
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        let result = TTVIDCardEngine.getInstance().recognition(capturedImage) as NSDictionary
        var resultStr = ""
        var score = Float(0)
        for (key, value) in result {
            
            let keyStr = key as! String
            if(keyStr == "image" || keyStr == "position") {
                continue
            } else if(keyStr == "score") {
                score = (result["score"] as! NSNumber).floatValue
                continue
            }

            if(keyStr == "ocr" || keyStr == "barcode" || keyStr == "mrz" || keyStr == "nation") {
                
                if(keyStr == "mrz") {
                    if(mrzValidCount == -1) {
                        mrzValidCount = 0
                    }
                    
                    let mrzValues = value as! NSDictionary
                    if((mrzValues["mrzValid"] as! NSNumber).boolValue == false) {
                        mrzValidCount += 1
                    } else {
                        mrzValidCount = 0
                    }
                }
                
                
                do {
                    let jsonData: Data = try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                    resultStr += (keyStr + ": " + jsonString!)
                    resultStr += "\n"
                } catch {
                }
            } else {
                let jsonString = value as! String
                resultStr += (keyStr + ": " + jsonString)
                resultStr += "\n"
            }
        }
        
        DispatchQueue.main.async {
                       
            if(resultStr.isEmpty) {
                self.textView.text = ""
                self.textView.backgroundColor = UIColor.clear
                self.self.mrzValidCount = -1
            } else {
//                self.textView.text = resultStr
//                self.textView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
            }
                        
            self.resultView.setFrameRect(frameSize: capturedImage.size)
            self.resultView.setFaceResults(faceResults: result)

            if(score >= 96 && self.cameraRunning == true && (self.mrzValidCount == -1 || self.mrzValidCount >= 3 || self.mrzValidCount == 0)) {
                self.cameraRunning = false
                self.mrzValidCount = -1
                self.resultView.setFaceResults(faceResults: nil)
                
                print("show result, send data")
                self.performSegue(withIdentifier: "showResult", sender: result)
            }
        }
    }
}
