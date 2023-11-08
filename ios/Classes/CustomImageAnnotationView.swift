//
//  CustomImageAnnotationView.swift
//  flutter_vnptmap_gl
//
//  Created by Võ Toàn on 08/11/2022.
//

import UIKit
import Mapbox

class CustomImageAnnotationView: MGLAnnotationView {
    var imageView: UIImageView!
    
    required init(reuseIdentifier: String?, image: UIImage) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.imageView = UIImageView(image: image)
        self.imageView.center = CGPoint(x: self.imageView.frame.size.width / 2,
                                        y: 0.0)
        self.addSubview(self.imageView)
        self.frame = self.imageView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
