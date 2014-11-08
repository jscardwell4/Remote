//
//  RemoteElementView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteElementView: UIView {

  private class InternalView: UIView {

    var delegate: RemoteElementView! { return superview as? RemoteElementView ?? nil }

    /** init */
    override init() {
      super.init()
      userInteractionEnabled = false
      backgroundColor = UIColor.clearColor()
      clipsToBounds = false
      opaque = false
      contentMode = .Redraw
      autoresizesSubviews = false
    }
  }

  private class SubelementsView: InternalView {

    /** init */
    override init() {
      super.init()
      userInteractionEnabled = true
    }

    /**
    addSubview:

    :param: subview UIView
    */
    override func addSubview(subview: UIView) {
      if let elementView = subview as? RemoteElementView {
        if let parentElement = elementView.model.parentElement {
          if parentElement == delegate.model {
            super.addSubview(subview)
          }
        }
      }
    }
  }

  private class ContentView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawContentInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

  }

  private class BackdropView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawBackdropInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

  }

  private class OverlayView: InternalView {

    var boundaryColor = UIColor.clearColor() {
      didSet {
        boundaryOverlay.strokeColor = boundaryColor.CGColor
        boundarOverlay.setNeedsDisplay()
      }
    }

    var showAlignmentIndicators: Bool = false {
      didSet {
        alignmentOverlay.hidden = !showAlignmentIndicators
        renderAlignmentOverlayIfNeeded()
      }
    }
    var showContentBoundary: Bool = false { didSet { boundaryOverlay.hidden = !showContentBoundary } }

    lazy var boundaryOverlay: CAShapeLayer = {
        let overlay = CAShapeLayer()
        overlay.lineWidth = self.lineWidth
        overlay.lineJoin = kCALineJoinRound
        overlay.fillColor = nil
        overlay.strokeColor = self.boundaryColor.CGColor
        overlay.path = self.boundaryPath
        overlay.opacity = 0.65
        overlay.hidden = !self.showContentBoundary
        return overlay
      }()

    lazy var alignmentOverlay: CALayer = {
        let overlay = CALayer()
        overlay.frame = self.layer.bounds
        overlay.hidden = !self.showAlignmentIndicators
        return overlay
      }()

    var lineWidth: CGFloat = 2.0

    /** init */
    override init() {
      super.init()
      self.layer.addSublayer(boundaryOverlay)
      self.layer.addSublayer(alignmentOverlay)
    }

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawOverlayInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

    func refreshBoundary() { boundaryOverlay.path = boundaryPath }

    var boundaryPath: CGPathRef {
      let path = delegate.borderPath ?? UIBezierPath(rect: bounds)
      let w = bounds.size.width
      let h = bounds.size.height
      path.applyTransform(CGAffineTransformMakeScale((w - lineWidth) / w, (h - lineWidth) / h))
      path.applyTransform(CGAffineTransformMakeTranslation(lineWidth / 2.0, lineWidth / 2.0))
      return path.CGPath
    }

    /** renderAlignmentOverlayIfNeeded */
    func renderAlignmentOverlayIfNeeded() {

      if showAlignmentIndicators {

        let manager = delegate.model.constraintManager

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        let context = UIGraphicsGetCurrentContext()

        let gentleHighlight = UIColor(red:1, green:1, blue:1, alpha:0.25)
        let parent          = UIColor(red:0.899, green:0.287, blue:0.238, alpha:1)
        let sibling         = UIColor(red:0.186, green:0.686, blue:0.661, alpha:1)
        let intrinsic       = UIColor(red:0.686, green:0.186, blue:0.899, alpha:1)
        let colors          = [gentleHighlight, parent, sibling, intrinsic]

        let outerOffset = CGSize(width: 0.1, height: -0.1)
        let outerRadius: CGFloat = 2.5
        let innerRadius: CGFloat = 0.5
        let frame = bounds.rectByInsetting(3.0, 3.0)
        let cornerRadius: CGFloat = 1.0

        if manager[NSLayoutAttributeLeft.rawValue] {

          // Left Bar Drawing
          let rect = CGRect(x: frame.minX + 1.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: -1.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeLeft)].setFill()
          barPath.fill()

          // Left Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset)),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[NSLayoutAttributeRight.rawValue] {

          // Right Bar Drawing
          let rect = CGRect(x: frame.minX + frame.width - 3.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 1.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeRight)].setFill()
          barPath.fill()

          // Right Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset )),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[NSLayoutAttributeTop.rawValue] {

          // Top Bar Drawing
          let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + 1.0, width: frame.width - 8.0, height: 2.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: -1.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeTop)].setFill()
          barPath.fill()

          // Top Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset )),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[NSLayoutAttributeBottom.rawValue] {

          // Bottom Bar Drawing
          let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + frame.height - 3.0, width: frame.width - 8.0, height: 2.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: 1.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeBottom)].setFill()
          barPath.fill()

          // Bottom Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset )),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[NSLayoutAttributeCenterX.rawValue] {

          // CenterX Bar Drawing
          let rect = CGRect(x: frame.minX + floor((frame.width - 2.0) * 0.5) + 0.5, y: frame.minY + 4.0,
            width: 2.0, height: frame.height - 7.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeCenterX)].setFill()
          barPath.fill()

          // CenterX Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset )),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[NSLayoutAttributeCenterY.rawValue] {

          // CenterY Bar Drawing
          let rect = CGRect(x: frame.minX + 3.5, y: frame.minY + floor(frame.height - 2.0) * 0.5 + 0.5),
                            width: frame.width - 8.0, height: 2.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyTypeForAttribute(NSLayoutAttributeCenterY)].setFill()
          barPath.fill()

          // CenterY Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(-innerRadius, -innerRadius)

          borderRect.offset(-offset.width, -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(-1, -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
          {
            let xOffset = offset.width + round(borderRect.size.width)
            let yOffset = offset.height

            CGContextSetShadowWithColor(context,
              CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset )),
              innerRadius,
              gentleHighlight.CGColor)

            barPath.addClip()

            let transform = CGAffineTransformMakeTranslation(-round(borderRect.width), 0)

            negativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            negativePath.fill()
          }

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        alignmentOverlay.contents = image.CGImage
        UIGraphicsEndImageContext()

      }

    }

  }

  class var minimumSize: CGSize { return CGSize(square: 44.0) }

  /**
  viewWithModel:

  :param: model RemoteElement

  :returns: RemoteElementView
  */
  class func viewWithModel(model: RemoteElement) -> RemoteElementView {
    if let remote = model as? Remote { return viewWithModel(remote) }
    else if let buttonGroup = model as? ButtonGroup { return viewWithModel(buttonGroup) }
    else if let button = model as? Button { return viewWithModel(button) }
    else { return RemoteElementView(model: model) }
  }

  /**
  viewWithModel:

  :param: model Remote

  :returns: RemoteElementView
  */
  @objc(viewWithRemote:)
  class func viewWithModel(model: Remote) -> RemoteElementView {
    return RemoteView(model: model)
  }

  /**
  viewWithModel:

  :param: model ButtonGroup

  :returns: RemoteElementView
  */
  @objc(viewWithButtonGroup:)
  class func viewWithModel(model: ButtonGroup) -> RemoteElementView {
    switch model.role {
      case .Rocker: return RockerView(model: model)
      case .SelectionPanel: return ModeSelectionView(model: model)
      default: return ButtonGroupView(model: model)
    }
  }

  /**
  viewWithModel:

  :param: model Button

  :returns: RemoteElementView
  */
  @objc(viewWithButton:)
  class func viewWithModel(model: Button) -> RemoteElementView {
    switch model.role {
      case .BatteryStatus: return BatteryStatusButtonView(model: model)
      case .ConnectionStatus: return ConnectionStatusButtonView(model: model)
      default: return ButtonView(model: model)
    }
  }

  /**
  initWithModel:

  :param: model RemoteElement
  */
  init(model: RemoteElement) {
    super.init()
    setTranslatesAutoresizingMaskIntoConstraints(false)
    self.model = model
    registerForChangeNotification()
    initializeIVARs()
  }

  deinit { kvoReceptionists = nil }

  /** updateConstraints */
  override func updateConstraints() {
    removeAllConstraints()
    constrainWithFormat("|[b]| :: V:|[b]| :: |[c]| :: V:|[c]| :: |[s]| :: V:|[s]| :: |[o]| :: V:|[o]|",
                  views: ["b": backdropView, "c": contentView, "s": subelementsView, "o": overlayView])
    if let modelConstraints = model.constraints?.allObjects as? [Constraint] {
      addConstraints(modelConstraints.map{RemoteElementLayoutConstraint(model: $0, forView: self)})
    }

    super.updateConstraints()
  }

  /**
  forwardingTargetForSelector:

  :param: aSelector Selector

  :returns: NSObject?
  */
  override func forwardingTargetForSelector(aSelector: Selector) -> NSObject? {
    return model ?? super.forwardingTargetForSelector(aSelector)
  }

  /**
  valueForUndefinedKey:

  :param: key String

  :returns: AnyObject?
  */
  override func valueForUndefinedKey(key: String) -> AnyObject? {
    return model != nil ? model.valueForKey(key) : super.valueForUndefinedKey(key)
  }

  override class var requiresConstraintBasedLayout: Bool { return true }

  private var subelementsView = SubelementsView.newForAutolayout()
  private var contentView = ContentView.newForAutolayout()
  private var backdropView = BackdropView.newForAutolayout()
  private var overlayView = OverlayView.newForAutolayout()

  var viewFrames: [String:CGRect] {
    var frames = [uuid: frame]
    if parentElementView != nil {
      frames[parentElementView!.uuid] = parentElementView!.frame
    }
    for subelementView in subelementViews { frames[subelementView.uuid] = subelementView.frame }
    return frames
  }

  var minimumSize: CGSize {

    var size = RemoteElementView.minimumSize

    if subelementViews.count > 0 {

      var xAxisIntervals: [HalfOpenInterval<CGFloat>] = []
      var yAxisIntervals: [HalfOpenInterval<CGFloat>] = []

      for subelementView in subelementViews {
        let min = subelementView.minimumSize
        let origin = subelementView.frame.origin
        xAxisIntervals.append(HalfOpenInterval(origin.x, (origin.x + min.width)))
        yAxisIntervals.append(HalfOpenInterval(origin.y, (origin.y + min.height)))
      }
      xAxisIntervals.sort{$0.start < $1.start}
      yAxisIntervals.sort{$0.start < $1.start}

      var tmpInterval = xAxisIntervals[0]
      var tmpAxisIntervals: [HalfOpenInterval<CGFloat>] = []
      for interval in xAxisIntervals {
        if overlaps(tmpInterval, interval) {
          tmpInterval.end = interval.end
        } else {
          tmpAxisIntervals.append(tmpInterval)
          tmpInterval = interval
        }
      }
      tmpAxisIntervals.append(tmpInterval)
      xAxisIntervals = tmpAxisIntervals

      tmpInterval = yAxisIntervals[0]
      tmpAxisIntervals.removeAll()
      for interval in yAxisIntervals {
        if overlaps(tmpInterval, interval) {
          tmpInterval.end = interval.end
        } else {
          tmpAxisIntervals.append(tmpInterval)
          tmpInterval = interval
        }
      }
      tmpAxisIntervals.append(tmpInterval)
      yAxisIntervals = tmpAxisIntervals

      size.width = xAxisIntervals.reduce(0.0) {$0 + ($1.end - $1.start)}
      size.height = yAxisIntervals.reduce(0.0) {$0 + ($1.end - $1.start)}

      if proportionLock { size = bounds.size.aspectMappedToSize(size, false) }

    }

    return size
  }

  var maximumSize: CGSize {
    var size = superview.bounds.size
    if proportionLock { size = bounds.size.aspectMappedToSize(size, true) }
    return size
  }

  override var backgroundColor: UIColor? { return super.backgroundColor ?? model?.backgroundColor }

  override func setNeedsDisplay() {
    super.setNeedsDisplay()
    backdropView.setNeedsDisplay()
    contentView.setNeedsDisplay()
    subelementsView.setNeedsDisplay()
    overlayView.setNeedsDisplay()
  }

  override var bounds: CGRect { didSet { refreshBorderPath() } }

  var uuid: String { return model.uuid }
  var key: String? { return model.key }
  var name: String? { return model.name }
  var proportionLock: Bool { return model.proportionLock }
  var currentMode: String { return modle.currentMode }

  /**
  subscript:

  :param: key String

  :returns: RemoteElementView?
  */
  subscript(key: String) -> RemoteElementView? {
    if model.isIdentifiedByString(key) { return self }
    else { return subelementViews.filter{$0.model.isIdentifiedByString()}.first }
  }

  /**
  subscript:

  :param: idx Int

  :returns: RemoteElementView?
  */
  subscript(idx: Int) -> RemoteElementView? {
    return idx < subelementsView.subviews.count ? subelementsView.subviews[idx] as? RemoteElementView : nil
  }

  var parentElementView: RemoteElementView? { return (superview as? SubelementsView)?.superview as? RemoteElementView }

  var model: RemoteElement!
  var subelementViews: [RemoteElementView] { return subelementsView.subviews }

  /**
  addSubelementViews:

  :param: views NSSet
  */
  func addSubelementViews(views: NSSet) {
    if let subelementViews = views.allObjects as? [RemoteElementView] {
      apply(subelementViews){self.subelementsView.addSubview($0)}
    }
  }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  func addSubelementView(view: RemoteElementView) { subelementsView.addSubview(view) }

  func removeSubelementViews(views: NSSet) {
    if let subelementViews = views.allObjects as? [RemoteElementView] {
      apply(subelementViews){$0.removeFromSuperview()}
    }
  }

  /**
  removeSubelementView:

  :param: view RemoteElementView
  */
  func removeSubelementView(view: RemoteElementView) { view.removeFromSuperview() }

  /**
  bringSubelementViewToFront:

  :param: subelementView RemoteElementView
  */
  func bringSubelementViewToFront(subelementView: RemoteElementView) {
    subelementsView.bringSubviewToFront(subelementView)
  }

  /**
  sendSubelementViewToBack:

  :param: subelementView RemoteElementView
  */
  func sendSubelementViewToBack(subelementView: RemoteElementView) {
    subelementsView.sendSubviewToBack(subelementView)
  }

  /**
  insertSubelementView:aboveSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  func insertSubelementView(subelementView: RemoteElementView, aboveSubelementView siblingSubelementView: RemoteElementView) {
    subelementsView.insertSubview(subelementView, aboveSubview: siblingSubelementView)
  }

  /**
  insertSubelementView:atIndex:

  :param: subelementView RemoteElementView
  :param: index Int
  */
  func insertSubelementView(subelementView: RemoteElementView, atIndex index: Int) {
    subelementsView.insertSubview(subelementView atIndex: index)
  }

  /**
  insertSubelementView:belowSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  func insertSubelementView(subelementView: RemoteElementView, belowSubelementView siblingSubelementView: RemoteElementView) {
    subelementsView.insertSubview(subelementView, belowSubview: siblingSubelementView)
  }

  var locked = false { didSet { apply(subelementViews){$0.resizable = !self.locked; $0.moveable = !self.locked} } }
  var editingMode: REEditingMode = .NotEditing { didSet { apply(subelementViews){$0.editingMode = self.editingMode} } }
  var isEditing: Bool { return model.elementType & editingMode == editingMode }
  var editingState: REEditingState = .NotEditing {
    didSet {
      overlayView.showAlignmentIndicators = editingState == .Moving
      overlayView.showContentBoundary = editingState != .NotEditing
      var color: UIColor
      switch editingState {
        case .Selected: color = UIColor.yellowColor()
        case .Moving: color = UIColor.blueColor()
        case .Focus: color = UIColor.redColor()
        default: color = UIColor.clearColor()
      }
      UIView.animateWithDuration(1.0) {
        self.overlayView.boundaryColor = color
        overlayView.setNeedsDisplay()
        overlayView.displayIfNeeded()
      }
    }
  }
  var resizable = false
  var moveable = false
  var shrinkwrap = false
  var appliedScale: CGFloat = 1.0

  /** updateSubelementOrderFromView */
  func updateSubelementOrderFromView() { model.subelements = NSOrderedSet(array: subelementViews.map{$0.model}) }

  /**
  translateSubelements:translation:

  :param: subelementViews NSSet
  :param: translation CGPoint
  */
  func translateSubelements(subelementViews: NSSet, translation: CGPoint) {
    model.constraintManager.translateSubelements((subelementViews.allObjects as [RemoteElementView]).map{$0.model},
                                     translation: translation,
                                         metrics: viewFrames)
    if shrinkwrap { model.constraintManager.shrinkWrapSubelements(viewFrames) }
    apply(subelementViews.allObjects as [RemoteElementView]){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }

  /**
  scaleSubelement:scale:

  :param: subelementViews NSSet
  :param: scale CGFloat
  */
  func scaleSubelement(subelementViews: NSSet, scale: CGFloat) {
    for subelementView in subelementViews {
      let maxSize = subelementView.maximumSize
      let minSize = subelementView.minimumSize
      let scaledSize = subelementsView.bounds.size * scale
      let newSize = maxSize.contains(scaledSize) ? (scaledSize.contains(minSize) ? scaledSize : minSize) : maxSize
      model.constraintManager.resizeElement(subelementView.model,
                                   fromSize: subelementView.bounds.size,
                                     toSize: newSize,
                                    metrics: viewFrames)
    }
    if shrinkwrap { model.constraintManager.shrinkWrapSubelements(viewFrames) }
    apply(subelementViews.allObjects as [RemoteElementView]){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }

  /**
  alignSubelements:toSibling:attribute:

  :param: subelementViews NSSet
  :param: siblingView RemoteElementView
  :param: attribute NSLayoutAttribute
  */
  func alignSubelements(subelementViews: NSSet, toSibling siblingView: RemoteElementView, attribute: NSLayoutAttribute) {
    model.constraintManager.alignSubelements((subelementViews.allObjects as [RemoteElementView]).map{$0.model},
                                  toSibling: siblingView.model,
                                  attribute: attribute,
                                    metrics: viewFrames)
    if shrinkwrap { model.constraintManager.shrinkWrapSubelements(viewFrames) }
    apply(subelementViews.allObjects as [RemoteElementView]){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()

  }

  /**
  resizeSubelements:toSibling:attribute:

  :param: subelementViews NSSet
  :param: siblingView RemoteElementView
  :param: attribute NSLayoutAttribute
  */
  func resizeSubelements(subelementViews: NSSet, toSibling siblingView: RemoteElementView, attribute: NSLayoutAttribute) {
    model.constraintManager.resizeSubelements((subelementViews.allObjects as [RemoteElementView]).map{$0.model},
                                    toSibling: siblingView.model,
                                    attribute: attribute,
                                      metrics: viewFrames)
    if shrinkwrap { model.constraintManager.shrinkWrapSubelements(viewFrames) }
    apply(subelementViews.allObjects as [RemoteElementView]){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }

  func scale(scale: CGFloat) {
    //TODO: Fill out stub
  }

  var appearanceDescriptionDictionary: MSDictionary {
    let element = model.faultedObject
    let appearanceDictionary = MSDictionary()
    appearanceDictionary.setValue(NSStringFromREShape(element.shape), forKey:"shape")
    appearanceDictionary.setValue(NSStringFromREStyle(element.style), forKey:"style")
    appearanceDictionary.setValue(namedModelObjectDescription(element.backgroundImage), forKey:"backgroundImage")
    appearanceDictionary.setValue("\(element.backgroundImageAlpha)", forKey:"backgroundImageAlpha")
    appearanceDictionary.setValue(NSStringFromUIColor(element.backgroundColor), forKey:"backgroundColor")
    appearanceDictionary.setValue("\(element.proportionLock)", forKey:"proportionLock")
    return (MSDictionary *)appearanceDictionary;
  }

  var appearanceDescription: String {
    //TODO: Fill out stub
    return ""
  }
  var framesDescription: String {
    //TODO: Fill out stub
    return ""
  }
  var constraintsDescription: String {
    //TODO: Fill out stub
    return ""
  }
  var viewConstraintsDescription: String {
    //TODO: Fill out stub
    return ""
  }
  var modelConstraintsDescription: String {
    //TODO: Fill out stub
    return ""
  }

  // func prettyRemoteElementConstraint(constraint: NSLayoutConstraint) -> String { return "" }

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {}

  /** registerForChangeNotification */
  func registerForChangeNotification() {
    if model != nil {
      kvoReceptionists = [:]
      for (keyPath, block) in kvoRegistration() {
        kvoReceptionists[keyPath] = MSKVOReceptionist(observer: self,
                                                      forObject: model,
                                                      keyPath: keyPath,
                                                      options: NSKeyValueObservingOptionNew,
                                                      queue: NSOperationQueue.mainQueue(),
                                                      handler: block)
      }
    }
  }

  /** initializeIVARs */
  func initializeIVARs() {
    clipsToBounds = false
    opaque = false
    multipleTouchEnabled = true
    userInteractionEnabled = true
    addInternalSubviews()
    attachGestureRecognizers()
    initializeViewFromModel()
  }

  /** initializeViewFromModel */
  func initializeViewFromModel() {
    super.backgroundColor = model.backgroundColor
    refreshBorderPath()
    for element in model.subelements { addSubelementView(RemoteElementView.viewWithModel(element)) }
  }

  var kvoReceptionists: [String:MSKVOReceptionist] = []

  func kvoRegistration() -> [String:(MSKVOReceptionist) -> Void] {
    var registry: [String:(MSKVOReceptionist) -> Void] = [:]
    registry["constraints"] = {
      (receptionist: MSKVOReceptionist) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsUpdateConstraints()
        }
    }
    registry["backgroundColor"] = {
      (receptionist: MSKVOReceptionist) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          if let color = receptionist.change[NSKeyValueChangeNewKey] as? UIColor {
            v.backgroundColor = color
          } else {
            v.backgroundColor = nil
          }
        }
    }
    registry["backgroundImage"] = {
      (receptionist: MSKVOReceptionist) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsDisplay()
        }
    }
    registry["style"] = {
      (receptionist: MSKVOReceptionist) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsDisplay()
        }
    }
    registry["shape"] = {
      (receptionist: MSKVOReceptionist) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.refreshBorderPath()
        }
    }
    return registry
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
    if model.shape == .RoundedRectangle {
      UIGraphicsPushContext(ctx)
      MSPainter.drawRoundedRectButtonBaseInContext(ctx,
                                       buttonColor: model.backgroundColor,
                                       shadowColor: nil,
                                            opaque: true,
                                             frame: rect)
      UIGraphicsPopContext()
    } else if borderPath != nil {
      UIGraphicsPushContext(ctx)
      backgroundColor.setFill()
      borderPath!.fill()
      UIGraphicsPopContext()
    }
    if model.backgroundImage != nil {
      let image = model.backgroundImage!.image
      if rect.size <= image.size {
        image.drawInRect(rect)
      } else {
        image.drawAsPatternInRect(rect)
      }
    }
  }

  /**
  drawOverlayInContext:inRect:

  :param: ctx CGContextRef
  :param: rect CGRect
  */
  func drawOverlayInContext(ctx: CGContextRef, inRect rect: CGRect) {
    let path = borderPath != nil ? UIBezierPath(CGPath: borderPath!.CGPath) : UIBezierPath(rect: rect)
    UIGraphicsPushContext(ctx)
    path.addClip()
    let style = model.style & REStyle.ApplyGloss
    switch style {
      case REStyle.GlossStyle1:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: 0.0)
      case REStyle.GlossStyle2:
        MSPainter.drawRoundedRectButtonOverlayInContext(ctx, shineColor: nil, frame: rect)
      case REStyle.GlossStyle3:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: 0.8)
      case REStyle.GlossStyle4:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: -0.8)
      default: break
    }
    if model.style & REStyle.DrawBorder != 0 {
      path.lineWidth = 3.0
      path.lineJoinStyle = kCGLineJoinRound
      UIColor.blackColor().setStroke()
      path.stroke()
    }
    UIGraphicsPopContext()
  }

  /** refreshBorderPath */
  func refreshBorderPath() {
    switch model.shape {
      case .Rectangle:
        borderPath = UIBezierPath(rect: bounds)
      case .RoundedRectangle:
        borderPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .AllCorners, cornerRadii: cornerRadii)
      case .Oval:
        borderPath = MSPainter.stretchedOvalFromRect(bounds)
      case .Triangle:
        fallthrough
      case .Diamond:
        fallthrough
      default:
        borderPath = nil
    }
  }

  var borderPath: UIBezierPath? {
    didSet {
      if borderPath != nil {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = borderPath!.CGPath
        layer.mask = shapeLayer
      } else {
        layer.mask = nil
      }
      overlayView.refreshBoundary()
    }
  }

  var cornerRadii = CGSize(square: 5.0)

  /** addInternalSubviews */
  func addInternalSubviews() {
    addSubview(backdropView)
    addSubview(contentView)
    addSubview(subelementsView)
    addSubview(overlayView)
  }

  /**
  addViewToContent:

  :param: view UIView
  */
  func addViewToContent(view: UIView) { contentView.addSubview(view) }

  /**
  addLayerToContent:

  :param: layer CALayer
  */
  func addLayerToContent(layer: CALayer) { contentView.layer.addSublayer(layer) }

  /**
  addViewToOverlay:

  :param: view UIView
  */
  func addViewToOverlay(view: UIView) { overlayView.addSubview(view) }

  /**
  addLayerToOverlay:

  :param: layer CALayer
  */
  func addLayerToOverlay(layer: CALayer) { overlayView.layer.addSublayer(layer) }

  /**
  addViewToBackdrop:

  :param: view UIView
  */
  func addViewToBackdrop(view: UIView) { backdropView.addSubview(view) }

  /**
  addLayerToBackdrop:

  :param: layer CALayer
  */
  func addLayerToBackdrop(layer: CALayer) { backdropView.layer.addSublayer(layer) }

  var contentInteractionEnabled: Bool {
    get { return contentView.userInteractionEnabled }
    set { contentView.userInteractionEnabled = newValue }
  }

  var subelementInteractionEnabled: Bool {
    get { return subelementsView.userInteractionEnabled }
    set { subelementsView.userInteractionEnabled = newValue }
  }

  var contentClipsToBounds: Bool {
    get { return contentView.clipsToBounds }
    set { contentView.clipsToBounds = newValue }
  }

  var overlayClipsToBounds: Bool {
    get { return overlayView.clipsToBounds }
    set { overlayView.clipsToBounds = newValue }
  }

  /**
  willResizeViews:

  :param: views NSSet
  */
  func willResizeViews(views: NSSet) {}

  /**
  didResizeViews:

  :param: views NSSet
  */
  func didResizeViews(views: NSSet) {}

  /**
  willScaleViews:

  :param: views NSSet
  */
  func willScaleViews(views: NSSet) {}

  /**
  didScaleViews:

  :param: views NSSet
  */
  func didScaleViews(views: NSSet) {}

  /**
  willAlignViews:

  :param: views NSSet
  */
  func willAlignViews(views: NSSet) {}

  /**
  didAlignViews:

  :param: views NSSet
  */
  func didAlignViews(views: NSSet) {}

  /**
  willTranslateViews:

  :param: views NSSet
  */
  func willTranslateViews(views: NSSet) {}

  /**
  didTranslateViews:

  :param: views NSSet
  */
  func didTranslateViews(views: NSSet) {}


}
