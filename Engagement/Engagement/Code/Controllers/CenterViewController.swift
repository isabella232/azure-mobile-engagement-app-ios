//
//  CenterViewController.swift
//  Engagement
//
//  Created by Microsoft on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

class CenterViewController: EngagementViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if self.navigationController?.viewControllers.count <= 1
    {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: AzIcon.iconMenu(18).imageWithSize(CGSizeMake(18, 18)),
        style: .Plain,
        target: self,
        action: #selector(CenterViewController.toggleDrawer))
    }
  }
  
  func toggleDrawer(){
    self.mm_drawerController.toggleDrawerSide(.Left, animated: true) { [weak self] (finished) -> Void in
      if self?.mm_drawerController.openSide == .Left{
        UIApplication.setStatusBarStyle(.Default)
      }else{
        UIApplication.setStatusBarStyle(.LightContent)
      }
    }
  }
}
