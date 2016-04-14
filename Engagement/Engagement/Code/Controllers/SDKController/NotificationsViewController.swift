//
//  NotificationsViewController.swift
//  Engagement
//
//  Created by Microsoft on 15/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

/*
This View Controller class is used for all Notifications demonstration scenarios.
*/
class NotificationsViewController: CenterViewController {
  
  @IBOutlet weak var ibTableView: UITableView!
  @IBOutlet weak var ibHowToButton: UIButton!
  
  var notificationScreen: NotificationScreen?
  var screenType: ScreenType?
  
  //MARK: Initialization
  init(notifScreen: ScreenType){
    self.screenType = notifScreen
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  //MARK: Overriding
  override func engagementActivityName() -> String! {
    if let screenType = self.screenType{
      return AnalyticsMonitor.Activities.ActivitiesExtras.notificationExtraValueForType(screenType)
    }
    return "NotificationsViewController"
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if hasPushEnabled() == false {
      let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert,
        UIUserNotificationType.Badge,
        UIUserNotificationType.Sound],
        categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(settings)
      UIApplication.sharedApplication().registerForRemoteNotifications()
      self.dismissViewControllerAnimated(true, completion: {});
    }
    
    self.view.backgroundColor = UIColor(named: UIColor.Name.PrimaryTheme)
    
    self.ibHowToButton.backgroundColor = UIColor(named: UIColor.Name.PrimaryThemeLight)
    self.ibHowToButton.titleLabel?.font = UIFont(named: UIFont.AppFont.Regular, size: 15)
    self.ibHowToButton.setTitle(L10n.tr("out.of.app.push.notifications.footer.text"), forState: .Normal)
    self.ibHowToButton.titleLabel?.numberOfLines = 0
    self.ibHowToButton.titleLabel?.textAlignment = .Center
    
    self.ibTableView.separatorStyle = .SingleLine
    self.ibTableView.separatorColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
    self.ibTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    self.ibTableView.backgroundColor = UIColor(named: UIColor.Name.PrimaryThemeLight)
    self.ibTableView.allowsSelection = false
    self.ibTableView.rowHeight = UITableViewAutomaticDimension
    self.ibTableView.estimatedRowHeight = 100
    self.ibTableView.registerNib(UINib(nibName: NotifiActionCell.identifier, bundle: nil),
      forCellReuseIdentifier: NotifiActionCell.identifier)
    
    let footerView = SimpleHeaderLabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
    footerView.update(UIFont(named: UIFont.AppFont.Bold, size: 13),
      mainTitle: self.screenType?.footerLabelTitle,
      headerType: HeaderViewType.TableHeader)
    self.ibTableView.setAndLayoutTableFooterView(footerView)
    
    if let screenType = self.screenType{
      self.notificationScreen = NotificationScreen(rootController: self, screenType: screenType)
      self.title = self.screenType?.maintTitle
    }
    
    let headerView = NotifTableHeader()
    headerView.update(self.notificationScreen?.screenType.image,
      mainTitle: self.notificationScreen?.screenType.message)
    self.ibTableView.setAndLayoutTableHeaderView(headerView)
    self.ibTableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.ibTableView.layoutTableHeaderView()
    self.ibTableView.layoutTableFooterView()
  }
  
  @IBAction func didHowToButtonTap(sender: AnyObject) {
    if let screenType = self.screenType {
      let webController = WebViewController(howToNotificationType: screenType)
      self.navigationController?.pushViewController(webController, animated: true)
    }
  }
  
  func hasPushEnabled() -> Bool {
    if UIApplication.sharedApplication().respondsToSelector("currentUserNotificationSettings") == true {
      let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
      if (settings?.types.contains(.Alert) == true){
        return true
      }
    }
    return false;
  }
  
}

//MARK: UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let nbItems = self.notificationScreen?.dataSource?.count{
      return nbItems
    }
    return 0
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(NotifiActionCell.identifier, forIndexPath: indexPath) as! NotifiActionCell
    
    if let notificationItem = self.notificationScreen?.dataSource?[indexPath.row]{
      cell.update(notificationItem, index: indexPath, delegate: self)
    }
    if let count = self.notificationScreen?.dataSource?.count{
      if (indexPath.row == count - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
      }
    }
    cell.backgroundColor = .clearColor()
    return cell
  }
}

//MARK: NotifActionDelegate
extension NotificationsViewController: NotifActionDelegate {
  
  func didTapButton(atIndex: NSIndexPath?) {
    if let index = atIndex, notificationItem = self.notificationScreen?.dataSource?[index.row]{
      notificationItem.action()
    }
  }
  
}