//
//  VideosViewController.swift
//  Engagement
//
//  Created by Microsoft on 11/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

/// Display the AZME videos SDK presentations
class VideosViewController: CenterViewController {
  
  @IBOutlet weak var ibTableView: UITableView!
  
  var dataSource = [Video]()
  
  var videoJobStarted = false
  
  //MARK: Overriding
  override func engagementActivityName() -> String! {
    return AnalyticsMonitor.Activities.Videos
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = L10n.tr("menu.videos.title")
    
    ibTableView.backgroundColor = UIColor(named: UIColor.Name.SecondaryGrey)
    ibTableView.separatorStyle = .None
    ibTableView.rowHeight = UITableViewAutomaticDimension
    ibTableView.estimatedRowHeight = 100
    ibTableView.registerNib(UINib(nibName: VideoCell.identifier, bundle: nil),
      forCellReuseIdentifier: VideoCell.identifier)
    
    self.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    if videoJobStarted == true {
      AnalyticsMonitor.Jobs.Video.end()
    }
  }
  
  /**
   Fetch video data
   */
  private func reloadData(){
    //Load video feed
    UIApplication.showHUD()
    AzMEService.fetchAzMEVideoFeed { (videos, error) -> Void in
      self.dataSource = videos
      
      self.ibTableView.reloadData()
      UIApplication.dismissHUD()
    }
  }
  
}

//MARK: UITableViewDataSource
extension VideosViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.dataSource.count > 0 ? 1 : 0
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataSource.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(VideoCell.identifier, forIndexPath: indexPath) as! VideoCell
    
    let video = self.dataSource[indexPath.row]
    cell.updateWith(video.title, subTitle: video.description, imageLink: video.pictureUrl, localImage: video.isEmbed)
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension VideosViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let video = self.dataSource[indexPath.row]
    
    if let videoUrl = video.videoUrl, videoURL = NSURL(string: videoUrl){
      let playerController = AVPlayerViewController()
      playerController.delegate = self
      if video.isEmbed == true{
        if let videoURLEmbed = NSBundle.mainBundle().URLForResource(videoUrl, withExtension: ".mp4"){
          playerController.player = AVPlayer(URL: videoURLEmbed)
        }
      }else{
        
        playerController.player = AVPlayer(URL: videoURL)
      }
      //AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.Video, extras: [NSObject : AnyObject]?)
      UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
      
      self.navigationController?.presentViewController(playerController,
        animated: true,
        completion: { [unowned self] in
          self.ibTableView.deselectRowAtIndexPath(indexPath, animated: true)
          playerController.player!.play()
          AnalyticsMonitor.sendActivityNamed(AnalyticsMonitor.Events.Video.play, extras: nil)
          AnalyticsMonitor.Jobs.Video.start(video.title, URL: videoUrl)
          self.videoJobStarted = true
        })
    }
    
  }
}

extension VideosViewController: AVPlayerViewControllerDelegate {
  //TODO : Video tagging
}