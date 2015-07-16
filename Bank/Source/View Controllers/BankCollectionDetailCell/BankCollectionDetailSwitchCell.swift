//
//  BankCollectionDetailSwitchCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailSwitchCell: BankCollectionDetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override func initializeIVARs() {
    super.initializeIVARs()
    switchView.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(switchView)
  }

  override func updateConstraints() {
    super.updateConstraints()
    let id = MoonKit.Identifier(self, "Internal")
    if constraintsWithIdentifier(id).count == 0 {
      constrain(𝗛|-nameLabel--switchView-|𝗛 --> id, [nameLabel.centerY => centerY, switchView.centerY => centerY] --> id)
    }
  }

  /**
  switchValueDidChange:

  - parameter sender: UISwitch
  */
  func switchValueDidChange(sender: UISwitch) { valueDidChange?(NSNumber(bool: sender.on)) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    switchView.on = false
  }

  override var editing: Bool { didSet { switchView.userInteractionEnabled = editing } }

  override var info: AnyObject? {
    get { return switchView.on }
    set { switchView.on = newValue as? Bool ?? false }
  }

  private let switchView: UISwitch = {
    let view = UISwitch()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.userInteractionEnabled = false
    view.setContentHuggingPriority(1000, forAxis: .Horizontal)
    return view
  }()

}
