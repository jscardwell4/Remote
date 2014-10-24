//
//  BankItemStepperCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemStepperCell: BankItemCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    stepper.addTarget(self, action:"stepperValueDidChange:", forControlEvents:.ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    contentView.addSubview(stepper)
    let format = "\n".join(
      "|-[name]-[label]",
      "label.trailing = stepper.leading - 8",
      "V:|-[name]-| :: V:|-[label]-| :: V:|-[stepper]-|",
      "'stepper leading' stepper.leading = self.trailing"
    )
    contentView.constrainWithFormat(format, views: ["name": nameLabel, "label": infoLabel, "stepper": stepper])
  }


  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    stepper.value = 0.0
    stepper.minimumValue = Double(CGFloat.min)
    stepper.maximumValue = Double(CGFloat.max)
    stepper.wraps = true
  }

  override var isEditingState: Bool {
    didSet {
      stepper.userInteractionEnabled = isEditingState
      if let stepperLeading = contentView.constraintWithIdentifier("stepper leading") {
        stepperLeading.constant = isEditingState ? -8.0 - (stepper.bounds.size.width ?? 0.0) : 0.0
      }
    }
  }

  override var info: AnyObject? {
    get { return stepper.value }
    set {
      stepper.value = newValue as? Double ?? 0.0
      infoLabel.text = textFromObject(newValue)
    }
  }

  private let stepper: UIStepper =  {
    let view = UIStepper()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    return view
  }()


  /**
  stepperValueDidChange:

  :param: sender UIStepper
  */
  func stepperValueDidChange(sender: UIStepper) {
    valueDidChange?(sender.value)
    infoLabel.text = textFromObject(sender.value)
  }

   /// MARK: Stepper settings
  ////////////////////////////////////////////////////////////////////////////////


  var stepperWraps:     Bool?   { get { return stepper.wraps        } set { stepper.wraps = newValue ?? true              } }
  var stepperMinValue:  Double? { get { return stepper.minimumValue } set { stepper.minimumValue = newValue ?? 0.0        } }
  var stepperMaxValue:  Double? { get { return stepper.maximumValue } set { stepper.maximumValue = newValue ?? 0.0        } }
  var stepperStepValue: Double? { get { return stepper.stepValue    } set { stepper.stepValue = max(newValue ?? 1.0, 1.0) } }


}
