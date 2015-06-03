//
//  BankCollectionDetailPickerCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/01/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailPickerCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    picker.delegate = self
    picker.dataSource = self
    contentView.addSubview(picker)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗩|picker|𝗩, 𝗛|picker|𝗛)
  }

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
      var searchIndex: Index = newValue == nil
                                 ? .NilItem(title: nilItemTitle ?? "")
                                 : .DataItem(object: newValue!, title: titleForInfo?(newValue!) ?? "")
      if let idx = find(_data, searchIndex) {
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

extension BankCollectionDetailPickerCell: UIPickerViewDataSource, UIPickerViewDelegate {

  /**
  numberOfComponentsInPickerView:

  :param: pickerView UIPickerView

  :returns: Int
  */
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  /**
  pickerView:numberOfRowsInComponent:

  :param: pickerView UIPickerView
  :param: component Int

  :returns: Int
  */
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return _data.count
  }

  /**
  pickerView:titleForRow:forComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int

  :returns: String?
  */
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return _data[row].title
  }

  /**
  Handles selection of `nil`, `create`, or `data` row

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
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

extension BankCollectionDetailPickerCell.Index: Equatable {}
/**
Whether lhs is equal to rhs

:param: lhs DetailPickerCell.Index
:param: rhs DetailPickerCell.Index

:returns: Bool
*/
func ==(lhs: BankCollectionDetailPickerCell.Index, rhs: BankCollectionDetailPickerCell.Index) -> Bool {
  switch (lhs, rhs) {
    case (.NilItem(_), .NilItem(_)), (.CreateItem(_), .CreateItem(_)), (.None, .None):
      return true
    case (.DataItem(let o1 as NSObject, _),
          .DataItem(let o2 as NSObject, _)) where o1.dynamicType.self === o2.dynamicType.self:
      return o1 == o2
    case (.DataItem(let o1, _), .DataItem(let o2, _)):
      return o1 === o2
    default:
      return false
  }
}
