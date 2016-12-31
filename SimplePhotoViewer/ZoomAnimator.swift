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
    func referenceImageView(for zoomAnimator: PhotoZoomAnimator) -> UIImageView?
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: PhotoZoomAnimator) -> CGRect?
}

class PhotoZoomAnimator: NSObject {
    
    var duration: TimeInterval
    var presenting: Bool = true
    var modalPresentationStyle: UIModalPresentationStyle?
    
    weak var fromDelegate: PhotoZoomAnimatorDelegate?
    weak var toDelegate: PhotoZoomAnimatorDelegate?
    
    var transitionImageView: UIImageView?
    var dimmingView: UIView?
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {
                return
        }
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        let toContentVC: UIViewController
        if toVC is UINavigationController {
            toContentVC = toVC.childViewControllers[0]
            let nav = toVC as! UINavigationController
            nav.navigationBar.backgroundColor = .white
        } else {
            toContentVC = toVC
        }
        
        let toContentVCOriginalBackgroundColor = UIColor(cgColor: toContentVC.view.backgroundColor!.cgColor)
        toContentVC.view.backgroundColor = .clear
        
        toVC.view.alpha = 0
        toReferenceImageView.isHidden = true
        containerView.addSubview(toVC.view)
        
        if self.dimmingView == nil {
            let dimmingView = UIView(frame: toVC.view.bounds)
            dimmingView.backgroundColor = toContentVCOriginalBackgroundColor
            dimmingView.alpha = 0
            self.dimmingView = dimmingView
            containerView.insertSubview(dimmingView, belowSubview: toVC.view)
        }
        
        let referenceImage = fromReferenceImageView.image!
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.insertSubview(transitionImageView, belowSubview: toVC.view)
        }
        
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage, forView: toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [UIViewAnimationOptions.transitionCrossDissolve],
                       animations: {
                        self.transitionImageView?.frame = finalTransitionSize
                        toVC.view.alpha = 1.0
                        self.dimmingView?.alpha = 1.0
        },
                       completion: { completed in
                    
                        toVC.childViewControllers[0].view.backgroundColor = toContentVCOriginalBackgroundColor
                        
                        if toVC is UINavigationController {
                            let nav = toVC as! UINavigationController
                            nav.navigationBar.backgroundColor = .clear
                        }
                        
                        self.transitionImageView?.removeFromSuperview()
                        self.dimmingView?.removeFromSuperview()
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        
                        self.transitionImageView = nil
                        self.dimmingView = nil
                        
                        self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                        self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
            let toReferenceImageViewFrame = self.toDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {
                return
        }
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        let fromContentVC: UIViewController
        if fromVC is UINavigationController {
            fromContentVC = fromVC.childViewControllers[0]
            let nav = fromVC as! UINavigationController
            nav.navigationBar.backgroundColor = .white
        } else {
            fromContentVC = fromVC
        }
        
        let fromContentVCOriginalBackgroundColor = UIColor(cgColor: fromContentVC.view.backgroundColor!.cgColor)
        fromContentVC.view.backgroundColor = .clear
        
        toReferenceImageView.isHidden = true
        
        let referenceImage = fromReferenceImageView.image!
        
        if self.dimmingView == nil {
            let dimmingView = UIView(frame: toVC.view.bounds)
            dimmingView.backgroundColor = fromContentVCOriginalBackgroundColor
            dimmingView.alpha = 1.0
            self.dimmingView = dimmingView
            containerView.insertSubview(dimmingView, belowSubview: fromVC.view)
        }
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.insertSubview(transitionImageView, belowSubview: fromVC.view)
        }
        
        if let modalPresentationStyle = self.modalPresentationStyle {
            if modalPresentationStyle != .overCurrentContext {
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            }
        } else {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        fromReferenceImageView.isHidden = true

        let finalTransitionSize = toReferenceImageViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        fromVC.view.alpha = 0
                        self.dimmingView?.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
        },
                       completion: { completed in
                        
                        fromContentVC.view.backgroundColor = fromContentVCOriginalBackgroundColor
                        
                        if fromVC is UINavigationController {
                            let nav = fromVC as! UINavigationController
                            nav.navigationBar.backgroundColor = .clear
                        }
                        
                        self.dimmingView?.removeFromSuperview()
                        self.transitionImageView?.removeFromSuperview()
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        
                        self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                        self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension PhotoZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.presenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
