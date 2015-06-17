//
//  DetailSliderCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSliderCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    sliderView.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
    sliderView.userInteractionEnabled = false
    contentView.addSubview(nameLabel)
    contentView.addSubview(sliderView)
    let format = "|-[name]-[slider]-| :: V:|-[name]-| :: V:|-[slider]-|"
    contentView.constrain(format, views: ["name": nameLabel, "label": infoLabel, "slider": sliderView])
  }

  /**
  sliderValueDidChange:

  - parameter sender: UISlider
  */
  func sliderValueDidChange(sender: UISlider) { valueDidChange?(sender.value) }

  override var infoDataType: DataType { get { return .FloatData(minValue...maxValue)} set {} }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() { super.prepareForReuse(); nameLabel.text = nil; minValue = 0.0; maxValue = 1.0 }

  override var isEditingState: Bool { didSet { sliderView.userInteractionEnabled = isEditingState } }

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
