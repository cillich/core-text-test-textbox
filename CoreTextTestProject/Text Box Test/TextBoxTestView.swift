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
    let hardCodedFontSize: CGFloat = 30


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attrString = NSAttributedString(string: stringText,
                                            attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle,
                                                         NSAttributedString.Key.font: UIFont(name: "Arial", size: hardCodedFontSize)!])
        
        
        
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Flip the coordinate system
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
// ---------------------------------------------------------------------------------------------------------
        // MARK: Option 1: Using Framesetter - Works!
        
//        let path = CGMutablePath()
//        // The rect is the bounds with insets for margins along the edges of the bounds
//        let frameRect = CGRect(origin: bounds.origin, size: bounds.size).insetBy(dx: 10.0, dy: 10.0)
//        path.addRect(frameRect)
//
//        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
//
//        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)
//
//        CTFrameDraw(frame, context)
        
// ---------------------------------------------------------------------------------------------------------
        // MARK: Option 2: Manually Calculating Line Breaks - Does not work with alignment!
        
//        let typesetter = CTTypesetterCreateWithAttributedString(attrString)
//        let availableWidth: Double = Double(bounds.size.width) - 10.0
//        var start: CFIndex = 0
//        var lineNumber: CGFloat = 1.0
//
//        while start < attrString.length {
//            let count: CFIndex = CTTypesetterSuggestLineBreak(typesetter, start, availableWidth)
//
//            let line: CTLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count))
//            context.textPosition = CGPoint(x: 5, y: bounds.size.height - (hardCodedFontSize * lineNumber)) // 30 is hardcoded
//            CTLineDraw(line, context)
//            start += count
//            lineNumber += 1
//        }
        
// ---------------------------------------------------------------------------------------------------------
        // MARK: Option 3: Manually Calculating Line Breaks With Flush(?) - Works!
        
        let typesetter = CTTypesetterCreateWithAttributedString(attrString)
        let availableWidth: Double = Double(bounds.size.width) - 10.0 // 10 leaves 5 points of margin on both sides
        var start: CFIndex = 0
        var lineNumber: CGFloat = 1.0
        
        while start < attrString.length {
            let count: CFIndex = CTTypesetterSuggestLineBreak(typesetter, start, availableWidth)
            
            let line: CTLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count))
            
            // Alignment stuff
            var flush: CGFloat
            
            switch textAlignment {
            case .left:
                flush = 0.0
            case .center:
                flush = 0.5
            case .right:
                flush = 1.0
            default:
                flush = 0.0
            }
            
            let penOffset: CGFloat = CGFloat(CTLineGetPenOffsetForFlush(line, flush, availableWidth))
            
            context.textPosition = CGPoint(x: 5 + penOffset, y: bounds.size.height - (hardCodedFontSize * lineNumber)) // 30 is hardcoded
            CTLineDraw(line, context)
            start += count
            lineNumber += 1
        }

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
