//
//  CarouselViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 3/5/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CarouselViewController: UIViewController {
    
    
    @IBOutlet var iCarouselView: iCarousel!
    
    var imagesArray:[RealEstateImages]!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "<- swipe left"
        
        view.backgroundColor = UIColor.darkgreen
        
        
        iCarouselView.type = .coverFlow
        iCarouselView.contentMode = .scaleAspectFill
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
   
    
    

}

extension CarouselViewController: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return imagesArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var imageView:UIImageView!
        if (view == nil) {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView = view as? UIImageView
        }
        imageView.image = UIImage(data: imagesArray[index].image!)
        return imageView
    }
    
}
