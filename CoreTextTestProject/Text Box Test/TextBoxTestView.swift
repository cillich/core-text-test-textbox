//
//  TextBoxTestView.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import UIKit
import CoreText

class TextBoxTestView: UIView {
    
    var stringText: String = "Hello World"
    var textAlignment: NSTextAlignment = NSTextAlignment.left


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attrString = NSAttributedString(string: stringText, attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.font: UIFont(name: "Arial", size: 30)!])
        
        
        
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Flip the coordinate system
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        //
        let path = CGMutablePath()
        // The rect is the bounds with insets for margins along the edges of the bounds
        let frameRect = CGRect(origin: bounds.origin, size: bounds.size).insetBy(dx: 10.0, dy: 10.0)
        path.addRect(frameRect)

        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)

        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)

        CTFrameDraw(frame, context)
        
    }
    
    func changeTextAlignment(alignment: NSTextAlignment) {
        self.textAlignment = alignment
        self.setNeedsDisplay()
    }
    
    func addCharToString(_ newString: String) {
        stringText += newString
        self.setNeedsDisplay()
    }
    
    func deleteLastCharFromString() {
        stringText.removeLast()
        self.setNeedsDisplay()
    }

}
