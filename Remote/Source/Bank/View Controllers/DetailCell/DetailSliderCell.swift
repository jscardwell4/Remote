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

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    sliderView.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    contentView.addSubview(sliderView)
    let format = "|-[name]-[slider]-[label]-| :: V:|-[label]-| :: V:|-[name]-| :: V:|-[slider]-|"
    contentView.constrain(format, views: ["name": nameLabel, "label": infoLabel, "slider": sliderView])
  }

  /**
  sliderValueDidChange:

  :param: sender UISlider
  */
  func sliderValueDidChange(sender: UISlider) {
    valueDidChange?(sender.value)
    infoLabel.text = textFromObject(sender.value)
  }


  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    sliderView.minimumValue = 0.0
    sliderView.maximumValue = 1.0
    sliderView.value = sliderView.minimumValue
  }

  override var isEditingState: Bool {
    didSet {
      sliderView.userInteractionEnabled = isEditingState
    }
  }

  override var info: AnyObject? {
    get { return sliderView.value }
    set {
      sliderView.value = (newValue as? NSNumber)?.floatValue ?? sliderView.minimumValue
      infoLabel.text = textFromObject(sliderView.value)
    }
  }

  private let sliderView: UISlider = {
    let view = UISlider()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    return view
  }()

  var sliderMinValue:  Float? {
    get { return sliderView.minimumValue }
    set { sliderView.minimumValue = newValue ?? 0.0 }
  }

  var sliderMaxValue:  Float? {
    get { return sliderView.maximumValue }
    set { sliderView.maximumValue = newValue ?? 1.0 }
  }

}
