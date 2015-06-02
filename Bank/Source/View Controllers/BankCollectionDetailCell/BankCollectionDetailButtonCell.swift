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

class BankCollectionDetailButtonCell: BankCollectionDetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override func initializeIVARs() {
    buttonView.addTarget(self, action:"buttonUpAction", forControlEvents:.TouchUpInside)
    contentView.addSubview(nameLabel)
    contentView.addSubview(buttonView)
    contentView.constrain(𝗛|-nameLabel--buttonView-|𝗛, 𝗩|-buttonView-|𝗩, 𝗩|-nameLabel-|𝗩)
  }

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
  func buttonUpAction() { if showingPicker { hidePickerView() } else if editing { showPickerView() } }

  private let buttonView: UIButton =  {
    let view = UIButton(autolayout: true)
    view.userInteractionEnabled = false
    view.titleLabel?.font = Bank.infoFont;
    view.titleLabel?.textAlignment = .Right;
    view.constrain(𝗩|view.titleLabel!|𝗩, 𝗛|view.titleLabel!|𝗛)
    view.setTitleColor(Bank.infoColor, forState:.Normal)
    return view
  }()

  override var info: AnyObject? {
    didSet {
      switch infoDataType.textualRepresentationForObject(info) {
        case let text as NSAttributedString: buttonView.setAttributedTitle(text, forState: .Normal)
        case let text as String:             buttonView.setTitle(text, forState: .Normal)
        default:                             buttonView.setTitle(detailPickerRow?.nilItemTitle, forState: .Normal)
      }
    }
  }

  /// MARK: Picker settings
  ////////////////////////////////////////////////////////////////////////////////

  var showPickerRow: ((BankCollectionDetailButtonCell) -> Bool)?
  var hidePickerRow: ((BankCollectionDetailButtonCell) -> Bool)?
  var detailPickerRow: BankCollectionDetailPickerRow?

  private var showingPicker: Bool = false

  /** showPickerView */
  func showPickerView() { if !(showingPicker || detailPickerRow == nil) { showingPicker = showPickerRow?(self) == true } }

  /** hidePickerView */
  func hidePickerView() { if showingPicker { showingPicker = !(hidePickerRow?(self) == true) } }

  override var editing: Bool {
    didSet { buttonView.userInteractionEnabled = editing; if !editing && showingPicker { hidePickerView() } }
  }

}
