//
//  File.swift
//  
//
//  Created by Scott Lydon on 7/19/22.
//


import UIKit

extension UIImage {
    
    /// 100x100 -> max 10x10, then 10x10
    /// 100x100 -> max 20x10 then 10x10
    /// 100x100 -> max 5x10 then 5x5
    func resizeImageProportionately(maxSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = maxSize.width  / size.width
        let heightRatio = maxSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        return resizeExact(targetSize: newSize)
    }
    
    func resize(maxDimension: CGFloat) -> UIImage? {
        resizeImageProportionately(maxSize: .init(width: maxDimension, height: maxDimension))
    }
    
    func resize(to multiplier: Double) -> UIImage? {
        resizeExact(targetSize: CGSize(width: size.width * multiplier, height: size.height * multiplier))
    }
    
    func resizeExact(targetSize: CGSize) -> UIImage? {
        let rect: CGRect = .init(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var fileSizeInKB: Double? {
        (jpegData(compressionQuality: 1) ?? pngData()).map {
            Double(NSData(data: $0).count) / 1000.0
        }
    }
}

