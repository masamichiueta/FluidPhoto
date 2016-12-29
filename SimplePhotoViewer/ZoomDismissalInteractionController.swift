//
//  ZoomDismissalInteractionController.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/29.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ZoomDismissalInteractionController: NSObject {
    
    var transitionContext: UIViewControllerContextTransitioning?
    var animator: UIViewControllerAnimatedTransitioning?
    
    var fromReferenceImageViewFrame: CGRect?
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let transitionContext = self.transitionContext,
            let animator = self.animator as? PhotoZoomAnimator else {
            return
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator),
            let toReferenceImageView = animator.toDelegate?.referenceImageView(for: animator),
            let fromReferenceImageViewFrame = self.fromReferenceImageViewFrame
            else {
                return
        }
        
        let anchorPoint = fromVC.view.center
        let translatedPoint = gestureRecognizer.translation(in: fromVC.view)
        
        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x, y: anchorPoint.y + translatedPoint.y)
        fromReferenceImageView.center = newCenter
        
        let verticalDelta = newCenter.y - anchorPoint.y < 0 ? 0 : newCenter.y - anchorPoint.y
        
        if fromVC is UINavigationController {
            fromVC.childViewControllers[0].view.backgroundColor = UIColor(white: 1.0, alpha: backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta))
        } else {
            fromVC.view.backgroundColor = UIColor(white: 1.0, alpha: backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta))
        }
        
        toReferenceImageView.isHidden = true
        
        if gestureRecognizer.state == .ended {
            let velocity = gestureRecognizer.velocity(in: fromVC.view)
            if velocity.y < 0 || newCenter.y < anchorPoint.y {
                UIView.animate(
                    withDuration: animator.duration,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        fromReferenceImageView.frame = fromReferenceImageViewFrame
                        if fromVC is UINavigationController {
                            fromVC.childViewControllers[0].view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                        } else {
                            fromVC.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                        }
                },
                    completion: { completed in
                        toReferenceImageView.isHidden = false
                        transitionContext.cancelInteractiveTransition()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        self.transitionContext = nil
                })
                return
            }
            
            animator.animateTransition(using: transitionContext)
            self.transitionContext = nil
        }
    }
    
    func backgroundAlphaFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha:CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1
        let totalAvailableAlpha = startingAlpha - finalAlpha
        
        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        
        return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha)
    }
}

extension ZoomDismissalInteractionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let animator = self.animator as? PhotoZoomAnimator,
            let fromReferenceImageViewFrame = animator.fromDelegate?.referenceImageViewFrameInTransitioningView(for: animator) else {
                return
        }
        
        self.fromReferenceImageViewFrame = fromReferenceImageViewFrame
    }
}
