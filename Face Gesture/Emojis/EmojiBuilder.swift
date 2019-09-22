//
//  EmojiBuilder.swift
//  Test
//
//  Created by Mike Cooper on 21/09/2019.
//  Copyright © 2019 Mike Cooper. All rights reserved.
//

import QuartzCore
import SceneKit
import SpriteKit

class EmojiBuilder: SCNNode {
    
    private let EMOJI_YELLOW =   #colorLiteral(red: 0.9986166358, green: 0.7901780605, blue: 0.1795150936, alpha: 1)
    private let EMOJI_SPHERE_RADIUS = CGFloat(0.035)
    
    private let frames: [UIImage]
    private let sphereGeometry: SCNGeometry

    init(type: Expression) {
        self.frames = GifHelper.toImages(gifNamed: type.rawValue, withBackground: EMOJI_YELLOW)!
        self.sphereGeometry = SCNSphere.init(radius: EMOJI_SPHERE_RADIUS)
        super.init()
        self.create()
        self.addChildNode(SCNNode(geometry: sphereGeometry))
        self.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func create() {
        let scaleSf = Float(1.50) * 0.8
        let scaleVal = SCNMatrix4MakeScale(1.85 * scaleSf, 1 * scaleSf, 0)
        let offsetSf = Float(-0.3) * 0.65
        let offsetVal =  SCNMatrix4MakeTranslation(3.1 * offsetSf, 0.75 * offsetSf, 0)
        sphereGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Mult(scaleVal, offsetVal)
        sphereGeometry.firstMaterial?.diffuse.contents = frames[0]
    }
    
    private func startAnimating() {
        let duration = TimeInterval(Float.greatestFiniteMagnitude)
        let changeFrame = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in
            let fps = 17.0
            let frame = (Int(Double(elapsedTime) * fps) % self.frames.count)
            self.sphereGeometry.firstMaterial!.diffuse.contents = self.frames[frame]
        }
        self.runAction(changeFrame)
    }
    
    private func getImage(fileName: String) -> UIImage {
        return UIImage( named: fileName)!.withBackground(color: EMOJI_YELLOW)!
    }
}

class GifHelper {
    class func toImages(gifNamed: String, withBackground: UIColor? = nil) -> [UIImage]? {

        guard let bundleURL = Bundle.main
            .url(forResource: gifNamed, withExtension: "gif") else {
                print("This image named \"\(gifNamed)\" does not exist!")
                return nil
        }

        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Cannot turn image named \"\(gifNamed)\" into NSData")
            return nil
        }

        let gifOptions = [
            kCGImageSourceShouldAllowFloat as String : true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String : true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String : true as NSNumber
            ] as CFDictionary

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions) else {
            debugPrint("Cannot create image source with data!")
            return nil
        }

        let framesCount = CGImageSourceGetCount(imageSource)
        var frameList = [UIImage]()

        for index in 0 ..< framesCount {

            if let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                  
                let uiImageRef = withBackground != nil ? UIImage(cgImage: cgImageRef).withBackground(color:  withBackground!)! : UIImage(cgImage: cgImageRef)
                frameList.append(uiImageRef)
            }

        }

        return frameList
    }
}

extension UIImage {
    func withBackground(color: UIColor) -> UIImage? {
      var image: UIImage?
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      if let context = UIGraphicsGetCurrentContext() {
        context.setFillColor(color.cgColor)
        context.fill(imageRect)
        draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
      }
      return nil
    }
    
}
