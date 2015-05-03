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
import DataModel

public class RemoteElementView: UIView {

  // MARK: - Initialization

 /**
  viewWithPreset:

  :param: preset Preset

  :returns: RemoteElementView?
  */
  public class func viewWithPreset(preset: Preset) -> RemoteElementView? {
    let model = RemoteElement.remoteElementFromPreset(preset)
    return model != nil ? viewWithModel(model!) : nil
  }

  /**
  viewWithModel:

  :param: model RemoteElement

  :returns: RemoteElementView
  */
  class func viewWithModel(model: RemoteElement) -> RemoteElementView? {
    switch model.elementType {
      case .Remote: return RemoteView(model: model)
      case .ButtonGroup:
        switch model.role {
          case RemoteElement.Role.Rocker:         return RockerView(model: model)
          case RemoteElement.Role.SelectionPanel: return ModeSelectionView(model: model)
          default:                                return ButtonGroupView(model: model)
        }
      case .Button:
        switch model.role {
          case RemoteElement.Role.BatteryStatus:    return BatteryStatusButtonView(model: model)
          case RemoteElement.Role.ConnectionStatus: return ConnectionStatusButtonView(model: model)
          default:                                  return ButtonView(model: model)
        }
      default: return nil
    }
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithModel:

  :param: model RemoteElement
  */
  required public init(model: RemoteElement) {
    if model.role & .DPad == RemoteElement.Role.DPad {
      MSLogDebug(model.description)
    }
    super.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    self.model = model
    self.model.refresh()
    registerForChangeNotification()
    initializeIVARs()
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {}

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


  // MARK: - Constraints

  public var modeledConstraints: [RemoteElementViewConstraint] {
    return constraints().filter{$0 is RemoteElementViewConstraint} as! [RemoteElementViewConstraint]
  }

  /** updateConstraints */
  override public func updateConstraints() {
    //TODO: Modify to use model constraint uuids to update only where necessary

    let identifier = createIdentifier(self, ["Internal", "Base"])
    let modelConstraints = model.constraints
    let modeledConstraints = self.modeledConstraints

    if modelConstraints.count > modeledConstraints.count {
      removeConstraints(modeledConstraints)
      for modelConstraint in modelConstraints {
        if let constraint = RemoteElementViewConstraint.constraintWithModel(modelConstraint, owningView: self) {
          constraint.identifier = identifier
          addConstraint(constraint)
        }
      }
    }

    super.updateConstraints()
  }

  override public class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  translateSubelements:translation:

  :param: subelementViews NSSet
  :param: translation CGPoint
  */
  public func translateSubelements(subelementViews: OrderedSet<RemoteElementView>, translation: CGPoint) {

    model.constraintManager.translateSubelements(subelementViews.array.map{$0.model},
                                     translation: translation,
                                         metrics: viewFrames)
    if shrinkwrap { model.constraintManager.shrinkwrapSubelementsUsingMetrics(viewFrames) }

//    apply(subelementViews.allObjects as [RemoteElementView]){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }


  /**
  scaleSubelement:scale:

  :param: subelementViews NSSet
  :param: scale CGFloat
  */
  public func scaleSubelement(subelementViews: OrderedSet<RemoteElementView>, scale: CGFloat) {
    for subelementView in subelementViews {
      let maxSize = subelementView.maximumSize
      let minSize = subelementView.minimumSize
      let scaledSize = bounds.size * scale
      let newSize = maxSize.contains(scaledSize) ? (scaledSize.contains(minSize) ? scaledSize : minSize) : maxSize
      model.constraintManager.resizeElement(subelementView.model,
                                   fromSize: subelementView.bounds.size,
                                     toSize: newSize,
                                    metrics: viewFrames)
    }
    if shrinkwrap { model.constraintManager.shrinkwrapSubelementsUsingMetrics(viewFrames) }
    apply(subelementViews){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }

  /**
  alignSubelements:toSibling:attribute:

  :param: subelementViews NSSet
  :param: siblingView RemoteElementView
  :param: attribute NSLayoutAttribute
  */
  public func alignSubelements(subelementViews: OrderedSet<RemoteElementView>,
                      toSibling siblingView: RemoteElementView,
                      attribute: NSLayoutAttribute)
  {
    MSLogDebug("model constraints before alignment…\n\(modeledConstraintsDescription)")
    model.constraintManager.alignSubelements(subelementViews.array.map{$0.model},
                                  toSibling: siblingView.model,
                                  attribute: attribute,
                                    metrics: viewFrames)
    MSLogDebug("model constraints after alignment and before shrinkwrap…\n\(modeledConstraintsDescription)")
    if shrinkwrap { model.constraintManager.shrinkwrapSubelementsUsingMetrics(viewFrames) }
    MSLogDebug("model constraints after shrinkwrap\n\(modeledConstraintsDescription)")
    apply(subelementViews){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()

  }

  /**
  resizeSubelements:toSibling:attribute:

  :param: subelementViews NSSet
  :param: siblingView RemoteElementView
  :param: attribute NSLayoutAttribute
  */
  public func resizeSubelements(subelementViews: OrderedSet<RemoteElementView>,
                      toSibling siblingView: RemoteElementView,
                      attribute: NSLayoutAttribute)
  {
    model.constraintManager.resizeSubelements(subelementViews.array.map{$0.model},
                                    toSibling: siblingView.model,
                                    attribute: attribute,
                                      metrics: viewFrames)
    if shrinkwrap { model.constraintManager.shrinkwrapSubelementsUsingMetrics(viewFrames) }
    apply(subelementViews){$0.setNeedsUpdateConstraints()}
    setNeedsUpdateConstraints()
  }

  /**
  scale:

  :param: scale CGFloat
  */
  public func scale(scale: CGFloat) {
    model.constraintManager.resizeElement(model,
                                 fromSize: bounds.size,
                                   toSize: bounds.size * (scale / appliedScale),
                                  metrics: viewFrames)
    appliedScale = scale
    setNeedsUpdateConstraints()
  }

  // MARK: - Subelement views

  /**
  objectIsSubelementKind:

  :param: object AnyObject

  :returns: Bool
  */
  public func objectIsSubelementKind(object: AnyObject) -> Bool {
    switch model.elementType {
      case .Remote: return object is ButtonGroupView
      case .ButtonGroup: return object is ButtonView
      default: return false
    }
  }

  public var viewFrames: [UUIDIndex:CGRect] {
    var frames = [model.uuidIndex: frame]
    if parentElementView != nil {
      frames[parentElementView!.model.uuidIndex] = parentElementView!.frame
    }
    for subelementView in subelementViews { frames[subelementView.model.uuidIndex] = subelementView.frame }
    return frames
  }

  /**
  subscript:

  :param: key String

  :returns: RemoteElementView?
  */
  override public subscript(key: String) -> RemoteElementView? {
    if model.isIdentifiedByString(key) { return self }
    else { return subelementViews.filter{$0.model.isIdentifiedByString(key)}.first }
  }

  /**
  subscript:

  :param: idx Int

  :returns: RemoteElementView?
  */
  public subscript(idx: Int) -> RemoteElementView? {
    let subelements = subelementViews
    assert(idx < subelements.count)
    return subelements[idx]
  }

  public var subelementViews: OrderedSet<RemoteElementView> {
    return OrderedSet(subviews.filter({$0 is RemoteElementView}) as? [RemoteElementView] ?? [])
  }

  /**
  addSubelementViews:

  :param: views NSSet
  */
  public func addSubelementViews(views: Set<RemoteElementView>) { apply(subelementViews){self.addSubview($0)} }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  public func addSubelementView(view: RemoteElementView) { addSubview(view) }

  /**
  removeSubelementViews:

  :param: views Set<RemoteElementView>
  */
  public func removeSubelementViews(views: Set<RemoteElementView>) { apply(subelementViews){$0.removeFromSuperview()} }

  /**
  removeSubelementView:

  :param: view RemoteElementView
  */
  public func removeSubelementView(view: RemoteElementView) { view.removeFromSuperview() }

  /**
  bringSubelementViewToFront:

  :param: subelementView RemoteElementView
  */
  public func bringSubelementViewToFront(subelementView: RemoteElementView) {
    bringSubviewToFront(subelementView)
  }

  /**
  sendSubelementViewToBack:

  :param: subelementView RemoteElementView
  */
  public func sendSubelementViewToBack(subelementView: RemoteElementView) {
    sendSubviewToBack(subelementView)
  }

  /**
  insertSubelementView:aboveSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  public func insertSubelementView(subelementView: RemoteElementView, aboveSubelementView siblingSubelementView: RemoteElementView) {
    insertSubview(subelementView, aboveSubview: siblingSubelementView)
  }

  /**
  insertSubelementView:atIndex:

  :param: subelementView RemoteElementView
  :param: index Int
  */
  public func insertSubelementView(subelementView: RemoteElementView, atIndex index: Int) {
    insertSubview(subelementView, atIndex: index)
  }

  /**
  insertSubelementView:belowSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  public func insertSubelementView(subelementView: RemoteElementView, belowSubelementView siblingSubelementView: RemoteElementView) {
    insertSubview(subelementView, belowSubview: siblingSubelementView)
  }

  // MARK: - Parent view

  public var parentElementView: RemoteElementView? { return (superview as? ViewProxy)?.superview as? RemoteElementView }

  // MARK: - Size

  override public var bounds: CGRect { didSet { refreshBorderPath() } }

  public static let MinimumSize = CGSize(square: 44)

  public var minimumSize: CGSize {

    var size = RemoteElementView.MinimumSize

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
          tmpInterval = HalfOpenInterval(tmpInterval.start, interval.end)
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
          tmpInterval = HalfOpenInterval(tmpInterval.start, interval.end)
        } else {
          tmpAxisIntervals.append(tmpInterval)
          tmpInterval = interval
        }
      }
      tmpAxisIntervals.append(tmpInterval)
      yAxisIntervals = tmpAxisIntervals

      size.width = xAxisIntervals.reduce(0.0) {$0 + ($1.end - $1.start)}
      size.height = yAxisIntervals.reduce(0.0) {$0 + ($1.end - $1.start)}

      if model.constraintManager.proportionLock { size = bounds.size.aspectMappedToSize(size, binding: false) }

    }

    return size
  }

  public var maximumSize: CGSize {
    var size = superview?.bounds.size ?? CGSize.zeroSize
    if model.constraintManager.proportionLock { size = bounds.size.aspectMappedToSize(size, binding: true) }
    return size
  }

  // MARK: - Model

  public var model: RemoteElement! { didSet { model?.fireFault() } }

  /** initializeViewFromModel */
  func initializeViewFromModel() {
    apply(compressedMap(model.subelements) {RemoteElementView.viewWithModel($0)}) {self.addSubelementView($0)}
    updateViewFromModel()
  }

  /** updateViewFromModel */
  func updateViewFromModel() {
    backgroundColor = model.background?.color
    backgroundImage = model.background?.rawImage
    backgroundImageAlpha = model.background?.alpha?.floatValue ?? backgroundImageAlpha
    refreshBorderPath()
    setNeedsDisplay()
  }

  /** updateSubelementOrderFromView */
  public func updateSubelementOrderFromView() { model.subelements = subelementViews.map{$0.model} }

  // MARK: - KVO

  typealias Property = String
  private var kvoReceptionists: [Property:KVOReceptionist] = [:]

  static let dumpObservation: (KVOReceptionist) -> Void = { receptionist in
    let element = (receptionist.observer as! RemoteElementView).model
    if element.role & .DPad != RemoteElement.Role.DPad { return }
    let name = element.name
    let type = element.elementType.stringValue
    let property = receptionist.keyPath
    let value: AnyObject? = receptionist.change?[NSKeyValueChangeNewKey]
    let valueString: String
    if let namedValue = value as? Named { valueString = namedValue.name }
    else { valueString = toString(value) }
    var string = "observed new value '\(valueString)' for property '\(property)' "
    string += " for \(type) named '\(name)' with faulting state '\(element.faultingState)', fault = \(element.fault)'"
    MSLogDebug(string)
  }

  /**
  kvoRegistration

  :returns: [Property:KVOReceptionist.Observation]
  */
  func kvoRegistration() -> [Property:KVOReceptionist.Observation] {
    var registry: [Property:KVOReceptionist.Observation] = [:]

    registry["background"] = {
      RemoteElementView.dumpObservation($0)
      let element = $0.object as? RemoteElement
      let view = $0.observer as? RemoteElementView
      view?.backgroundColor = element?.background?.color
      view?.backgroundImage = element?.background?.rawImage
      view?.backgroundImageAlpha = element?.background?.alpha?.floatValue ?? view?.backgroundImageAlpha ?? 1.0
    }
    registry["constraints"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? RemoteElementView)?.setNeedsUpdateConstraints()
    }
    registry["style"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? RemoteElementView)?.setNeedsDisplay()
    }
    registry["shape"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? RemoteElementView)?.refreshBoundary()
      ($0.observer as? RemoteElementView)?.setNeedsDisplay()
    }
    registry["currentMode"] = {($0.observer as? RemoteElementView)?.updateViewFromModel()}

    return registry
  }


  /** registerForChangeNotification */
  func registerForChangeNotification() {
    precondition(model != nil, "why are we calling this without a valid model object?")
    kvoReceptionists = map(kvoRegistration()) { KVOReceptionist(observer: self, keyPath: $0, object: self.model, handler: $1) }
  }

  // MARK: Cached model values

  public private(set) var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }
  public private(set) var backgroundImageAlpha: Float = 1.0 { didSet { setNeedsDisplay() } }


  // MARK: - Editing

  public var locked: Bool = false { didSet { apply(subelementViews){$0.resizable = !self.locked; $0.moveable = !self.locked} } }

  public var editingMode: RemoteElement.BaseType = .Undefined {
    didSet { apply(subelementViews){$0.editingMode = self.editingMode} }
  }

  public var isEditing: Bool { return editingMode != .Undefined }

  public enum EditingState {
    case None, Selected, Moving, Focus
    var color: UIColor {
      switch self {
        case .None: return UIColor.clearColor()
        case .Selected: return UIColor.yellowColor()
        case .Moving: return UIColor.blueColor()
        case .Focus: return UIColor.redColor()
      }
    }
  }

  public var editingState: EditingState = .None {
    didSet {
      showAlignmentIndicators = editingState == .Moving
      showContentBoundary = editingState != .None
      refreshBoundary()
      boundaryColor = editingState.color
      /*boundaryOverlay.setNeedsDisplay()*/
      /*alignmentOverlay.displayIfNeeded()*/
    }
  }
  public var resizable = false
  public var moveable = false
  public var shrinkwrap = false
  public var appliedScale: CGFloat = 1.0

  private var boundaryColor: UIColor = UIColor.clearColor() { didSet { boundaryOverlay.strokeColor = boundaryColor.CGColor } }
  private var showAlignmentIndicators: Bool = false {
    didSet { alignmentOverlay.hidden = !showAlignmentIndicators; renderAlignmentOverlayIfNeeded() }
  }
  private var showContentBoundary: Bool = false { didSet { refreshBoundary(); boundaryOverlay.hidden = !showContentBoundary } }
  private var lineWidth: CGFloat = 2.0 { didSet { boundaryOverlay.lineWidth = lineWidth } }

  /** refreshBoundary */
  private func refreshBoundary() { boundaryOverlay.path = boundaryPath }

  private var boundaryPath: CGPath { return (borderPath ?? UIBezierPath(rect: bounds)).CGPath }

  /** refreshBorderPath */
  private func refreshBorderPath() {
    switch model?.shape ?? .Undefined {
      case _ where bounds.isEmpty: fallthrough
      case .Undefined: borderPath = nil
      default: borderPath = Painter.pathForShape(model.shape, withAttributes: Painter.Attributes(rect: bounds))
    }
  }

  public var borderPath: UIBezierPath? {
    didSet {
      if let p = borderPath?.CGPath { let s = CAShapeLayer(); s.path = p; layer.mask = s } else { layer.mask = nil }
      refreshBoundary()
    }
  }

  public var cornerRadii = CGSize(square: 5.0)

  /** renderAlignmentOverlayIfNeeded */
  private func renderAlignmentOverlayIfNeeded() {

    if showAlignmentIndicators {

      let manager = model.constraintManager

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
      let frame = bounds.rectByInsetting(dx: 3.0, dy: 3.0)
      let cornerRadius: CGFloat = 1.0

      if manager[.Left] {

        // Left Bar Drawing
        let rect = CGRect(x: frame.minX + 1.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
        let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
        let offset = CGSize(width: -1.1, height: -0.1)

        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
        colors[manager.dependencyForAttribute(.Left).rawValue].setFill()
        barPath.fill()

        // Left Bar Inner Shadow
        var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

        borderRect.offset(dx: -offset.width, dy: -offset.height)
        borderRect.union(barPath.bounds)
        borderRect.inset(dx: -1, dy: -1)

        let negativePath = UIBezierPath(rect:borderRect)

        negativePath.appendPath(barPath)
        negativePath.usesEvenOddFillRule = true

        CGContextSaveGState(context)
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

        CGContextRestoreGState(context)

        CGContextRestoreGState(context)
      }

      if manager[.Right] {

        // Right Bar Drawing
        let rect = CGRect(x: frame.minX + frame.width - 3.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
        let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
        let offset = CGSize(width: 1.1, height: -0.1)

        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
        colors[manager.dependencyForAttribute(.Right).rawValue].setFill()
        barPath.fill()

        // Right Bar Inner Shadow
        var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

        borderRect.offset(dx: -offset.width, dy: -offset.height)
        borderRect.union(barPath.bounds)
        borderRect.inset(dx: -1, dy: -1)

        let negativePath = UIBezierPath(rect:borderRect)

        negativePath.appendPath(barPath)
        negativePath.usesEvenOddFillRule = true

        CGContextSaveGState(context)
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

        CGContextRestoreGState(context)

        CGContextRestoreGState(context)
      }

      if manager[.Top] {

        // Top Bar Drawing
        let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + 1.0, width: frame.width - 8.0, height: 2.0)
        let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
        let offset = CGSize(width: 0.1, height: -1.1)

        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
        colors[manager.dependencyForAttribute(.Top).rawValue].setFill()
        barPath.fill()

          // Top Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

          borderRect.offset(dx: -offset.width, dy: -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(dx: -1, dy: -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
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

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[.Bottom] {

          // Bottom Bar Drawing
          let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + frame.height - 3.0, width: frame.width - 8.0, height: 2.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: 1.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyForAttribute(.Bottom).rawValue].setFill()
          barPath.fill()

          // Bottom Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

          borderRect.offset(dx: -offset.width, dy: -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(dx: -1, dy: -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
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

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[.CenterX] {

          // CenterX Bar Drawing
          let rect = CGRect(x: frame.minX + floor((frame.width - 2.0) * 0.5) + 0.5, y: frame.minY + 4.0,
            width: 2.0, height: frame.height - 7.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyForAttribute(.CenterX).rawValue].setFill()
          barPath.fill()

          // CenterX Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

          borderRect.offset(dx: -offset.width, dy: -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(dx: -1, dy: -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
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

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        if manager[.CenterY] {

          // CenterY Bar Drawing
          let rect = CGRect(x: frame.minX + 3.5, y: frame.minY + floor(frame.height - 2.0) * 0.5 + 0.5,
                            width: frame.width - 8.0, height: 2.0)
          let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
          let offset = CGSize(width: 0.1, height: -0.1)

          CGContextSaveGState(context)
          CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
          colors[manager.dependencyForAttribute(.CenterY).rawValue].setFill()
          barPath.fill()

          // CenterY Bar Inner Shadow
          var borderRect = barPath.bounds.rectByInsetting(dx: -innerRadius, dy: -innerRadius)

          borderRect.offset(dx: -offset.width, dy: -offset.height)
          borderRect.union(barPath.bounds)
          borderRect.inset(dx: -1, dy: -1)

          let negativePath = UIBezierPath(rect:borderRect)

          negativePath.appendPath(barPath)
          negativePath.usesEvenOddFillRule = true

          CGContextSaveGState(context)
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

          CGContextRestoreGState(context)

          CGContextRestoreGState(context)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        alignmentOverlay.contents = image.CGImage
        UIGraphicsEndImageContext()

      }

  }

  // MARK: - Descriptions

  public var modeledConstraintsDescription: String { return "\n".join(modeledConstraints.map{$0.description}) }

  // MARK: - Overlay layers

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

  /** addInternalSubviews */
  func addInternalSubviews() {}
}
