//
//  DetailPickerCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/01/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailPickerCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    picker.delegate = self
    picker.dataSource = self
    contentView.addSubview(picker)
    contentView.stretchSubview(picker)
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    _data.removeAll()
    selection = .None
    createItem = nil
    didSelectItem = nil
    titleForInfo = nil
  }

  override var info: AnyObject? {
    get {
      switch selection {
        case .DataItem(let obj, _): return obj
        default:                    return nil
      }
    }
    set {
      let searchIndex: Index = newValue == nil
                                 ? .NilItem(title: nilItemTitle ?? "")
                                 : .DataItem(object: newValue!, title: titleForInfo?(newValue!) ?? "")
      if let idx = _data.indexOf(searchIndex) {
        selection = _data[idx]
        picker.selectRow(idx, inComponent: 0, animated: false)
      }
    }
  }

  private let picker: UIPickerView = UIPickerView(autolayout: true)

  enum Index {
    case None
    case NilItem (title: String)
    case CreateItem (title: String)
    case DataItem (object: AnyObject, title: String)

    var title: String {
      switch self {
        case .None:                return ""
        case .NilItem(let t):      return t
        case .CreateItem(let t):   return t
        case .DataItem(_, let t):  return t
      }
    }
  }

  var createItem: ((Void) -> Void)?
  var didSelectItem: ((AnyObject?) -> Void)?

  var titleForInfo: ((AnyObject?) -> String)?

  private var _data: [Index] = []
  var data: [AnyObject] {
    get {
      var objects: [AnyObject] = []
      for index in _data {
        switch index {
          case .DataItem(let obj, _): objects.append(obj)
          default: break
        }
      }
      return objects
    }
    set {
      _data.removeAll(keepCapacity: true)
      if nilItemTitle != nil { _data.append(.NilItem(title: nilItemTitle!)) }
      for object in newValue {
        if let title = titleForInfo?(object) {
          _data.append(.DataItem(object: object, title: title))
        } else if let title = infoDataType.textualRepresentationForObject(object) as? String {
          _data.append(.DataItem(object: object, title: title))
        }
      }
      if createItemTitle != nil { _data.append(.CreateItem(title: createItemTitle!)) }
      picker.reloadAllComponents()
    }
  }

  private var selection: Index = .None

  var nilItemTitle: String?
  var createItemTitle: String?

}

// MARK: - UIPickerViewDataSource

extension DetailPickerCell: UIPickerViewDataSource, UIPickerViewDelegate {

  /**
  numberOfComponentsInPickerView:

  - parameter pickerView: UIPickerView

  - returns: Int
  */
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  /**
  pickerView:numberOfRowsInComponent:

  - parameter pickerView: UIPickerView
  - parameter component: Int

  - returns: Int
  */
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return _data.count
  }

  /**
  pickerView:titleForRow:forComponent:

  - parameter pickerView: UIPickerView
  - parameter row: Int
  - parameter component: Int

  - returns: String?
  */
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return _data[row].title
  }

  /**
  Handles selection of `nil`, `create`, or `data` row

  - parameter pickerView: UIPickerView
  - parameter row: Int
  - parameter component: Int
  */
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selection = _data[row]
    switch selection {
      case .None:                 break
      case .NilItem:              didSelectItem?(nil)
      case .CreateItem:           createItem?()
      case .DataItem(let obj, _): didSelectItem?(obj)
    }
  }

}

extension DetailPickerCell.Index: Equatable {}
/**
Whether lhs is equal to rhs

- parameter lhs: DetailPickerCell.Index
- parameter rhs: DetailPickerCell.Index

- returns: Bool
*/
func ==(lhs: DetailPickerCell.Index, rhs: DetailPickerCell.Index) -> Bool {
  switch (lhs, rhs) {
    case (.NilItem(_), .NilItem(_)), (.CreateItem(_), .CreateItem(_)), (.None, .None):
      return true
    case (.DataItem(let o1 as NSObject, _), .DataItem(let o2 as NSObject, _)) where o1.dynamicType.self === o2.dynamicType.self:
      return o1 == o2
    case (.DataItem(let o1, _), .DataItem(let o2, _)):
      return o1 === o2
    default:
      return false
  }
}
