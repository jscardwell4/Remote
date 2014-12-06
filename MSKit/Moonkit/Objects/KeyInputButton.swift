//
//  KeyInputButton.swift
//  MSKit
//
//  Created by Jason Cardwell on 12/5/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class KeyInputButton: UIControl {

  public enum Style { case Default, Prominent, Reversed, DeleteBackward, Done }

  public var style: Style = .Default
  public var title: String = ""

  public override var highlighted: Bool { didSet { setNeedsDisplay() } }
  public override var enabled: Bool { didSet { setNeedsDisplay() } }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame) }

  /** init */
  public override init() { super.init() }

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool) { self.init(); setTranslatesAutoresizingMaskIntoConstraints(!autolayout) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  drawRect:

  :param: rect CGRect
  */
  public override func drawRect(rect: CGRect) {
    switch style {
      case .Default:
        DrawingKit.drawKeyInputButton(frame: rect,
                                      title: title,
                                      highlighted: highlighted,
                                      prominent: false,
                                      reverse: false,
                                      disabled: !enabled)
      case .Prominent:
        DrawingKit.drawKeyInputButton(frame: rect,
                                      title: title,
                                      highlighted: highlighted,
                                      prominent: true,
                                      reverse: false,
                                      disabled: !enabled)
      case .Reversed:
        DrawingKit.drawKeyInputButton(frame: rect,
                                      title: title,
                                      highlighted: highlighted,
                                      prominent: false,
                                      reverse: true,
                                      disabled: !enabled)
      case .DeleteBackward:
        DrawingKit.drawDeleteBackwardButton(frame: rect, highlighted: highlighted,  disabled: !enabled)
      case .Done:
        DrawingKit.drawDoneButton(frame: rect, highlighted: highlighted)
    }
  }

}

extension KeyInputButton.Style: Equatable {}
public func ==(lhs: KeyInputButton.Style, rhs: KeyInputButton.Style) -> Bool {
  switch (lhs, rhs) {
    case (.Default, .Default),
         (.Prominent, .Prominent),
         (.Reversed, .Reversed),
         (.DeleteBackward, .DeleteBackward),
         (.Done, .Done):
     return true
    default:
      return false
  }
}
