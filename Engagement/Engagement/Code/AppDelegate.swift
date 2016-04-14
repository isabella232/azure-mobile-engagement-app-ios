//
//  AppDelegate.swift
//  Engagement
//
//  Created by Microsoft on 08/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import MMDrawerController
import AdSupport //Just to print your device advertisingIdentifier
import SwiftyJSON
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
    private var popOver: UIPopoverPresentationController?
  
  //MARK: UIApplicationDelegate
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    configureAzMESDK()
    
    Theme.prepareThemeAppearance()
    
    //Prepare drawer root naivigation
    let screenBounds = UIScreen.mainScreen().bounds
    
    let leftController = MenuViewController()
    let centerController = UINavigationController(rootViewController: HomeViewController())
    let drawer = MMDrawerController(centerViewController: centerController, leftDrawerViewController: leftController)
    drawer.shouldStretchDrawer = false
    drawer.maximumLeftDrawerWidth = min(screenBounds.width - 50, 310)//For iPad, not be too large
    drawer.openDrawerGestureModeMask = .PanningCenterView
    drawer.closeDrawerGestureModeMask = .All
    drawer.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(2.0))
    drawer.setGestureCompletionBlock { (drawer, gesture) -> Void in
      UIApplication.checkStatusBarForDrawer(drawer)
    }
    self.window = UIWindow(frame: screenBounds)
    self.window?.backgroundColor = UIColor.blackColor()
    
    let drawerNav = UINavigationController(rootViewController: drawer)
    drawerNav.navigationBarHidden = true
    self.window?.rootViewController = drawerNav
    
    self.window?.makeKeyAndVisible()
    
    return true
  }
  
  func application(application: UIApplication,
    didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
    fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
  {
    EngagementAgent.shared().applicationDidReceiveRemoteNotification(userInfo,
      fetchCompletionHandler: completionHandler)
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    //Only from background
    if application.applicationState != .Active{
      DeepLinkHelper.manageLocalNotification(notification.userInfo)
    }
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    EngagementAgent.shared().registerDeviceToken(deviceToken)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

    let notificationAlert = UIAlertController(title: "Notifications",
      message: L10n.tr("permission.message"),
      preferredStyle: UIAlertControllerStyle.Alert)
    
    notificationAlert.addAction(UIAlertAction(title: "Go to settings",
      style: .Default,
      handler:
      { (action: UIAlertAction!) in
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
          UIApplication.sharedApplication().openURL(url)
        }
    }))
    notificationAlert.addAction(UIAlertAction(title: "Cancel",
      style: .Cancel,
      handler: { (action: UIAlertAction!) in
      notificationAlert.dismissViewControllerAnimated(true, completion: nil)
    }))
    self.window?.rootViewController?.presentViewController(notificationAlert, animated: true, completion: nil)
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return DeepLinkHelper.canManage(url)
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    
    if identifier == Config.Notifications.shareIdentifier {
      let textToShare = "Product feedback"
      let objectsToShare = [textToShare]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      activityVC.popoverPresentationController?.sourceView = self.window?.rootViewController?.view
      self.window?.rootViewController?.presentViewController(activityVC, animated: true, completion: nil)
    }
    else if identifier == Config.Notifications.feedbackIdentifier {
      let mailComposerVC = MFMailComposeViewController()
      mailComposerVC.mailComposeDelegate = self
      mailComposerVC.setToRecipients([""])
      mailComposerVC.setSubject("Feedback about the recent update")
      mailComposerVC.setMessageBody("Say something", isHTML: false)
      mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
      
      // TODO: Need to updates this part.
      self.window?.rootViewController?.presentViewController(mailComposerVC, animated: true, completion: {
        UIApplication.setStatusBarStyle(.LightContent)
      })
    }
  }
  
  /**
   Configure default AzME SDK implemntation
   */
  func configureAzMESDK()
  {
    if let reachModule = AEReachModule.moduleWithNotificationIcon(UIImage(named: "")) as? AEReachModule {
      //Poll Notifications
      reachModule.registerPollController(PollViewController.classForCoder(), forCategory: kAEReachDefaultCategory)

      reachModule.registerNotifier(AzMENotifier(), forCategory: kAEReachDefaultCategory)
      reachModule.registerNotifier(AzMENotifier(), forCategory: Config.AzMESDK.popUpCategory)
      
      reachModule.registerAnnouncementController(AnnouncementViewController.classForCoder(),
        forCategory: kAEReachDefaultCategory)
      reachModule.registerAnnouncementController(FullscreenInterstitialViewController.classForCoder(),
        forCategory: Config.AzMESDK.interstitialCategory)
      reachModule.registerAnnouncementController(FullscreenInterstitialViewController.classForCoder(),
        forCategory: Config.AzMESDK.webAnnouncementCategory)
      
      reachModule.setAutoBadgeEnabled(true)
      reachModule.dataPushDelegate = self
      if Config.AzMESDK.endPoint.isEmpty == false{
        EngagementAgent.init(Config.AzMESDK.endPoint, modulesArray: [reachModule])
      }
      
    }
  }
  
}

//MARK: AEReachDataPushDelegate
extension AppDelegate: AEReachDataPushDelegate{
  
  func didReceiveStringDataPushWithCategory(category: String!, body: String!) -> Bool {
    if let dataFromString = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
      let json = JSON(data: dataFromString)
      
      let isDiscountAvailable = json[Config.Product.DataPush.isDiscountAvailable].boolValue
      let discountRateInPercent = json[Config.Product.DataPush.discountRateInPercent].intValue
      
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setBool(isDiscountAvailable, forKey: Config.Product.DataPush.isDiscountAvailable)
      defaults.setInteger(discountRateInPercent, forKey: Config.Product.DataPush.discountRateInPercent)
      defaults.synchronize()
      NSNotificationCenter.defaultCenter().postNotificationName(Config.Notifications.dataPushValuesUpdated, object: nil)
    }
    return true
  }
}

//MARK: MFMailComposeViewControllerDelegate
extension AppDelegate: MFMailComposeViewControllerDelegate{
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}


