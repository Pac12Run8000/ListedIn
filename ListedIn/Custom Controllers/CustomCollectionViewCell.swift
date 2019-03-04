//
//  CustomCollectionViewCell.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/12/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var customImageView: UIImageView!
    
    var realEstateImage:RealEstateImages? {
        didSet {
            self.customImageView.image = UIImage(data: (realEstateImage?.image)!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customImageView.backgroundColor = UIColor.brightGreen_2
        

    }
    
    
    
}

