//
//  ScanNetAnimator.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit

class ScanNetAnimator: UIImageView {
    
    var isAnimationing = false
    var animationRect:CGRect = CGRect.zero
    
    func startAnimatingWithRect(animationRect:CGRect, parentView:UIView, image:UIImage?)
    {
        self.image = image
        self.animationRect = animationRect
        parentView.addSubview(self)
        
        self.isHidden = false
        isAnimationing = true
        
        if (image != nil) {
            stepAnimation()
        }
    }
    
    @objc func stepAnimation() {
        if (!isAnimationing) { return }
        
        var rect = animationRect
        let hImg = self.image!.size.height * animationRect.size.width / self.image!.size.width;
        
        rect.origin.y -= hImg;
        rect.size.height = hImg;
        self.frame = rect;
        
        self.alpha = 0.0;
        
        UIView.animate(withDuration: 1.2, animations: { () -> Void in
            
            self.alpha = 1.0;
            
            var rect = self.animationRect;
            let hImg = self.image!.size.height * self.animationRect.size.width / self.image!.size.width;
            
            rect.origin.y += (rect.size.height -  hImg);
            rect.size.height = hImg;
            self.frame = rect
            
        }, completion:{ (value: Bool) -> Void in
            
            self.perform(#selector(ScanNetAnimator.stepAnimation), with: nil, afterDelay: 0.3)
            
        })
    }
    
    func stopStepAnimating()
    {
        self.isHidden = true;
        isAnimationing = false;
    }
    
}
