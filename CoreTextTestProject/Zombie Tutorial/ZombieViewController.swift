//
//  ViewController.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import UIKit

class ZombieViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let file = Bundle.main.path(forResource: "zombies", ofType: "txt") else { return }
        
        do {
            // Load the zombie.txt file into a string
            let text = try String(contentsOfFile: file, encoding: .utf8)
            
            // Create a new parser
            let parser = MarkupParser()
            
            // Feed the text into the parser
            parser.parseMarkup(text)
            
            // Pass the returned attributed string into the view
            (view as? CTView)?.buildFrames(withAttrString: parser.attrString, andImages: parser.images)
        } catch _ {
            
        }
    }


}

