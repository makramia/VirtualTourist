//
//  FlickrPhotoViewCell.swift
//  Virtual Tourist
//
//  Created by makramia on 25/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import UIKit

class FlickrPhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imageUrl: String = ""
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                
                self.contentView.alpha = 0.5
            }
            else
            {
              
                 self.contentView.alpha = 1.0
            }
        }
    }
}
