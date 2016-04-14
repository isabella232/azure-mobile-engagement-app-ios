//
//  UIKit+Extensions.swift
//  Engagement
//
//  Created by Microsoft on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import MMDrawerController

//MARK: UIApplication
extension UIApplication{
  static func showHUD(){
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
  }
  static func dismissHUD(){
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
  static func setStatusBarStyle(style: UIStatusBarStyle, animated: Bool = false){
    UIApplication.sharedApplication().setStatusBarStyle(style, animated: animated)
  }
  
  static func checkStatusBarForDrawer(drawer: MMDrawerController?){
    if let drawer = drawer {
      if drawer.openSide == .Left{
        UIApplication.setStatusBarStyle(.Default)
      }else{
        UIApplication.setStatusBarStyle(.LightContent)
      }
    }
  }
}

//MARK: UIAlertController
extension UIAlertController{
  static func alertControllerPreventNotification(completion : () -> Void) -> UIAlertController {
    let alertController = UIAlertController(title: "A notification is going to be sent",
      message: "The out-of-app can't appear in the notification center if you are still in the application. Please press OK on this popup and then press the home button on your phone.",
      preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
      action in
      
      completion()
      
    })
    alertController.addAction(okAction)
    
    return alertController
  }
}

//MARK: UIViewController
extension UIViewController{
  func closeDrawer () {
    self.mm_drawerController.closeDrawerAnimated(true,
      completion: { [weak self] completed in
        UIApplication.checkStatusBarForDrawer(self?.mm_drawerController)
      })
  }
}

//MARK: UITableView
extension UITableView {
  //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
  func setAndLayoutTableFooterView(footer: UIView) {
    self.tableFooterView = footer
    footer.setNeedsLayout()
    footer.layoutIfNeeded()
    let height = footer.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    var frame = footer.frame
    frame.size.height = height
    footer.frame = frame
    self.tableFooterView = footer
  }
  
  func layoutTableFooterView() {
    if let footer = self.tableFooterView{
      let height = footer.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
      var frame = footer.frame
      frame.size.height = height
      footer.frame = frame
      self.tableFooterView = footer
    }
  }
  
  func setAndLayoutTableHeaderView(header: UIView) {
    self.tableHeaderView = header
    header.setNeedsLayout()
    header.layoutIfNeeded()
    let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    var frame = header.frame
    frame.size.height = height
    header.frame = frame
    self.tableHeaderView = header
  }
  
  func layoutTableHeaderView() {
    if let header = self.tableHeaderView{
      let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
      var frame = header.frame
      frame.size.height = height
      header.frame = frame
      self.tableHeaderView = header
    }
  }
}