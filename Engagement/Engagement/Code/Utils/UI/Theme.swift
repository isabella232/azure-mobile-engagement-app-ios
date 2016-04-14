//
//  Theme.swift
//  Engagement
//
//  Created by Microsoft on 08/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

/**
 *  Configure the UI default styles like navigation bar appearence
 */
struct Theme{
  
  /**
   Prepare the default style. The method have to be initially call from the app delegate didFinishLauching method
   */
  static func prepareThemeAppearance(){
    UIApplication.setStatusBarStyle(.LightContent)
    
    //Custom UINavigationBar Appearance
    let navAppearance = UINavigationBar.appearance()
    navAppearance.barTintColor = UIColor(named: UIColor.Name.PrimaryTheme)
    navAppearance.tintColor = .whiteColor()
    navAppearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    navAppearance.translucent = false
    navAppearance.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    navAppearance.shadowImage = UIImage()
  }
}