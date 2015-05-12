//
//  FormView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

final class FormView: UIView {

  typealias Field = FormViewController.Field
  typealias Appearance = FormViewController.Appearance

  // MARK: - Customizing appearance

  let fieldAppearance: Appearance?

  // MARK: - Initializing the view

  /**
  initWithFields:Field>:

  :param: fields OrderedDictionary<String, Field>
  :param: appearance Appearance? = nil
  */
  init(fields: OrderedDictionary<String,Field>, appearance: Appearance? = nil) {
    fieldAppearance = appearance
    super.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    backgroundColor = UIColor(white: 0.9, alpha: 0.75)
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
    apply(fields) { self.addSubview(FieldView(name: $1, field: $2)) }
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
    let fields = fieldViews
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

  override func intrinsicContentSize() -> CGSize {
    let fieldSizes = fieldViews.map {$0.intrinsicContentSize()}
    let w = maxElement(fieldSizes.map {$0.width})
    let h = sum(fieldSizes.map {$0.height}) + CGFloat(fieldSizes.count + 1) * CGFloat(10)
    return CGSize(width: w, height: h)
  }

}

