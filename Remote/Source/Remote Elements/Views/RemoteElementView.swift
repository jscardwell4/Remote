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



  class var MinimumSize: CGSize { return CGSize(square: 44.0) }

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

  /** init */
  override init() { super.init() }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithModel:

  :param: model RemoteElement
  */
  required init(model: RemoteElement) {
    super.init()
    setTranslatesAutoresizingMaskIntoConstraints(false)
    self.model = model
//    self.model.refresh()
    registerForChangeNotification()
    initializeIVARs()
  }

  /**
  objectIsSubelementKind:

  :param: object AnyObject

  :returns: Bool
  */
  func objectIsSubelementKind(object: AnyObject) -> Bool {
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
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /** updateConstraints */
  override func updateConstraints() {
    //TODO: Modify to use model constraint uuids to update only where necessary
    var identifier = createIdentifier(self, ["Internal", "Base"])
    if constraintsWithIdentifier(identifier).count == 0 {
      constrain("|[b]| :: V:|[b]| :: |[c]| :: V:|[c]| :: |[s]| :: V:|[s]| :: |[o]| :: V:|[o]|",
                    views: ["b": backdropView, "c": contentView, "s": subelementsView, "o": overlayView],
               identifier: identifier)
    }

    let modelConstraints: [Constraint] = model.ownedConstraints
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

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  private lazy var subelementsView: SubelementsView = SubelementsView(delegate: self)
  private lazy var contentView: ContentView = ContentView(delegate: self)
  private lazy var backdropView: BackdropView = BackdropView(delegate: self)
  private lazy var overlayView: OverlayView = OverlayView(delegate: self)

  var viewFrames: [String:CGRect] {
    var frames = [model.uuid: frame]
    if parentElementView != nil {
      frames[parentElementView!.model.uuid] = parentElementView!.frame
    }
    for subelementView in subelementViews { frames[subelementView.model.uuid] = subelementView.frame }
    return frames
  }

  var minimumSize: CGSize {

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

  var maximumSize: CGSize {
    var size = superview?.bounds.size ?? CGSize.zeroSize
    if model.constraintManager.proportionLock { size = bounds.size.aspectMappedToSize(size, binding: true) }
    return size
  }

  override var backgroundColor: UIColor? {
    get { return super.backgroundColor ?? model?.backgroundColor }
    set { super.backgroundColor = newValue }
  }

//  override func setNeedsDisplay() {
//    super.setNeedsDisplay()
//    backdropView.setNeedsDisplay()
//    contentView.setNeedsDisplay()
//    subelementsView.setNeedsDisplay()
//    overlayView.setNeedsDisplay()
//  }

  override var bounds: CGRect { didSet { refreshBorderPath() } }

  /**
  subscript:

  :param: key String

  :returns: RemoteElementView?
  */
  override subscript(key: String) -> RemoteElementView? {
    if model.isIdentifiedByString(key) { return self }
    else { return subelementViews.filter{$0.model.isIdentifiedByString(key)}.first }
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
  var modeledConstraints: [RemoteElementViewConstraint] {
    return constraints().filter{$0 is RemoteElementViewConstraint} as [RemoteElementViewConstraint]
  }
  var subelementViews: [RemoteElementView] { return subelementsView.subviews as? [RemoteElementView] ?? [] }

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
    subelementsView.insertSubview(subelementView, atIndex: index)
  }

  /**
  insertSubelementView:belowSubelementView:

  :param: subelementView RemoteElementView
  :param: siblingSubelementView RemoteElementView
  */
  func insertSubelementView(subelementView: RemoteElementView, belowSubelementView siblingSubelementView: RemoteElementView) {
    subelementsView.insertSubview(subelementView, belowSubview: siblingSubelementView)
  }

  var locked: Bool = false {
    didSet {
      apply(subelementViews){$0.resizable = !self.locked; $0.moveable = !self.locked}
    }
  }

  var editingMode: RemoteElement.BaseType = .Undefined {
    didSet {
      apply(subelementViews){$0.editingMode = self.editingMode}
    }
  }

  var isEditing: Bool { return editingMode != .None }

  enum EditingState {
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

  var editingState: EditingState = .None {
    didSet {
      overlayView.showAlignmentIndicators = editingState == .Moving
      overlayView.showContentBoundary = editingState != .None
      overlayView.refreshBoundary()
      overlayView.boundaryColor = editingState.color
      overlayView.layer.setNeedsDisplay()
      overlayView.layer.displayIfNeeded()
    }
  }
  var resizable = false
  var moveable = false
  var shrinkwrap = false
  var appliedScale: CGFloat = 1.0

  /** updateSubelementOrderFromView */
  func updateSubelementOrderFromView() { model.childElements = subelementViews.map{$0.model} }

  /**
  translateSubelements:translation:

  :param: subelementViews NSSet
  :param: translation CGPoint
  */
  func translateSubelements(subelementViews: OrderedSet<RemoteElementView>, translation: CGPoint) {

    model.constraintManager.translateSubelements(subelementViews.map{$0.model},
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
  func scaleSubelement(subelementViews: OrderedSet<RemoteElementView>, scale: CGFloat) {
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
  func alignSubelements(subelementViews: OrderedSet<RemoteElementView>,
              toSibling siblingView: RemoteElementView,
              attribute: NSLayoutAttribute)
  {
    MSLogDebug("model constraints before alignment…\n\(modeledConstraintsDescription)")
    model.constraintManager.alignSubelements(subelementViews.map{$0.model},
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
  func resizeSubelements(subelementViews: OrderedSet<RemoteElementView>,
               toSibling siblingView: RemoteElementView,
               attribute: NSLayoutAttribute)
  {
    model.constraintManager.resizeSubelements(subelementViews.map{$0.model},
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
 func scale(scale: CGFloat) {
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
    registry["constraints"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsUpdateConstraints()
        }
    }
    registry["backgroundColor"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          if let color = receptionist.change[NSKeyValueChangeNewKey] as? UIColor {
            v.backgroundColor = color
          } else {
            v.backgroundColor = nil
          }
        }
    }
    registry["backgroundImage"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsDisplay()
        }
    }
    registry["style"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
        if let v = receptionist.observer as? RemoteElementView {
          v.setNeedsDisplay()
        }
    }
    registry["shape"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
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
      backgroundColor?.setFill()
      borderPath!.fill()
      UIGraphicsPopContext()
    }
    if model.backgroundImage != nil {
      if let image = model.backgroundImage!.image {
        if rect.size <= image.size {
          image.drawInRect(rect)
        } else {
          image.drawAsPatternInRect(rect)
        }
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
    let style = model.style & RemoteElement.Style.GlossStyleMask
    switch style {
      case RemoteElement.Style.GlossStyle1:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: 0.0)
      case RemoteElement.Style.GlossStyle2:
        MSPainter.drawRoundedRectButtonOverlayInContext(ctx, shineColor: nil, frame: rect)
      case RemoteElement.Style.GlossStyle3:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: 0.8)
      case RemoteElement.Style.GlossStyle4:
        MSPainter.drawGlossGradientWithColor(UIColor(white: 1.0, alpha: 0.02), rect: bounds, context: ctx, offset: -0.8)
      default: break
    }
    if model.style & RemoteElement.Style.DrawBorder != nil {
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

  var modeledConstraintsDescription: String { return "\n".join(modeledConstraints.map{$0.description}) }

}

extension RemoteElementView {
  private class InternalView: UIView {

    weak var delegate: RemoteElementView!


    /** init */
    override init() { super.init() }

    /**
    initWithFrame:

    :param: frame CGRect
    */
    override init(frame: CGRect) { super.init(frame: frame) }

    /**
    initWithDelegate:

    :param: delegate RemoteElementView
    */
    init(delegate: RemoteElementView) {
      super.init(frame: delegate.bounds)
      self.delegate = delegate
      userInteractionEnabled = self is RemoteElementView.SubelementsView
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

    /** init */
    override init() { super.init() }

    /**
    initWithFrame:

    :param: frame CGRect
    */
    override init(frame: CGRect) { super.init(frame: frame) }

    /**
    initWithDelegate:

    :param: delegate RemoteElementView
    */
    override init(delegate: RemoteElementView) {
      super.init(delegate: delegate)
      layer.addSublayer(boundaryOverlay)
      layer.addSublayer(alignmentOverlay)
    }

    /**
    init:

    :param: aDecoder NSCoder
    */
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

          if manager[NSLayoutAttribute.Left.rawValue] {

            // Left Bar Drawing
            let rect = CGRect(x: frame.minX + 1.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: -1.1, height: -0.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.Left).rawValue].setFill()
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

          if manager[NSLayoutAttribute.Right.rawValue] {

            // Right Bar Drawing
            let rect = CGRect(x: frame.minX + frame.width - 3.0, y: frame.minY + 3.0, width: 2.0, height: frame.height - 6.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: 1.1, height: -0.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.Right).rawValue].setFill()
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

          if manager[NSLayoutAttribute.Top.rawValue] {

            // Top Bar Drawing
            let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + 1.0, width: frame.width - 8.0, height: 2.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: 0.1, height: -1.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.Top).rawValue].setFill()
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

          if manager[NSLayoutAttribute.Bottom.rawValue] {

            // Bottom Bar Drawing
            let rect = CGRect(x: frame.minX + 4.0, y: frame.minY + frame.height - 3.0, width: frame.width - 8.0, height: 2.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: 0.1, height: 1.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.Bottom).rawValue].setFill()
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

          if manager[NSLayoutAttribute.CenterX.rawValue] {

            // CenterX Bar Drawing
            let rect = CGRect(x: frame.minX + floor((frame.width - 2.0) * 0.5) + 0.5, y: frame.minY + 4.0,
              width: 2.0, height: frame.height - 7.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: 0.1, height: -0.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.CenterX).rawValue].setFill()
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

          if manager[NSLayoutAttribute.CenterY.rawValue] {

            // CenterY Bar Drawing
            let rect = CGRect(x: frame.minX + 3.5, y: frame.minY + floor(frame.height - 2.0) * 0.5 + 0.5,
                              width: frame.width - 8.0, height: 2.0)
            let barPath = UIBezierPath(roundedRect:rect, cornerRadius:cornerRadius)
            let offset = CGSize(width: 0.1, height: -0.1)

            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, outerOffset, outerRadius, gentleHighlight.CGColor)
            colors[manager.dependencyForAttribute(NSLayoutAttribute.CenterY).rawValue].setFill()
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
