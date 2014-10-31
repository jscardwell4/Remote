//
//  ColorSelectionController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc protocol ColorSelectionControllerDelegate: class {
	func colorSelectionController(controller: ColorSelectionController, didSelectColor color: UIColor)
	func colorSelectionControllerDidCancel(controller: ColorSelectionController)
}

class ColorSelectionController: SelectionViewController {

	var initialColor: UIColor = UIColor.blueColor()

	weak var delegate: ColorSelectionControllerDelegate?

//	var hidesToolbar: Bool = false { didSet { buttonToolbar?.hidden = hidesToolbar } }

	let colorNames: [String] = (UIColor.colorNames() as [String]).sorted(<)

	@IBOutlet weak var redSlider:  UISlider!
	@IBOutlet weak var greenSlider:  UISlider!
	@IBOutlet weak var blueSlider:  UISlider!
	@IBOutlet weak var alphaSlider:  UISlider!
	@IBOutlet weak var colorBox:  UIView!
	@IBOutlet weak var picker:  UIPickerView!
	@IBOutlet weak var presetsButton:  UIBarButtonItem!
	@IBOutlet weak var buttonToolbar:  UIToolbar!
  @IBOutlet weak var pickerConstraint: NSLayoutConstraint!
  @IBOutlet weak var controlsWrapper: UIView!
  @IBOutlet weak var pickerWrapper: UIVisualEffectView!

	/** viewDidLoad */
	override func viewDidLoad() {
		super.viewDidLoad()
		redSlider.maximumTrackTintColor   = UIColor.redColor()
		greenSlider.maximumTrackTintColor = UIColor.greenColor()
		blueSlider.maximumTrackTintColor  = UIColor.blueColor()
		alphaSlider.maximumTrackTintColor = UIColor.whiteColor()
		setPresentationForColor(initialColor)
	}

	/**
	setPresentationForColor:

	:param: color UIColor
	*/
	func setPresentationForColor(color: UIColor) {

		colorBox.backgroundColor = color

		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    redSlider.value = Float(red)
		greenSlider.value = Float(green)
		blueSlider.value = Float(blue)
		alphaSlider.value = Float(alpha)

	}

	/**
	sliderValueDidChange:

	:param: sender UISlider
	*/
	@IBAction func sliderValueDidChange(sender: UISlider) {

		colorBox.backgroundColor = UIColor(red:   CGFloat(redSlider.value),
                                       green: CGFloat(greenSlider.value),
                                       blue:  CGFloat(blueSlider.value),
                                       alpha: CGFloat(alphaSlider.value))
	}

	/** togglePresets */
  @IBAction func togglePresets() {
    var c: CGFloat
    switch pickerConstraint.constant {
      case 0.0:
        presetsButton.tintColor = UIColor(red: 0.0, green: 145/255.0, blue: 1.0, alpha: 1.0)
        c = -pickerWrapper.bounds.size.height
      default:
        presetsButton.tintColor = nil
        c = 0.0
    }
    view.layoutIfNeeded()
    UIView.animateWithDuration(1.0) {
      self.pickerConstraint.constant = c
      self.view.layoutIfNeeded()
    }
  }

	/** cancel */
	@IBAction func cancel() { delegate?.colorSelectionControllerDidCancel(self) }

	/** reset */
	@IBAction func reset() { setPresentationForColor(initialColor) }

	/** save */
	@IBAction func save() { delegate?.colorSelectionController(self, didSelectColor: colorBox.backgroundColor!) }

}

extension ColorSelectionController: UIPickerViewDelegate, UIPickerViewDataSource {

  /**
  numberOfComponentsInPickerView:

  :param: pickerView UIPickerView

  :returns: Int
  */
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }

  /**
  pickerView:numberOfRowsInComponent:

  :param: pickerView UIPickerView
  :param: component Int

  :returns: Int
  */
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return colorNames.count }

  /**
  pickerView:viewForRow:forComponent:var:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
  :param: view UIView!

  :returns: UIView
  */
  func pickerView(pickerView: UIPickerView,
  	   viewForRow row: Int,
  	 forComponent component: Int,
  var reusingView view: UIView!) -> UIView
  {
	  if view == nil {

	  	view = UIView(frame: colorBox.bounds)
	  	view.backgroundColor = UIColor.clearColor()

	  	let box = UIView(frame: CGRect(x: 0, y: 5, width: 44, height: 34))
	  	box.tag = 1
	  	view.addSubview(box)

	  	let colorName = UILabel(frame: CGRect(x: 54, y: 0, width: 200, height: 44))
	  	colorName.baselineAdjustment = .AlignCenters
	  	colorName.adjustsFontSizeToFitWidth = true
	  	colorName.backgroundColor = UIColor.clearColor()
	  	colorName.tag = 2
	  	view.addSubview(colorName)

	  }

	  let colorName = colorNames[row]

    view.viewWithTag(1)!.backgroundColor = UIColor(name: colorName)
	  (view.viewWithTag(2) as UILabel).text = colorName

	  return view!

  }

  /**
  Handles selection of `nil`, `create`, or `pickerData` row

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
  */
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
  	setPresentationForColor(UIColor(name: colorNames[row]))
  }

}
