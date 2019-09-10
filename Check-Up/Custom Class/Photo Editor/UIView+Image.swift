//
//  UIView+Image.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension UIView {
    /**
     Convert UIView to UIImage
     */
    func toImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
//        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
//        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
//        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return snapshotImageFromMyView!
    }
}
