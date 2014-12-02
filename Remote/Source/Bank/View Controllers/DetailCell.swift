//
//  DetailCell.swift
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

class DetailCell: UITableViewCell {


  /// MARK: Identifiers
  ////////////////////////////////////////////////////////////////////////////////


  private let identifier: Identifier

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the cell */
  enum Identifier: String, EnumerableType {
    case AttributedLabel = "DetailAttributedLabelCell"
    case Label           = "DetailLabelCell"
    case List            = "DetailListCell"
    case Button          = "DetailButtonCell"
    case Image           = "DetailImageCell"
    case LabeledImage    = "DetailLabeledImageCell"
    case Switch          = "DetailSwitchCell"
    case Color           = "DetailColorCell"
    case Slider          = "DetailSliderCell"
    case Picker          = "DetailPickerCell"
    case Stepper         = "DetailStepperCell"
    case TextView        = "DetailTextViewCell"
    case TextField       = "DetailTextFieldCell"

    static var all: [Identifier] {
      return [.AttributedLabel, .Label, .List, .Button, .Image, .LabeledImage, .Switch,
              .Color, .Slider, .Picker, .Stepper, .TextView, .TextField]
    }

    var cellType: DetailCell.Type {
      switch self {
        case .AttributedLabel: return DetailAttributedLabelCell.self
        case .Label:           return DetailLabelCell.self
        case .List:            return DetailListCell.self
        case .Button:          return DetailButtonCell.self
        case .LabeledImage:    return DetailLabeledImageCell.self
        case .Image:           return DetailImageCell.self
        case .Color:           return DetailColorCell.self
        case .Slider:          return DetailSliderCell.self
        case .Switch:          return DetailSwitchCell.self
        case .Picker:          return DetailPickerCell.self
        case .Stepper:         return DetailStepperCell.self
        case .TextField:       return DetailTextFieldCell.self
        case .TextView:        return DetailTextViewCell.self
      }
    }

    /**
    enumerate:

    :param: block (Identifier) -> Void
    */
    static func enumerate(block: (Identifier) -> Void) { apply(all, block) }

    /**
    registerWithTableView:

    :param: tableView UITableView
    */
    func registerWithTableView(tableView: UITableView) { tableView.registerClass(cellType, forCellReuseIdentifier: rawValue) }

    /**
    registerAllWithTableView:

    :param: tableView UITableView
    */
    static func registerAllWithTableView(tableView: UITableView) { enumerate { $0.registerWithTableView(tableView) } }
  }

  /**
  registerIdentifiersWithTableView:

  :param: tableView UITableView
  */
  class func registerIdentifiersWithTableView(tableView: UITableView) { Identifier.registerAllWithTableView(tableView) }


  /// MARK: Handlers
  ////////////////////////////////////////////////////////////////////////////////


  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var sizeDidChange: ((DetailCell) -> Void)?


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
    case AttributedStringData

    /**
    objectFromText:

    :param: text String?

    :returns: AnyObject?
    */
    func objectFromText(text: String?) -> AnyObject? {
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
          case .AttributedStringData:
            fallthrough
          case .StringData:
            return t
        }
      }
      return nil
    }

    /**
    objectFromText:

    :param: text NSAttributedString?

    :returns: AnyObject?
    */
    func objectFromAttributedText(text: NSAttributedString?) -> AnyObject? {
      if let t = text {
        let scanner = NSScanner.localizedScannerWithString(t.string) as NSScanner
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
          case .AttributedStringData:
            return t
          case .StringData:
            return t.string
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
    else if object?.respondsToSelector("name") == true { text = object!.valueForKey("name") as? String }
    else if object?.respondsToSelector("title") == true { text = object!.valueForKey("title") as? String }
    else if object != nil { text = "\(object!)" }
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

/**
subscript:rhs:

:param: lhs DetailCell.DataType
:param: rhs DetailCell.DataType

:returns: Bool
*/
func ==(lhs: DetailCell.DataType, rhs: DetailCell.DataType) -> Bool {
  switch (lhs, rhs) {
    case (.IntData, .IntData),
         (.IntegerData, .IntegerData),
         (.LongLongData, .LongLongData),
         (.FloatData, .FloatData),
         (.DoubleData, .DoubleData),
         (.StringData, .StringData),
         (.AttributedStringData, .AttributedStringData): return true
    default: return false
  }
}

