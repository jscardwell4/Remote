//
//  DetailRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

protocol DetailRow {

  var name: String? { get set }
  var info: AnyObject? { get set }
  var identifier: DetailCell.Identifier { get }
  var indexPath: NSIndexPath? { get set }
  var select: ((Void) -> Void)? { get set }
  var delete: ((Void) -> Void)? { get set }
  var editActions: [UITableViewRowAction]? { get set }
  var editingStyle: UITableViewCellEditingStyle { get }
  var deleteRemovesRow: Bool { get set }
  var infoDataType: DetailCell.DataType { get set }
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)? { get set }
  var valueDidChange: ((AnyObject?) -> Void)? { get set }
  var valueIsValid: ((AnyObject?) -> Bool)? { get set }
  var indentationLevel: Int { get set }
  var indentationWidth: CGFloat { get set }
  var backgroundColor: UIColor? { get set }

  func configureCell(cell: DetailCell, forTableView tableView: UITableView)

}

