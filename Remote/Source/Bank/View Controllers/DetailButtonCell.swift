//
//  DetailButtonCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// protocol DetailButtonCellDelegate {
//   func insertPickerRow(pickerRow: DetailPickerRow, forDetailButtonCell buttonCell: DetailButtonCell)
//   func removePickerRowForDetailButtonCell(buttonCell: DetailButtonCell)
// }

class DetailButtonCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    buttonView.addTarget(self, action:"buttonUpAction", forControlEvents:.TouchUpInside)
    contentView.addSubview(nameLabel)
    contentView.addSubview(buttonView)
    contentView.constrain("|-[n]-[b]-| :: V:|-[n]-| :: V:|-[b]-|", views: ["n": nameLabel, "b": buttonView])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    buttonView.setTitle(nil, forState: .Normal)
    showPickerRow = nil
    hidePickerRow = nil
    detailPickerRow = nil
    if showingPicker { hidePickerView() }
  }

  /**
  buttonUpAction:

  :param: sender UIButton
  */
  func buttonUpAction() {
    // If we have a picker view already, remove it
    if showingPicker { hidePickerView() }

    // Otherwise, check editing state and picker availability before showing
    else if isEditingState { showPickerView() }
  }

  private let buttonView: UIButton =  {
    let view = UIButton(autolayout: true)
    view.userInteractionEnabled = false
    view.titleLabel?.font = Bank.infoFont;
    view.titleLabel?.textAlignment = .Right;
    view.constrain("|[title]| :: V:|[title]|", views: ["title": view.titleLabel!])
    view.setTitleColor(Bank.infoColor, forState:.Normal)
    return view
  }()

  override var info: AnyObject? {
    didSet {
      if infoDataType == .AttributedStringData {
        buttonView.setAttributedTitle(info as? NSAttributedString, forState: .Normal)
      } else {
        buttonView.setTitle(textFromObject(info), forState:.Normal)
      }
    }
  }

  /// MARK: Picker settings
  ////////////////////////////////////////////////////////////////////////////////

  var showPickerRow: ((DetailButtonCell) -> Bool)?
  var hidePickerRow: ((DetailButtonCell) -> Bool)?
  var detailPickerRow: DetailPickerRow?

  private var showingPicker: Bool = false

  /** showPickerView */
  func showPickerView() {
    if showingPicker || detailPickerRow == nil { return }

    showingPicker = showPickerRow?(self) == true
  }

  /** hidePickerView */
  func hidePickerView() {
    if !showingPicker { return }

    showingPicker = !(hidePickerRow?(self) == true)
  }

  override var isEditingState: Bool {
    didSet {
      buttonView.userInteractionEnabled = isEditingState
      if !isEditingState && showingPicker { hidePickerView() }
    }
  }

}
