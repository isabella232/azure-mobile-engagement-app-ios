//
//  ExpandableTableView.swift
//  Engagement
//
//  Created by Jocelyn Girard on 10/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: NSObjectProtocol {
    func headerViewOpen(section:Int)
    func headerViewClose(section:Int)
}

class UIExpandableTableView : UITableView, HeaderViewDelegate {
    
    var sectionOpen:Int = NSNotFound
    
    // MARK: HeaderViewDelegate
    func headerViewOpen(section: Int) {
        
        if self.sectionOpen != NSNotFound {
            headerViewClose(self.sectionOpen)
        }
        
        self.sectionOpen = section
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section)
        var indexesPathToInsert:[NSIndexPath] = []
        
        for var i = 0; i < numberOfRows; i++ {
            indexesPathToInsert.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        if indexesPathToInsert.count > 0 {
            self.beginUpdates()
            self.insertRowsAtIndexPaths(indexesPathToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.endUpdates()
        }
    }
    
    func headerViewClose(section: Int) {
        
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section)
        var indexesPathToDelete:[NSIndexPath] = []
        self.sectionOpen = NSNotFound
        
        for var i = 0 ; i < numberOfRows; i++ {
            indexesPathToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        if indexesPathToDelete.count > 0 {
            self.beginUpdates()
            self.deleteRowsAtIndexPaths(indexesPathToDelete, withRowAnimation: UITableViewRowAnimation.Top)
            self.endUpdates()
        }
    }
}