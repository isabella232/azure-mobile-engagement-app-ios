//
//  HomeViewController.swift
//  Engagement
//
//  Created by Microsoft on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import SafariServices

//MARK: HomeViewController
class HomeViewController: CenterViewController {
  
  private let kHeaderHeight = 50
  
  @IBOutlet weak var ibSubTitle: UILabel!
  @IBOutlet weak var ibMainTitle: UILabel!
  @IBOutlet weak var ibTopView: UIView!
  @IBOutlet weak var ibTableView: UITableView!
  @IBOutlet weak var ibLogo: UIImageView!
  
  var dataSource = HomeDataSource()
  
  //MARK: Overriding
  override func engagementActivityName() -> String! {
    return AnalyticsMonitor.Activities.Home
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.ibMainTitle.text = L10n.tr("application.name")
    self.ibSubTitle.text = L10n.tr("home.subtitle")
    
    ibMainTitle.font = UIFont(named: UIFont.AppFont.Bold, size: 20)
    ibSubTitle.font = UIFont(named: UIFont.AppFont.Medium, size: 14)
    
    let image = AzIcon.iconLogoAzme(85).imageWithSize(CGSize(width: 60, height: 85))
    ibLogo.image = image .imageWithRenderingMode(.AlwaysTemplate)
    ibLogo.tintColor = .whiteColor()
    
    ibTopView.backgroundColor = UIColor(named: UIColor.Name.PrimaryTheme)
    ibTableView.alwaysBounceVertical = false
    ibTableView.separatorStyle = .None
    ibTableView.rowHeight = UITableViewAutomaticDimension
    ibTableView.estimatedRowHeight = 60
    ibTableView.registerNib(UINib(nibName: TextFeedCell.identifier, bundle: nil),
      forCellReuseIdentifier: TextFeedCell.identifier)
    ibTableView.registerNib(UINib(nibName: HighlightCell.identifier, bundle: nil),
      forCellReuseIdentifier: HighlightCell.identifier)
    
    self.reloadData()
    self.changeBackgroundAccordingToOffset()
  }
  
  //MARK: Private methods
  
  /**
  Reload current data like recent updates
  Note : _be sure to empty the dataSource if a refreshControl is going to be set_
  */
  private func reloadData(){
    UIApplication.showHUD()
    AzMEService.fetchAzMERecentUpdates(forHome: true) { (channels, error) -> Void in
      UIApplication.dismissHUD()
      
      let sectionUpdates = HomeSection(title: L10n.tr("home.recent.updates.title"),
        titleColor: UIColor(named: UIColor.Name.PrimaryTheme),
        bgColor: UIColor(named: UIColor.Name.SecondaryGrey),
        buttonTitle: L10n.tr("home.recent.updates.view.all"),
        action: {
          
      })
      
      self.dataSource.sections.insert((sectionUpdates, channels), atIndex: 0)
      self.ibTableView.beginUpdates()
      self.ibTableView.insertSections(NSIndexSet(index: 0),
        withRowAnimation: UITableViewRowAnimation.Fade)
      self.ibTableView.endUpdates()
    }
  }
  
  /**
   Change the tableview background color according to its offset.
   This enable the behavior to have the tableFooterView with an "infinite" height (same colors)
   */
  private func changeBackgroundAccordingToOffset(){
    if ibTableView.contentOffset.y < 0{
      self.ibTableView.backgroundColor = UIColor(named: UIColor.Name.SecondaryGrey)
    }else{
      self.ibTableView.backgroundColor = UIColor(named: UIColor.Name.SecondaryOrange)
    }
  }
}

//MARK: UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate{
  func scrollViewDidScroll(scrollView: UIScrollView) {
    self.changeBackgroundAccordingToOffset()
  }
}

//MARK: UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataSource.sections.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.sections[section].items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let channel = dataSource.sections[indexPath.section].items[indexPath.row] as? RecentUpdate{
      let cell = tableView.dequeueReusableCellWithIdentifier(TextFeedCell.identifier, forIndexPath: indexPath) as! TextFeedCell
      cell.updateWith(channel.title, subTitle: channel.pubDate, description: channel.description)
      
      return cell
    }
    else if let highligthTitle = dataSource.sections[indexPath.section].items[indexPath.row] as? String{
      let cell = tableView.dequeueReusableCellWithIdentifier(HighlightCell.identifier, forIndexPath: indexPath) as! HighlightCell
      
      cell.updateWith(highligthTitle)
      
      return cell
    }
    return UITableViewCell()
    
  }
}

//MARK: UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return indexPath.section != 1
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    //open link
    if let channel = dataSource.sections[indexPath.section].items[indexPath.row] as? RecentUpdate,
      channelLink = channel.link
    {
      AnalyticsMonitor.Events.Home.clickArticleHome(channel.title, URL: channelLink)
      let webController = AzMESafariController(URL: NSURL(string: channelLink)!)
      webController.delegate = self
      
      self.navigationController?.presentViewController(webController, animated: true, completion: { () -> Void in
        UIApplication.setStatusBarStyle(.Default)
      })
    }
    
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = FeedHeader(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.size.width), height: kHeaderHeight))
    
    let section =  dataSource.sections[section].section
    
    headerView.updateWith(section.title,
      buttonTitle: section.buttonTitle,
      action: { [weak self] () -> Void in
        AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.Home.viewAllUpdates, extras: nil)
        self?.navigationController?.pushViewController(RecentUpdatesController(), animated: true)
      },
      bgColor: section.bgColor,
      titleColor: section.titleColor)
    
    return headerView
    
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(kHeaderHeight)
  }
  
}

//MARK: SFSafariViewControllerDelegate
extension HomeViewController: SFSafariViewControllerDelegate{
  func safariViewControllerDidFinish(controller: SFSafariViewController) {
    UIApplication.setStatusBarStyle(.LightContent)
  }
}
