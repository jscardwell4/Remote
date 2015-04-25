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



  class var MinimumSize: CGSize { return CGSize(square: 44.0) }

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
    MSLogDebug("model = \(model)")
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

  /** init */
//  override init() { super.init() }

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
    super.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    self.model = model
    self.model.refresh()
    registerForChangeNotification()
    initializeIVARs()
  }

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

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /** updateConstraints */
  override public func updateConstraints() {
    //TODO: Modify to use model constraint uuids to update only where necessary

    MSLogDebug("model = \(model)")

    var identifier = createIdentifier(self, ["Internal", "Base"])
    if constraintsWithIdentifier(identifier).count == 0 {
      constrain("|[b]| :: V:|[b]| :: |[c]| :: V:|[c]| :: |[s]| :: V:|[s]| :: |[o]| :: V:|[o]|",
                    views: ["b": backdropView, "c": contentView, "s": subelementsView, "o": overlayView],
               identifier: identifier)
    }

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

  private lazy var subelementsView: SubelementsView = SubelementsView(delegate: self)
  private lazy var contentView: ContentView = ContentView(delegate: self)
  private lazy var backdropView: BackdropView = BackdropView(delegate: self)
  private lazy var overlayView: OverlayView = OverlayView(delegate: self)

  public var viewFrames: [String:CGRect] {
    var frames = [model.uuid: frame]
    if parentElementView != nil {
      frames[parentElementView!.model.uuid] = parentElementView!.frame
    }
    for subelementView in subelementViews { frames[subelementView.model.uuid] = subelementView.frame }
    return frames
  }

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

  override public var backgroundColor: UIColor? {
    get { return super.backgroundColor ?? model?.backgroundColor }
    set { super.backgroundColor = newValue }
  }

 /** setNeedsDisplay */
 override public func setNeedsDisplay() {
   super.setNeedsDisplay()
   backdropView.setNeedsDisplay()
   contentView.setNeedsDisplay()
   subelementsView.setNeedsDisplay()
   overlayView.setNeedsDisplay()
 }

  override public var bounds: CGRect { didSet { refreshBorderPath() } }

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
    return idx < subelementsView.subviews.count ? subelementsView.subviews[idx] as? RemoteElementView : nil
  }

  public var parentElementView: RemoteElementView? { return (superview as? SubelementsView)?.superview as? RemoteElementView }

  public var model: RemoteElement!
  public var modeledConstraints: [RemoteElementViewConstraint] {
    return constraints().filter{$0 is RemoteElementViewConstraint} as! [RemoteElementViewConstraint]
  }
  public var subelementViews: OrderedSet<RemoteElementView> {
    return OrderedSet(subelementsView.subviews as? [RemoteElementView] ?? [])
  }

  /**
  addSubelementViews:

  :param: views NSSet
  */
  public func addSubelementViews(views: Set<RemoteElementView>) {
    apply(subelementViews){self.subelementsView.addSubview($0)}
  }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  public func addSubelementView(view: RemoteElementView) { subelementsView.addSubview(view) }

  public func removeSubelementViews(views: Set<RemoteElementView>) {
    apply(subelementViews){$0.removeFromSuperview()}
  }

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
    subelementsView.bringSubviewToFront(subelementView)
  }

  /**
  sendSubelementViewToBack:

  :param: subelementView RemoteElementView
  */
  public func sendSubelementViewToBack(subelementView: RemoteElementView) {
    subelementsView.sendSubviewToBack(subelementView)
  }

  /**
  insertSubelementView:aboveSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  public func insertSubelementView(subelementView: RemoteElementView, aboveSubelementView siblingSubelementView: RemoteElementView) {
    subelementsView.insertSubview(subelementView, aboveSubview: siblingSubelementView)
  }

  /**
  insertSubelementView:atIndex:

  :param: subelementView RemoteElementView
  :param: index Int
  */
  public func insertSubelementView(subelementView: RemoteElementView, atIndex index: Int) {
    subelementsView.insertSubview(subelementView, atIndex: index)
  }

  /**
  insertSubelementView:belowSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  public func insertSubelementView(subelementView: RemoteElementView, belowSubelementView siblingSubelementView: RemoteElementView) {
    subelementsView.insertSubview(subelementView, belowSubview: siblingSubelementView)
  }

  public var locked: Bool = false {
    didSet {
      apply(subelementViews){$0.resizable = !self.locked; $0.moveable = !self.locked}
    }
  }

  public var editingMode: RemoteElement.BaseType = .Undefined {
    didSet {
      apply(subelementViews){$0.editingMode = self.editingMode}
    }
  }

  public var isEditing: Bool { return editingMode != .None }

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
      overlayView.showAlignmentIndicators = editingState == .Moving
      overlayView.showContentBoundary = editingState != .None
      overlayView.refreshBoundary()
      overlayView.boundaryColor = editingState.color
      overlayView.layer.setNeedsDisplay()
      overlayView.layer.displayIfNeeded()
    }
  }
  public var resizable = false
  public var moveable = false
  public var shrinkwrap = false
  public var appliedScale: CGFloat = 1.0

  /** updateSubelementOrderFromView */
  public func updateSubelementOrderFromView() { model.childElements = subelementViews.map{$0.model} }

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
      let scaledSize = subelementsView.bounds.size * scale
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

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {}

  /** registerForChangeNotification */
  func registerForChangeNotification() {
    precondition(model != nil, "why are we calling this without a valid model object?")
    kvoReceptionists = map(kvoRegistration()) {
      (key: String, value: (MSKVOReceptionist!) -> Void) -> MSKVOReceptionist in
        MSKVOReceptionist(observer: self, forObject: self.model, keyPath: key, options: .New,
                          queue: NSOperationQueue.mainQueue(), handler: value)
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
    for element in model.childElements {
      if let subelementView = self.dynamicType.viewWithModel(element) {
        addSubelementView(subelementView)
      }
    }
  }

  var kvoReceptionists: [String:MSKVOReceptionist] = [:]

  /**
  kvoRegistration

  :returns: [String:(MSKVOReceptionist!) -> Void]
  */
  func kvoRegistration() -> [String:(MSKVOReceptionist!) -> Void] {

    var registry: [String:(MSKVOReceptionist!) -> Void] = [:]
    registry["backgroundColor"] = {
        if let v = $0.observer as? RemoteElementView {
          let currentColor = v.backgroundColor
          let changeColor = $0.change[NSKeyValueChangeNewKey] as? UIColor
          if currentColor != changeColor {
            v.backgroundColor = changeColor
            v.setNeedsDisplay()
          }
        }
    }
    registry["constraints"] = {($0.observer as? RemoteElementView)?.setNeedsUpdateConstraints()}

    let updateDisplay: (MSKVOReceptionist!) -> Void = {($0.observer as? RemoteElementView)?.setNeedsDisplay()}
    registry["backgroundImageAlpha"] = updateDisplay
    registry["backgroundImage"] = updateDisplay
    registry["style"] = updateDisplay
    registry["shape"] = updateDisplay

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
    if model.role == .Toolbar { return }
    switch model.shape {
      case .RoundedRectangle:
        UI.DrawingKit.drawRoundishButtonBase(frame: rect,
                                             color: model.backgroundColor ?? UI.DrawingKit.buttonBaseColor,
                                             radius: cornerRadii.width)
      case .Rectangle:
        UI.DrawingKit.drawRectangularButtonBase(frame: rect, color: model.backgroundColor ?? UI.DrawingKit.buttonBaseColor)
      case .Triangle:
        UI.DrawingKit.drawTriangleButtonBase(frame: rect, color: model.backgroundColor ?? UI.DrawingKit.buttonBaseColor)
      case .Diamond:
        UI.DrawingKit.drawDiamondButtonBase(frame: rect, color: model.backgroundColor ?? UI.DrawingKit.buttonBaseColor)
      default:
        if let path = borderPath {
          UIGraphicsPushContext(ctx)
          backgroundColor?.setFill()
          path.fill()
          UIGraphicsPopContext()
        }
    }

    // Draw background image
    if let imageView = model.backgroundImage,
      imageModel = imageView.image,
      image = imageModel.image
    {
      if rect.size <= image.size { image.drawInRect(rect) }
      else { image.drawAsPatternInRect(rect) }
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

    if model.style & RemoteElement.Style.DrawBorder != nil {
      path.lineWidth = 3.0
      path.lineJoinStyle = kCGLineJoinRound
      // TODO: Parameterize stroke color
      UIColor.blackColor().setStroke()
      path.stroke()
    }

    if model.style & RemoteElement.Style.GlossStyleMask != nil {
      UI.DrawingKit.drawGloss(frame: rect)
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
        borderPath = UIBezierPath(ovalInRect: bounds.rectByInsetting(dx: 2, dy: 2))
      case .Triangle:
        //TODO: Refactor DrawingKit code to include a function for creating a triangle path from a rect
        fallthrough
      case .Diamond:
        //TODO: Refactor DrawingKit code to include a function for creating a diamond path from a rect
        fallthrough
      default:
        borderPath = nil
    }
  }

  public var borderPath: UIBezierPath? {
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

  public var cornerRadii = CGSize(square: 5.0)

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
  public func addViewToContent(view: UIView) { contentView.addSubview(view) }

  /**
  addLayerToContent:

  :param: layer CALayer
  */
  public func addLayerToContent(layer: CALayer) { contentView.layer.addSublayer(layer) }

  /**
  addViewToOverlay:

  :param: view UIView
  */
  public func addViewToOverlay(view: UIView) { overlayView.addSubview(view) }

  /**
  addLayerToOverlay:

  :param: layer CALayer
  */
  public func addLayerToOverlay(layer: CALayer) { overlayView.layer.addSublayer(layer) }

  /**
  addViewToBackdrop:

  :param: view UIView
  */
  public func addViewToBackdrop(view: UIView) { backdropView.addSubview(view) }

  /**
  addLayerToBackdrop:

  :param: layer CALayer
  */
  public func addLayerToBackdrop(layer: CALayer) { backdropView.layer.addSublayer(layer) }

  public var contentInteractionEnabled: Bool {
    get { return contentView.userInteractionEnabled }
    set { contentView.userInteractionEnabled = newValue }
  }

  public var subelementInteractionEnabled: Bool {
    get { return subelementsView.userInteractionEnabled }
    set { subelementsView.userInteractionEnabled = newValue }
  }

  public var contentClipsToBounds: Bool {
    get { return contentView.clipsToBounds }
    set { contentView.clipsToBounds = newValue }
  }

  public var overlayClipsToBounds: Bool {
    get { return overlayView.clipsToBounds }
    set { overlayView.clipsToBounds = newValue }
  }

  public var modeledConstraintsDescription: String { return "\n".join(modeledConstraints.map{$0.description}) }

}

extension RemoteElementView {
  private class InternalView: UIView {

    weak var delegate: RemoteElementView!

    /**
    initWithDelegate:

    :param: delegate RemoteElementView
    */
    convenience init(delegate: RemoteElementView) {
      self.init(frame: delegate.bounds)
      self.delegate = delegate
      initialize()
    }

    /** initialize */
    func initialize() {
      userInteractionEnabled = self is RemoteElementView.SubelementsView
      setTranslatesAutoresizingMaskIntoConstraints(false)
      backgroundColor = UIColor.clearColor()
      clipsToBounds = false
      opaque = false
      contentMode = .Redraw
      autoresizesSubviews = false
    }

  }
}

extension RemoteElementView {
  private class SubelementsView: InternalView {

    /**
    addSubview:

    :param: subview UIView
    */
    override func addSubview(subview: UIView) {
      if let elementView = subview as? RemoteElementView {
        if elementView.model.parentElement == delegate!.model {
          super.addSubview(elementView)
        }
      }
    }

  }
}

extension RemoteElementView {
  private class ContentView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawContentInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

  }
}

extension RemoteElementView {
  private class BackdropView: InternalView {

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawBackdropInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

  }
}

extension RemoteElementView {
  private class OverlayView: InternalView {

    var boundaryColor: UIColor = UIColor.clearColor() { didSet { boundaryOverlay.strokeColor = boundaryColor.CGColor } }

    var showAlignmentIndicators: Bool = false {
      didSet {
        alignmentOverlay.hidden = !showAlignmentIndicators
        renderAlignmentOverlayIfNeeded()
      }
    }
    var showContentBoundary: Bool = false {
      didSet {
        refreshBoundary()
        boundaryOverlay.hidden = !showContentBoundary
      }
    }

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

    var lineWidth: CGFloat = 2.0 { didSet { boundaryOverlay.lineWidth = lineWidth } }

    /** initialize */
    override func initialize() {
      super.initialize()
      layer.addSublayer(boundaryOverlay)
      layer.addSublayer(alignmentOverlay)
    }

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) { delegate?.drawOverlayInContext(UIGraphicsGetCurrentContext(), inRect: rect) }

    /** refreshBoundary */
    func refreshBoundary() { boundaryOverlay.path = boundaryPath }

    var boundaryPath: CGPathRef { return (delegate?.borderPath ?? UIBezierPath(rect: bounds)).CGPath }

    /** renderAlignmentOverlayIfNeeded */
    func renderAlignmentOverlayIfNeeded() {

      if showAlignmentIndicators {

        if let manager = delegate?.model.constraintManager {

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

    }

  }
}
