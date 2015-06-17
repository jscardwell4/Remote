//
//  BankCollectionDetailCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailCell: UICollectionViewCell {

  /// MARK: Identifiers

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the cell */
  enum Identifier: String, EnumerableType {
    case Cell            = "BankCollectionDetailCell"
    case AttributedText  = "BankCollectionDetailAttributedTextCell"
    case Label           = "BankCollectionDetailLabelCell"
    case List            = "BankCollectionDetailListCell"
    case Button          = "BankCollectionDetailButtonCell"
    case Image           = "BankCollectionDetailImageCell"
    case LabeledImage    = "BankCollectionDetailLabeledImageCell"
    case Switch          = "BankCollectionDetailSwitchCell"
    case Color           = "BankCollectionDetailColorCell"
    case Slider          = "BankCollectionDetailSliderCell"
    case TwoToneSlider   = "BankCollectionDetailTwoToneSliderCell"
    case Picker          = "BankCollectionDetailPickerCell"
    case Stepper         = "BankCollectionDetailStepperCell"
    case TextView        = "BankCollectionDetailTextViewCell"
    case TextField       = "BankCollectionDetailTextFieldCell"
    case Custom          = "BankCollectionDetailCustomCell"

    static var all: [Identifier] {
      return [.AttributedText, .Label, .List, .Button, .Image, .LabeledImage, .Switch, .Custom,
              .Color, .Slider, .TwoToneSlider, .Picker, .Stepper, .TextView, .TextField, .Cell]
    }

    var cellType: BankCollectionDetailCell.Type {
      switch self {
        case .Cell:            return BankCollectionDetailCell.self
        case .AttributedText:  return BankCollectionDetailAttributedTextCell.self
        case .Label:           return BankCollectionDetailLabelCell.self
        case .List:            return BankCollectionDetailListCell.self
        case .Button:          return BankCollectionDetailButtonCell.self
        case .LabeledImage:    return BankCollectionDetailLabeledImageCell.self
        case .Image:           return BankCollectionDetailImageCell.self
        case .Color:           return BankCollectionDetailColorCell.self
        case .Slider:          return BankCollectionDetailSliderCell.self
        case .TwoToneSlider:   return BankCollectionDetailTwoToneSliderCell.self
        case .Switch:          return BankCollectionDetailSwitchCell.self
        case .Picker:          return BankCollectionDetailPickerCell.self
        case .Stepper:         return BankCollectionDetailStepperCell.self
        case .TextField:       return BankCollectionDetailTextFieldCell.self
        case .TextView:        return BankCollectionDetailTextViewCell.self
        case .Custom:          return BankCollectionDetailCustomCell.self
      }
    }

    /**
    enumerate:

    - parameter block: (Identifier) -> Void
    */
    static func enumerate(block: (Identifier) -> Void) { apply(all, block) }

    /**
    registerWithCollectionView:

    - parameter collectionView: UICollectionView
    */
    func registerWithCollectionView(collectionView: UICollectionView) {
      collectionView.registerClass(cellType, forCellWithReuseIdentifier: rawValue)
    }

    /**
    registerAllWithCollectionView:

    - parameter collectionView: UICollectionView
    */
    static func registerAllWithCollectionView(collectionView: UICollectionView) {
      enumerate { $0.registerWithCollectionView(collectionView) }
    }
  }

  /**
  registerIdentifiersWithCollectionView:

  - parameter collectionView: UICollectionView
  */
  class func registerIdentifiersWithCollectionView(collectionView: UICollectionView) {
    Identifier.registerAllWithCollectionView(collectionView)
  }


  /// MARK: Handlers

  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var sizeDidChange: ((DetailCell) -> Void)?
  var select: (() -> Void)?
  var delete: (() -> Void)?

  /// MARK: Name and info properties

  var name: String? { didSet { nameLabel.text = name } }

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
    textualRepresentationForObject:

    - parameter object: AnyObject?

    - returns: AnyObject?
    */
    func textualRepresentationForObject(object: AnyObject?) -> AnyObject? {
      var text: AnyObject?

      switch self {
        case .IntData, .IntegerData, .LongLongData:
          if let number = object as? NSNumber { text = "\(number)" }
        case .FloatData:
          if let number = object as? NSNumber { text = String(format: "%.2f", number.floatValue) }
        case .DoubleData:
          if let number = object as? NSNumber { text = String(format: "%.2f", number.doubleValue) }
        case .AttributedStringData:
          if object is NSAttributedString { text = object }
        case .StringData:
          if object != nil {
            assert(!(object is NSAttributedString))
            if object! is String { text = object }
            else if object!.respondsToSelector("name") { text = object!.valueForKey("name") }
            else if object!.respondsToSelector("title") { text = object!.valueForKey("title") }
          }
      }

      return text
    }

    /**
    objectFromText:attributedText:

    - parameter text: String?
    - parameter attributedText: NSAttributedString?

    - returns: AnyObject?
    */
    func objectFromText(text: String?, attributedText: NSAttributedString?) -> AnyObject? {
      switch self {
        case .AttributedStringData: return objectFromAttributedText(attributedText)
        default:                    return objectFromText(text)
      }
    }

    /**
    objectFromText:

    - parameter text: String?

    - returns: AnyObject?
    */
    func objectFromText(text: String?) -> AnyObject? {
      if let t = text {
        let scanner = NSScanner.localizedScannerWithString(t) as! NSScanner
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

    - parameter text: NSAttributedString?

    - returns: AnyObject?
    */
    func objectFromAttributedText(text: NSAttributedString?) -> AnyObject? {
      if let t = text {
        let scanner = NSScanner.localizedScannerWithString(t.string) as! NSScanner
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

  - parameter obj: AnyObject
  - parameter dataType: DataType = .StringData

  - returns: String
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

  lazy var nameLabel: Label = {
    let label = Label(autolayout: true)
    label.font      = Bank.labelFont
    label.textColor = Bank.labelColor
    label.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
    label.setContentHuggingPriority(900, forAxis: .Horizontal)
    return label
  }()

  lazy var infoLabel: Label = {
    let label = Label(autolayout: true)
    label.font = Bank.infoFont
    label.textColor = Bank.infoColor
    label.textAlignment = .Right
    return label
  }()


  /// MARK: Initializers

  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** Hook for subclass cell setup */
  func initializeIVARs() {}

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  var editing: Bool = false

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗩|contentView|𝗩, 𝗛|contentView|𝗛)
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    info = nil
    infoDataType = .StringData
    shouldAllowNonDataTypeValue = nil
    valueDidChange = nil
    valueIsValid = nil
    sizeDidChange = nil
  }

}

extension BankCollectionDetailCell.DataType: Equatable {}
/**
subscript:rhs:

- parameter lhs: DetailCell.DataType
- parameter rhs: DetailCell.DataType

- returns: Bool
*/
func ==(lhs: BankCollectionDetailCell.DataType, rhs: BankCollectionDetailCell.DataType) -> Bool {
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

