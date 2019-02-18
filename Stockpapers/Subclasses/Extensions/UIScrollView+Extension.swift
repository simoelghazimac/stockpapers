//
//  UIScrollViewHelper.swift
//
//  Created by Federico Vitale on 07/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {
    func getCurrentPage() -> Int {
        let w: CGFloat = frame.size.width
        let frPage = contentOffset.x / w
        
        return lroundf(Float(frPage));
    }
    
    func getFractionComplete() -> Double {
        let w = frame.size.width
        let f = contentOffset.x / w
        
        return Double(f)
    }
    
    func scrollTo(page: Int = 1, duration: TimeInterval = 0) {
        let pageSize = contentSize.width / CGFloat(subviews.count);
        
        
        if duration == 0 {
            setContentOffset(CGPoint(x: pageSize * CGFloat(page), y: 0), animated: true);
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.contentOffset = CGPoint(x: pageSize * CGFloat(page), y: 0)
            })
        }
    }
}
