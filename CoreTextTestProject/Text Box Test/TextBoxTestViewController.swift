//
//  TextBoxTestViewController.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import UIKit

class TextBoxTestViewController: UIViewController {
    
    // MARK: View
    @IBOutlet weak var textBoxView: TextBoxTestView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textBoxView.layer.borderWidth = 2.0
        textBoxView.layer.borderColor = UIColor.blue.cgColor
        
    }
    
    // MARK: Button Actions

    @IBAction func leftAlignPressed(_ sender: Any) {
        textBoxView.changeTextAlignment(alignment: .left)
    }
    
    @IBAction func centerAlignPressed(_ sender: Any) {
        textBoxView.changeTextAlignment(alignment: .center)
    }
    
    @IBAction func rightAlignPressed(_ sender: Any) {
        textBoxView.changeTextAlignment(alignment: .right)
    }
    
    // MARK: Keyboard Presses
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        // Claire's attempt at a text engine (without showing the keyboard on the screen oops)
        if key.keyCode == .keyboardDeleteOrBackspace {
            textBoxView.deleteLastCharFromString()
        } else if key.characters.count == 1 {
            textBoxView.addCharToString(key.characters)
        }
        
        super.pressesBegan(presses, with: event)
    }
    
}
