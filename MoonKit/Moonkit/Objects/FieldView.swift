//
//  FieldView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/** View subclass for a single form field with a name label and a control for capturing the value */
final class FieldView: UIView, UITextFieldDelegate, AKPickerViewDelegate, AKPickerViewDataSource {

  typealias Field = FormViewController.Field

  // MARK: - Field-related properties

  let name: String
  let field: Field
  var value: Any? {
    switch field {
      case .Text:     return textControl?.text
      case .Switch:   return switchControl?.on
      case .Slider:   return sliderControl?.value
      case .Stepper:  return stepperControl?.value
      case .Picker:   return pickerControl?.selectedItem
      case .Checkbox: return checkboxControl?.checked
    }
  }

  // MARK: - Customizing appearance

  var labelFont: UIFont { get { return nameLabel.font } set { nameLabel.font = newValue } }
  var labelTextColor: UIColor { get { return nameLabel.textColor } set { nameLabel.textColor = newValue } }

  var controlFont: UIFont? {
    get { return textControl?.font ?? pickerControl?.font }
    set { if let font = newValue { textControl?.font = font; pickerControl?.font = font } }
  }
  var controlSelectedFont: UIFont? {
    get { return pickerControl?.highlightedFont }
    set { if let font = newValue { pickerControl?.highlightedFont = font } }
  }
  var controlTextColor: UIColor? {
    get { return textControl?.textColor ?? pickerControl?.textColor }
    set { if let color = newValue { textControl?.textColor = color;  pickerControl?.textColor = color } }
  }
  var controlSelectedTextColor: UIColor? {
    get { return  pickerControl?.highlightedTextColor }
    set { if let color = newValue { pickerControl?.highlightedTextColor = color } }
  }

  // MARK: - Label and control

  /** Overridden to return the field view's `name` property */
  override var nametag: String! { get { return nameLabel.text } set {} }

  weak var nameLabel: UILabel!
  weak var fieldControl: UIView!

  /**
  fieldControlForField:

  :param: field Field

  :returns: UIView
  */
  private func fieldControlForField(field: Field) -> UIView {
    let control: UIView
    switch field {
    case let .Text(initial, placeholder, validation):
      let textField = UITextField.newForAutolayout()
      textField.text = initial
      textField.textAlignment = .Right
      textField.placeholder = placeholder
      textField.returnKeyType = .Done
      textField.layer.shadowColor = UIColor.redColor().CGColor
      textFieldValidation = validation
      textField.delegate = self
      control = textField
    case let .Switch(initial):
      let switchControl = UISwitch.newForAutolayout()
      switchControl.on = initial
      control = switchControl
    case let .Checkbox(initial):
      let checkbox = Checkbox.newForAutolayout()
      checkbox.checked = initial
      control = checkbox
    case let .Slider(initial, min, max):
      let slider = UISlider.newForAutolayout()
      slider.minimumValue = min
      slider.maximumValue = max
      slider.value = initial
      control = slider
    case let .Stepper(initial, min, max, step):
      let stepper = UIStepper.newForAutolayout()
      stepper.minimumValue = min
      stepper.maximumValue = max
      stepper.stepValue = step
      stepper.value = initial
      control = stepper
    case let .Picker(initial, choices):
      let picker = AKPickerView.newForAutolayout()
      picker.delegate = self
      picker.dataSource = self
      picker.interitemSpacing = 20.0
      control = picker
    }
    return control
  }

  var textControl: UITextField? { return fieldControl as? UITextField }
  var switchControl: UISwitch? { return fieldControl as? UISwitch }
  var sliderControl: UISlider? { return fieldControl as? UISlider }
  var stepperControl: UIStepper? { return fieldControl as? UIStepper }
  var pickerControl: AKPickerView? { return fieldControl as? AKPickerView }
  var checkboxControl: Checkbox? { return fieldControl as? Checkbox }

  // MARK: Validating text fields

  var textFieldValidation: ((String?) -> Bool)?
  var valid: Bool { return textFieldValidation?(textControl?.text) ?? true }
  var showingInvalid = false { didSet { textControl?.layer.shadowOpacity = showingInvalid ? 0.9 : 0.0 } }

  // MARK: Picker data

  var choices: [String] = []
  var choice = 0

  // MARK: - Initializing the view

  /** initializeIVARs */
  private func initializeIVARs() {
    setTranslatesAutoresizingMaskIntoConstraints(false)
    let label = UILabel.newForAutolayout()
    label.text = name
    addSubview(label)
    nameLabel = label
    let control = fieldControlForField(field)
    control.layer.borderColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.8).CGColor
    addSubview(control)
    fieldControl = control
  }

  /**
  Initialize the view with a name and field

  :param: n String
  :param: f Field
  */
  init(tag t: Int, name n: String, field f: Field) {
    name = n; field = f
    super.init(frame: CGRect.zeroRect)
    tag = t
    initializeIVARs()
  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Constraints

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  override func intrinsicContentSize() -> CGSize {
    let labelSize = nameLabel.intrinsicContentSize()
    let fieldSize = fieldControl.intrinsicContentSize()
    return CGSize(width: labelSize.width + 10.0 + fieldSize.width, height: max(labelSize.height, fieldSize.height))
  }

  override func updateConstraints() {
    super.updateConstraints()
    let id = createIdentifier(self, "Internal")
    removeConstraintsWithIdentifier(id)
    constrain([𝗩|nameLabel|𝗩, 𝗩|fieldControl|𝗩] --> id)
    constrain([𝗛|nameLabel, fieldControl.left => nameLabel.right + 10.0, fieldControl|𝗛] --> id)
  }

  // MARK: - Text field delegate

  @objc func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

  // MARK: - Picker delegate and data source

  @objc func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int { return choices.count }
  @objc func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String { return choices[item] }
  @objc func pickerView(pickerView: AKPickerView, didSelectItem item: Int) { choice = item }

}
