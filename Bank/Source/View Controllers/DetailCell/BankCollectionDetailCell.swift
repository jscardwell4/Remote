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
    case Cell            = "DetailCell"
    case AttributedText  = "DetailAttributedTextCell"
    case Label           = "DetailLabelCell"
    case List            = "DetailListCell"
    case Button          = "DetailButtonCell"
    case Image           = "DetailImageCell"
    case LabeledImage    = "DetailLabeledImageCell"
    case Switch          = "DetailSwitchCell"
    case Color           = "DetailColorCell"
    case Slider          = "DetailSliderCell"
    case TwoToneSlider   = "DetailTwoToneSliderCell"
    case Picker          = "DetailPickerCell"
    case Stepper         = "DetailStepperCell"
    case TextView        = "DetailTextViewCell"
    case TextField       = "DetailTextFieldCell"
    case Custom          = "DetailCustomCell"

    static var all: [Identifier] {
      return [.AttributedText, .Label, .List, .Button, .Image, .LabeledImage, .Switch, .Custom,
              .Color, .Slider, .TwoToneSlider, .Picker, .Stepper, .TextView, .TextField, .Cell]
    }

    var cellType: DetailCell.Type {
      switch self {
        case .Cell:            return DetailCell.self
        case .AttributedText:  return DetailAttributedTextCell.self
        case .Label:           return DetailLabelCell.self
        case .List:            return DetailLabelCell.self
        case .Button:          return DetailButtonCell.self
        case .LabeledImage:    return DetailLabeledImageCell.self
        case .Image:           return DetailImageCell.self
        case .Color:           return DetailColorCell.self
        case .Slider:          return DetailSliderCell.self
        case .TwoToneSlider:   return DetailTwoToneSliderCell.self
        case .Switch:          return DetailSwitchCell.self
        case .Picker:          return DetailPickerCell.self
        case .Stepper:         return DetailStepperCell.self
        case .TextField:       return DetailTextFieldCell.self
        case .TextView:        return DetailTextViewCell.self
        case .Custom:          return DetailCustomCell.self
      }
    }

    /**
    enumerate:

    :param: block (Identifier) -> Void
    */
    static func enumerate(block: (Identifier) -> Void) { apply(all, block) }

    /**
    registerWithCollectionView:

    :param: collectionView UICollectionView
    */
    func registerWithCollectionView(collectionView: UICollectionView) {
      collectionView.registerClass(cellType, forCellWithReuseIdentifier: rawValue)
    }

    /**
    registerAllWithCollectionView:

    :param: collectionView UICollectionView
    */
    static func registerAllWithCollectionView(collectionView: UICollectionView) {
      enumerate { $0.registerWithCollectionView(collectionView) }
    }
  }

  /**
  registerIdentifiersWithCollectionView:

  :param: collectionView UICollectionView
  */
  class func registerIdentifiersWithCollectionView(collectionView: UICollectionView) {
    Identifier.registerAllWithCollectionView(collectionView)
  }


  /// MARK: Handlers

  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var sizeDidChange: ((DetailCell) -> Void)?


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

    :param: object AnyObject?

    :returns: AnyObject?
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

    :param: text String?
    :param: attributedText NSAttributedString?

    :returns: AnyObject?
    */
    func objectFromText(text: String?, attributedText: NSAttributedString?) -> AnyObject? {
      switch self {
        case .AttributedStringData: return objectFromAttributedText(attributedText)
        default:                    return objectFromText(text)
      }
    }

    /**
    objectFromText:

    :param: text String?

    :returns: AnyObject?
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

    :param: text NSAttributedString?

    :returns: AnyObject?
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

  lazy var nameLabel: Label = {
    let label = Label(autolayout: true)
    label.font      = Bank.labelFont
    label.textColor = Bank.labelColor
    label.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
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

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** Hook for subclass cell setup */
  func initializeIVARs() {}

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  var editing: Bool = false

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

:param: lhs DetailCell.DataType
:param: rhs DetailCell.DataType

:returns: Bool
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

