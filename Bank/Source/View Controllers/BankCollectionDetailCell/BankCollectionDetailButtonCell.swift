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

class BankCollectionDetailButtonCell: BankCollectionDetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override func initializeIVARs() {
    super.initializeIVARs()
//    infoLabel.alpha = 0
    picker.nametag = "picker"
    picker.didSelectItem = {
      _, row in

        self.selection = self._data[row]
        switch self.selection {
          case .None:                       break
          case .NilItem:                    self.didSelectItem?(nil)
          case .CreateItem (_, let action): action()
          case .DataItem   (_, let obj):    self.didSelectItem?(obj)
      }
    }
    contentView.addSubview(nameLabel)
//    contentView.addSubview(infoLabel)
    contentView.addSubview(picker)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(/*𝗛|-nameLabel--infoLabel-|𝗛, */𝗛|-nameLabel--picker-|𝗛)
    constrain(/*infoLabel.centerY => centerY, */picker.centerY => centerY, nameLabel.centerY => centerY)
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    MSLogDebug("")
    super.prepareForReuse()
//    infoLabel.transform = CGAffineTransform.identityTransform
//    infoLabel.alpha = 1
    _data.removeAll()
//    picker.alpha = 0
    selection = .None
    createItem = nil
    didSelectItem = nil
    titleForInfo = nil
  }

  /**
  swapSelectWithAction:

  - parameter action: () -> Void
  */
//  private func swapSelectWithAction(action: () -> Void) { _select = select; select = action }

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
      let searchItem: Item?
      if let nilItem = nilItem where newValue == nil {
        searchItem = nilItem
      } else if let object: AnyObject = newValue, title = titleForObject(object) {
        searchItem = .DataItem(title: title, object: object)
      } else {
        searchItem = nil
      }
      if let item = searchItem, idx = _data.indexOf(item) {
        selection = _data[idx]
        picker.selectItem(idx, animated: false)
      }
    }
  }

  /// MARK: Picker settings

  var nilItem: Item? {
    didSet { if let item = nilItem { switch item { case .NilItem: break; default: nilItem = nil } } }
  }
  var createItem: Item? {
    didSet { if let item = createItem { switch item { case .CreateItem: break; default: createItem = nil } } }
  }
  var didSelectItem: ((AnyObject?) -> Void)?
  var titleForInfo: ((AnyObject?) -> String)?
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
      if let nilItem = nilItem { _data.append(nilItem) }
      _data.extend(
        compressedMap(newValue) {
          if let title = self.titleForObject($0) { return .DataItem(title: title, object: $0) } else { return nil }
        }
      )
      if let createItem = createItem { _data.append(createItem) }
      picker.labels = _data.map { $0.title }
    }
  }

  // MARK: Picker view

  private var _data: [Item] = []
  private var selection: Item = .None //{ didSet { infoLabel.text = selection.title } }

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

    var object: AnyObject? { switch self { case .DataItem(_, let object): return object; default: return nil } }
  }

  private let picker: InlinePickerView = {
    let view = InlinePickerView(autolayout: true)
    view.font = Bank.infoFont
    view.selectedFont = Bank.infoFont
    view.textColor = Bank.infoColor
    view.selectedTextColor = Bank.infoColor.brightnessAdjustedBy(-15)
    return view
    }()

//  private func updateForCurrentState() {
//    switch (editing, showingPicker) {
//      case (true,  true): swapSelectWithAction(hidePickerView)
//      case (false, true): hidePickerView()
//      case (true, false): swapSelectWithAction(showPickerView)
//      default:            select = _select ?? select
//    }
//  }

//  private var showingPicker: Bool = false { didSet { updateForCurrentState() } }

  /** Store select property value so we can temporarily override it */
//  private var _select: (() -> Void)?

  private func dumpState(message: String) {
    MSLogDebug("\n\t".join(
      message,
      description,
      "constraints = \n\t" + "\n\t".join(constraints.map {$0.prettyDescription}),
      "nameLabel = \(nameLabel.description)",
//      "infoLabel = \(infoLabel.description)",
      "picker = \(picker.description)"
      ))
  }

  /** showPickerView */
//  func showPickerView() {
//    if !showingPicker && editing {
//      let textRect = infoLabel.textRectForBounds(infoLabel.bounds, limitedToNumberOfLines: 1)
//      MSLogDebug("infoLabel.frame = \(infoLabel.frame), textRect = \(textRect), picker.frame = \(picker.frame), picker.selectedItemFrame = \(picker.selectedItemFrame)")
//      let offset = textRect.minX / 2
//      let transform = CGAffineTransform(tx: -offset, ty: 0)
//      infoLabel.setNeedsLayout()
//      UIView.animateWithDuration(0.25,
//        animations: {
//          self.infoLabel.transform = transform
//          self.infoLabel.layoutIfNeeded()
//        },
//        completion: {
//          didComplete in
//          if didComplete {
//            self.infoLabel.setNeedsLayout()
//            self.picker.setNeedsLayout()
//            UIView.animateWithDuration(0.25,
//              animations: {
//                self.infoLabel.alpha = 0
//                self.picker.alpha = 1
//                self.infoLabel.layoutIfNeeded()
//                self.picker.layoutIfNeeded()
//              },
//              completion: {
//                didComplete in
//                self.showingPicker = didComplete
//                if !didComplete { MSLogDebug("didn't complete, wtf?") }
//            })
//          } else {
//            MSLogDebug("didn't complete, wtf?")
//          }
//      })
//    }
//  }

  /** hidePickerView */
//  func hidePickerView() {
//    if showingPicker {
//      // Updated info label's transform before animation in case the text has chnaged
//      let textRect = infoLabel.textRectForBounds(infoLabel.bounds, limitedToNumberOfLines: 1)
//      let offset = textRect.minX / 2
//      let transform = CGAffineTransform(tx: -offset, ty: 0)
//      infoLabel.transform = transform
//      infoLabel.setNeedsLayout()
//      picker.setNeedsLayout()
//      UIView.animateWithDuration(0.25,
//        animations: {
//          self.infoLabel.alpha = 1
//          self.picker.alpha = 0
//          self.infoLabel.layoutIfNeeded()
//          self.picker.layoutIfNeeded()
//        },
//        completion: {
//          didComplete in
//          if didComplete {
//            self.infoLabel.setNeedsLayout()
//            UIView.animateWithDuration(0.25,
//              animations: {
//                self.infoLabel.transform = CGAffineTransform.identityTransform
//                self.infoLabel.layoutIfNeeded()
//              },
//              completion: {
//                didComplete in
//                self.showingPicker = !didComplete
//                if !didComplete { MSLogDebug("didn't complete, wtf?") }
//            })
//          } else {
//            MSLogDebug("didn't complete, wtf?")
//          }
//      })
//    }
//  }

  override var editing: Bool {
    didSet {
      guard oldValue != editing else { return }
      picker.editing = editing
//      if editing { showPickerView() } else { hidePickerView() }
//      updateForCurrentState()
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
