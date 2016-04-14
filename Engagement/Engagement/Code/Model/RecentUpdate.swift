//
//  RecentUpdate.swift
//  Engagement
//
//  Created by Microsoft on 12/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import SWXMLHash

/// Recent Update model
class RecentUpdate {
  
  var title: String?
  var description: String?
  var pubDate: String?
  var link: String?
  var category: String?
  
  /**
   Parse a XML element to create a RecentUpdate Object
   
   - parameter element: XMLIndexer element
   
   - returns: RecentUpdate object
   */
  static func parseFromXMLElements(element: XMLIndexer) -> RecentUpdate
  {
    let recentUpdate = RecentUpdate()
    recentUpdate.title = element["title"].element?.text
    recentUpdate.pubDate = element["pubDate"].element?.text
    
    if let text = element["description"].element?.text
    {
      //decode text
      let encodedData = text.dataUsingEncoding(NSUTF8StringEncoding)!
      
      let text = try! NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
      
      let cleanedText = text.string.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
      recentUpdate.description = cleanedText
      
    }
    
    recentUpdate.link = element["link"].element?.text
    recentUpdate.category = element["category"].element?.text
    return recentUpdate
  }
}