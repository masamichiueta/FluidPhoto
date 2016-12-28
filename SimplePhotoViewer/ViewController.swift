//
//  ViewController.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photos = [
            #imageLiteral(resourceName: "1"),
            #imageLiteral(resourceName: "2"),
            #imageLiteral(resourceName: "3")
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = segue.destination as! UINavigationController
            nav.transitioningDelegate = self
            let vc = nav.viewControllers[0] as! PhotoPageContainerViewController
            vc.delegate = self
            let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
            vc.currentIndex = selectedIndexPath.row
            vc.photos = self.photos
        }
    }
    
    @IBAction func backToViewController(segue: UIStoryboardSegue) {
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PhotoCollectionViewCell.self)", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.image = self.photos[indexPath.row]
        return cell
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let zoomAnimator = PhotoZoomAnimator(duration: 0.5, presenting: true)
        let nav = presented as! UINavigationController
        let containerView = nav.viewControllers[0] as! PhotoPageContainerViewController
        zoomAnimator.fromDelegate = self
        zoomAnimator.toDelegate = containerView
        return zoomAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let zoomAnimator = PhotoZoomAnimator(duration: 0.5, presenting: false)
        let nav = dismissed as! UINavigationController
        let containerView = nav.viewControllers[0] as! PhotoPageContainerViewController
        zoomAnimator.fromDelegate = containerView
        zoomAnimator.toDelegate = self
        return zoomAnimator
    }
    
}

extension ViewController: PhotoPageContainerViewControllerDelegate {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
}

extension ViewController: PhotoZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: PhotoZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: PhotoZoomAnimator) {
        
    }
    
    func referenceImageView(for zoomAnimator: PhotoZoomAnimator) -> UIImageView? {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
        let cell = self.collectionView.cellForItem(at: selectedIndexPath) as! PhotoCollectionViewCell
        
        return cell.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: PhotoZoomAnimator) -> CGRect? {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
        let cell = self.collectionView.cellForItem(at: selectedIndexPath) as! PhotoCollectionViewCell
        
        return self.collectionView.convert(cell.frame, to: self.view)
    }
}
