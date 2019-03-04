//
//  CustomCollectionViewCell.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/12/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

protocol CustomCellDelegate:class {
    func deleteImage(cell:CustomCollectionViewCell)
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var deleteButtonBackgroundBackgroundView: UIVisualEffectView!
    
    var realEstateImage:RealEstateImages? {
        didSet {
            self.customImageView.image = UIImage(data: (realEstateImage?.image)!)
        }
    }
    
    var isEditing:Bool = false {
        didSet {
            deleteButtonBackgroundBackgroundView.isHidden = !isEditing
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customImageView.backgroundColor = UIColor.brightGreen_2
        customImageView.layer.borderWidth = 2
        customImageView.layer.borderColor = UIColor.white.cgColor


    }
    
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        print("Button pressed")
    }
    
}

