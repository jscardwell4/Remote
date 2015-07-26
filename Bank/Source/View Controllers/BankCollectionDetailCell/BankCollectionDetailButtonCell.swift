//
//  BankCollectionDetailButtonCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import Chameleon

// TODO: This class should be renamed since it no longer users a button view

final class BankCollectionDetailButtonCell: BankCollectionDetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override func initializeIVARs() {
    super.initializeIVARs()
    picker.nametag = "picker"
    picker.didSelectItem = {
      [unowned self] _, item in

        self.selection = self._data[item]
        switch self.selection {
          case .None:                       break
          case .NilItem:                    self.didSelectItem?(nil)
          case .CreateItem (_, let action): action()
          case .DataItem   (_, let obj):    self.didSelectItem?(obj)
      }
    }
    contentView.addSubview(nameLabel)
    contentView.addSubview(picker)
  }

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()
    let id = MoonKit.Identifier(self, "Internal")
    if constraintsWithIdentifier(id).count == 0 {
      constrain(𝗛|-nameLabel--picker-|𝗛 --> id, [picker.centerY => centerY, nameLabel.centerY => centerY] --> id)
    }
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    MSLogDebug("")
    super.prepareForReuse()
    _data.removeAll()
    dataItems.removeAll()
    selection = .None
    createItem = nil
    didSelectItem = nil
    titleForInfo = nil
  }

  /**
  titleForObject:

  - parameter object: AnyObject

  - returns: String?
  */
  private func titleForObject(object: AnyObject) -> String? {
    return titleForInfo?(object) ?? infoDataType.textualRepresentationForObject(object) as? String
  }

  override var info: AnyObject? {
    get { return selection.object }
    set {
      switch newValue {
        case nil where nilItem != nil: selection = nilItem!
        case let object?: if let title = titleForObject(object) { selection = .DataItem(title: title, object: object) }
        default: selection = .None
      }
      updatePickerSelection()
    }
  }

  /** updatePickerSelection */
  private func updatePickerSelection() {
    guard let idx = _data.indexOf( { [title = self.selection.title] in $0.title == title }) else { return }
    picker.selectItem(idx, animated: false)
  }

  /// MARK: Picker settings

  /** rebuildData */
  private func rebuildData() {
    _data.removeAll(keepCapacity: true)
    if let nilItem = nilItem { _data.append(nilItem) }
    _data.extend(dataItems)
    if let createItem = createItem { _data.append(createItem) }
    picker.labels = _data.map { $0.title }
    updatePickerSelection()
  }

  var nilItem: Item? { didSet { switch nilItem { case .NilItem?: break; default: nilItem = nil }; rebuildData() } }

  var createItem: Item? { didSet { switch createItem { case .CreateItem?: break; default: createItem = nil }; rebuildData() } }

  var didSelectItem: ((AnyObject?) -> Void)?

  var titleForInfo: ((AnyObject?) -> String)?

  var data: [AnyObject] {
    get {
      var objects: [AnyObject] = []
      for case .DataItem(let obj, _) in dataItems { objects.append(obj) }
      return objects
    }
    set {
      dataItems = newValue.flatMap {
        guard let title = self.titleForObject($0) else { return nil }
        return .DataItem(title: title, object: $0)
      }
      rebuildData()
    }
  }

  // MARK: Picker view

  private var _data: [Item] = []
  private var dataItems: [Item] = [] // Should only contain `DataItem` case values
  private var selection = Item.None

  enum Item {
    case None
    case NilItem    (title: String)
    case CreateItem (title: String, createItem: () -> Void)
    case DataItem   (title: String, object: AnyObject)

    var title: String {
      switch self {
        case .None:                  return ""
        case .NilItem    (let t   ): return t
        case .CreateItem (let t, _): return t
        case .DataItem   (let t, _): return t
      }
    }

    var object: AnyObject? {
      switch self { case .DataItem(_, let object): return object; default: return nil } }
  }

  private let picker: InlinePickerView = {
    let view = InlinePickerView(autolayout: true)
    view.font = Bank.infoFont
    view.selectedFont = Bank.infoFont
    view.textColor = Bank.infoColor
    view.selectedTextColor = Bank.infoColor.brightnessAdjustedBy(-15)
    return view
    }()

  /**
  dumpState:

  - parameter message: String
  */
  private func dumpState(message: String) {
    MSLogDebug("\n\t".join(
      message,
      description,
      "constraints = \n\t" + "\n\t".join(constraints.map {$0.prettyDescription}),
      "nameLabel = \(nameLabel.description)",
      "picker = \(picker.description)"
      ))
  }

  override var editing: Bool {
    didSet {
      guard oldValue != editing else { return }
      picker.editing = editing
    }
  }

}

extension BankCollectionDetailButtonCell.Item: Equatable {}
/**
Whether lhs is equal to rhs

- parameter lhs: DetailPickerCell.Index
- parameter rhs: DetailPickerCell.Index

- returns: Bool
*/
func ==(lhs: BankCollectionDetailButtonCell.Item, rhs: BankCollectionDetailButtonCell.Item) -> Bool {
  switch (lhs, rhs) {
    case (.NilItem, .NilItem), (.CreateItem, .CreateItem), (.None, .None):
      return true
    case let (.DataItem(_, o1 as NSObject), .DataItem(_, o2 as NSObject)) where o1.dynamicType.self === o2.dynamicType.self:
      return o1 == o2
    case let (.DataItem(_, o1), .DataItem(_, o2)):
      return o1 === o2
    default:
      return false
  }
}
