//
//  CTColumnView.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import UIKit

class CTColumnView: UIView {

    // MARK: Properties
    var ctFrame: CTFrame!
    var images: [(image: UIImage, frame: CGRect)] = []
    
    // MARK: Initializers
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(frame: CGRect, ctFrame: CTFrame) {
        super.init(frame: frame)
        
        self.ctFrame = ctFrame
        backgroundColor = .white
    }
    
    // MARK: Life Cycle
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Flip coordinate system
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        CTFrameDraw(ctFrame, context)
        
        for imageData in images {
            if let image = imageData.image.cgImage {
                let imgBounds = imageData.frame
                context.draw(image, in: imgBounds)
            }
        }
    }

}
