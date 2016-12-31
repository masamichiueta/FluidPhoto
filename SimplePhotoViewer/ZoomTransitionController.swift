//
//  ZoomTransitionController.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/29.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ZoomTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    let animator: PhotoZoomAnimator
    let interactionController: ZoomDismissalInteractionController
    var isInteractive: Bool = false
    
    weak var fromDelegate: PhotoZoomAnimatorDelegate?
    weak var toDelegate: PhotoZoomAnimatorDelegate?
    
    override init() {
        animator = PhotoZoomAnimator()
        interactionController = ZoomDismissalInteractionController()
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.presenting = true
        self.animator.fromDelegate = fromDelegate
        self.animator.toDelegate = toDelegate
        return self.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.presenting = false
        let tmp = self.fromDelegate
        self.animator.fromDelegate = self.toDelegate
        self.animator.toDelegate = tmp
        self.animator.modalPresentationStyle = dismissed.modalPresentationStyle
        return self.animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.isInteractive {
            return nil
        }
        
        self.interactionController.animator = animator
        return self.interactionController
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        self.interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
    }
    
}
