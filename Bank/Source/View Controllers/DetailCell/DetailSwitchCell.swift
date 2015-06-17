//
//  DetailSwitchCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSwitchCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    switchView.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(switchView)
    let format = "|-[name]-[switch]-| :: V:|-[name]-| :: V:|-[switch]-|"
    contentView.constrain(format, views: ["name": nameLabel, "switch": switchView])
  }

  /**
  switchValueDidChange:

  - parameter sender: UISwitch
  */
  func switchValueDidChange(sender: UISwitch) { valueDidChange?(NSNumber(bool: sender.on)) }


  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    switchView.on = false
  }

  override var isEditingState: Bool {
    didSet {
      switchView.userInteractionEnabled = isEditingState
    }
  }

  override var info: AnyObject? {
    get { return switchView.on }
    set { switchView.on = newValue as? Bool ?? false }
  }

  private let switchView: UISwitch = {
    let view = UISwitch()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.userInteractionEnabled = false
    return view
  }()

}
