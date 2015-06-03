//
//  BankCollectionDetailTwoToneSliderCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/08/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailTwoToneSliderCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    sliderView.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
    sliderView.userInteractionEnabled = false
    contentView.addSubview(nameLabel)
    contentView.addSubview(sliderView)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|-nameLabel--sliderView-|𝗛, 𝗩|-sliderView-|𝗩, 𝗩|-nameLabel-|𝗩)
  }

  /**
  sliderValueDidChange:

  :param: sender UISlider
  */
  func sliderValueDidChange(sender: UISlider) { valueDidChange?(sender.value) }

  override var infoDataType: DataType { get { return .FloatData(0.0...1.0)} set {} }

  /** prepareForReuse */
  override func prepareForReuse() { super.prepareForReuse(); nameLabel.text = nil }

  override var editing: Bool { didSet { sliderView.userInteractionEnabled = editing } }

  override var info: AnyObject? {
    get { return sliderView.value }
    set { sliderView.value = (newValue as? NSNumber)?.floatValue ?? sliderView.minimumValue }
  }

  private let sliderView = TwoToneSlider(type: .Custom, autolayout: true)

  var generatedColorType: TwoToneSlider.GeneratedColorType {
    get { return sliderView.generatedColorType }
    set { sliderView.generatedColorType = newValue }
  }

  var lowerColor: (TwoToneSlider) -> UIColor {
    get { return sliderView.lowerColor }
    set { sliderView.lowerColor = newValue }
  }

  var upperColor: (TwoToneSlider) -> UIColor {
    get { return sliderView.upperColor }
    set { sliderView.upperColor = newValue }
  }

}
