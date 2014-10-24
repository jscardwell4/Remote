//
//  BankItemButtonCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemButtonCell: BankItemCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    buttonℹ.addTarget(self, action:"buttonUpAction", forControlEvents:.TouchUpInside)
    wrapper.addSubview(nameLabel)
    wrapper.addSubview(buttonℹ)
    wrapper.constrainWithFormat("|-[name]-[button]-| :: V:|-[name]-| :: V:|-[button]-|", views: ["name": nameLabel, "button": buttonℹ])
    contentView.addSubview(wrapper)
    contentView.constrainWithFormat("|[wrapper]| :: V:|[wrapper]-(>=0)-|",
                              views: ["wrapper": wrapper],
                         identifier: createIdentifier(self, "Wrapper"))
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    buttonℹ.setTitle(nil, forState: .Normal)
    pickerData = nil
    pickerSelection = nil
  }

  /**
  buttonUpAction:

  :param: sender UIButton
  */
  func buttonUpAction() {
    // If we have a picker view already, remove it
    if picker != nil { hidePickerView() }

    // Otherwise, check editing state and picker availability before showing
    else if isEditingState && pickerEnabled { showPickerView() }
  }

  private let wrapper: UIView = {
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    return view
  }()

  private let buttonℹ: UIButton =  {
    let view = UIButton()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.titleLabel?.font = Bank.infoFont;
    view.titleLabel?.textAlignment = .Right;
    view.constrainWithFormat("|[title]| :: V:|[title]|", views: ["title": view.titleLabel!])
    view.setTitleColor(Bank.infoColor, forState:.Normal)
    return view
  }()

  override var info: AnyObject? {
    get { return buttonℹ.titleForState(.Normal) }
    set { buttonℹ.setTitle(textFromObject(newValue), forState:.Normal) }
  }


  private weak var picker: UIPickerView?

  /// MARK: Picker settings
  ////////////////////////////////////////////////////////////////////////////////

  class var pickerHeight: CGFloat { return 162.0 }

  var pickerCreateSelectionHandler: ((Void) -> Void)?
  var shouldShowPicker: ((BankItemButtonCell) -> Bool)?
  var shouldHidePicker: ((BankItemButtonCell) -> Bool)?
  var didShowPicker: ((BankItemButtonCell) -> Void)?
  var didHidePicker: ((BankItemButtonCell) -> Void)?
  var didSelectItem: ((NSObject?) -> Void)?

  var pickerData: [NSObject]?

  var pickerSelection: NSObject? {
    didSet {
      info = pickerSelection ?? pickerNilSelectionTitle
      picker?.selectRow(pickerSelectionIndex, inComponent: 0, animated: true)
    }
  }

  var pickerSelectionIndex: Int {
    precondition(pickerEnabled, "this shouldn't get called unless we are actually using a picker view")
    if let idx = find(pickerData!, pickerSelection) {
      return idx + prependedPickerItemCount
    }
    return 0
  }

  var pickerNilSelectionTitle: String? {
    didSet { prependedPickerItemCount = pickerNilSelectionTitle != nil ? 1 : 0 }
  }

  var pickerCreateSelectionTitle: String? {
    didSet { appendedPickerItemCount = pickerCreateSelectionTitle != nil ? 1 : 0 }
  }

  var pickerEnabled: Bool { return pickerData != nil }

  var prependedPickerItemCount = 0
  var appendedPickerItemCount = 0

  var pickerItemCount: Int {
    var count = prependedPickerItemCount + appendedPickerItemCount
    if pickerData != nil { count += pickerData!.count }
    return count
  }

  /**
  pickerDataItemForRow:

  :param: row Int

  :returns: NSObject?
  */
  func pickerDataItemForRow(row: Int) -> NSObject? {
    if prependedPickerItemCount > 0 && row == 0 { return pickerNilSelectionTitle }
    else if appendedPickerItemCount > 0 && row == pickerItemCount - 1 { return pickerCreateSelectionTitle }
    else { return pickerData?[row - prependedPickerItemCount] }
  }

  /** showPickerView */
  func showPickerView() {
    precondition(pickerEnabled, "method should only be called when picker is enabled")
    if picker == nil && shouldShowPicker ∅|| shouldShowPicker!(self) {
      picker = {
        let pickerView = UIPickerView()
        pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(self.pickerSelectionIndex, inComponent: 0, animated: false)
        self.contentView.addSubview(pickerView)
        let identifier = createIdentifier(self, "Wrapper")
        self.contentView.removeConstraintsWithIdentifier(identifier)
        self.contentView.constrainWithFormat("|[wrapper]| :: |[picker]| :: V:|[wrapper]-(<=0,>=0)-[picker]|",
                                       views: ["wrapper": self.wrapper, "picker": pickerView],
                                  identifier: identifier)
        return pickerView
      }()
      didShowPicker?(self)
    }
  }

  /** hidePickerView */
  func hidePickerView() {
    precondition(pickerEnabled, "method should only be called when picker is enabled")
    if picker != nil && shouldHidePicker ∅|| shouldHidePicker!(self) {
      picker!.removeFromSuperview()
      picker = nil
      let identifier = createIdentifier(self, "Wrapper")
      contentView.removeConstraintsWithIdentifier(identifier)
      contentView.constrainWithFormat("|[wrapper]| :: V:|[wrapper]-(>=0)-|",
                                views: ["wrapper": wrapper],
                           identifier: identifier)
      didSelectItem?(pickerSelection)
      didHidePicker?(self)
    }
  }

  override var isEditingState: Bool {
    didSet {
      buttonℹ.userInteractionEnabled = isEditingState
      if !isEditingState && pickerEnabled && picker != nil { hidePickerView() }
    }
  }


}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UIPickerViewDataSource
////////////////////////////////////////////////////////////////////////////////
extension BankItemButtonCell: UIPickerViewDataSource {


  /**
  numberOfComponentsInPickerView:

  :param: pickerView UIPickerView

  :returns: Int
  */
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }

  /**
  pickerView:numberOfRowsInComponent:

  :param: pickerView UIPickerView
  :param: component Int

  :returns: Int
  */
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItemCount
  }

  /**
  pickerView:titleForRow:forComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int

  :returns: String?
  */
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return textFromObject(pickerDataItemForRow(row)) ?? ""
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UIPickerViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankItemButtonCell: UIPickerViewDelegate {

  /**
  Handles selection of `nil`, `create`, or `pickerData` row

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
  */
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    if appendedPickerItemCount > 0 && row == pickerItemCount - 1 { pickerCreateSelectionHandler?() }
    else {
      pickerSelection = row - prependedPickerItemCount >= 0 ? pickerData![row - prependedPickerItemCount] : nil
    }
  }

}
