//
//  DocumentSelectionController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DocumentSelectionController: UITableViewController {

  private class DocumentCell: UITableViewCell {

    lazy var label: UILabel = {
      let view = UILabel()
      view.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.font = Bank.infoFont
      view.textColor = Bank.infoColor
      return view
    }()

    /**
    initWithStyle:reuseIdentifier:

    :param: style UITableViewStyle
    :param: reuseIdentifier String
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style:style, reuseIdentifier: reuseIdentifier)
      contentView.addSubview(label)
      contentView.constrainWithFormat("|-[label]-| :: V:|-[label]-|", views: ["label": label])
    }

    /**
    init:

    :param: aDecoder NSCoder
    */
    required init(coder aDecoder: NSCoder) { identifier = .Label; super.init(coder: aDecoder) }


    /// MARK: UITableViewCell
    ////////////////////////////////////////////////////////////////////////////////

    /**
    requiresConstraintBasedLayout

    :returns: Bool
    */
    override class func requiresConstraintBasedLayout() -> Bool { return true }

  }

  let files = MoonFunctions.documentsDirectoryContents().filter{$0.hasSuffix(".json")}.map{$0[0..<($0.length - 5)]}

  /** loadView */
  override func loadView() {
    tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.separatorStyle = .None
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(DocumentCell.self, forReuseIdentifier: "Cell")
  }

  /**
  numberOfSectionsInTableView:

  :param: tableView UITableView

  :returns: Int
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return files.count }

  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as DocumentCell
    cell.label.text = files[indexPath.row]
    return cell
  }

}
