//
//  FormView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public final class FormView: UIView {

  // MARK: - Form type

  public let form: Form

  // MARK: - Customizing appearance

  public var labelFont: UIFont  = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet {
      fieldViews.apply { $0.labelFont = self.labelFont }
    }
  }
  public var controlFont: UIFont  = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline) {
    didSet {
      fieldViews.apply { $0.controlFont = self.controlFont }
    }
  }

  public var controlSelectedFont: UIFont  = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet {
      fieldViews.apply { $0.controlSelectedFont = self.controlSelectedFont }
    }
  }

  public var labelTextColor: UIColor = UIColor.blackColor() {
    didSet {
      fieldViews.apply { $0.labelTextColor = self.labelTextColor }
    }
  }

  public var controlTextColor: UIColor = UIColor.blackColor() {
    didSet {
      fieldViews.apply { $0.controlTextColor = self.controlTextColor }
    }
  }

  public var controlSelectedTextColor: UIColor = UIColor.blackColor() {
    didSet {
      fieldViews.apply { $0.controlSelectedTextColor = self.controlSelectedTextColor }
    }
  }

  public enum Style { case Plain, Shadow }

  // MARK: - Initializing the view

  /**
  initWithForm:appearance:

  - parameter form: Form
  */
  public init(form f: Form, style: Style = .Plain) {
    form = f
    super.init(frame: CGRect.zeroRect)
    translatesAutoresizingMaskIntoConstraints = false
    if case .Shadow = style {
      backgroundColor = UIColor(white: 0.9, alpha: 0.75)
      layer.shadowOpacity = 0.75
      layer.shadowRadius = 8
      layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
    }
    form.fields.apply {
      (idx: Int, name: String, field: Field) -> Void in
      self.addSubview(FieldView(tag: idx, name: name, field: field))
    }
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Field views

  /** Limit subviews to instances of `FieldView` */
  public override func addSubview(view: UIView) { if let fieldView = view as? FieldView { super.addSubview(fieldView) } }

  var fieldViews: [FieldView] { return subviews as! [FieldView] }

  // MARK: - Constraints

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  public override class func requiresConstraintBasedLayout() -> Bool { return true }

  /** updateConstraints */
  public override func updateConstraints() {
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

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  public override func intrinsicContentSize() -> CGSize {
    let fieldSizes = fieldViews.map {$0.intrinsicContentSize()}
    let w = min(fieldSizes.map {$0.width}.maxElement()!, UIScreen.mainScreen().bounds.width - 8)
    let h = sum(fieldSizes.map {$0.height}) + CGFloat(fieldSizes.count + 1) * CGFloat(10)
    return CGSize(width: w, height: h)
  }

}

