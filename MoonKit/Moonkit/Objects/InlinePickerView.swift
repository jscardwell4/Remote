//
//  InlinePickerView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class InlinePickerView: UIView {

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override public init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** initializeIVARs */
  private func initializeIVARs() {
    picker.delegate = self
    picker.dataSource = self
    addSubview(picker)
  }

  override public func updateConstraints() {
    super.updateConstraints()

    let id = createIdentifier(self, "Internal")

    removeConstraintsWithIdentifier(id)
    constrain(identifier: id,
              picker.left => self.left,
              picker.right => self.right,
              picker.top => self.top,
              picker.bottom => self.bottom)
  }

  private let picker = UIPickerView.newForAutolayout()

  override public class func requiresConstraintBasedLayout() -> Bool { return true }
  override public func intrinsicContentSize() -> CGSize { return picker.intrinsicContentSize() }

  /**
  selectRow:inComponent:animated:

  - parameter row: Int
  - parameter component: Int
  - parameter animated: Bool
  */
  public func selectRow(row: Int, animated: Bool) { picker.selectRow(row, inComponent: 0, animated: animated) }

  public var labels: [String] = []
  public var didSelectRow: ((InlinePickerView, Int) -> Void)?

}

extension InlinePickerView: UIPickerViewDataSource {
  public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
  public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return labels.count }
  public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return labels[row]
  }
}

extension InlinePickerView: UIPickerViewDelegate {
  public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { didSelectRow?(self, row) }

}