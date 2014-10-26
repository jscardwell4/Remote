//
//  BankItemCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// TODO: Add creation row option for table style cells as well as ability to delete member rows
// TODO: Create a specific cell type for the cells of a table style cell

class BankItemCell: UITableViewCell {


  /// MARK: Identifiers
  ////////////////////////////////////////////////////////////////////////////////


  private let identifier: Identifier

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the cell */
  enum Identifier: String {
    case Label     = "BankItemDetailLabelCell"
    case List      = "BankItemDetailListCell"
    case Button    = "BankItemDetailButtonCell"
    case Image     = "BankItemDetailImageCell"
    case Switch    = "BankItemDetailSwitchCell"
    case Stepper   = "BankItemDetailStepperCell"
    case TextView  = "BankItemDetailTextViewCell"
    case TextField = "BankItemDetailTextFieldCell"

    /**
    registerWithTableView:

    :param: tableView UITableView
    */
    func registerWithTableView(tableView: UITableView) {
      switch self {
        case .Label:     tableView.registerClass(BankItemLabelCell.self,     forCellReuseIdentifier: self.rawValue)
        case .List:      tableView.registerClass(BankItemListCell.self,      forCellReuseIdentifier: self.rawValue)
        case .Button:    tableView.registerClass(BankItemButtonCell.self,    forCellReuseIdentifier: self.rawValue)
        case .Image:     tableView.registerClass(BankItemImageCell.self,     forCellReuseIdentifier: self.rawValue)
        case .Switch:    tableView.registerClass(BankItemSwitchCell.self,    forCellReuseIdentifier: self.rawValue)
        case .Stepper:   tableView.registerClass(BankItemStepperCell.self,   forCellReuseIdentifier: self.rawValue)
        case .TextField: tableView.registerClass(BankItemTextFieldCell.self, forCellReuseIdentifier: self.rawValue)
        case .TextView:  tableView.registerClass(BankItemTextViewCell.self,  forCellReuseIdentifier: self.rawValue)
      }
    }
  }

  /**
  registerIdentifiersWithTableView:

  :param: tableView UITableView
  */
  class func registerIdentifiersWithTableView(tableView: UITableView) {
    let identifiers: [Identifier] = [.Label, .List, .Button, .Image, .Switch, .Stepper,.TextField, .TextView]
    for identifier in identifiers { identifier.registerWithTableView(tableView) }
  }


  /// MARK: Handlers
  ////////////////////////////////////////////////////////////////////////////////


  var valueDidChange: ((NSObject?) -> Void)?
  var valueIsValid: ((NSObject?) -> Bool)?
  var sizeDidChange: ((BankItemCell) -> Void)?


  /// MARK: Name and info properties
  ////////////////////////////////////////////////////////////////////////////////


  var name: String? { get { return nameLabel.text } set { nameLabel.text = newValue } }



  /** A simple enum to specify kinds of data */
  enum DataType {
    case IntData(ClosedInterval<Int32>)
    case IntegerData(ClosedInterval<Int>)
    case LongLongData(ClosedInterval<Int64>)
    case FloatData(ClosedInterval<Float>)
    case DoubleData(ClosedInterval<Double>)
    case StringData

    /**
    objectFromText:

    :param: text String?

    :returns: NSObject?
    */
    func objectFromText(text: String?) -> NSObject? {
      if let t = text {
        let scanner = NSScanner.localizedScannerWithString(t) as NSScanner
        switch self {
          case .IntData(let r):
            var n: Int32 = 0
            if scanner.scanInt(&n) && r ∋ n { return NSNumber(int: n) }
          case .IntegerData(let r):
            var n: Int = 0
            if scanner.scanInteger(&n) && r ∋ n { return NSNumber(long: n) }
          case .LongLongData(let r):
            var n: Int64 = 0
            if scanner.scanLongLong(&n) && r ∋ n { return NSNumber(longLong: n) }
          case .FloatData(let r):
            var n: Float = 0
            if scanner.scanFloat(&n) && r ∋ n { return NSNumber(float: n) }
          case .DoubleData(let r):
            var n: Double = 0
            if scanner.scanDouble(&n) && r ∋ n { return NSNumber(double: n) }
          case .StringData:
            return t
        }
      }
      return nil
    }
  }

  var infoDataType: DataType = .StringData

  /**
  textFromObject:dataType:

  :param: obj AnyObject
  :param: dataType DataType = .StringData

  :returns: String
  */
  func textFromObject(object: AnyObject?) -> String? {
    var text: String?
    if let string = object as? String { text = string }
    else if let obj: AnyObject = object {
      if obj.respondsToSelector("name") { text = obj.valueForKey("name") as? String }
      else { text = "\(obj)"}
    }
    return text
  }

  var info: AnyObject?


  /// MARK: Content subviews
  ////////////////////////////////////////////////////////////////////////////////


  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.font      = Bank.labelFont
    label.textColor = Bank.labelColor
    return label
  }()

  lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.font = Bank.infoFont
    label.textColor = Bank.infoColor
    label.textAlignment = .Right
    return label
  }()


  /// MARK: Initializers
  ////////////////////////////////////////////////////////////////////////////////


  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewStyle
  :param: reuseIdentifier String
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    identifier = Identifier(rawValue: reuseIdentifier ?? "") ?? .Label
    super.init(style:style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .None
    contentView.layoutMargins = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 8.0, right: 20.0)
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

  /**
  Overridden to prevent indented content view

  :param: editing Bool
  :param: animated Bool
  */
  override func setEditing(editing: Bool, animated: Bool) { isEditingState = editing }

  var isEditingState: Bool = false

}
