//
//  GetDeviceIdViewController.swift
//  Engagement
//
//  Created by Microsoft on 11/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//


import UIKit

/// To Share the AzME device ID
class GetDeviceIdViewController: CenterViewController {
  
  @IBOutlet weak var ibIcon: UIImageView!
  @IBOutlet weak var ibShareButton: AzButton!
  
  override func engagementActivityName() -> String! {
    return AnalyticsMonitor.Activities.GetDeviceID
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = L10n.tr("menu.get.device.id.title")
    
    ibShareButton.setImage(UIImage(named: "share")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    
    ibIcon.image = AzIcon.iconMenGetDeviceID(60).imageWithSize(CGSize(width: 60, height: 60)).imageWithRenderingMode(.AlwaysTemplate)
    ibIcon.tintColor = UIColor(named: UIColor.Name.LightGrey)
  }
  
  //MARK: Actions
  @IBAction func didTapShareButton(sender: AnyObject)
  {
    AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.GetDeviceID.share, extras: nil)
    if let azmeDeviceIdentifier = EngagementAgent.shared()?.deviceId(){
      let objectsToShare = [azmeDeviceIdentifier]
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
      {
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (activityTypeString, completed, items, error) in
          if completed == true && error == nil{
            if (activityTypeString == UIActivityTypeCopyToPasteboard){
              AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.GetDeviceID.copy, extras: nil)
            }else{
              AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.GetDeviceID.share, extras: nil)
            }
          }
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.presentViewController(activityVC, animated: true, completion: nil)
        }
      }
    }
  }
}
