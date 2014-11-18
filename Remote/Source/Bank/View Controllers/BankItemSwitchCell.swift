//
//  BankItemSwitchCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemSwitchCell: BankItemCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    switchℹ.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(switchℹ)
    let format = "|-[name]-[switch]-| :: V:|-[name]-| :: V:|-[switch]-|"
    contentView.constrain(format, views: ["name": nameLabel, "switch": switchℹ])
  }

  /**
  switchValueDidChange:

  :param: sender UISwitch
  */
  func switchValueDidChange(sender: UISwitch) { valueDidChange?(NSNumber(bool: sender.on)) }


  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    switchℹ.on = false
  }

  override var isEditingState: Bool {
    didSet {
      switchℹ.userInteractionEnabled = isEditingState
    }
  }

  override var info: AnyObject? {
    get { return switchℹ.on }
    set { switchℹ.on = newValue as? Bool ?? false }
  }

  private let switchℹ: UISwitch = {
    let view = UISwitch()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    return view
  }()

}
