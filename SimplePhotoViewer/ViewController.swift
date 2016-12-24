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
        
        let nav = presented as! UINavigationController
        let containerView = nav.viewControllers[0] as! PhotoPageContainerViewController
        return ZoomAnimator(duration: 0.3, presenting: true, fromDelegate: self, toDelegate: containerView)
    }
    
}

extension ViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func referenceImageView() -> UIImageView {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
        let cell = self.collectionView.cellForItem(at: selectedIndexPath) as! PhotoCollectionViewCell
        return cell.imageView
    }
}
