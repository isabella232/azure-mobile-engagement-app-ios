//
//  MenuViewController.swift
//  Engagement
//
//  Created by Microsoft on 08/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

private let kTableLeftMargin: CGFloat = 20
private let kTableHeaderHeight: CGFloat = 25
private let kTableExpandableRow = 3

/// Left Side Menu
class MenuViewController: UIViewController {
  
  @IBOutlet weak var ibTableView: UITableView!
  
  var expendedItems = [MenuItem]()
  var expended = false
  var dataSource = [(sectionName: String, items: [MenuItem])]()
  var currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //because drawer have to be able to push controller, it is embeded into a UINavContr. Fix with top View Xib and header adjustements
    let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
    header.backgroundColor = .whiteColor()
    ibTableView.tableHeaderView = header
    
    ibTableView.registerNib(UINib(nibName: MenuCell.identifier, bundle: nil),
      forCellReuseIdentifier: MenuCell.identifier)
    
    self.dataSource = MenuItem.defaultDataSoruceFromMenuController(self)
    self.expendedItems = MenuItem.helpfulLinksFromMenuController(self)
    self.ibTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0),
      animated: false,
      scrollPosition: UITableViewScrollPosition.Top)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    ibTableView.selectRowAtIndexPath(self.currentIndexPath, animated: false, scrollPosition: .Middle)
  }
  
  //MARK: Events behaviors
  
  /**
  Open an Internet Link via a SafariViewController
  
  - parameter link: the string URL
  */
  func openLink(link: String){
    if let URL = NSURL(string: link) {
      let controller = AzMESafariController(URL: URL)
      self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
  }
  
  /**
   Expand or collapse Helpful links inside the menu
   */
  func toogleLinks() {
    self.expended = !self.expended
    
    if self.expended == true{
      self.dataSource[1].items.insertContentsOf(expendedItems, at: kTableExpandableRow)
      self.ibTableView.beginUpdates()
      self.ibTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 1),
        NSIndexPath(forRow: 4, inSection: 1),
        NSIndexPath(forRow: 5, inSection: 1),
        NSIndexPath(forRow: 6, inSection: 1),
        NSIndexPath(forRow: 7, inSection: 1)],
        withRowAnimation: .Fade)
      self.ibTableView.endUpdates()
      
    }else{
      self.dataSource[1].items.removeRange(Range(start: kTableExpandableRow,end: kTableExpandableRow + expendedItems.count))
      self.ibTableView.beginUpdates()
      self.ibTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 1),
        NSIndexPath(forRow: 4, inSection: 1),
        NSIndexPath(forRow: 5, inSection: 1),
        NSIndexPath(forRow: 6, inSection: 1),
        NSIndexPath(forRow: 7, inSection: 1)],
        withRowAnimation: .Fade)
      self.ibTableView.endUpdates()
    }
  }
}

// MARK: - UITableViewDelegate
extension MenuViewController : UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let menuItem = dataSource[indexPath.section].items[indexPath.row]
    
    if indexPath.isEqual(self.currentIndexPath) == false || indexPath.row == kTableExpandableRow || menuItem.isChild == false {
      
      if let selectAction = menuItem.selectedCompletion{
        let cell = tableView.dequeueReusableCellWithIdentifier(MenuCell.identifier, forIndexPath: indexPath) as! MenuCell
        cell.toggleIndicator()
        selectAction()
      }
      else if let controller = menuItem.initViewController?()
      {
        self.currentIndexPath = indexPath
        self.mm_drawerController.setCenterViewController(UINavigationController(rootViewController: controller),
          withCloseAnimation: true,
          completion: { [weak self] (bool) in
            UIApplication.checkStatusBarForDrawer(self?.mm_drawerController)
          })
      }
    }else{
      self.closeDrawer()
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let sectionTitle = dataSource[section].sectionName
    
    guard sectionTitle.isEmpty == false else{
      return nil
    }
    
    let headerView =  UIView(frame: CGRect(x: 0, y: 5, width: self.view.frame.size.width, height: kTableHeaderHeight))
    
    headerView.backgroundColor = UIColor(named: UIColor.Name.SecondaryText)
    
    let frame = CGRect(x: kTableLeftMargin,
      y: 0,
      width: headerView.frame.width - kTableLeftMargin,
      height: kTableHeaderHeight)
    
    let label = UILabel(frame: frame)
    label.font = UIFont(named: UIFont.AppFont.Medium, size: 15)
    label.text = sectionTitle
    label.textColor = .whiteColor()
    headerView.addSubview(label)
    
    return headerView
    
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return dataSource[section].sectionName.isEmpty ? 0 : kTableHeaderHeight
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
}

// MARK: - UITableViewDataSource
extension MenuViewController : UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource[section].items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let menuItem = dataSource[indexPath.section].items[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(MenuCell.identifier, forIndexPath: indexPath) as! MenuCell
    cell.menuItem = menuItem
    
    if menuItem.separator == true {
      cell.separatorInset = UIEdgeInsetsZero
    }else{
      cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
    }
    return cell
  }
  
  
}