//
//  BankCollectionDetailStepperCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailStepperCell: BankCollectionDetailCell {

  private weak var stepperConstraint: NSLayoutConstraint!

  override func initializeIVARs() {
    stepper.addTarget(self, action:"stepperValueDidChange:", forControlEvents:.ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    contentView.addSubview(stepper)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(
      𝗛|-nameLabel--infoLabel,
      𝗩|-nameLabel-|𝗩,
      𝗩|-infoLabel-|𝗩, 𝗩|-stepper-|𝗩,
      [infoLabel--20--stepper, stepper.left => right --> "stepper leading"]
    )
    stepperConstraint = constraintWithIdentifier("stepper leading")
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    stepper.value = 0.0
    stepper.minimumValue = Double(CGFloat.min)
    stepper.maximumValue = Double(CGFloat.max)
    stepper.wraps = true
  }

  override var editing: Bool {
    didSet {
      stepper.userInteractionEnabled = editing
      stepperConstraint.constant = editing ? -8.0 - stepper.bounds.width : 0.0
    }
  }

  override var info: AnyObject? {
    get { return stepper.value }
    set {
      stepper.value = newValue as? Double ?? 0.0
      infoLabel.text = infoDataType.textualRepresentationForObject(newValue) as? String
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
    infoLabel.text = infoDataType.textualRepresentationForObject(sender.value) as? String
  }

   /// MARK: Stepper settings


  var stepperWraps:     Bool?   { get { return stepper.wraps        } set { stepper.wraps = newValue ?? true              } }
  var stepperMinValue:  Double? { get { return stepper.minimumValue } set { stepper.minimumValue = newValue ?? 0.0        } }
  var stepperMaxValue:  Double? { get { return stepper.maximumValue } set { stepper.maximumValue = newValue ?? 0.0        } }
  var stepperStepValue: Double? { get { return stepper.stepValue    } set { stepper.stepValue = max(newValue ?? 1.0, 1.0) } }


}
