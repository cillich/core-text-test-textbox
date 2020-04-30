//
//  CTView.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//
// Tutorial used: https://www.raywenderlich.com/578-core-text-tutorial-for-ios-making-a-magazine-app

import UIKit
import CoreText

class CTView: UIScrollView {
    
//    // MARK: Properties
//    var attrString: NSAttributedString!
//
//    // MARK: Internal
//    func importAttrString(_ attrString: NSAttributedString) {
//        self.attrString = attrString
//    }
//
//    // Run automatically to render the view's backing layer
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        // Flip the coordinate system
//        context.textMatrix = .identity
//        context.translateBy(x: 0, y: bounds.size.height)
//        context.scaleBy(x: 1.0, y: -1.0)
//
//        let path = CGMutablePath()
//        path.addRect(bounds)
//
//        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
//
//        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)
//
//        CTFrameDraw(frame, context)
//    }
    
    // MARK: Properties
    var imageIndex: Int! // Keep track of the current image index as being drawn
    
    // Create CTColumnViews then add them to the scroll view
    func buildFrames(withAttrString attrString: NSAttributedString,
                     andImages images: [[String: Any]]) {
        // initialize imageIndex
        imageIndex = 0
        
        // Scroll behavior so scrolling snaps to page
        isPagingEnabled = true
        
        // Create each column's CTFrame of attributed text
        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        
        var pageView = UIView() // Contains each page's column subviews
        var textPos = 0 // Keeps track of the next character
        var columnIndex: CGFloat = 0.0
        var pageIndex: CGFloat = 0.0
        let settings = CTSettings()
        
        
        while textPos < attrString.length {
            if columnIndex.truncatingRemainder(dividingBy: settings.columnsPerPage) == 0 {
                
                columnIndex = 0
                pageView = UIView(frame: settings.pageRect.offsetBy(dx: pageIndex * bounds.width, dy: 0))
                addSubview(pageView)
                pageIndex += 1
            }
            
            let columnXOrigin = pageView.frame.size.width / settings.columnsPerPage
            let columnOffset = columnIndex * columnXOrigin
            let columnFrame = settings.columnRect.offsetBy(dx: columnOffset, dy: 0)
        
            let path = CGMutablePath()
            path.addRect(CGRect(origin: .zero, size: columnFrame.size))
            
            // Render new CTFrame with as much text as can fit
            let ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, nil)
            
            // Create new column
            let column = CTColumnView(frame: columnFrame, ctFrame: ctframe)
            if images.count > imageIndex {
                attachImagesWithFrame(images,
                                      ctframe: ctframe,
                                      margin: settings.margin,
                                      columnView: column)
            }
            pageView.addSubview(column)
            
            // Calculate the range of text contained within the column and increment
            // texPos by that range length to reflect the current text position
            let frameRange = CTFrameGetVisibleStringRange(ctframe)
            textPos += frameRange.length
            
            columnIndex += 1.0
        }
        
        // Setting the scroll view's content size after the loop
        contentSize = CGSize(width: pageIndex * bounds.size.width,
                             height: bounds.size.height)
    }
    
    func attachImagesWithFrame(_ images: [[String: Any]],
                               ctframe: CTFrame,
                               margin: CGFloat,
                               columnView: CTColumnView) {
        let lines = CTFrameGetLines(ctframe) as NSArray
        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(ctframe, CFRangeMake(0,0), &origins)
        
        var nextImage = images[imageIndex]
        guard var imgLocation = nextImage["location"] as? Int else { return }
        
        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex] as! CTLine
            if let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun],
            let imageFilename = nextImage["filename"] as? String,
                let img = UIImage(named: imageFilename) {
                for run in glyphRuns {
                    let runRange = CTRunGetStringRange(run)
                    if runRange.location > imgLocation || runRange.location + runRange.length <= imgLocation {
                        continue
                    }
                    
                    var imgBounds: CGRect = .zero
                    var ascent: CGFloat = 0
                    
                    imgBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, nil, nil))
                    
                    imgBounds.size.height = ascent
                    
                    let xOffset = CTLineGetOffsetForStringIndex(line,
                                                                CTRunGetStringRange(run).location,
                                                                nil)
                    imgBounds.origin.x = origins[lineIndex].x + xOffset
                    imgBounds.origin.y = origins[lineIndex].y
                    
                    columnView.images += [(image: img, frame: imgBounds)]
                    
                    imageIndex! += 1
                    
                    if imageIndex < images.count {
                        nextImage = images[imageIndex]
                        imgLocation = (nextImage["location"] as AnyObject).intValue
                    }
                }
            }
        }
    }
}
