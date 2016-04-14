//
//  AnnouncementViewController.swift
//  Engagement
//
//  Created by Microsoft on 18/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

protocol AnnouncementIntersticialDelegate{
  func didCloseIntersticial()
  func didOpenIntersticial()
}

/// AnnouncementViewController, for local and AzME SDK
class AnnouncementViewController: AEAnnouncementViewController {
  
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var ibNavItemTitle: UINavigationItem!
  @IBOutlet weak var ibWebView: UIWebView!
  @IBOutlet weak var ibActionButton: UIButton!
  @IBOutlet weak var ibCloseButton: UIButton!
  @IBOutlet weak var ibSeparator: UIView!
  
  @IBOutlet weak var ibNavBarHeight: NSLayoutConstraint!
  private var isLocal: Bool = false
  
  private var announcementVM: AnnouncementViewModel?
  
  var intersticialDelegate: AnnouncementIntersticialDelegate?
  
  //MARK: Initialization
  override init!(announcement anAnnouncement: AEReachAnnouncement!) {
    super.init(announcement: anAnnouncement)
  }
  
  init(announcement anAnnouncement: AnnouncementViewModel, isLocal: Bool) {
    self.isLocal = true
    self.announcementVM = anAnnouncement
    super.init(nibName: nil, bundle: nil)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(nibName: nil, bundle: nil)
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ibSeparator.backgroundColor = UIColor(named: UIColor.Name.LightGrey)
    ibActionButton.tintColor = UIColor(named: UIColor.Name.PrimaryTheme)
    ibCloseButton.tintColor = UIColor(named: UIColor.Name.PrimaryTheme)
    
    if let announcement = self.announcement{
      self.announcementVM = AnnouncementViewModel(fromAnnouncement: announcement)
    }
    
    //cast here, to improve
    if let _ = parentViewController as? FullscreenInterstitialViewController {
      // Do nothing
    }
    else if isLocal == true {
      self.ibNavBarHeight.constant = 0
    }
    
    if let actionTitle = announcementVM?.actionTitle where actionTitle.isEmpty == false {
      ibActionButton.setTitle(actionTitle, forState: .Normal)
    } else {
      ibActionButton.removeFromSuperview()
    }
    
    if let exitTitle = announcementVM?.exitTitle where exitTitle.isEmpty == false {
      ibCloseButton.setTitle(exitTitle, forState: .Normal)
    } else {
      ibCloseButton.removeFromSuperview()
    }
    
    self.title = announcementVM?.title
    self.ibNavItemTitle.title = announcementVM?.title
    let mainBundle = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
    
    if let HTMLBody = announcementVM?.body{
      if announcementVM?.type == AEAnnouncementType.Text{
        let htmlContent = String(HTMLString: HTMLBody)
        ibWebView.loadHTMLString(htmlContent, baseURL: mainBundle)
      }else{
        ibWebView.loadHTMLString(HTMLBody, baseURL: mainBundle)
      }
      
    }
  }
  
  //MARK: Actions
  @IBAction func didTapActionButton(sender: AnyObject) {
    AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.ReboundScreen.viewAll, extras: nil)
    if isLocal == true{
      self.announcementVM?.action?()
    } else {
      if let delegate = self.intersticialDelegate{
        delegate.didOpenIntersticial()
      }else{
        self.action()
      }
      
    }
  }
  
  @IBAction func didTapCloseButton(sender: AnyObject) {
    AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.ReboundScreen.close, extras: nil)
    if isLocal == true{
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    else{
      
      if let delegate = self.intersticialDelegate{
        delegate.didCloseIntersticial()
      }else{
        self.exit()
      }
      
    }
  }
}
