//
//  InlinePickerView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol InlinePickerViewDelegate: NSObjectProtocol {
  func inlinePicker(picker: InlinePickerView, didSelectRows rows: [Int])
  func inlinePickerDidCancel(picker: InlinePickerView)
  func numberOfComponentsForInlinePicker(picker: InlinePickerView) -> Int
  func inlinePicker(picker: InlinePickerView, numberOfRowsForComponent component: Int) -> Int
  func inlinePicker(picker: InlinePickerView, titleForRow row: Int, forComponent component: Int) -> String?
  optional func inlinePicker(picker: InlinePickerView, didSelectRow row: Int, inComponent component: Int)

}

public class InlinePickerView: UIView {

  public var cancelBarButtonItem: UIBarButtonItem?
  public var selectBarButtonItem: UIBarButtonItem?

  public var delegate: InlinePickerViewDelegate?
  private var toolbar: UIToolbar!
  private var picker: UIPickerView!

  class var requiresConstraintBasedLayout: Bool { return true }

  /** cancelAction */
  func cancelAction() {
    delegate?.inlinePickerDidCancel(self)
  }

  /** selectAction */
  func selectAction() {
    delegate?.inlinePicker(self, didSelectRows: map(0..<picker.numberOfComponents){self.picker.selectedRowInComponent($0)})
  }

  /**
  selectRow:inComponent:animated:

  :param: row Int
  :param: component Int
  :param: animated Bool
  */
  public func selectRow(row: Int, inComponent component: Int, animated: Bool) {
    picker.selectRow(row, inComponent: component, animated: animated)
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override public init(frame: CGRect) {
    super.init(frame: frame)
    toolbar = UIToolbar.newForAutolayout()
    cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
    selectBarButtonItem = UIBarButtonItem(title: "Select", style: .Done, target: self, action: "selectAction")
    toolbar.items = [cancelBarButtonItem!,
                     UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                     selectBarButtonItem!]
    addSubview(toolbar)
    picker = UIPickerView.newForAutolayout()
    picker.delegate = self
    picker.dataSource = self
    addSubview(picker)
    constrain("|[toolbar]| :: |[picker]| :: V:|[toolbar][picker]|", views: ["toolbar": toolbar, "picker": picker])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension InlinePickerView: UIPickerViewDataSource {

  /**
  numberOfComponentsInPickerView:

  :param: pickerView UIPickerView

  :returns: Int
  */
  public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return delegate?.numberOfComponentsForInlinePicker(self) ?? 1
  }

  /**
  pickerView:numberOfRowsInComponent:

  :param: pickerView UIPickerView
  :param: component Int

  :returns: Int
  */
  public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return delegate?.inlinePicker(self, numberOfRowsForComponent: component) ?? 0
  }

}

extension InlinePickerView: UIPickerViewDelegate {

  /**
  pickerView:didSelectRow:inComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
  */
  public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    delegate?.inlinePicker?(self, didSelectRow: row, inComponent: component)
  }

}