//
//  FeedHeader.swift
//  Engagement
//
//  Created by Microsoft on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

/// FeedHeader
class FeedHeader: UIView {
  
  @IBOutlet weak var ibRootView: UIView!
  @IBOutlet weak var ibHeaderTitle: UILabel!
  @IBOutlet weak var ibActionButton: UIButton!
  
  var action: (() -> Void)?
  
  //MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    NSBundle.mainBundle().loadNibNamed("FeedHeader", owner: self, options: nil)
    self.frame = self.ibRootView.frame
    self.addSubview(self.ibRootView)
    
    self.ibRootView.backgroundColor = UIColor(named: UIColor.Name.PrimaryTextPressed)
    
    self.ibHeaderTitle.font = UIFont(named: UIFont.AppFont.Regular, size: 18)
    
    self.ibActionButton.addTarget(self, action: #selector(FeedHeader.didTapButton), forControlEvents: .TouchUpInside)
    self.ibActionButton.titleLabel?.font = UIFont(named: UIFont.AppFont.Regular, size: 13)
  }
  
  //MARK: Actions
  func didTapButton(){
    self.action?()
  }
  
  /**
   Update cell with correct UI content
   
   - parameter title:       Notification title
   - parameter buttonTitle: The title of the right button of section view
   - parameter action:      Target action for the right button of section view
   - parameter bgColor:     section view header background color
   - parameter titleColor:  section title color
   */
  func updateWith(title: String?, buttonTitle: String?, action : (() -> Void)? = nil, bgColor: UIColor?, titleColor: UIColor?){
    self.ibHeaderTitle.text =  title
    self.ibHeaderTitle.textColor = titleColor
    
    self.ibActionButton.setTitle(buttonTitle?.uppercaseString, forState: .Normal)
    self.action = action
    self.ibRootView.backgroundColor = bgColor
    self.ibActionButton.addTarget(self, action: #selector(FeedHeader.didTapButton), forControlEvents: .TouchUpInside)
  }
  
}
