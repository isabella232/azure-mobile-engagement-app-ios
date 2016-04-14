//
//  AzMENotifier.swift
//  Engagement
//
//  Created by Microsoft on 16/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import QuartzCore
/*
AzME AEDefaultNotifier sublcass to bind in-app notification view informations
*/
class AzMENotifier: AEDefaultNotifier{
  override func nibNameForCategory(category: String!) -> String! {
    return "AzMENotificationView"
  }
  
  /**
   * This function is called when the notification view must be prepared, e.g. change texts,
   * icon etc... based on the specified content. This is the responsibility of this method to
   * associate actions to the buttons. At this point the notification is not yet attached to the
   * view hierarchy, so you can not have access to its superview.
   *
   * The provided custom view must contains the following subviews:
   *
   *  - `UIImageView` with tag 1 to display the notification icon
   *  - `UILabel` with tag 2 to display the notification's title
   *  - `UILabel` with tag 3 to display the notification's message
   *  - `UIImageView` with tag 4 to display the additional notification image
   *  - `UIButton` with tag 5 used when the notification is 'actioned'
   *  - `UIButton` with tag 6 used when the notification is 'exited'
   *
   * params: content Content to be notified.
   * params: view View used to display the notification.
   * - note: Some "dispatch_after" hacks here due to UI force changes failures (layoutIfNeeded/setNeedsLayout), to improve.
   */
  override func prepareNotificationView(view: UIView!, forContent content: AEInteractiveContent!) {
    
    super.prepareNotificationView(view, forContent: content)
    
    if let imageView = view.viewWithTag(1) as? UIImageView {
      imageView.contentMode = .ScaleAspectFit
      if let notificationItem = content.notificationImage {
        imageView.image = notificationItem
      } else {
        imageView.image = UIImage(named: "Icon512")?.imageWithInsets(UIEdgeInsetsMake(0, 0, 45, 0))
      }
    }
    
    if let titleLabel = view.viewWithTag(2) as? UILabel{
      titleLabel.textColor = UIColor(named: UIColor.Name.GeneralText)
      titleLabel.font = UIFont(named: UIFont.AppFont.Medium, size: 18)
      titleLabel.text = content.notificationTitle
      titleLabel.sizeToFit()
    }
    
    if let messageLabel = view.viewWithTag(3) as? UILabel{
      messageLabel.textColor = UIColor(named: UIColor.Name.SecondaryText)
      messageLabel.font = UIFont(named: UIFont.AppFont.Regular, size: 16)
      messageLabel.text = content.notificationMessage
      // If your label is included in a nib or storyboard as a subview of the view of a ViewController that uses
      // autolayout, then putting your sizeToFit call into viewDidLoad won't work, because autolayout sizes and
      // positions the subviews after viewDidLoad is called and will immediately undo the effects of your
      // sizeToFit call. However, calling sizeToFit from within viewDidLayoutSubviews will work.
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        messageLabel.sizeToFit()
      }
    }
    
    if let closeButton = view.viewWithTag(6) as? UIButton{
      closeButton.setImage(AzIcon.iconClose(20).imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysTemplate),
        forState: .Normal)
      closeButton.tintColor = UIColor(named: UIColor.Name.SmallMentions)
    }
    
    if let contentView = view.viewWithTag(10) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        
        contentView.layer.cornerRadius = 5
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = CGSizeZero
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        contentView.layer.masksToBounds = false
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds).CGPath
      }
    }
    
    
    if content.category != nil{
      // In case of "INTERSTITIAL" category, we remove the in-app notification view and perform the notification action.
      if content.category == Config.AzMESDK.interstitialCategory {
        if let contentView = view.viewWithTag(10) {
          view.hideAndDisable()
          contentView.hideAndDisable()
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            view.superview?.hideAndDisable()
          }
        }
        // We delayed the notification action to be performed after the AzME SDK notification preparation.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
          content.actionNotification(true)
        }
        // In case of "POP-UP" category, we customize the in-app notification.
      } else if content.category == Config.AzMESDK.popUpCategory{
        AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.InAppPopUpNotifications.displayInAppPopUp,
          extras: nil)
        let t =  content.notificationTitle ?? ""
        let alertController = UIAlertController(title: t,
          message: content.notificationMessage ?? "",
          preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: content.actionLabel ?? "Ok", style: UIAlertActionStyle.Default, handler: {
          action in
          
          content.actionNotification(true)
          
        })
        let cancel = UIAlertAction(title: content.exitLabel ?? L10n.tr("close.button"), style: UIAlertActionStyle.Cancel, handler: {
          action in
          content.exitNotification()
        })
        alertController.addAction(okAction)
        alertController.addAction(cancel)
        alertController.view.tintColor = UIColor(named: UIColor.Name.PrimaryTheme)
        if let contentView = view.viewWithTag(10) {
          view.hideAndDisable()
          contentView.hideAndDisable()
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            view.superview?.hideAndDisable()
          }
        }
        DeepLinkHelper.rootNavigationViewController()?.presentViewController(alertController, animated: true, completion: nil)
      }
    } else {
      if let contentView = view.viewWithTag(10) {
        view.showAndEnable()
        contentView.showAndEnable()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
          view.superview?.hideAndDisable()
        }
      }
    }
  }
}

extension UIView {
  
  func hideAndDisable() {
    self.hidden = true
    self.userInteractionEnabled = false
  }
  
  func showAndEnable() {
    self.hidden = false
    self.userInteractionEnabled = true
  }
  
}

extension UIImage {
  
  func imageWithInsets(insets: UIEdgeInsets) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(
      CGSizeMake(self.size.width + insets.left + insets.right,
        self.size.height + insets.top + insets.bottom), false, self.scale)
    UIGraphicsGetCurrentContext()
    let origin = CGPoint(x: insets.left, y: insets.top)
    self.drawAtPoint(origin)
    let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return imageWithInsets
  }
  
}