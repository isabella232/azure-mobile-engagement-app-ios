//
//  AzMEService.swift
//  Engagement
//
//  Created by Microsoft on 09/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import SWXMLHash
import SwiftyJSON

/**
 *  Service Manager
 */
struct AzMEService{
  
  /**
   Retrieve all recent AzME recent updates
   
   - parameter forHome:    true if you just want the last recent update, false by default
   - parameter completion: Closure paramters : a non empty array of RecentUpdate object and an optionnal error
   */
  static func fetchAzMERecentUpdates(forHome forHome: Bool = false, completion : ([RecentUpdate], NSError?) -> Void )
  {
    if let feedURL = NSURL(string: Config.Services.recentUpdates)
    {
      NSURLSession.sharedSession().dataTaskWithURL(feedURL, completionHandler:
        { (data, response, error) -> Void in
          if let data = data where error == nil
          {
            let xml = SWXMLHash.parse(data)
            
            var parsedUpdates = [RecentUpdate]()
            
            let channel = xml.children.first?.children.filter({ (element) -> Bool in
              return element.element?.name == "channel"
            })
            let recentUpdates = channel?.first?.children.filter({ (xmlElement) -> Bool in
              return xmlElement.element?.name == "item"
            })
            if let recentUpdates = recentUpdates
            {
              for update in recentUpdates
              {
                
                parsedUpdates.append(RecentUpdate.parseFromXMLElements(update))
                if forHome == true{
                  break
                }
              }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              completion(parsedUpdates, nil)
            })
          }else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              completion([RecentUpdate](), error)
            })
          }
      }).resume()
    }
  }
  
  /**
   Retrieve all AzME SDK Video presentations
   
   - parameter completion: Closure parameter : a non empty Video object array and an optionnal service error
   */
  static func fetchAzMEVideoFeed(completion : ([Video], NSError?) -> Void )
  {
    if let feedURL = NSURL(string: Config.Services.azmeMoviesFeed)
    {
      NSURLSession.sharedSession().dataTaskWithURL(feedURL, completionHandler:
        { (data, response, error) -> Void in
          if let data = data
          {
            do
            {
              let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
              let swiftyJSON = JSON(json)
              
              var videosParsed = [Video]()
              if let videos = swiftyJSON["result"].array
              {
                for video in videos{
                  videosParsed.append(Video.parseFromJSONElement(video))
                }
                videosParsed.insert(Video.defaultVideo(), atIndex: 0)
              }
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(videosParsed, nil)
              })
            }
            catch {
              let customError = NSError(domain: "azure.microsoft.com",
                code: 600,
                userInfo: [NSLocalizedDescriptionKey : "Error : incorrect response format"])
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion([Video](), customError)
              })
              
            }
          }
          else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              completion([Video](), error)
            })
          }
      }).resume()
    }
  }
}