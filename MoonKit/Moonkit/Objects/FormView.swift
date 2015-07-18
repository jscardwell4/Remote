//
//  FormView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public final class Form: CustomStringConvertible {

  public var fields: OrderedDictionary<String, Field>
  public var changeHandler: ((Form, Field, String) -> Void)?

  public init(templates: OrderedDictionary<String, FieldTemplate>) {
    fields = templates.map {Field.fieldWithTemplate($2)}
    apply(fields) {$2.changeHandler = self.didChangeField}
  }

  func didChangeField(field: Field) { if let name = nameForField(field) { changeHandler?(self, field, name) } }

  func nameForField(field: Field) -> String? {
    if let idx = fields.values.indexOf(field) { return fields.keys[idx] } else { return nil }
  }

  public var invalidFields: [(Int, String, Field)] {
    var result: [(Int, String, Field)] = []
    for (idx, name, field) in fields { if !field.valid { result.append((idx, name, field)) } }
    return result
  }

  public var valid: Bool { return invalidFields.count == 0 }

  public var values: OrderedDictionary<String, Any>? {
    var values: OrderedDictionary<String, Any> = [:]
    for (_, n, f) in fields { if f.valid, let value: Any = f.value { values[n] = value } else { return nil } }
    return values
  }

  public var description: String {
    return "Form: {\n\t" + "\n\t".join(fields.map {"\($0): \($1) = \(String($2.value))"}) + "\n}"
  }

}

final class FormView: UIView {

  typealias Appearance = FormViewController.Appearance

  // MARK: - Form type

  let form: Form

  // MARK: - Customizing appearance

  let fieldAppearance: Appearance?

  // MARK: - Initializing the view

  /**
  initWithForm:appearance:

  - parameter form: Form
  - parameter appearance: Appearance? = nil
  */
  init(form f: Form, appearance: Appearance? = nil) {
    form = f; fieldAppearance = appearance
    super.init(frame: CGRect.zeroRect)
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor(white: 0.9, alpha: 0.75)
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
    f.fields.apply {
      (idx: Int, name: String, field: Field) -> Void in
      let fieldView = FieldView(tag: idx, name: name, field: field)
      if let appearance = appearance {
        field.font = appearance.controlFont
        field.selectedFont = appearance.controlSelectedFont
        field.color = appearance.controlTextColor
        field.selectedColor = appearance.controlSelectedTextColor
        fieldView.labelFont = appearance.labelFont
        fieldView.labelTextColor = appearance.labelTextColor
      }
      self.addSubview(fieldView)
    }
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Field views

  /** Limit subviews to instances of `FieldView` */
  override func addSubview(view: UIView) { if let fieldView = view as? FieldView { super.addSubview(fieldView) } }

  var fieldViews: [FieldView] { return subviews as! [FieldView] }

  // MARK: - Constraints

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  override func updateConstraints() {
    super.updateConstraints()
    let id = Identifier(self, "Internal")
    guard constraintsWithIdentifier(id).count == 0 else { return }

    fieldViews.apply { constrain($0.left => self.left + 10.0 --> id, $0.right => self.right - 10.0 --> id) }
    if let first = fieldViews.first, last = fieldViews.last {

      constrain(first.top => self.top + 10.0 --> id)

      if fieldViews.count > 1 {
        var middle = fieldViews[1..<fieldViews.count].generate()
        var p = first
        while let c = middle.next() { constrain(c.top => p.bottom + 10.0 --> id); p = c }
      }

      constrain(last.bottom => self.bottom - 10.0 --> id)
    }
  }

  override func intrinsicContentSize() -> CGSize {
    let fieldSizes = fieldViews.map {$0.intrinsicContentSize()}
    let w = min(fieldSizes.map {$0.width}.maxElement()!, UIScreen.mainScreen().bounds.width - 8)
    let h = sum(fieldSizes.map {$0.height}) + CGFloat(fieldSizes.count + 1) * CGFloat(10)
    return CGSize(width: w, height: h)
  }

}

