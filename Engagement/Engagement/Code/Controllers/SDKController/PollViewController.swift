//
//  PollViewController.swift
//  Engagement
//
//  Created by Microsoft on 22/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

/// Poll ViewController for local and AzME SDK
class PollViewController: AEPollViewController {
  
  @IBOutlet weak var ibDismissButton: AzButton!
  @IBOutlet weak var ibActionButton: AzButton!
  @IBOutlet weak var ibTableView: UITableView!
  @IBOutlet weak var ibNavBar: UINavigationBar!
  @IBOutlet weak var ibcNavBarHeight: NSLayoutConstraint!
  @IBOutlet weak var ibNavBarTitleItem: UINavigationItem!
  
  private var isFake = false
  private var hasBody = false
  private var selectedChoices = [String : (choiceId: String, indexPath: NSIndexPath)]()
  
  var reachPollViewModel : PollViewModel?
  
  //MARK: Initialization
  override init!(poll: AEReachPoll!) {
    super.init(nibName: "PollViewController", bundle: nil)
    self.poll = poll
    self.reachPollViewModel = PollViewModel(fromPoll: poll)
  }
  
  init(pollModel: PollViewModel){
    super.init(nibName: "PollViewController", bundle: nil)
    self.reachPollViewModel = pollModel
    self.isFake = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if self.isFake == true{
      self.ibcNavBarHeight.constant = 0
      self.title = self.reachPollViewModel?.title
    }
    self.ibNavBarTitleItem.title = self.reachPollViewModel?.title
    self.view.backgroundColor = UIColor(named: UIColor.Name.PrimaryThemeLight)
    
    self.ibTableView.backgroundColor = UIColor(named: UIColor.Name.PrimaryThemeLight)
    self.ibTableView.rowHeight = UITableViewAutomaticDimension
    self.ibTableView.estimatedRowHeight = 60
    self.ibTableView.allowsMultipleSelection = true
    let headerView = SimpleHeaderLabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
    let attributedString = NSMutableAttributedString()
    if self.isFake == true {
      attributedString.appendAttributedString(NSAttributedString(string: "A sample poll/survey notification\n\n",
        attributes: [NSFontAttributeName : UIFont(named: UIFont.AppFont.Bold, size: 13)]))
    }
    if let body = self.reachPollViewModel?.body{
      attributedString.appendAttributedString(NSAttributedString(string: body,
        attributes: [NSFontAttributeName : UIFont(named: UIFont.AppFont.Regular, size: 22)]))
    }
    headerView.updateAttributed(attributedString, headerType: HeaderViewType.TableHeader)
    self.ibTableView.setAndLayoutTableHeaderView(headerView)
    
    self.ibTableView.registerNib(UINib(nibName: PollChoiceCell.identifier, bundle: nil),
      forCellReuseIdentifier: PollChoiceCell.identifier)
    self.ibTableView.tableFooterView = UIView()
    self.ibTableView.separatorStyle = .None
    
    self.hasBody = self.reachPollViewModel?.body.isEmpty ?? false
    
    if let exitTitle = self.reachPollViewModel?.exitTitle where exitTitle.isEmpty == false {
      ibDismissButton.setTitle(exitTitle.uppercaseString, forState: .Normal)
    } else {
      ibDismissButton.removeFromSuperview()
    }
    if let actionTitle = self.reachPollViewModel?.actionTitle where actionTitle.isEmpty == false {
      ibActionButton.setTitle(actionTitle.uppercaseString, forState: .Normal)
    } else {
      ibActionButton.removeFromSuperview()
    }
    
    self.ibActionButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.SecondaryPurple).colorWithAlphaComponent(0.6)),
      forState: UIControlState.Disabled)
    self.ibActionButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.SecondaryPurple)),
      forState: .Normal)
    self.ibDismissButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.PrimaryTheme)),
      forState: .Normal)
    
    updateActionButtonState()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.ibTableView.layoutTableHeaderView()
  }
  
  //MARK: Actions
  @IBAction func didTapExitButton(sender: AnyObject) {
    if isFake == true{
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    else{
      self.exitButtonClicked(sender)
    }
  }
  
  @IBAction func didTapActionButton(sender: AnyObject) {
    if self.isFake == true{
      self.reachPollViewModel?.action?()
      
    }
    else{
      var answers = [String : String]()
      
      for (key, tupleChoice) in self.selectedChoices{
        answers[key] = tupleChoice.choiceId
      }
      self.submitAnswers(answers)
      DeepLinkHelper.presentViewController(SuccessPollViewController(), animated: false)
    }
  }
  
  /**
   Update the state of the action button.
   Button is disable when not all question have a choice
   */
  func updateActionButtonState(){
    self.ibActionButton.enabled = (self.selectedChoices.count == self.reachPollViewModel?.questions.count && self.selectedChoices.count > 0)
  }
  
  /**
   Retrieve the correct choice ViewModel at index
   
   - parameter fromIndex: the data source index path
   
   - returns: a PollChoiceViewModel
   */
  func choice(fromIndex: NSIndexPath) -> PollChoiceViewModel?{
    
    if let question = self.question(fromIndex){
      return question.choices[fromIndex.row]
    }
    return nil
  }
  
  /**
   Retrieve the correct question ViewModel at index
   
   - parameter fromIndex: the data source index path
   
   - returns: a PollQuestionViewModel
   */
  func question(fromIndex: NSIndexPath) -> PollQuestionViewModel?{
    return self.reachPollViewModel?.questions[fromIndex.section]
  }
  
}

//MARK: UITableViewDataSource
extension PollViewController: UITableViewDataSource{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.reachPollViewModel?.questions.count ?? 0
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let question = self.reachPollViewModel?.questions[section]{
      return question.choices.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(PollChoiceCell.identifier, forIndexPath: indexPath) as! PollChoiceCell
    
    //retrieve choice, update title
    if let choice = self.choice(indexPath){
      cell.update(choice.title)
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension PollViewController: UITableViewDelegate{
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let headerView = SimpleHeaderLabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
    
    if let question = self.question(NSIndexPath(forRow: 0, inSection: section)){
      headerView.update(UIFont(named: UIFont.AppFont.Bold, size: 18),
        mainTitle: question.title,
        headerType: HeaderViewType.SectionHeader)
    }
    
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if let question = self.question(NSIndexPath(forRow: 0, inSection: section)){
      return SimpleHeaderLabel.headerHeight(UIFont(named: UIFont.AppFont.Bold, size: 18),
        forTitle: question.title,
        insideWidth: self.view.frame.size.width,
        headerType: HeaderViewType.SectionHeader)
    }
    
    return 0.1
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let question = self.question(indexPath), choice = self.choice(indexPath){
      
      if let choiceTuple = (self.selectedChoices[question.questionId]){
        
        if choiceTuple.indexPath != indexPath{
          tableView.deselectRowAtIndexPath(choiceTuple.indexPath, animated: true)
          self.selectedChoices[question.questionId] = (choice.choiceId, indexPath)
        }
        
      }else{
        self.selectedChoices[question.questionId] = (choice.choiceId, indexPath)
      }
    }
    updateActionButtonState()
  }
}