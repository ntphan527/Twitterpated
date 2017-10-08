//
//  ImageUtil.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 10/1/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class ImageUtil: NSObject {

    class func loadImage(imageUrl: URL, loadImageView: UIImageView) {
        let imageRequest = URLRequest(url: imageUrl)
        
        loadImageView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    loadImageView.alpha = 0.0
                    loadImageView.image = image
                    loadImageView.contentMode = .scaleAspectFill
                    loadImageView.clipsToBounds = true
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        loadImageView.alpha = 1.0
                    })
                } else {
                    loadImageView.image = image
                    loadImageView.contentMode = .scaleAspectFill
                    loadImageView.clipsToBounds = true
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                print(error.localizedDescription)
        })
    }
}
