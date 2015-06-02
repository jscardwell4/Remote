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

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override func initializeIVARs() {
    switchView.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(switchView)
    contentView.constrain(𝗛|-nameLabel--switchView-|𝗛, 𝗩|-nameLabel-|𝗩, 𝗩|-switchView-|𝗩)
  }

  /**
  switchValueDidChange:

  :param: sender UISwitch
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
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    return view
  }()

}
