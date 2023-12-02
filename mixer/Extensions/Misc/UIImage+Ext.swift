//
//  UIImage+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 7/31/23.
//

import SwiftUI

extension UIImage {
    func resizeImage(toWidth width: CGFloat) -> UIImage? {
        let aspectRatio = size.width/size.height
        let newHeight = width / aspectRatio
        UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func roundImage() -> UIImage? {
        let minEdge = min(size.width, size.height)
        let logoSquareSize = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(logoSquareSize, false, UIScreen.main.scale)
        
        let logoImageDrawRect = CGRect(
            x: (logoSquareSize.width - size.width) / 2,
            y: (logoSquareSize.height - size.height) / 2,
            width: size.width, height: size.height
        )
        draw(in: logoImageDrawRect)
        
        let logoSquareImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let logoSquareImageWidth = logoSquareImage?.size.width ?? 0
        let logoSquareImageHeight = logoSquareImage?.size.height ?? 0
        
        let logoCornerRadius = logoSquareImageWidth / 2
        UIGraphicsBeginImageContextWithOptions(logoSquareImage?.size ?? CGSize.zero, false, UIScreen.main.scale)
        
        let logoRoundedRect = CGRect(
            x: (logoSquareImageWidth - logoSquareImageWidth) / 2,
            y: (logoSquareImageHeight - logoSquareImageHeight) / 2,
            width: logoSquareImageWidth, height: logoSquareImageHeight
        )
        
        UIBezierPath(
            roundedRect: logoRoundedRect,
            cornerRadius: logoCornerRadius
        ).addClip()
        
        logoSquareImage?.draw(in: logoRoundedRect)
        
        let roundedLogoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedLogoImage
    }
}
