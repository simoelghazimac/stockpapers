//
//  UIImageViewHelper.swift
//  Wallpapers
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Nuke

extension UIImageView {
    var averageColor: UIColor? {
        return self.image?.averageColor
    }
    
    var cropRatio: CGFloat? {
        if self.image != nil {
            return self.image!.getCropRatio()
        }
        
        return nil
    }
    
    func smoothLoad(source src: URL, onComplete completion: @escaping () -> ()) -> Void {
        let opts = ImageLoadingOptions(transition: .fadeIn(duration: 0.25))

        Nuke.loadImage(with: src, options: opts, into: self, progress: nil) { (_, _) in
            completion()
        }
    }
    
    func loadImageFrom(source string: String) -> Void {
        return self.loadImageFrom(source: URL(string: string)!)
    }
    
    func loadImageFrom(source url: URL) -> Void {
        DispatchQueue.main.async {
            let data = try? Data.init(contentsOf: url)
            
            if let data = data {
                self.image = UIImage(data: data);
            }
        }
    }
    
    func getCroppedImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            return image
        }
        
        return nil
    }
    
    func getAverageColor() -> UIColor? {
        return self.averageColor
    }
    
    func getCropRatio() -> CGFloat? {
        return self.cropRatio
    }
}



