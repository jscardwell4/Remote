//
//  TitleAttributesDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 11/29/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

@objc protocol TitleAttributesDelegateObserver {
  optional func saveInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate)
  optional func deleteInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate)
  optional func rollbackInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate)
}

@objc final class TitleAttributesDelegate: Editable , Detailable {

  var titleAttributes: TitleAttributes

  let initialAttributes: TitleAttributes

  var name: String?

  var observer: TitleAttributesDelegateObserver?
  internal var editable: Bool { return true }

  func save() { observer?.saveInvokedForTitleAttributesDelegate?(self) }
  func delete() { observer?.deleteInvokedForTitleAttributesDelegate?(self) }
  func rollback() { titleAttributes = initialAttributes; observer?.rollbackInvokedForTitleAttributesDelegate?(self) }

  /**
  initWithAttributes:

  :param: titleAttributes TitleAttributes
  */
  init(titleAttributes: TitleAttributes, observer: TitleAttributesDelegateObserver? = nil) {
    initialAttributes = titleAttributes
    self.titleAttributes = titleAttributes
    self.observer = observer
  }

  /**
  detailController

  :returns: UIViewController
  */
  func detailController() -> UIViewController { return TitleAttributesDetailController(item: self) }

  /**
  defaultSuppliedForProperty:

  :param: property TitleAttributes.PropertyKey

  :returns: Bool
  */
  func defaultSuppliedForProperty(property: TitleAttributes.PropertyKey) -> Bool { return titleAttributes[property] == nil }

  var iconTextOrder: TitleAttributes.IconTextOrderSpecification  {
    get { return titleAttributes.iconTextOrder }
    set { titleAttributes.iconTextOrder = newValue}
  }

  var text: String { get { return titleAttributes.text } set { titleAttributes.text = newValue} }

  var iconName: String? { get { return titleAttributes.iconName } set { titleAttributes.iconName = newValue} }

  var icon: String { get { return titleAttributes.icon } set { titleAttributes.icon = newValue} }

  var font: UIFont { get { return titleAttributes.font } set { titleAttributes.font = newValue} }

  var foregroundColor: UIColor {
    get { return titleAttributes.foregroundColor }
    set { titleAttributes.foregroundColor = newValue}
  }

  var backgroundColor: UIColor? {
    get { return titleAttributes.backgroundColor }
    set { titleAttributes.backgroundColor = newValue}
  }

  var ligature: Int { get { return titleAttributes.ligature } set { titleAttributes.ligature = newValue} }

  var shadow: NSShadow? { get { return titleAttributes.shadow } set { titleAttributes.shadow = newValue} }

  var expansion: Float { get { return titleAttributes.expansion } set { titleAttributes.expansion = newValue} }

  var obliqueness: Float { get { return titleAttributes.obliqueness } set { titleAttributes.obliqueness = newValue} }

  var strikethroughColor: UIColor {
    get { return titleAttributes.strikethroughColor }
    set { titleAttributes.strikethroughColor = newValue}
  }

  var underlineColor: UIColor {
    get { return titleAttributes.underlineColor }
    set { titleAttributes.underlineColor = newValue}
  }

  var baselineOffset: Float { get { return titleAttributes.baselineOffset } set { titleAttributes.baselineOffset = newValue} }

  var textEffect: String? { get { return titleAttributes.textEffect } set { titleAttributes.textEffect = newValue} }

  var strokeWidth: Float { get { return titleAttributes.strokeWidth } set { titleAttributes.strokeWidth = newValue} }

  var strokeFill: Bool { get { return titleAttributes.strokeFill } set { titleAttributes.strokeFill = newValue } }

  var strokeColor: UIColor { get { return titleAttributes.strokeColor } set { titleAttributes.strokeColor = newValue} }

  var underlineStyle: NSUnderlineStyle {
    get { return titleAttributes.underlineStyle ?? .StyleNone }
    set { titleAttributes.underlineStyle = newValue}
  }

  var strikethroughStyle: NSUnderlineStyle {
    get { return titleAttributes.strikethroughStyle ?? .StyleNone}
    set { titleAttributes.strikethroughStyle = newValue}
  }

  var kern: Float { get { return titleAttributes.kern } set { titleAttributes.kern = newValue} }

  var paragraphStyle: NSParagraphStyle {
    get { return titleAttributes.paragraphStyle }
    set { titleAttributes.paragraphStyle = newValue}
  }

  var alignment: NSTextAlignment { get { return titleAttributes.alignment } set { titleAttributes.alignment = newValue} }

  var firstLineHeadIndent: CGFloat {
    get { return titleAttributes.firstLineHeadIndent }
    set { titleAttributes.firstLineHeadIndent = newValue}
  }

  var headIndent: CGFloat { get { return titleAttributes.headIndent } set { titleAttributes.headIndent = newValue} }

  var tailIndent: CGFloat { get { return titleAttributes.tailIndent } set { titleAttributes.tailIndent = newValue} }

  var lineHeightMultiple: CGFloat {
    get { return titleAttributes.lineHeightMultiple }
    set { titleAttributes.lineHeightMultiple = newValue}
  }

  var maximumLineHeight: CGFloat {
    get { return titleAttributes.maximumLineHeight }
    set { titleAttributes.maximumLineHeight = newValue}
  }

  var minimumLineHeight: CGFloat {
    get { return titleAttributes.minimumLineHeight }
    set { titleAttributes.minimumLineHeight = newValue}
  }

  var lineSpacing: CGFloat { get { return titleAttributes.lineSpacing } set { titleAttributes.lineSpacing = newValue} }

  var paragraphSpacing: CGFloat {
    get { return titleAttributes.paragraphSpacing }
    set { titleAttributes.paragraphSpacing = newValue}
  }

  var paragraphSpacingBefore: CGFloat {
    get { return titleAttributes.paragraphSpacingBefore }
    set { titleAttributes.paragraphSpacingBefore = newValue}
  }

  var hyphenationFactor: Float {
    get { return titleAttributes.hyphenationFactor }
    set { titleAttributes.hyphenationFactor = newValue}
  }

  var lineBreakMode: NSLineBreakMode {
    get { return titleAttributes.lineBreakMode }
    set { titleAttributes.lineBreakMode = newValue}
  }

  var stringText: String { return titleAttributes.stringText }

  var iconString: NSAttributedString { return titleAttributes.iconString }

  var textString: NSAttributedString  {  return titleAttributes.textString }

  var string: NSAttributedString  {  return titleAttributes.string }

  var attributes: MSDictionary  {  return titleAttributes.attributes }

}
