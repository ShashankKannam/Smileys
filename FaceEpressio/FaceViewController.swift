//
//  ViewController.swift
//  FaceEpressio
//
//  Created by shashank kannam on 5/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

import UIKit

class FaceViewController: VCLLoggingViewController {
    
    @IBOutlet weak var faceView: FaceView!  {
        didSet{
            print("---FaceView outlet property is set---")
            let pinchGesture = UIPinchGestureRecognizer(target: faceView, action: #selector(faceView.changedByPinchGesture(pinch:)))
            faceView.addGestureRecognizer(pinchGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleEyes(byReactingTo:)))
            tapGesture.numberOfTapsRequired = 1
            faceView.addGestureRecognizer(tapGesture)
            
            let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.increaseHapiness))
            swipeUpGesture.direction = .up
            let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.decreaseHapiness))
            swipeDownGesture.direction = .down
            faceView.addGestureRecognizer(swipeUpGesture)
            faceView.addGestureRecognizer(swipeDownGesture)
            updateUI()
        }
    }
    
    private struct HeadShake {
        static let angle = CGFloat.pi/6 // radians
        static let segementDuration: TimeInterval = 0.5 // head shake
    }
    
    private func rotateHead(by angle: CGFloat) {
        faceView.transform = faceView.transform.rotated(by: angle)
    }
     
    func sheakHead() {
        UIView.animate(withDuration: HeadShake.segementDuration, animations: { 
            self.rotateHead(by: HeadShake.angle)
        }) { finished in
            if finished {
                UIView.animate(withDuration: HeadShake.segementDuration, animations: { 
                    self.rotateHead(by: -HeadShake.angle * 2)
                }, completion: { finished in
                    if finished {
                        UIView.animate(withDuration: HeadShake.segementDuration, animations: {
                            self.rotateHead(by: HeadShake.angle)
                        })
                    }
                })
            }
        }
    }
    
    
    var expression = FacialExpression(eyes: .closed, mouth: .neutral) {
        didSet{
            updateUI()
        }
    }
    
    func increaseHapiness() {
        expression = expression.happier
    }
    
    func decreaseHapiness() {
        expression = expression.sadder
    }
    
    func toggleEyes(byReactingTo tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            let eyes: FacialExpression.Eyes = (expression.eyes == .open) ? .closed : .open
            expression = FacialExpression(eyes: eyes, mouth: expression.mouth)
        }
    }
    
    private let mouthCurvatures: [FacialExpression.Mouth: CGFloat] = [.grin : 0.5, .neutral : 0.0, .frown : -1.0, .smile : 1.0, .smirk : -0.5]

    
    func updateUI(){
        switch expression.eyes {
        case .open:
            faceView?.isEyesClosed = false
        case .closed:
            faceView?.isEyesClosed = true
        case .squinting:
            //faceView?.isEyesClosed = true
            break
        }
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended,.changed,.began:
            sheakHead()
        default:
            break
        }
    }
}

