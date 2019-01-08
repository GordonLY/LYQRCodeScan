//
//  ScanLineAnimator.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit

class ScanLineAnimator: UIView {
    
    var animator: UIImageView
    override init(frame: CGRect) {
        animator = UIImageView()
        super.init(frame: frame)
        self.addSubview(animator)
        self.clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    private var isAnimationing = false
    private var animationRect = CGRect.zero
}

// MARK: - ********* Public method
extension ScanLineAnimator {
    
    func startAnimating(WithRect rect:CGRect, parentView: UIView, image: UIImage?) {
        self.frame = rect
        animator.image = image
        animationRect = CGRect(origin: .zero, size: rect.size)
        parentView.addSubview(self)
        
        self.isHidden = false
        isAnimationing = true
        if (image != nil) { stepAnimation() }
    }
}
// MARK: - ********* Private method
extension ScanLineAnimator {
    
    @objc func stepAnimation() {
        if (!isAnimationing) { return }
        
        var rect = animationRect
        let hImg = animator.image!.size.height * animationRect.size.width / animator.image!.size.width
        rect.origin.y = -hImg
        rect.size.height = hImg
        animator.frame = rect
        animator.alpha = 0.0;
        UIView.animate(withDuration: 1.2, animations: { () -> Void in
            self.animator.alpha = 1.0;
            rect.origin.y = self.bounds.height - hImg
            self.animator.frame = rect
        }, completion:{ (value: Bool) -> Void in
            self.perform(#selector(ScanLineAnimator.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    func stopStepAnimating() {
        self.isHidden = true;
        isAnimationing = false;
    }
}
