//
//  ZoomDismissalInteractionController.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/29.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ZoomDismissalInteractionController: NSObject, UIViewControllerInteractiveTransitioning {
    
    var transitionContext: UIViewControllerContextTransitioning!
    var animator: UIViewControllerAnimatedTransitioning!
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView) {
        
    }
    
    func finishPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        
    }
}
