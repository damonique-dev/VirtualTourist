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
        imageView.image = image
        if imageView.image != nil {
            activityIndicator.stopAnimating()
        }
    }
}
