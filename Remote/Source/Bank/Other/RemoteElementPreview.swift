//
//  RemoteElementPreview.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteElementPreview: UIView {

  class var MinimumSize: CGSize { return RemoteElementView.MinimumSize }

  /**
  viewWithPreset:

  :param: preset Preset

  :returns: RemoteElementPreview
  */
  class func viewWithPreset(preset: Preset) -> RemoteElementPreview? {
    switch preset.baseType {
      case .Remote: return RemotePreview(preset: preset)
      case .ButtonGroup:
        switch preset.role {
          case RemoteElement.Role.Rocker:         return RockerPreview(preset: preset)
          case RemoteElement.Role.SelectionPanel: return ModeSelectionPreview(preset: preset)
          default:                                return ButtonGroupPreview(preset: preset)
        }
      case .Button:
        switch preset.role {
          case RemoteElement.Role.BatteryStatus:    return BatteryStatusButtonPreview(preset: preset)
          case RemoteElement.Role.ConnectionStatus: return ConnectionStatusButtonPreview(preset: preset)
          default:                                  return ButtonPreview(preset: preset)
        }
      default: return nil
    }
  }

  /** init */
  override init() { super.init() }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithPreset:

  :param: preset Preset
  */
  required init(preset: Preset) {
    super.init()
    setTranslatesAutoresizingMaskIntoConstraints(false)
    self.preset = preset
    initializeIVARs()
  }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
//  override func intrinsicContentSize() -> CGSize {
//
//  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /** updateConstraints */
  override func updateConstraints() {

    let baseID = createIdentifier(self, ["Internal", "Base"])
    if constraintsWithIdentifier(baseID).count == 0 {
      let subviews = self.subviews as [UIView]
      apply(subviews) {
        (subview: UIView) in _ = self.stretchSubview(subview, identifier: baseID)
      }
    }

    let presetID = createIdentifier(self, ["Internal", "Preset"])
    if constraintsWithIdentifier(presetID).count == 0 {
      if var format = preset.constraints {
        format.replaceMatchesForRegEx(~/"self", withTemplate: "\\$0")
        let views = [self] + subelementsView.subviews.reverse()
        let names = (0..<views.count).map{"$\($0)"}
        let directory = OrderedDictionary(keys: names, values: views)

        let constraints = NSLayoutConstraint.constraintsByParsingFormat(format, views: directory.dictionary)
        apply(constraints) {$0.identifier = presetID; $0.priority = 999}
        if constraints.count > 0 { addConstraints(constraints) }
      }
    }

    super.updateConstraints()
  }

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  let subelementsView = UIView(autolayout: true)

  var preset: Preset!

  var elementBackgroundColor :UIColor?

  /** initializeIVARs */
  func initializeIVARs() {
    clipsToBounds = false
    opaque = false
    setContentHuggingPriority(900, forAxis: .Vertical)
    setContentHuggingPriority(900, forAxis: .Horizontal)
    setContentCompressionResistancePriority(900, forAxis: .Vertical)
    setContentCompressionResistancePriority(900, forAxis: .Horizontal)
    addInternalSubviews()
    initializeViewFromPreset()
  }

  /** initializeViewFromPreset */
  func initializeViewFromPreset() {
    elementBackgroundColor = preset.backgroundColor
    if let childPresets = preset.childPresets {
      for childPreset in childPresets.array as [Preset] {
        if let childView = RemoteElementPreview.viewWithPreset(childPreset) {
          subelementsView.addSubview(childView)
        }
      }
    }

  }

  /**
  drawContentInContext:inRect:

  :param: ctx CGContextRef
  :param: rect CGRect
  */
  func drawContentInContext(ctx: CGContextRef, inRect rect: CGRect) {}

  /**
  drawBackdropInContext:inRect:

  :param: ctx CGContextRef
  :param: rect CGRect
  */
  func drawBackdropInContext(ctx: CGContextRef, inRect rect: CGRect) {
    if let color = elementBackgroundColor {
      switch preset.shape {
        case .RoundedRectangle: RemoteDrawingKit.drawRoundishButtonBase(frame: rect, color: color, radius: 5.0)
        case .Rectangle:        RemoteDrawingKit.drawRectangularButtonBase(frame: rect, color: color)
        case .Diamond:          RemoteDrawingKit.drawDiamondButtonBase(frame: rect, color: color)
        case .Triangle:         RemoteDrawingKit.drawTriangleButtonBase(frame: rect, color: color)
        case .Oval:             RemoteDrawingKit.drawOvalButtonBase(frame: rect, color: color)
        default:                break
      }
    }
    if let image = preset.backgroundImage?.image {
      if rect.size <= image.size { image.drawInRect(rect) } else { image.drawAsPatternInRect(rect) }
    }
  }

 /**
  drawOverlayInContext:inRect:

  :param: ctx CGContextRef
  :param: rect CGRect
  */
  func drawOverlayInContext(ctx: CGContextRef, inRect rect: CGRect) {
    switch preset.style & RemoteElement.Style.GlossStyleMask {
      case RemoteElement.Style.GlossStyle1: fallthrough
      case RemoteElement.Style.GlossStyle2: fallthrough
      case RemoteElement.Style.GlossStyle3: fallthrough
      case RemoteElement.Style.GlossStyle4: break //RemoteDrawingKit.drawGloss(frame: rect, radius: 0)
      default: break
    }
  }

  /** addInternalSubviews */
  func addInternalSubviews() {
    addSubview(BackdropView(delegate: self))
    addSubview(ContentView(delegate: self))
    addSubview(subelementsView)
    addSubview(OverlayView(delegate: self))
  }


}

extension RemoteElementPreview {
  private class InternalView: UIView {

    weak var delegate: RemoteElementPreview!


    /** init */
    override init() { super.init() }

    /**
    initWithFrame:

    :param: frame CGRect
    */
    override init(frame: CGRect) { super.init(frame: frame) }

    /**
    initWithDelegate:

    :param: delegate RemoteElementPreview
    */
    init(delegate: RemoteElementPreview) {
      super.init(frame: delegate.bounds)
      self.delegate = delegate
      setTranslatesAutoresizingMaskIntoConstraints(false)
      backgroundColor = UIColor.clearColor()
      clipsToBounds = false
      opaque = false
      contentMode = .Redraw
      autoresizesSubviews = false
    }

    /**
    init:

    :param: aDecoder NSCoder
    */
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  }
}

extension RemoteElementPreview {
  private class ContentView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) {
      delegate?.drawContentInContext(UIGraphicsGetCurrentContext(), inRect: rect)
    }

  }
}

extension RemoteElementPreview {
  private class BackdropView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) {
      delegate?.drawBackdropInContext(UIGraphicsGetCurrentContext(), inRect: rect)
    }

  }
}

extension RemoteElementPreview {
  private class OverlayView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) {
      delegate?.drawOverlayInContext(UIGraphicsGetCurrentContext(), inRect: rect)
    }

  }
}
