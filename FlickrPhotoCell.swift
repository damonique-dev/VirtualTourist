//
//  FlickrPhotoCell.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/24/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func setCellImage(image:UIImage?){
        dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = image
            if self.imageView.image != nil {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
