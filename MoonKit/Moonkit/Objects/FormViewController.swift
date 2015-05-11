//
//  FormViewController.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/9/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class FormViewController: UIViewController {

  // MARK: - Field enumeration

  /** Enumeration for defining a field in the form */
  public enum Field {
    case Text (initial: String?, placeholder: String?, validation: ((String?) -> Bool)?)
    case Switch (initial: Bool)
    case Slider (initial: Float, min: Float, max: Float)
    case Stepper (initial: Double, min: Double, max: Double, step: Double)
    case Picker (initial: Int, choices: [String])
    case Checkbox (initial: Bool)
  }

  // MARK: - Internally used `FieldView` class

  /** View subclass for a single form field with a name label and a control for capturing the value */
  private final class FieldView: UIView, UITextFieldDelegate, AKPickerViewDelegate, AKPickerViewDataSource {

    /** Overridden to return the field view's `name` property */
    override var nametag: String! { get { return nameLabel.text } set {} }

    let name: String
    let field: Field
    var value: Any {
      switch field {
        case .Text:     return (fieldControl as! UITextField).text
        case .Switch:   return (fieldControl as! UISwitch).on
        case .Slider:   return (fieldControl as! UISlider).value
        case .Stepper:  return (fieldControl as! UIStepper).value
        case .Picker:   return (fieldControl as! AKPickerView).selectedItem
        case .Checkbox: return (fieldControl as! Checkbox).checked
      }
    }

    var labelFont: UIFont {
      get { return nameLabel.font }
      set { nameLabel.font = newValue }
    }
    var labelTextColor: UIColor {
      get { return nameLabel.textColor }
      set { nameLabel.textColor = newValue }
    }
    var controlFont: UIFont? {
      get {
        switch field {
          case .Text:   return (fieldControl as? UITextField)?.font
          case .Picker: return (fieldControl as? AKPickerView)?.font
          default:      return nil
        }
      }
      set {
        if let font = newValue {
          switch field {
            case .Text:   (fieldControl as? UITextField)?.font = font
            case .Picker: (fieldControl as? AKPickerView)?.font = font
                          (fieldControl as? AKPickerView)?.highlightedFont = font.fontWithSize(font.pointSize + 2.0)
            default:      break
          }
        }
      }
    }
    var controlTextColor: UIColor? {
      get {
        switch field {
        case .Text:   return (fieldControl as? UITextField)?.textColor
        case .Picker: return (fieldControl as? AKPickerView)?.textColor
        default:      return nil
        }
      }
      set {
        if let color = newValue {
          switch field {
          case .Text:   (fieldControl as? UITextField)?.textColor = color
          case .Picker: (fieldControl as? AKPickerView)?.textColor = color
          default:      break
          }
        }
      }
    }

    weak var nameLabel: UILabel!
    weak var fieldControl: UIView!
    var textFieldValidation: ((String?) -> Bool)?
    var choices: [String] = []
    var choice = 0

    override class func requiresConstraintBasedLayout() -> Bool { return true }

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
    init(name n: String, field f: Field) {
      name = n; field = f
      super.init(frame: CGRect.zeroRect)
      initializeIVARs()
    }

    /**
    intrinsicContentSize

    :returns: CGSize
    */
    override func intrinsicContentSize() -> CGSize {
      let labelSize = nameLabel.intrinsicContentSize()
      let fieldSize = fieldControl.intrinsicContentSize()
      return CGSize(width: labelSize.width + 10.0 + fieldSize.width, height: max(labelSize.height, fieldSize.height))
    }

    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func updateConstraints() {
      super.updateConstraints()
      let id = createIdentifier(self, "Internal")
      removeConstraintsWithIdentifier(id)
      constrain([𝗩|nameLabel|𝗩, 𝗩|fieldControl|𝗩] --> id)
      constrain([𝗛|nameLabel, fieldControl.left => nameLabel.right + 10.0, fieldControl|𝗛] --> id)
    }

    var valid: Bool {
      switch field {
        case .Text(_, _, let validation): return validation?((fieldControl as? UITextField)?.text) ?? true
        default: return true
      }
    }

    var showingInvalid = false { didSet { layer.borderWidth = showingInvalid ? 2 : 0 } }

    @objc func textFieldShouldReturn(textField: UITextField) -> Bool { MSLogDebug(""); textField.resignFirstResponder(); return false }
    @objc func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int { return choices.count }
    @objc func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String { return choices[item] }
    @objc func pickerView(pickerView: AKPickerView, didSelectItem item: Int) { choice = item }

  }

  // MARK: - Internally used `FormView` class

  private class FormView: UIView {

    override class func requiresConstraintBasedLayout() -> Bool { return true }

    /**
    initWithFields:Field>:

    :param: fields OrderedDictionary<String
    :param: Field>
    */
    init(fields: OrderedDictionary<String,Field>) {
      super.init(frame: CGRect.zeroRect)
      setTranslatesAutoresizingMaskIntoConstraints(false)
      layer.backgroundColor = UIColor(white: 0.9, alpha: 0.75).CGColor
      layer.shadowOpacity = 0.75
      layer.shadowRadius = 8
      layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
      apply(fields) { idx, name, field in
        let fieldView = FieldView(name: name, field: field)
        fieldView.tag = idx
        self.addSubview(fieldView)
      }
      setNeedsUpdateConstraints()
    }

    var fieldViews: [FieldView]? { return subviews as? [FieldView] }

    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override private func updateConstraints() {
      super.updateConstraints()
      if let fields = fieldViews {
        let id = createIdentifier(self, "Internal")
        removeConstraintsWithIdentifier(id)
        apply(fields) {constrain($0.left => self.left + 10.0, $0.right => self.right - 10.0 --> id)}
        if let first = fields.first, last = fields.last {

          constrain(first.top => self.top + 10.0 --> id)

          if fields.count > 1 {
            var middle = fields[1..<fields.count].generate()
            var p = first
            while let c = middle.next() { constrain(identifier: id, c.top => p.bottom + 10.0); p = c }
          }
          constrain(last.bottom => self.bottom - 10.0 --> id)
        }
      }
    }

    override private func intrinsicContentSize() -> CGSize {
      var w = CGFloat(), h = CGFloat()
      if let fields = fieldViews {
        let labelMaxWidth: CGFloat = reduce(fields, 0, {max($0, $1.nameLabel.intrinsicContentSize().width)})
        let controlMaxWidth: CGFloat = reduce(fields, 0, {max($0, $1.fieldControl.intrinsicContentSize().width)})
        w = labelMaxWidth + 10.0 + controlMaxWidth
        h = reduce(fields, 0, {$0 + 10.0 + max($1.nameLabel.intrinsicContentSize().height,
                                               $1.fieldControl.intrinsicContentSize().height)}) + 10.0
      }
      return CGSize(width: w, height: h)
    }

  }

  // MARK: - Initializating the controller

  /**
  initWithFields:Field>:

  :param: fields OrderedDictionary<String
  :param: Field>
  */
  public init(fields f: OrderedDictionary<String,Field>,
              didSubmit submit: ((OrderedDictionary<String,Any>) -> Void)? = nil,
              didCancel cancel: (() -> Void)? = nil)
  {
    fields = f; didSubmit = submit; didCancel = cancel
    super.init(nibName: nil, bundle: nil)
    modalTransitionStyle = .CrossDissolve
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - The controller's public properties
  public private(set) var cancelled = false

  // MARK: Customizing the form's appearance

  public dynamic var labelFont: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet { apply(flattened(formView?.fieldViews ?? []) as [FieldView]) {$0.labelFont = self.labelFont} }
  }
  public dynamic var controlFont: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline) {
    didSet { apply(flattened(formView?.fieldViews ?? []) as [FieldView]) {$0.controlFont = self.controlFont} }
  }

  public dynamic var labelTextColor: UIColor = UIColor.blackColor() {
    didSet { apply(flattened(formView?.fieldViews ?? []) as [FieldView]) {$0.labelTextColor = self.labelTextColor} }
  }
  public dynamic var controlTextColor: UIColor = UIColor.blackColor() {
    didSet { apply(flattened(formView?.fieldViews ?? []) as [FieldView]) {$0.controlTextColor = self.controlTextColor} }
  }

  // MARK: - The controller's private properties
  private let didSubmit: ((OrderedDictionary<String,Any>) -> Void)?
  private let didCancel: (() -> Void)?
  private let fields: OrderedDictionary<String,Field>
  private weak var snapshotView: UIView?
  private weak var effectView: UIVisualEffectView?
  private weak var formView: FormView?
  private weak var toolbar: UIToolbar?

  // MARK: - Loading/updating the controller's view

  public override func prefersStatusBarHidden() -> Bool { return true }

  /** loadView */
  public override func loadView() {
    self.view = UIView(frame: UIScreen.mainScreen().bounds)

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effectView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(effectView)
    self.effectView = effectView

    let formView = FormView(fields: fields)
    apply(flattened(formView.fieldViews ?? []) as [FieldView]) {$0.labelFont = self.labelFont}
    apply(flattened(formView.fieldViews ?? []) as [FieldView]) {$0.controlFont = self.controlFont}
    apply(flattened(formView.fieldViews ?? []) as [FieldView]) {$0.labelTextColor = self.labelTextColor}
    apply(flattened(formView.fieldViews ?? []) as [FieldView]) {$0.controlTextColor = self.controlTextColor}

    effectView.contentView.addSubview(formView)
    self.formView = formView

    let toolbar = UIToolbar.newForAutolayout()
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
    toolbar.tintColor = UIColor(white: 0.5, alpha: 1)
    toolbar.items = [UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAction"),
                     UIBarButtonItem.flexibleSpace(),
                     UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submitAction")]
    effectView.contentView.addSubview(toolbar)
    self.toolbar = toolbar

    view.setNeedsUpdateConstraints()

  }

  public override func viewWillAppear(animated: Bool) {
    if isBeingPresented(), let controller = presentingViewController where controller.isViewLoaded() {
      let snapshot = controller.view.snapshotViewAfterScreenUpdates(false)
      snapshotView?.removeFromSuperview()
      assert(effectView != nil)
      view.insertSubview(snapshot, belowSubview: effectView!)
      snapshotView = snapshot
    }
  }

  /** updateViewConstraints */
  public override func updateViewConstraints() {
    super.updateViewConstraints()
    let id = createIdentifier(self, "Internal")
    if let effect = effectView, form = formView, tool = toolbar {
      view.removeConstraintsWithIdentifier(id)
      view.constrain([𝗛|effect|𝗛, 𝗩|effect|𝗩] --> id)
      view.constrain([form.centerX => effect.centerX, form.centerY => effect.centerY] --> id)
      view.constrain([tool.left => form.left, tool.right => form.right, tool.top => form.bottom] --> id)
    }
  }

  // MARK: - Actions

  /** cancelAction */
  func cancelAction() { cancelled = true; didCancel?() }

  /** submitAction */
  func submitAction() {
    if let fieldViews = formView?.fieldViews {
      var values: OrderedDictionary<String,Any> = [:]
      var valid = true
      for fieldView in fieldViews {
        fieldView.showingInvalid = !fieldView.valid
        if fieldView.showingInvalid { valid = false }
        else { values[fieldView.name] = fieldView.value }
      }
      if valid { didSubmit?(values) }
    }
  }

}
