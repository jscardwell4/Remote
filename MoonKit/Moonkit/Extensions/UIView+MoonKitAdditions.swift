//
//  UIView+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool) {
    self.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
  }

  /**
  framesDescription

  :returns: String
  */
  public func framesDescription() -> String {
  	return self.viewTreeDescriptionWithProperties(["frame"])
      .stringByReplacingRegEx("[{]\\s*\n\\s*frame = \"NSRect:\\s*([^\"]+)\";\\s*\n\\s*[}]", withString: " { frame=$1 }")
  }

  /**
  descriptionTree:

  :param: properties String ...

  :returns: String
  */
  public func descriptionTree(properties: String ...) -> String {
  	return self.viewTreeDescriptionWithProperties(properties)
  }

  /**
  subscript:

  :param: nametag String

  :returns: UIView?
  */
  public subscript(nametag: String) -> UIView? { return viewWithNametag(nametag) }

  /**
  nearestCommonAncestorWithView:

  :param: view UIView

  :returns: UIView?
  */
  public func nearestCommonAncestorWithView(view: UIView) -> UIView? {
    var ancestor: UIView? = nil
    var ancestors = Set<UIView>()
    var v: UIView? = self
    while v != nil { ancestors.insert(v!); v = v!.superview }
    v = view
    while v != nil { if ancestors.contains(v!) { ancestor = v; break } else { v = v!.superview } }
    return ancestor
  }

  /**
  constraintsWithIdentifierTag:

  :param: tag String

  :returns: [NSLayoutConstraint]
  */
  public func constraintsWithIdentifierTag(tag: String) -> [NSLayoutConstraint] {
    return (constraints() as! [NSLayoutConstraint]).filter {
      if let identifier = $0.identifier where tagsFromIdentifier(identifier) ∋ tag { return true } else { return false }
    }
  }

  /**
  constrain:views:identifier:

  :param: format String
  :param: views [String AnyObject]? = nil
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func constrain(format: String, views: [String:AnyObject]? = nil, identifier: String? = nil) -> [NSLayoutConstraint] {
    if format.isEmpty { return [] }

    var dict: [String:AnyObject] = views ?? [:]
    dict["self"] = self

    let constraints = NSLayoutConstraint.constraintsByParsingFormat(format, views: dict)
    apply(constraints){$0.identifier = identifier}
    addConstraints(constraints)
    return constraints
  }
  public var right: (UIView, PseudoConstraint.Attribute) { return (self, .Right) }
  public var left: (UIView, PseudoConstraint.Attribute) { return (self, .Left) }
  public var top: (UIView, PseudoConstraint.Attribute) { return (self, .Top) }
  public var bottom: (UIView, PseudoConstraint.Attribute) { return (self, .Bottom) }
  public var centerX: (UIView, PseudoConstraint.Attribute) { return (self, .CenterX) }
  public var centerY: (UIView, PseudoConstraint.Attribute) { return (self, .CenterY) }
  public var width: (UIView, PseudoConstraint.Attribute) { return (self, .Width) }
  public var height: (UIView, PseudoConstraint.Attribute) { return (self, .Height) }
  public var baseline: (UIView, PseudoConstraint.Attribute) { return (self, .Baseline) }
  public var leading: (UIView, PseudoConstraint.Attribute) { return (self, .Leading) }
  public var trailing: (UIView, PseudoConstraint.Attribute) { return (self, .Trailing) }

  /**
  constrain:pseudo:

  :param: id String? = nil
  :param: pseudo [PseudoConstraint] ...

  :returns: [NSLayoutConstraint]
  */
  public func constrain(identifier id: String? = nil, _ pseudo: [PseudoConstraint] ...) -> [NSLayoutConstraint] {
    let p = reduce(pseudo, [], {$0 + $1})
    let result = flatMap(p, {$0.expanded}).compressedMap({$0.constraint()}) ➤| {$0.identifier = id}
    addConstraints(result)
    return result
  }

  /**
  constrain:pseudo:

  :param: id String? = nil
  :param: pseudo PseudoConstraint ...

  :returns: [NSLayoutConstraint]
  */
  public func constrain(identifier id: String? = nil, _ pseudo: PseudoConstraint ...) -> [NSLayoutConstraint] {
    return constrain(identifier: id, pseudo)
  }

  /**
  constrainSize:identifier:

  :param: size CGSize
  :param: id String? = nil

  :returns: (w: NSLayoutConstraint, h: NSLayoutConstraint)
  */
  public func constrainSize(size: CGSize, identifier id: String? = nil) -> (w: NSLayoutConstraint, h: NSLayoutConstraint) {
    return (w: constrainWidth(Float(size.width), identifier: id), h: constrainHeight(Float(size.height), identifier: id))
  }

  /**
  stretchSubview:

  :param: subview UIView
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func stretchSubview(subview: UIView, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return horizontallyStretchSubview(subview, identifier: id) + verticallyStretchSubview(subview, identifier: id)
  }

  /**
  insetSubview:insets:identifier:

  :param: subview UIView
  :param: insets UIEdgeInsets
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func insetSubview(subview: UIView, insets: UIEdgeInsets, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    let (top, left, bottom, right) = insets.unpack()
    return constrain(identifier: id,
                     subview.left => self.left + Float(left),
                     subview.right => self.right - Float(right),
                     subview.top => self.top + Float(top),
                     subview.bottom => self.bottom - Float(bottom))
  }

  /**
  horizontallyStretchSubview:identifier:

  :param: subview UIView
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func horizontallyStretchSubview(subview: UIView, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.left => self.left, subview.right => self.right)
  }

  /**
  verticallyStretchSubview:identifier:

  :param: subview UIView
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func verticallyStretchSubview(subview: UIView, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.top => self.top, subview.bottom => self.bottom)
  }

  /**
  horizontallyCenterSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func horizontallyCenterSubview(subview: UIView,
                                 offset: Float = 0.0,
                             identifier id: String? = nil) -> [NSLayoutConstraint]
  {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.centerX => self.centerX + offset)
  }

  /**
  verticallyCenterSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func verticallyCenterSubview(subview: UIView,
                               offset: Float = 0.0,
                           identifier id: String? = nil) -> [NSLayoutConstraint]
  {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.centerY => self.centerY + offset)
  }

  /**
  centerSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func centerSubview(subview: UIView, offset: Float = 0.0, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.centerX => self.centerX + offset, subview.centerY => self.centerY + offset)
  }

  /**
  leftAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func leftAlignSubview(subview: UIView, offset: Float = 0.0, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.left => self.left + offset)
  }

  /**
  rightAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func rightAlignSubview(subview: UIView, offset: Float = 0.0, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.right => self.right + offset)
  }

  /**
  topAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func topAlignSubview(subview: UIView, offset: Float = 0.0, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.top => self.top + offset)
  }

  /**
  bottomAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset Float = 0.0
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func bottomAlignSubview(subview: UIView, offset: Float = 0.0, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !subview.isDescendantOfView(self) { return [] }
    return constrain(identifier: id, subview.bottom => self.bottom + offset)
  }

  /**
  constrainWidth:identifier:

  :param: width Float
  :param: id String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainWidth(width: Float, identifier id: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(self.width => abs(width) --> id)
    addConstraint(constraint)
    return constraint
  }

  /**
  constrainHeight:identifier:

  :param: height Float
  :param: id String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainHeight(height: Float, identifier id: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(self.height => abs(height) --> id)
    addConstraint(constraint)
    return constraint
  }

  /**
  constrainAspect:identifier:

  :param: aspect Float
  :param: id String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainAspect(aspect: Float, identifier id: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(self.width => self.height * aspect --> id)
    addConstraint(constraint)
    return constraint
  }

  /**
  alignSubview:besideSubview:offset:identifier:

  :param: s1 UIView
  :param: s2 UIView
  :param: offset Float
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func alignSubview(s1: UIView,
             besideSubview s2: UIView,
                    offset: Float,
                identifier id: String? = nil) -> [NSLayoutConstraint]
  {
    if !((subviews as! [UIView]) ⊃ [s1, s2]) { return [] }
    return constrain(identifier: id, s2.left => s1.right + offset)
  }

  /**
  alignSubview:aboveSubview:offset:identifier:

  :param: s1 UIView
  :param: s2 UIView
  :param: offset Float
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func alignSubview(s1: UIView,
              aboveSubview s2: UIView,
                    offset: Float,
                identifier id: String? = nil) -> [NSLayoutConstraint]
  {
    if !((subviews as! [UIView]) ⊃ [s1, s2]) { return [] }
    return constrain(identifier: id, s2.top => s1.bottom + offset)
  }

  /**
  stretchSubview:toSubview:identifier:

  :param: s1 UIView
  :param: s2 UIView
  :param: id String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func stretchSubview(s1: UIView, toSubview s2: UIView, identifier id: String? = nil) -> [NSLayoutConstraint] {
    if !((subviews as! [UIView]) ⊃ [s1, s2]) { return [] }
    return constrain(identifier: id, s1.left => s2.left, s1.right => s2.right, s1.top => s2.top, s1.bottom => s2.bottom)
  }

}
