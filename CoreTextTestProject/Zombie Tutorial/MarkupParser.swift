//
//  MarkupParser.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import UIKit
import CoreText

class MarkupParser: NSObject {

    // MARK: Properties
    var color: UIColor = .black
    var fontName: String = "Arial"
    var attrString: NSMutableAttributedString!
    var images: [[String: Any]] = []
    
     // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: Internal
    
    func parseMarkup(_ markup: String) {
        // Starts out empty, eventually will contain parsed markup
        attrString = NSMutableAttributedString(string: "")
        
        do {
            // Regex that matches blocks of text with tags immediately following them
            let regex = try NSRegularExpression(pattern: "(.*?)(<[^>]+>|\\Z)",
                                                options: [.caseInsensitive, .dotMatchesLineSeparators])
            
            // Search the entire range of markup for regex matches, producing array of
            // NSTextCheckingResults
            let chunks = regex.matches(in: markup,
                                       options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                       range: NSRange(location: 0,
                                                      length: markup.count))
            
            let defaultFont: UIFont = .systemFont(ofSize: UIScreen.main.bounds.size.height / 40)
            
            for chunk in chunks {
                guard let markupRange = markup.range(from: chunk.range) else { continue }
            
                let parts = markup[markupRange].components(separatedBy: "<")
                
                let font = UIFont(name: fontName, size: UIScreen.main.bounds.size.height / 40) ?? defaultFont
                
                let attrs = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font] as [NSAttributedString.Key: Any]
                
                let text = NSMutableAttributedString(string: parts[0], attributes: attrs)
                
                attrString.append(text)
                
                if parts.count <= 1 { continue }
                
                let tag = parts[1]
                
                if tag.hasPrefix("font") {
                    let colorRegex = try NSRegularExpression(pattern: "(?<=color=\")\\w+",
                                                             options: NSRegularExpression.Options(rawValue: 0))
                    colorRegex.enumerateMatches(in: tag,
                                                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                range: NSMakeRange(0, tag.count)) { (match, _, _) in
                                                            if let match = match,
                                                                let range = tag.range(from: match.range) {
                                                                let colorSel = NSSelectorFromString(tag[range]+"Color")
                                                                color = UIColor.perform(colorSel).takeRetainedValue() as? UIColor ?? .black
                                                            }
                    }
                
                    let faceRegex = try NSRegularExpression(pattern: "(?<=face=\")[^\"]+",
                                                            options: NSRegularExpression.Options(rawValue: 0))
                    
                    faceRegex.enumerateMatches(in: tag,
                                               options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                               range: NSMakeRange(0, tag.count)) { (match, _, _) in
                                                if let match = match,
                                                    let range = tag.range(from: match.range) {
                                                    fontName = String(tag[range])
                                                }
                    }
                
                    // end of font parsing
                } else if tag.hasPrefix("img") {
                    var filename: String = ""
                    let imageRegex = try NSRegularExpression(pattern: "(?<=src=\")[^\"]+",
                                                             options: NSRegularExpression.Options(rawValue: 0))
                    
                    imageRegex.enumerateMatches(in: tag,
                                                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                range: NSMakeRange(0, tag.count)) { (match, _, _) in
                                                    if let match = match,
                                                        let range = tag.range(from: match.range) {
                                                        filename = String(tag[range])
                                                    }
                    }
                    let settings = CTSettings()
                    
                    // Initially set the width of the image to the width of the column
                    var width: CGFloat = settings.columnRect.width
                    var height: CGFloat = 0
                    
                    if let image = UIImage(named: filename) {
                        height = width * (image.size.height / image.size.width)
                        
                        // If the height of the image is too tall for the column, size the height of the image
                        // to the height of the column and size down the width maintaining the aspect ratio
                        if height > settings.columnRect.height - font.lineHeight {
                            height = settings.columnRect.height - font.lineHeight
                            width = height * (image.size.width / image.size.height)
                        }
                    }
                    
                    images += [["width": NSNumber(value: Float(width)),
                                "height": NSNumber(value: Float(height)),
                                "filename": filename,
                                "location": NSNumber(value: attrString.length)]]
                    
                    struct RunStruct {
                        let ascent: CGFloat
                        let descent: CGFloat
                        let width: CGFloat
                    }
                    
                    let extentBuffer = UnsafeMutablePointer<RunStruct>.allocate(capacity: 1)
                    extentBuffer.initialize(to: RunStruct(ascent: height, descent: 0, width: width))
                    
                    var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1,
                                                           dealloc: { (pointer) in
                    }, getAscent: { (pointer) -> CGFloat in
                        let d = pointer.assumingMemoryBound(to: RunStruct.self)
                        return d.pointee.ascent
                    }, getDescent: { (pointer) -> CGFloat in
                        let d = pointer.assumingMemoryBound(to: RunStruct.self)
                        return d.pointee.descent
                    }, getWidth: { (pointer) -> CGFloat in
                        let d = pointer.assumingMemoryBound(to: RunStruct.self)
                        return d.pointee.width
                    })
                    
                    let delegate = CTRunDelegateCreate(&callbacks, extentBuffer)
                    
                    let attrDictionaryDelegate = [(kCTRunDelegateAttributeName as NSAttributedString.Key): (delegate as Any)]
                    attrString.append(NSAttributedString(string: "", attributes: attrDictionaryDelegate))
                }
                
                
            }
        } catch _ {
        }
    }
}

extension String {
    
    // Converts String's starting and ending indices (in NSRange) to String.UTF16View.Index
    // and then to String.Index which produces Range
    func range(from range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex,
                                       offsetBy: range.location,
                                       limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) else {
            return nil
        }
        
        return from ..< to
    }
}
