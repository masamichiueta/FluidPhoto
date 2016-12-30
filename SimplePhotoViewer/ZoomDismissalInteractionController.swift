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
    var fromViewBackgroundColor: UIColor?
    
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
        
        let contentFromVC: UIViewController
        if fromVC is UINavigationController {
            contentFromVC = fromVC.childViewControllers[0]
            let nav = fromVC as! UINavigationController
            nav.navigationBar.backgroundColor = .white
        } else {
            contentFromVC = fromVC
        }
        
        fromReferenceImageView.isHidden = true
        
        let anchorPoint = CGPoint(x: fromReferenceImageViewFrame.midX, y: fromReferenceImageViewFrame.midY)
        let translatedPoint = gestureRecognizer.translation(in: fromReferenceImageView)
        
        let verticalDelta = translatedPoint.y < 0 ? 0 : translatedPoint.y
        let backgroundAlpha = backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
        let scale = scaleFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
        
        contentFromVC.view.backgroundColor = .clear
        fromVC.view.alpha = backgroundAlpha
        animator.dimmingView?.alpha = backgroundAlpha
        
        animator.transitionImageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x, y: anchorPoint.y + translatedPoint.y)
        
        animator.transitionImageView?.center = newCenter

        
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
                        animator.transitionImageView?.frame = fromReferenceImageViewFrame
                        animator.dimmingView?.alpha = 1.0
                        fromVC.view.alpha = 1.0
                },
                    completion: { completed in
                        let nav = fromVC as! UINavigationController
                        nav.navigationBar.backgroundColor = .clear
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        contentFromVC.view.backgroundColor = self.fromViewBackgroundColor
                        animator.transitionImageView?.removeFromSuperview()
                        animator.dimmingView?.removeFromSuperview()
                        animator.transitionImageView = nil
                        animator.dimmingView = nil
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
        let finalAlpha: CGFloat = 0.0
        let totalAvailableAlpha = startingAlpha - finalAlpha
        
        let maximumDelta = view.bounds.height / 4.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        
        return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha)
    }
    
    func scaleFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingScale:CGFloat = 1.0
        let finalScale: CGFloat = 0.5
        let totalAvailableScale = startingScale - finalScale
        
        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        
        return startingScale - (deltaAsPercentageOfMaximun * totalAvailableScale)
    }
}

extension ZoomDismissalInteractionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        guard let animator = self.animator as? PhotoZoomAnimator,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageViewFrame = animator.fromDelegate?.referenceImageViewFrameInTransitioningView(for: animator),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator)
             else {
                return
        }
        
        let contentFromVC: UIViewController
        if fromVC is UINavigationController {
            contentFromVC = fromVC.childViewControllers[0]
        } else {
            contentFromVC = fromVC
        }
        
        self.fromViewBackgroundColor = UIColor(cgColor: contentFromVC.view.backgroundColor!.cgColor)
        self.fromReferenceImageViewFrame = fromReferenceImageViewFrame

        let referenceImage = fromReferenceImageView.image!
        
        if animator.dimmingView == nil {
            let dimmingView = UIView(frame: toVC.view.bounds)
            dimmingView.backgroundColor = self.fromViewBackgroundColor
            dimmingView.alpha = 1.0
            animator.dimmingView = dimmingView
            containerView.insertSubview(dimmingView, belowSubview: fromVC.view)
        }
        
        if animator.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            animator.transitionImageView = transitionImageView
            containerView.insertSubview(transitionImageView, belowSubview: fromVC.view)
        }
        
        
    }
}
