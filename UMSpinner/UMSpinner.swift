//
//  UMSpinner.swift
//  UMSpinner
//
//  Created by Uros Mihailovic on 10/28/15.
//  Copyright © 2015 UMI. All rights reserved.
//

import UIKit
import Foundation


struct AnimatedLayer {
    var layer = CALayer()
    var animations : [CABasicAnimation] = []
}

public class UMSpinner: UIView {

    var animatedLayer: AnimatedLayer!
    var replicatorLayer: CAReplicatorLayer!
    var count : Int = 0
    var duration : Double = 0.86
    
    public func startSpinning() {
        for animation in animatedLayer.animations {
            animatedLayer.layer.addAnimation(animation, forKey: nil)
        }
    }
    
    public func stopSpinning() {
        UIView.animateWithDuration(0.4, delay: 0.2, options: .CurveLinear,
            animations: { () -> Void in
                self.alpha = 0.0
            }) { (done) -> Void in
                if done {
                    self.animatedLayer.layer.removeAllAnimations()
                }
        }
    }
    
    public func petalColor(color: CGColor) {
        animatedLayer.layer.backgroundColor = color
    }
    
    public func configureSpinner(withStyle style: UMSpinnerStyle) {
        replicatorLayer = CAReplicatorLayer()
        replicatorLayer.bounds = frame
        replicatorLayer.position = CGPoint(x: frame.width * 0.5, y: frame.width * 0.5)
        
        animatedLayer = layerToReplicate(withStyle: style)
        
        replicatorLayer.instanceCount = count
        let angleIncrement = (2.0 * CGFloat(M_PI)) / CGFloat(count)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angleIncrement, 0, 0, 1.0)
        replicatorLayer.instanceDelay = Double(duration)/Double(count)
       
        replicatorLayer.addSublayer(animatedLayer.layer)
        self.layer.addSublayer(replicatorLayer)
        
    }

    private func layerToReplicate(withStyle style: UMSpinnerStyle) -> AnimatedLayer {
        switch style {
            case .NativePetals:
                count = 14
                return createNativePetals()
            case .FadingBeads:
                count = 10
                duration = 1.0
                return createFadingBeads()
            case .FadingHexagons:
                count = 6
                return createFadingHexagons()
        }
    }

    private func createNativePetals() -> AnimatedLayer {
        var dot = AnimatedLayer()
        let replicantWidth = 0.08 * bounds.width
        dot.layer.bounds = CGRect(x: 0.0, y: 0.0, width: replicantWidth, height: 0.24 * bounds.width)
        dot.layer.position = CGPoint(x: center.x,y: center.y - 0.7 * (bounds.width) * 0.5)
        dot.layer.backgroundColor = UIColor.whiteColor().CGColor
        dot.layer.cornerRadius = replicantWidth * 0.5
        dot.layer.opacity = 0.1
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.8
        fade.toValue = 0.1
        fade.duration = duration
        fade.repeatCount = Float.infinity
        fade.removedOnCompletion = false
        
        dot.animations.append(fade)
        return dot
    }
    
    
    private func createFadingBeads() -> AnimatedLayer {
        var dot = AnimatedLayer()
        let replicantWidth = 0.16 * bounds.width
        dot.layer.bounds = CGRect(x: 0.0, y: 0.0, width: replicantWidth, height: replicantWidth)
        dot.layer.position = CGPoint(x: center.x,y: center.y - 0.7 * (bounds.width) * 0.5)
        dot.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 70.0/255.0, alpha: 1.0).CGColor
        dot.layer.cornerRadius = replicantWidth * 0.5
        dot.layer.opacity = 0.2
        dot.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = duration
        fade.repeatCount = Float.infinity
        fade.removedOnCompletion = false
        
        let shrink = CABasicAnimation(keyPath: "transform.scale")
        shrink.fromValue = 1.0
        shrink.toValue = 0.6
        shrink.duration = duration
        shrink.repeatCount = Float.infinity
        shrink.removedOnCompletion = false
        
        dot.animations.append(fade)
        dot.animations.append(shrink)
        return dot
    }
    
    private func createFadingHexagons() -> AnimatedLayer {
        var hexagon = AnimatedLayer()
        hexagon.layer = CAShapeLayer()
        let replicantWidth = 0.38 * bounds.width
        hexagon.layer.bounds = CGRect(x: 0.0, y: 0.0, width: replicantWidth, height: replicantWidth)
        hexagon.layer.position = CGPoint(x: center.x,y: center.y - 0.62 * (self.bounds.width) * 0.5)
        (hexagon.layer as! CAShapeLayer).path = hexagonPathInRect(hexagon.layer.bounds).CGPath
        (hexagon.layer as! CAShapeLayer).fillColor = UIColor(red: 251.0/255.0, green: 211.0/255.0, blue: 74.0/255.0, alpha: 1.0).CGColor
        hexagon.layer.opacity = 0.0
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.0
        fade.duration = duration
        fade.repeatCount = Float.infinity
        fade.removedOnCompletion = false
        
        hexagon.animations.append(fade)
        return hexagon
    }
}

extension UMSpinner {
   
    func pointOnCircumference(rect: CGRect, withAngle angle: CGFloat, andRadius radius: CGFloat) -> CGPoint{
        let x = rect.width * 0.5 + radius * sin(angle)
        let y = rect.height * 0.5 + radius * cos(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    func pointsOnCircumference(inRect: CGRect, numberOfPoints: UInt, withOffset offsetMultiplier: CGFloat, andRadius radius: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        let angleIncrement = (2.0*CGFloat(M_PI)/CGFloat(numberOfPoints))
        for i in 1...numberOfPoints {
            points.append(pointOnCircumference(inRect,withAngle: (CGFloat(i)*angleIncrement) + offsetMultiplier * angleIncrement, andRadius: radius))
        }
        return points
    }

    func hexagonPathInRect(rect: CGRect) -> UIBezierPath {
        let hexaPath = UIBezierPath()
        let points = pointsOnCircumference(rect,numberOfPoints: 6,withOffset: 0.5, andRadius: rect.width * 0.45)
        hexaPath.moveToPoint(points[0])
        for index in 1..<points.count {
            hexaPath.addLineToPoint(points[index])
        }
        hexaPath.closePath()
        return hexaPath
    }

}

