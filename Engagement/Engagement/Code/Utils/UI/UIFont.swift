//
//  UIFont.swift
//  Engagement
//
//  Created by Microsoft on 11/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

extension UIFont {
  enum AppFont : String {
    case Regular = ".SFUIDisplay-Regular"
    case Medium  = ".SFUIDisplay-Medium"
    case Bold    = ".SFUIDisplay-Bold"
    case Light   = ".SFUIDisplay-Light"
    case Italic  = ".SFUIText-Italic"
  }
  
  /**
   Create an return a desired default App Font
   
   - parameter name: The AppFont enum font name
   - parameter size: desired size of your string
   
   - returns: Custom UIFont
   */
  convenience init(named name: AppFont, size:CGFloat) {
    self.init(name:name.rawValue, size:size)!
  }
}
