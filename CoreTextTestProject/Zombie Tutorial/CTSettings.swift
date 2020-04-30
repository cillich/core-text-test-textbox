//
//  CTSettings.swift
//  CoreTextTestProject
//
//  Created by Claire Illich on 4/27/20.
//  Copyright © 2020 claireCreations. All rights reserved.
//

import Foundation
import UIKit

class CTSettings {
    
    // MARK: Properties
    
    let margin: CGFloat = 20
    var columnsPerPage: CGFloat!
    var pageRect: CGRect!
    var columnRect: CGRect!
    
    // MARK: Initializers
    init() {
        columnsPerPage = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 2
        pageRect = UIScreen.main.bounds.insetBy(dx: margin, dy: margin)
        columnRect  = CGRect(x: 0,
                             y: 0,
                             width: pageRect.width / columnsPerPage,
                             height: pageRect.height).insetBy(dx: margin, dy: margin)
        
    }
}
