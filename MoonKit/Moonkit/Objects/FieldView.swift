//
//  FieldView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public enum FieldTemplate {
  case Text     (value: String, placeholder: String?, validation: ((String?) -> Bool)?, editable: Bool)
  case Switch   (value: Bool, editable: Bool)
  case Slider   (value: Float, min: Float, max: Float, editable: Bool)
  case Stepper  (value: Double, min: Double, max: Double, step: Double, editable: Bool)
  case Picker   (value: String, choices: [String], editable: Bool)
  case Checkbox (value: Bool, editable: Bool)

  public var values: [String:Any] {
    switch self {
      case let .Text(value, placeholder, validation, editable):
        return ["value": value, "editable": editable, "placeholder": placeholder, "validation": validation]
      case let .Switch(value, editable):
        return ["value": value, "editable": editable]
      case let .Slider(value, min, max, editable):
        return ["value": value, "editable": editable, "min": min, "max": max]
      case let .Stepper(value, min, max, step, editable):
        return ["value": value, "editable": editable, "min": min, "max": max, "step": step]
      case let .Picker(value, choices, editable):
        return ["value": value, "editable": editable, "choices": choices]
      case let .Checkbox(value, editable):
        return ["value": value, "editable": editable]
    }
  }
}

public class Field: NSObject {
  public enum Type { case Undefined, Text, Switch, Slider, Stepper, Picker, Checkbox }

  var control: UIView { return UIView() }
  var editable = true
  var font: UIFont?
  var selectedFont: UIFont?
  var color: UIColor?
  var selectedColor: UIColor?

  public var value: Any?
  public var valid: Bool { return true }
  public var type: Type { return .Undefined }
  public var changeHandler: ((Field) -> Void)?

  func valueDidChange(sender: AnyObject) {
    switch sender {
      case let text as UITextField:       value = text.text
      case let `switch` as UISwitch:      value = `switch`.on
      case let slider as UISlider:        value = slider.value
      case let stepper as LabeledStepper: value = stepper.value
      case let picker as AKPickerView:    value = picker.dataSource?.pickerView?(picker, titleForItem: picker.selectedItem)
      case let checkbox as Checkbox:      value = checkbox.checked
      default:                            break
    }
    changeHandler?(self)
  }

  public static func fieldWithTemplate(template: FieldTemplate) -> Field {
    switch template {
    case let .Text(value, placeholder, validation, editable):
      return TextField(value: value, placeholder: placeholder, validation: validation, editable: editable)
    case let .Switch(value, editable):
      return SwitchField(value: value, editable: editable)
    case let .Slider(value, min, max, editable):
      return SliderField(value: value, min: min, max: max, editable: editable)
    case let .Stepper(value, min, max, step, editable):
      return StepperField(value: value, min: min, max: max, step: step, editable: editable)
    case let .Picker(value, choices, editable) where choices.count > 0 && choices.contains(value):
      return PickerField(value: value, choices: choices, editable: editable)
    case .Picker:
      return PickerField()
    case let .Checkbox(value, editable):
      return CheckboxField(value: value, editable: editable)
    }
  }

  private final class TextField: Field, UITextFieldDelegate {
    var _value: String = ""
    override var type: Type { return .Text }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? String {
          _value = v
          _control?.text = v
        }
      }
    }
    override var valid: Bool { return validation?(_value) ?? true }
    var placeholder: String?
    var validation: ((String?) -> Bool)?
    override var font: UIFont? { didSet { if let font = font { _control?.font = font } } }
    override var color: UIColor? { didSet { if let color = color { _control?.textColor = color } } }
    init(value: String, placeholder: String?, validation: ((String?) -> Bool)?, editable: Bool = true) {
      _value = value; self.placeholder = placeholder; self.validation = validation; super.init()
    }
    weak var _control: UITextField?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = UITextField(autolayout: true)
      control.userInteractionEnabled = editable
      control.textAlignment = .Right
      control.adjustsFontSizeToFitWidth = true
      control.minimumFontSize = 10
      control.returnKeyType = .Done
      control.layer.shadowColor = UIColor.redColor().CGColor
      control.delegate = self
      control.addTarget(self, action: "valueDidChange:", forControlEvents: .EditingChanged)
      control.text = _value
      if let font = font { control.font = font }
      if let color = color { control.textColor = color }
      control.placeholder = placeholder
      _control = control
      return control
    }
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return false
    }
  }

  private final class SwitchField: Field {
    var _value = false
    override var type: Type { return .Switch }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? Bool {
          _value = v
          _control?.on = v
        }
      }
    }
    init(value: Bool, editable: Bool = true) { _value = value; super.init()  }
    weak var _control: UISwitch?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = UISwitch(autolayout: true)
      control.userInteractionEnabled = editable
      control.addTarget(self, action: "valueDidChange:", forControlEvents: .ValueChanged)
      control.on = _value
      _control = control
      return control
    }
  }

  private final class SliderField: Field {
    var _value: Float = 0
    override var type: Type { return .Slider }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? Float {
          _value = v
          _control?.value = v
        }
      }
    }
    var min: Float = 0
    var max: Float = 1
    init(value: Float, min: Float, max: Float, editable: Bool = true) {
      _value = value; self.min = min; self.max = max; super.init()
    }
    weak var _control: UISlider?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = UISlider(autolayout: true)
      control.userInteractionEnabled = editable
      control.value = _value
      control.addTarget(self, action: "valueDidChange:", forControlEvents: .ValueChanged)
      _control = control
      return control
    }
  }

  private final class StepperField: Field {
    var _value = 0.0
    override var type: Type { return .Stepper }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? Double {
          _value = v
          _control?.value = v
        }
      }
    }
    var min = 0.0
    var max = 100.0
    var step = 1.0
    var autorepeat = false
    var wraps = true
    init(value: Double, min: Double, max: Double, step: Double, editable: Bool = true) {
      _value = value; self.min = min; self.max = max; self.step = step; super.init()
    }
    weak var _control: LabeledStepper?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = LabeledStepper(autolayout: true)
      control.userInteractionEnabled = editable
      control.value = _value
      control.minimumValue = min
      control.maximumValue = max
      control.stepValue = step
      control.wraps = wraps
      control.autorepeat = autorepeat
      if let font = font { control.font = font }
      if let color = color { control.textColor = color }
      control.addTarget(self, action: "valueDidChange:", forControlEvents: .ValueChanged)
      _control = control
      return control
    }
  }

  private final class PickerField: Field, AKPickerViewDelegate, AKPickerViewDataSource {
    var _value = ""
    override var type: Type { return .Picker }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? String, idx = choices.indexOf(v) {
          _value = v
          _control?.selectItem(idx, animated: _control?.superview != nil)
        }
      }
    }
    var choices: [String] = []
    override init() { super.init() }
    init(value: String, choices: [String], editable: Bool = true) {
      _value = value; self.choices = choices; super.init()
    }
    override var font: UIFont? { didSet { if let font = font { _control?.font = font } } }
    override var selectedFont: UIFont? { didSet { if let font = selectedFont { _control?.highlightedFont = font } } }
    override var color: UIColor? { didSet { if let color = color { _control?.textColor = color } } }
    override var selectedColor: UIColor? { didSet { if let color = selectedColor { _control?.highlightedTextColor = color } } }
    weak var _control: AKPickerView?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = AKPickerView(autolayout: true)
      control.userInteractionEnabled = editable
      if let font = font { control.font = font }
      if let color = color { control.textColor = color }
      if let font = selectedFont { control.highlightedFont = font }
      if let color = selectedColor { control.highlightedTextColor = color }
      control.delegate = self
      control.dataSource = self
      if let idx = choices.indexOf(_value) { control.selectItem(idx) }
      control.interitemSpacing = 20.0
      _control = control
      return control
    }
    @objc func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int { return choices.count }
    @objc func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String { return choices[item] }
    @objc func pickerView(pickerView: AKPickerView, didSelectItem item: Int) { _value = choices[item]; valueDidChange(self) }
  }

  private final class CheckboxField: Field {
    var _value = false
    override var type: Type { return .Checkbox }
    override var value: Any? {
      get { return _value }
      set {
        if let v = newValue as? Bool {
          _value = v
          _control?.checked = v
        }
      }
    }
    init(value: Bool, editable: Bool = true) { _value = value; super.init() }
    weak var _control: Checkbox?
    override var editable: Bool { didSet { _control?.userInteractionEnabled = editable } }
    override var control: UIView {
      if _control != nil { return _control! }
      let control = Checkbox(autolayout: true)
      control.userInteractionEnabled = editable
      control.checked = _value
      control.addTarget(self, action: "valueDidChange:", forControlEvents: .ValueChanged)
      _control = control
      return control
    }
  }

}


/** View subclass for a single form field with a name label and a control for capturing the value */
final class FieldView: UIView {

  // MARK: - Field-related properties

  let name: String
  let field: Field

  // MARK: - Customizing appearance

  var labelFont: UIFont? { get { return label?.font } set { if let font = newValue { label?.font = font } } }
  var labelTextColor: UIColor? { get { return label?.textColor } set { if let color = newValue { label?.textColor = color } } }

  // MARK: - Label and control

  /** Overridden to return the field view's `name` property */
  override var nametag: String! { get { return name } set {} }

  // MARK: - Initializing the view

  /** initializeIVARs */
  private func initializeIVARs() {
    translatesAutoresizingMaskIntoConstraints = false
    let label = UILabel(autolayout: true)
    label.text = name
    addSubview(label)
    let control = field.control
    addSubview(control)
  }

  /**
  Initialize the view with a name and field

  - parameter n: String
  - parameter f: Field
  */
  init(tag t: Int, name n: String, field f: Field) {
    name = n; field = f
    super.init(frame: CGRect.zeroRect)
    tag = t
    initializeIVARs()
  }

  private var label: UILabel? { return firstSubviewOfKind(UILabel.self) }
  private var control: UIView? {
    let controlTypes = [UITextField.self, UISwitch.self, UISlider.self, Checkbox.self, LabeledStepper.self, AKPickerView.self]
    let controlTypeIdentifiers = Set(arrayLiteral: controlTypes).map({ObjectIdentifier($0)})
    return firstSubviewMatching({controlTypeIdentifiers.contains(ObjectIdentifier(($0 as AnyObject).dynamicType.self))})
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Constraints

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  override func intrinsicContentSize() -> CGSize {
    if let label = label, control = control {
      let lSize = label.intrinsicContentSize()
      let cSize = control.intrinsicContentSize()
      return CGSize(width: lSize.width + 10.0 + cSize.width, height: max(lSize.height, cSize.height))
    } else { return CGSize(square: UIViewNoIntrinsicMetric) }
  }

  override func updateConstraints() {
    super.updateConstraints()
    let id = createIdentifier(self, "Internal")
    removeConstraintsWithIdentifier(id)
    if let label = label, control = control {
      constrain(identifier: id, 𝗩|label|𝗩, 𝗩|control|𝗩)
      constrain(identifier: id, 𝗛|label, control.left => label.right + 10.0, control|𝗛)
    }
  }

}
