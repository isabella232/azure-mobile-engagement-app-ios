//
//  Foundation+Extensions.swift
//  Engagement
//
//  Created by Microsoft on 29/03/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

extension String{
  init(HTMLString: String){
    self = "<html> <head> <link rel=\"stylesheet\" type=\"text/css\" href=\"html/styles.css\"/> </head> <body> <p>" + HTMLString + "</p> </body> </html>"
  }
}