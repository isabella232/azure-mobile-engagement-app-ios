//
//  AzMEInAppNotificationView.swift
//  Engagement
//
//  Created by Microsoft on 18/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

/// Local Fake InApp AzME notification
class AzMEInAppNotificationView: UIView {
  
  @IBOutlet var ibRootView: UIView!
  @IBOutlet weak var ibTitleLabel: UILabel!
  @IBOutlet weak var ibMessageLabel: UILabel!
  @IBOutlet weak var ibContentView: UIView!
  @IBOutlet weak var ibCloseButton: UIButton!
  
  private var announcementVM: AnnouncementViewModel?
  
  //MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  init(announcement: AnnouncementViewModel){
    self.announcementVM = announcement
    super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    self.commonInit()
  }
  
  func commonInit() {
    NSBundle.mainBundle().loadNibNamed("AzMEInAppNotificationView", owner: self, options: nil)
    self.frame = self.ibRootView.frame
    self.addSubview(self.ibRootView)
    
    ibTitleLabel.textColor = UIColor(named: UIColor.Name.GeneralText)
    ibTitleLabel.font = UIFont(named: UIFont.AppFont.Medium, size: 17)
    
    ibMessageLabel.textColor = UIColor(named: UIColor.Name.SecondaryText)
    ibMessageLabel.font = UIFont(named: UIFont.AppFont.Regular, size: 15)
    
    self.ibTitleLabel.text = self.announcementVM?.title
    self.ibMessageLabel.text = self.announcementVM?.body
    
    ibCloseButton.setImage(AzIcon.iconClose(18).imageWithSize(CGSize(width: 18, height: 18)).imageWithRenderingMode(.AlwaysTemplate),
      forState: .Normal)
    ibCloseButton.tintColor = UIColor(named: UIColor.Name.SmallMentions)
    
  }
  
  func applyShadow(){
    self.ibContentView.layer.cornerRadius = 5
    self.ibContentView.layer.shadowOpacity = 1
    self.ibContentView.layer.shadowRadius = 5
    self.ibContentView.layer.shadowOffset = CGSizeZero
    self.ibContentView.layer.shadowColor = UIColor.blackColor().CGColor
    self.ibContentView.layer.masksToBounds = false
    self.ibContentView.layer.shadowPath = UIBezierPath(rect: self.ibContentView.bounds).CGPath
  }
  
  //MARK: Actions
  @IBAction func didTapCloseButton(sender: AnyObject) {
    UIView.animateWithDuration(0.3,
      animations: { () -> Void in
        self.alpha = 0
      }){ (completed) -> Void in
        self.removeFromSuperview()
    }
  }
  
  @IBAction func didTapActionButton(sender: AnyObject)
  {
    UIView.animateWithDuration(0.3,
      animations: { () -> Void in
        self.alpha = 0
      }){ (completed) -> Void in
        self.announcementVM?.action?()
        self.removeFromSuperview()
        
    }
  }
}
