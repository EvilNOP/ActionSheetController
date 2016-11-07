//
//  UIImage+ImageInColor.swift
//  ActionSheetController
//
//  Created by Matthew on 04/11/2016.
//  Copyright © 2016 Matthew. All rights reserved.
//

import UIKit.UIImage
import UIKit.UIColor
import CoreGraphics

extension UIImage {
    
    class func image(inColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
