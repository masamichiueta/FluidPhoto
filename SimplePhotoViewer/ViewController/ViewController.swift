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
    
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photos = [
            #imageLiteral(resourceName: "1"),
            #imageLiteral(resourceName: "2"),
            #imageLiteral(resourceName: "3"),
            #imageLiteral(resourceName: "4"),
            #imageLiteral(resourceName: "5"),
            #imageLiteral(resourceName: "6"),
            #imageLiteral(resourceName: "7"),
            #imageLiteral(resourceName: "8"),
            #imageLiteral(resourceName: "9"),
            #imageLiteral(resourceName: "10"),
            #imageLiteral(resourceName: "11"),
            #imageLiteral(resourceName: "12"),
            #imageLiteral(resourceName: "13"),
            #imageLiteral(resourceName: "14"),
            #imageLiteral(resourceName: "15"),
            #imageLiteral(resourceName: "16"),
            #imageLiteral(resourceName: "17"),
            #imageLiteral(resourceName: "18"),
            #imageLiteral(resourceName: "1"),
            #imageLiteral(resourceName: "2"),
            #imageLiteral(resourceName: "3"),
            #imageLiteral(resourceName: "4"),
            #imageLiteral(resourceName: "5"),
            #imageLiteral(resourceName: "6"),
            #imageLiteral(resourceName: "7"),
            #imageLiteral(resourceName: "8"),
            #imageLiteral(resourceName: "9"),
            #imageLiteral(resourceName: "10"),
            #imageLiteral(resourceName: "11"),
            #imageLiteral(resourceName: "12"),
            #imageLiteral(resourceName: "13"),
            #imageLiteral(resourceName: "14"),
            #imageLiteral(resourceName: "15"),
            #imageLiteral(resourceName: "16"),
            #imageLiteral(resourceName: "17"),
            #imageLiteral(resourceName: "18")
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = self.navigationController
            let vc = segue.destination as! PhotoPageContainerViewController
            nav?.delegate = vc.transitionController
            vc.transitionController.fromDelegate = self
            vc.transitionController.toDelegate = vc
            vc.delegate = self
            vc.currentIndex = self.selectedIndexPath.row
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
}


extension ViewController: PhotoPageContainerViewControllerDelegate {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension ViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as! PhotoCollectionViewCell
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as! PhotoCollectionViewCell
        return cell.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        self.collectionView.layoutIfNeeded()
        
        let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as! PhotoCollectionViewCell
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
}
