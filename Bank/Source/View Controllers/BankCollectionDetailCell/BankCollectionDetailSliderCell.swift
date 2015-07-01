//
//  BankCollectionDetailSliderCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailSliderCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    sliderView.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
    sliderView.userInteractionEnabled = false
    contentView.addSubview(nameLabel)
    contentView.addSubview(sliderView)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|-nameLabel--sliderView-|𝗛, [nameLabel.centerY => centerY, sliderView.centerY => centerY])
  }

  /**
  sliderValueDidChange:

  - parameter sender: UISlider
  */
  func sliderValueDidChange(sender: UISlider) { valueDidChange?(sender.value) }

  override var infoDataType: DataType { get { return .FloatData(minValue...maxValue)} set {} }

  /** prepareForReuse */
  override func prepareForReuse() { super.prepareForReuse(); nameLabel.text = nil; minValue = 0.0; maxValue = 1.0 }

  override var editing: Bool { didSet { sliderView.userInteractionEnabled = editing } }

  override var info: AnyObject? {
    get { return sliderView.value }
    set { sliderView.value = (newValue as? NSNumber)?.floatValue ?? sliderView.minimumValue }
  }

  private let sliderView: Slider = Slider(autolayout: true)

  var minValue:  Float {
    get { return sliderView.minimumValue }
    set { sliderView.minimumValue = newValue }
  }

  var maxValue:  Float {
    get { return sliderView.maximumValue }
    set { sliderView.maximumValue = newValue }
  }

  var sliderStyle: Slider.SliderStyle {
    get { return sliderView.sliderStyle }
    set { sliderView.sliderStyle = newValue }
  }

}
