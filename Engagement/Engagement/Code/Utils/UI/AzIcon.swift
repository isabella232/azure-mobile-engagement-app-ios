//
//  AzIcon.swift
//  Engagement
//
//  Created by Microsoft on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import FontAwesomeKit

/*
Font Awesome icon class to generate dynamic images from a Font file SVG icons and targetted sizes
*/
class AzIcon: FAKIcon{
  struct const {
    static let fontName = "AzME_icons"      // Postscript Font File Name.
    static let fontFileName = "AzME_icons"
  }
  
  
  // MARK: - Required Overrides -
  override class func initialize () {
    self.registerIconFontWithURL(NSBundle.mainBundle().URLForResource(const.fontFileName, withExtension:"ttf"))
  }
  
  override class func iconFontWithSize(size: CGFloat) -> UIFont! {
    if let font = UIFont(name:const.fontName, size:size) {
      return font
    }
    fatalError("Unable to find font \"\(const.fontName)\"")
  }
  
  class func iconMenuAbout(size: Int = 20) -> AzIcon { return AzIcon(code: "A", size: CGFloat(size)) }
  class func iconMenuDataPush(size: Int = 20) -> AzIcon { return AzIcon(code: "B", size: CGFloat(size)) }
  class func iconMenuDemoAppBackend(size: Int = 20) -> AzIcon { return AzIcon(code: "C", size: CGFloat(size)) }
  class func iconMenuFeatures(size: Int = 20) -> AzIcon { return AzIcon(code: "D", size: CGFloat(size)) }
  class func iconMenuFullScreen(size: Int = 20) -> AzIcon { return AzIcon(code: "E", size: CGFloat(size)) }
  class func iconMenGetDeviceID(size: Int = 20) -> AzIcon { return AzIcon(code: "F", size: CGFloat(size)) }
  class func iconMenuHelpfulLinks(size: Int = 20) -> AzIcon { return AzIcon(code: "G", size: CGFloat(size)) }
  class func iconMenuHome(size: Int = 20) -> AzIcon { return AzIcon(code: "H", size: CGFloat(size)) }
  class func iconMenuInApp(size: Int = 20) -> AzIcon { return AzIcon(code: "I", size: CGFloat(size)) }
  class func iconMenuOutApp(size: Int = 20) -> AzIcon { return AzIcon(code: "J", size: CGFloat(size)) }
  class func iconMenuPoll(size: Int = 20) -> AzIcon { return AzIcon(code: "K", size: CGFloat(size)) }
  class func iconMenuPopUp(size: Int = 20) -> AzIcon { return AzIcon(code: "L", size: CGFloat(size)) }
  class func iconMenuRecentUpdates(size: Int = 20) -> AzIcon { return AzIcon(code: "M", size: CGFloat(size)) }
  class func iconMenuTwitter(size: Int = 20) -> AzIcon { return AzIcon(code: "N", size: CGFloat(size)) }
  class func iconMenuVideos(size: Int = 20) -> AzIcon { return AzIcon(code: "O", size: CGFloat(size)) }
  class func iconLogoAzme(size: Int = 20) -> AzIcon { return AzIcon(code: "P", size: CGFloat(size)) }
  class func iconCheck(size: Int = 20) -> AzIcon { return AzIcon(code: "Q", size: CGFloat(size)) }
  class func iconDocumentation(size: Int = 20) -> AzIcon { return AzIcon(code: "R", size: CGFloat(size)) }
  class func iconMSDNForum(size: Int = 20) -> AzIcon { return AzIcon(code: "S", size: CGFloat(size)) }
  class func iconPricing(size: Int = 20) -> AzIcon { return AzIcon(code: "T", size: CGFloat(size)) }
  class func iconSLA(size: Int = 20) -> AzIcon { return AzIcon(code: "U", size: CGFloat(size)) }
  class func iconUserVoiceForum(size: Int = 20) -> AzIcon { return AzIcon(code: "V", size: CGFloat(size)) }
  class func iconMenuArrow(size: Int = 20) -> AzIcon { return AzIcon(code: "W", size: CGFloat(size)) }
  class func iconMenu(size: Int = 20) -> AzIcon { return AzIcon(code: "X", size: CGFloat(size)) }
  class func iconClose(size: Int = 20) -> AzIcon { return AzIcon(code: "Y", size: CGFloat(size)) }
  
}