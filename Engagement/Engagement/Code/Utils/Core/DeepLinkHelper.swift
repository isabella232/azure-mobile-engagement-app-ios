//
//  DeepLinkHelper.swift
//  Engagement
//
//  Created by Microsoft on 16/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import MMDrawerController


private let recentUpdatesDeepLink = Config.AzMESDK.DeepLink.recentUpdatesSubPath
private let videosDeepLink = Config.AzMESDK.DeepLink.videosSubPath
/*
Default local notifications type to simulate across the app
*/
enum AzMELocalNotification: String{
  case DeepLink, WebAnnouncement, Poll, Fullscreen
  
  static let keyNotificationType = "keyNotificationType"
  static let keyNotificationLink = "keyNotificationLink"
  static let keyNotificationContent = "keyNotificationContent"
}

/**
 *  DeepLink Helper for the App. This will manage UILocalNotifications, RemoteNotifications and some controller worflow behaviors
 */
struct DeepLinkHelper{
  
  /**
   Return true and perform related action according to the received DeepLink URLScheme
   
   - parameter url: URL Scheme received
   
   - returns: Return true if any action can be perfomed by the app
   */
  static func canManage(url: NSURL) -> Bool
  {
    if url.scheme == "http"
    {
      let controller = AzMESafariController(URL: url)
      self.rootNavigationViewController()?.presentViewController(controller, animated: true, completion: nil)
    }
    else if url.path == recentUpdatesDeepLink
    {
      self.pushViewController(RecentUpdatesController())
    }
    else if url.path == videosDeepLink
    {
      self.pushViewController(VideosViewController())
    }
    else if url.path == Config.AzMESDK.DeepLink.productSubPath
    {
      self.pushViewController(ProductViewController())
    }
    
    return false
  }
  
  /**
   Manage a UILocalNotification to simulate Push & DeepLinking management in local
   
   - parameter userInfo: The content of the local notification received
   */
  static func manageLocalNotification(userInfo: [NSObject : AnyObject]?)
  {
    
    if let userInfo = userInfo,
      type = userInfo[AzMELocalNotification.keyNotificationType] as? String,
      notificationType = AzMELocalNotification(rawValue: type)
    {
      switch notificationType
      {
      case .DeepLink:
        if let linkString = userInfo[AzMELocalNotification.keyNotificationLink] as? String,
          let URL = NSURL(string: linkString)
        {
          DeepLinkHelper.canManage(URL)
        }
        break
      case .WebAnnouncement:
        if let content = userInfo[AzMELocalNotification.keyNotificationContent] as? [NSObject : AnyObject]{
          
          var fakeAnnouncement = AnnouncementViewModel()
          fakeAnnouncement.title = content["title"] as? String
          fakeAnnouncement.actionTitle = content["actionButton"] as? String
          fakeAnnouncement.exitTitle = content["exitButton"] as? String
          fakeAnnouncement.body = content["body"] as? String
          fakeAnnouncement.action =
            {
              if let linkString = userInfo[AzMELocalNotification.keyNotificationLink] as? String,
                let URL = NSURL(string: linkString)
              {
                self.rootNavigationViewController()?.dismissViewControllerAnimated(true,
                  completion: { () -> Void in
                    DeepLinkHelper.canManage(URL)
                })
              }
          }
          
          let controller = UINavigationController(rootViewController: AnnouncementViewController(announcement: fakeAnnouncement,
            isLocal: true))
          
          self.rootNavigationViewController()?.presentViewController(controller,
            animated: true,
            completion: nil)
          
        }
      case .Fullscreen:
        if let content = userInfo[AzMELocalNotification.keyNotificationContent] as? [NSObject : AnyObject]{
          
          var fakeAnnouncement = AnnouncementViewModel()
          fakeAnnouncement.title = content["title"] as? String
          fakeAnnouncement.actionTitle = content["actionButton"] as? String
          fakeAnnouncement.exitTitle = content["exitButton"] as? String
          fakeAnnouncement.body = content["body"] as? String
          fakeAnnouncement.action =
            {
              if let linkString = userInfo[AzMELocalNotification.keyNotificationLink] as? String,
                let URL = NSURL(string: linkString)
              {
                self.rootNavigationViewController()?.dismissViewControllerAnimated(true,
                  completion: { () -> Void in
                    DeepLinkHelper.canManage(URL)
                })
              }
          }
          
          let controller = FullscreenInterstitialViewController(announcement: fakeAnnouncement, isLocal: true)
          //                    controller.view.backgroundColor = UIColor.clearColor()
          //                    controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
          
          
          controller.providesPresentationContextTransitionStyle = true
          controller.definesPresentationContext = true
          controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
          controller.view.backgroundColor = UIColor(named: UIColor.Name.PrimaryTheme)
          self.rootNavigationViewController()?.presentViewController(controller,
            animated: true,
            completion: nil)
        }
        break
      case .Poll: break
      }
      
    }
    
  }
  
  /**
   Analyze the announcement view model object an display a fake in-app AzME notification inside a specific controller
   
   - parameter announcement: The Announcement View Model which contains deep link and notifications informations
   - parameter inController: The controller where the in-app notification view have to be displayed
   */
  static func displayLocalInAppNotification(announcement: AnnouncementViewModel, inController: UIViewController){
    
    let notificationView = AzMEInAppNotificationView(announcement: announcement)
    notificationView.alpha = 0
    notificationView.translatesAutoresizingMaskIntoConstraints = false
    inController.view.addSubview(notificationView)
    
    let trailing = "H:|-0-[notificationView]-0-|"
    let vertical = "V:[notificationView(>=55)]-0-|"
    
    let trailingConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
      trailing,
      options: [],
      metrics: nil,
      views: ["notificationView" : notificationView])
    
    let toBottomConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
      vertical,
      options: [],
      metrics: nil,
      views: ["notificationView" : notificationView])
    
    inController.view.addConstraints(trailingConstraint)
    inController.view.addConstraints(toBottomConstraint)
    
    notificationView.sizeToFit()
    notificationView.setNeedsLayout()
    notificationView.layoutIfNeeded()
    notificationView.applyShadow()
    
    UIView.animateWithDuration(0.3) { () -> Void in
      notificationView.alpha = 1
    }
  }
  
  /**
   Push a ViewController according to the actual view navigation hierarchy
   
   - parameter controller: ViewController to be pushed
   */
  static func pushViewController(controller: UIViewController){
    self.rootNavigationViewController()?.pushViewController(controller, animated: true)
  }
  
  /**
   Present a ViewController according to the actual view navigation hierarchy
   
   - parameter controller: ViewController to be modally presented
   */
  static func presentViewController(controller: UIViewController, animated: Bool){
    self.rootNavigationViewController()?.presentViewController(controller, animated: animated, completion: nil)
  }
  
  /**
   Retrieve and optionnally return the default root UINavigationController
   
   - returns: Default root UINavigationController
   */
  static func rootNavigationViewController() -> UINavigationController?
  {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
      rootController = appDelegate.window?.rootViewController as? UINavigationController,
      drawer = rootController.viewControllers.first as? MMDrawerController,
      rootNav = drawer.centerViewController as? UINavigationController
    {
      return rootNav
    }
    return nil
  }
}
