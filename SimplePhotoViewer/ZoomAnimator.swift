//
//  PhotoZoomAnimator.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol PhotoZoomAnimatorDelegate: class {
    func transitionWillStartWith(zoomAnimator: PhotoZoomAnimator)
    func transitionDidEndWith(zoomAnimator: PhotoZoomAnimator)
    func referenceImageViewFrame() -> CGRect
}

class PhotoZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval
    var presenting: Bool
    
    weak var fromDelegate: PhotoZoomAnimatorDelegate?
    weak var toDelegate: PhotoZoomAnimatorDelegate?
    
    init(duration: TimeInterval, presenting: Bool, image: UIImage, fromDelegate: PhotoZoomAnimatorDelegate?, toDelegate: PhotoZoomAnimatorDelegate?) {
        self.duration = duration
        self.presenting = presenting
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView

        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
        let fromImageViewFrame = self.fromDelegate?.referenceImageViewFrame(),
        let toImageViewFrame = self.toDelegate?.referenceImageViewFrame()
        else {
            return
        }
        
        containerView.addSubview(fromImageView)
        
        containerView.addSubview(toVC.view)
        toVC.view.isHidden = true
        
        let toViewSnapShot = toVC.view.snapshotView(afterScreenUpdates: true)!
        containerView.addSubview(toViewSnapShot)
        toViewSnapShot.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: [],
                       animations: {
                        toViewSnapShot.alpha = 1.0
                        fromImageView.frame = toImageView.frame
        },
                       completion: { completed in
                        
                        self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                        self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
                        
                        fromImageView.removeFromSuperview()
                        toViewSnapShot.removeFromSuperview()
                        
                        toVC.view.isHidden = false
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}
