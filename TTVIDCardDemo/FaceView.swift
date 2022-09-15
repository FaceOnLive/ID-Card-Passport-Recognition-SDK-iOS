//
//  FaceView.swift
//  SmartFaceDetection
//
//  Created by Admin on 27.07.2021.
//

import UIKit

class FaceView: UIView {
    var faceResults_: NSDictionary? = nil
    var frameSize_: CGSize? = nil

    public func setFrameRect(frameSize: CGSize) {
        frameSize_ = frameSize
    }
    public func setFaceResults(faceResults: NSDictionary?) {
        faceResults_ = faceResults
        setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        if(frameSize_ == nil) {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let x_scale = Float(frameSize_!.width) / Float(rect.width)
        let y_scale = Float(frameSize_!.height) / Float(rect.height)

        context.beginPath()
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(3.0)

        if(faceResults_ != nil) {
            if(faceResults_!["position"] != nil) {
                let position = faceResults_!["position"] as! NSDictionary
                let score = (faceResults_!["score"] as! NSNumber).floatValue

                let left = (position["left"] as! NSNumber).floatValue
                let top = (position["top"] as! NSNumber).floatValue
                let right = (position["right"] as! NSNumber).floatValue
                let bottom = (position["bottom"] as! NSNumber).floatValue
                                
                let faceWidth = Float(right) - Float(left)
                let faceHeight = Float(bottom) - Float(top)
                let divider = Float(6.0)

                let color = UIColor.green
                let string = String(score)
                let attr = [NSAttributedString.Key.font: UIFont(name: "Georgia", size: 20)!, NSAttributedString.Key.foregroundColor: color]
                string.draw(at: CGPoint(x: CGFloat(left / x_scale), y: CGFloat(top / y_scale - 30)), withAttributes: attr)
                
                context.move(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat(top / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat((left + faceWidth / divider) / x_scale), y: CGFloat(top / y_scale)))

                context.move(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat(top / y_scale)));
                context.addLine(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat((top + faceHeight / divider) / y_scale)))

                context.move(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat(top / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat((right - faceWidth / divider) / x_scale), y: CGFloat(top / y_scale)))
	
                context.move(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat(top / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat((top + faceHeight / divider) / y_scale)))

                context.move(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat(bottom / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat((left + faceWidth / divider) / x_scale), y: CGFloat(bottom / y_scale)))

                context.move(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat(bottom / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat(left / x_scale), y: CGFloat((bottom - faceHeight / divider) / y_scale)))

                context.move(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat(bottom / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat((right - faceWidth / divider) / x_scale), y: CGFloat(bottom / y_scale)))

                context.move(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat(bottom / y_scale)))
                context.addLine(to: CGPoint(x: CGFloat(right / x_scale), y: CGFloat((bottom - faceHeight / divider) / y_scale)))
            }
        }
        
        context.strokePath()
    }
}
