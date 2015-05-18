//
//  FormView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public final class Form {

  public var fields: OrderedDictionary<String, Field>
  public var changeHandler: ((Form, Field, String) -> Void)?

  public init(templates: OrderedDictionary<String, FieldTemplate>) {
    fields = templates.map {Field.fieldWithTemplate($2)}
    apply(fields) {$2.changeHandler = self.didChangeField}
  }

  func didChangeField(field: Field) { if let name = nameForField(field) { changeHandler?(self, field, name) } }

  func nameForField(field: Field) -> String? {
    if let idx = find(fields.values, field) { return fields.keys[idx] } else { return nil }
  }

  public var invalidFields: [(Int, String, Field)] {
    var result: [(Int, String, Field)] = []
    for (idx, name, field) in fields { if !field.valid { result.append((idx, name, field)) } }
    return result
  }

  public var values: OrderedDictionary<String, Any>? {
    var values: OrderedDictionary<String, Any> = [:]
    for (_, n, f) in fields { if f.valid, let value: Any = f.value { values[n] = value } else { return nil } }
    return values
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

  :param: form Form
  :param: appearance Appearance? = nil
  */
  init(form f: Form, appearance: Appearance? = nil) {
    form = f; fieldAppearance = appearance
    super.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    backgroundColor = UIColor(white: 0.9, alpha: 0.75)
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
    apply(f.fields) {self.addSubview(FieldView(tag: $0, name: $1, field: $2))}
  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Field views

  /** Limit subviews to instances of `FieldView` */
  override func addSubview(view: UIView) {
    if let fieldView = view as? FieldView {
      if let appearance = fieldAppearance {
        fieldView.labelFont = appearance.labelFont
        fieldView.labelTextColor = appearance.labelTextColor
        fieldView.controlFont = appearance.controlFont
        fieldView.controlSelectedFont = appearance.controlSelectedFont
        fieldView.controlTextColor = appearance.controlTextColor
        fieldView.controlSelectedTextColor = appearance.controlSelectedTextColor
      }
      super.addSubview(fieldView)
    }
  }

  var fieldViews: [FieldView] { return subviews as! [FieldView] }

  // MARK: - Constraints

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  override func updateConstraints() {
    super.updateConstraints()
    let fieldViews = self.fieldViews
    let id = createIdentifier(self, "Internal")
    removeConstraintsWithIdentifier(id)
    apply(fieldViews) {constrain($0.left => self.left + 10.0, $0.right => self.right - 10.0 --> id)}
    if let first = fieldViews.first, last = fieldViews.last {

      constrain(first.top => self.top + 10.0 --> id)

      if fieldViews.count > 1 {
        var middle = fieldViews[1..<fieldViews.count].generate()
        var p = first
        while let c = middle.next() { constrain(identifier: id, c.top => p.bottom + 10.0); p = c }
      }
      constrain(last.bottom => self.bottom - 10.0 --> id)
    }
  }

  override func intrinsicContentSize() -> CGSize {
    let fieldSizes = fieldViews.map {$0.intrinsicContentSize()}
    let w = maxElement(fieldSizes.map {$0.width})
    let h = sum(fieldSizes.map {$0.height}) + CGFloat(fieldSizes.count + 1) * CGFloat(10)
    return CGSize(width: w, height: h)
  }

}

