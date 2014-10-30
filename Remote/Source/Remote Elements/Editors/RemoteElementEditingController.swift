//
//  RemoteElementEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc protocol EditingDelegate: NSObjectProtocol {
  func editorDidCancel(editor: RemoteElementEditingController)
  func editorDidSave(editor: RemoteElementEditingController)
}

class RemoteElementEditingController: UIViewController {

  enum MenuState: Int { case Default, StackedViews }

  weak var delegate: EditingDelegate?

  /// MARK: Model-related properties
  ////////////////////////////////////////////////////////////////////////////////

  var remoteElement: RemoteElement! {
    didSet {
      if oldValue == nil || (remoteElement != nil && oldValue!.uuid != remoteElement.uuid) {
        context = CoreDataManager.childContextOfType(.MainQueueConcurrencyType, forContext: remoteElement!.managedObjectContext!)
        context.nametag = _stdlib_getDemangledTypeName(self)
        context.performBlockAndWait {
          self.changedModelValues = self.remoteElement!.changedValues()
          self.remoteElement = self.context.existingObjectWithID(self.remoteElement!.objectID, error: nil) as? RemoteElement
        }
      }
    }
  }
  var context: NSManagedObjectContext!
  var changedModelValues: [NSObject:AnyObject]?

  /// MARK: Flag and state properties
  ////////////////////////////////////////////////////////////////////////////////

  var testInProgress = false
  var movingSelectedViews = false
  var snapToEnabled = false
  var showSourceBoundary = true
  var popoverActive = false
  var presetsActive = false
  var menuState: MenuState = .Default

  /// MARK: Geometry
  ////////////////////////////////////////////////////////////////////////////////

  var appliedScale: CGFloat = 1.0
  var originalFrame = CGRectZero
  var currentFrame = CGRectZero
  var longPressPreviousLocation = CGPointZero
  var contentRect = CGRectZero
  var startingPanOffset: CGFloat = 0.0
  var allowableSourceViewYOffset = ClosedInterval<CGFloat>(0, 0)
  var maxSizeCache: [String:CGSize] = [:]
  var minSizeCache: [String:CGSize] = [:]
  var startingOffsets: NSMutableDictionary?
  var mockParentSize = CGSizeZero

  /// MARK: Bar button items
  ////////////////////////////////////////////////////////////////////////////////

  var singleSelButtons: [UIBarButtonItem] = []
  var anySelButtons: [UIBarButtonItem] = []
  var noSelButtons: [UIBarButtonItem] = []
  var multiSelButtons: [UIBarButtonItem] = []
  var undoButton: MSBarButtonItem!

  /// MARK: Toolbars
  ////////////////////////////////////////////////////////////////////////////////

  weak var currentToolbar: UIToolbar! {
    didSet {
      if currentToolbar != nil && oldValue != nil && currentToolbar != oldValue {
        let animations: (Void) -> Void = { self.currentToolbar.hidden = false; oldValue.hidden = true }
        UIView.animateWithDuration(0.25, animations: animations, completion: nil)
      }
    }
  }
  var topToolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(size: CGSize(width: 320, height: 44)))
    toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    return toolbar
  }()
  var emptySelectionToolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    return toolbar
  }()
  var nonEmptySelectionToolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    toolbar.hidden = true
    return toolbar
  }()
  var focusSelectionToolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    toolbar.hidden = true
    return toolbar
  }()
  var toolbars: [UIToolbar] { return [topToolbar, emptySelectionToolbar, nonEmptySelectionToolbar, focusSelectionToolbar] }

  /// MARK: Gestures
  ////////////////////////////////////////////////////////////////////////////////

  weak var longPressGesture: UILongPressGestureRecognizer!
  weak var pinchGesture: UIPinchGestureRecognizer!
  weak var oneTouchDoubleTapGesture: UITapGestureRecognizer!
  weak var multiselectGesture: MSMultiselectGestureRecognizer!
  weak var anchoredMultiselectGesture: MSMultiselectGestureRecognizer!
  weak var twoTouchPanGesture: UIPanGestureRecognizer!
  weak var toolbarLongPressGesture: UILongPressGestureRecognizer!
  // weak var oneTouchTapGesture: UITapGestureRecognizer?
  // weak var twoTouchTapGesture: UITapGestureRecognizer?
  // weak var panGesture: UIPanGestureRecognizer?
  var gestures: NSPointerArray?
  var gestureManager: GestureManager!

  /// MARK: View-related properties
  ////////////////////////////////////////////////////////////////////////////////

  var focusView: RemoteElementView? {
    didSet {
      oldValue?.editingState = .Selected
      focusView?.editingState = .Focus
      updateState()
    }
  }
  var sourceView: RemoteElementView! {
    didSet {
      if oldValue != sourceView {
        if oldValue != nil {
          oldValue.removeFromSuperview()
          mockParentView?.removeFromSuperview()
          mockParentView = nil
        }
        if sourceView != nil {
          sourceView.editingMode = self.dynamicType.editingModeForElement()
          let barHeight = topToolbar.intrinsicContentSize().height
          allowableSourceViewYOffset = ClosedInterval<CGFloat>(-barHeight, barHeight)
          mockParentView = UIView(frame: CGRect(size: mockParentSize))
          sourceViewBoundsObserver = MSKVOReceptionist(
            observer: self,
            forObject: sourceView.layer,
            keyPath: "bounds",
            options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New,
            queue: NSOperationQueue.mainQueue(),
            handler: {
              (receptionist: MSKVOReceptionist!) -> Void in
                if let controller = receptionist.observer as? RemoteElementEditingController {
                  controller.updateBoundaryLayer()
                }
          })
          mockParentView!.addSubview(sourceView)
          if let parentElement = remoteElement.parentElement {
            let parentConstraints = remoteElement.firstItemConstraints.objectsPassingTest {
              (obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                if let constraint = obj as? Constraint {
                  return obj.secondItem == parentElement
                }
                return false
            }
            if let constraints = parentConstraints.allObjects as? [Constraint] {
              for constraint in constraints {
                let view1: AnyObject = sourceView
                let attr1: NSLayoutAttribute = NSLayoutAttribute(rawValue: Int(constraint.firstAttribute))!
                let relation: NSLayoutRelation = NSLayoutRelation(rawValue: Int(constraint.relation))!
                let view2: AnyObject? = mockParentView
                let attr2: NSLayoutAttribute = NSLayoutAttribute(rawValue: Int(constraint.secondAttribute))!
                let multiplier: CGFloat = CGFloat(constraint.multiplier)
                let constant: CGFloat = CGFloat(constraint.constant)
                let c = NSLayoutConstraint(
                  item: view1,
                  attribute: attr1,
                  relatedBy: relation,
                  toItem: view2,
                  attribute: attr2,
                  multiplier: multiplier,
                  constant: constant
                )
                c.priority = constraint.priority
                c.identifier = createIdentifier(self, "Parent")
                mockParentView!.addConstraint(c)
              }
            }
          } else {
            let centerXIdentifier = createIdentifier(self, "CenterX")
            let centerYIdentifier = createIdentifier(self, "CenterY")
            let format = "\n".join("'\(centerXIdentifier)' source.centerX = self.centerX",
                                   "'\(centerYIdentifier)' source.centerY = self.centerY + \(allowableSourceViewYOffset.end)")
            mockParentView!.constrainWithFormat(format, views: ["source": sourceView])
            sourceViewCenterYConstraint = mockParentView!.constraintWithIdentifier(centerYIdentifier)
          }
          view.insertSubview(mockParentView!, belowSubview: topToolbar)
          let format = "\n".join("mock.center = self.center",
                                 "mock.width = \(mockParentSize.width)",
                                 "mock.height = \(mockParentSize.height)")
          view.constrainWithFormat(format, views: ["mock": mockParentView!])
          view.layer.addSublayer(sourceViewBoundsLayer)
        }
      }
    }
  }
  var selectedViews: [RemoteElementView] = []
  var sourceViewBoundsLayer: CAShapeLayer!
  var selectionInProgress: [RemoteElementView] = []
  var deselectionInProgress: [RemoteElementView] = []
  var sourceViewCenterYConstraint: NSLayoutConstraint!
  var mockParentView: UIView?
  var referenceView: UIView?
  var sourceViewBoundsObserver: MSKVOReceptionist?

  /// Methods
  ////////////////////////////////////////////////////////////////////////////////

  /**
  subelementClass

  :returns: RemoteElementView.Type
  */
  class func subelementClass() -> RemoteElementView.Type { return RemoteElementView.self }

  /**
  isSubelementKind:

  :param: obj AnyObject

  :returns: Bool
  */
  class func isSubelementKind(obj: AnyObject) -> Bool { return obj is RemoteElementView }

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  class func elementClass() -> RemoteElementView.Type { return RemoteElementView.self }

  /**
  editingModeForElement

  :returns: REEditingMode
  */
  class func editingModeForElement() -> REEditingMode { return .NotEditing }

  /**
  Convenience method that calls the following additional methods:
  - `updateBarButtonItems`
  - `updateToolbarDisplayed`
  - `updateBoundaryLayer`
  - `updateGesturesEnabled`
  */
  func updateState() {
    updateBarButtonItems()
    updateToolbarDisplayed()
    updateBoundaryLayer()
    updateGesturesEnabled()
  }

  /** Updates whether `sourceViewBoundsLayer` is hidden and sets its `path` from `sourceView.frame`. */
  func updateBoundaryLayer() {
    sourceViewBoundsLayer.path = UIBezierPath(rect: sourceView.frame).CGPath
    sourceViewBoundsLayer.hidden = !showSourceBoundary
  }

  /** updateGesturesEnabled */
  func updateGesturesEnabled() {
    let focused = focusView != nil
    let selection = selectionCount > 0
    longPressGesture.enabled = !focused
    pinchGesture.enabled = selection
    oneTouchDoubleTapGesture.enabled = !movingSelectedViews
    multiselectGesture.enabled = !movingSelectedViews
    anchoredMultiselectGesture.enabled = !movingSelectedViews
  }

  /**
  clearCacheForViews:

  :param: views [RemoteElementView]
  */
  func clearCacheForViews(views: [RemoteElementView]) {
    for identifier in (views.map{$0.uuid}) {
      maxSizeCache.removeValueForKey(identifier)
      minSizeCache.removeValueForKey(identifier)
    }
  }

  /**
  Opens the specified subelement in its Class-level editor.

  :param: subelement The element to edit
  */
  func openSubelementInEditor(subelement: RemoteElement) {}

  /// MARK: Aligning
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-alignment. */
  func willAlignSelectedViews() {}

  /**
  Sends `alignSubelements:toSibling:attribute:` to the `sourceView` to perform actual alignment

  :param: alignment `NSLayoutAttribute` to use when aligning the `selectedViews` to the `focusView`
  */
  func alignSelectedViews(alignment: NSLayoutAttribute) {
    precondition(focusView != nil, "there must be a view to align to")
    willAlignSelectedViews()
    sourceView.alignSubelements(NSSet(array: selectedViews ∖ [focusView!]), toSibling: focusView!, attribute: alignment)
    didAlignSelectedViews()
  }

  /** Override point for subclasses to perform additional work post-alignment. */
  func didAlignSelectedViews() { clearCacheForViews(selectedViews) }

  /// MARK: Resizing
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-sizing. */
  func willResizeSelectedViews() {}

  /**
  Sends `resizeSubelements:toSibling:attribute:` to the `sourceView` to perform actual resizing.

  :param: axis `NSLayoutAttribute` specifying whether resizing should involve width or height
  */
  func resizeSelectedViews(axis: NSLayoutAttribute) {
    precondition(focusView != nil, "there must be a view to resize to")
    willResizeSelectedViews()
    sourceView.resizeSubelements(NSSet(array: selectedViews ∖ [focusView!]), toSibling: focusView!, attribute: axis)
    didResizeSelectedViews()
  }

  /** Override point for subclasses to perform additional work pre-sizing. */
  func didResizeSelectedViews() {}

  /// MARK: Scaling
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-scaling. */
  func willScaleSelectedViews() {}

  /**
  Performs a sanity check on the scale to be applied and then sends `scaleSubelements:scale:` to the `sourceView`
  to perform actual scaling.

  :param: scale CGFloat The scale to apply to the current selection

  :returns: CGFloat The actual scale value applied to the current selection
  */
  func scaleSelectedViews(scale: CGFloat) -> CGFloat {

    let isValid =  {
      (view: RemoteElementView, size: CGSize, inout max: CGSize, inout min: CGSize) -> Bool in
        let frame = view.convertRect(view.frame, toView: nil)
        let cachedMax = self.maxSizeCache[view.uuid]
        let cachedMin = self.minSizeCache[view.uuid]
        if cachedMax != nil && cachedMin != nil {
          max = cachedMax!
          min = cachedMin!
        } else {
          let deltaSize = CGSizeGetDelta(frame.size, view.maximumSize)
          let maximumSize = view.maximumSize
          let maxFrame = CGRect(x: frame.origin.x + deltaSize.width / CGFloat(2),
                                y: frame.origin.y + deltaSize.height / CGFloat(2),
                                width: maximumSize.width,
                                height: maximumSize.height)
          if !CGRectContainsRect(self.contentRect, maxFrame) {
            let intersection = CGRectIntersection(self.contentRect, maxFrame)
            let deltaMin = CGPointGetDeltaABS(frame.origin, intersection.origin)
            let deltaMax = CGPointGetDeltaABS(CGPoint(x: CGRectGetMaxX(frame), y: CGRectGetMaxY(frame)),
                                                CGPoint(x: CGRectGetMaxX(intersection), y: CGRectGetMaxY(intersection)))
            max = CGSize(width: (frame.size.width + Swift.min(deltaMin.x, deltaMax.x) * CGFloat(2.0)),
                         height: (frame.size.height + Swift.min(deltaMin.y, deltaMax.y) * CGFloat(2.0)))
            if view.proportionLock {
              if max.width < max.height {
                max.height = frame.size.height / frame.size.width * max.width
              } else {
                max.width = frame.size.width / frame.size.height * max.height
              }
            }
          } else {
            max = view.maximumSize
          }
          min = view.minimumSize

          self.maxSizeCache[view.uuid] = max
          self.minSizeCache[view.uuid] = min

        }
        return (   size.width <= max.width
                && size.height <= max.height
                && size.width >= min.width
                && size.height >= min.height)
    }

    var scaleRejections: [CGFloat] = []
    for view in selectedViews {
      let scaledSize = CGSizeApplyAffineTransform(view.bounds.size, CGAffineTransformMakeScale(scale, scale))
      var maxSize = CGSizeZero, minSize = CGSizeZero
      if !isValid(view, scaledSize, &maxSize, &minSize) {
        let boundedSize = CGSize(square: (scale > CGFloat(1) ? CGSizeMinAxis(maxSize) : CGSizeMaxAxis(minSize)))
        let validScale = boundedSize.width / view.bounds.size.width
        scaleRejections.append(validScale)
      }
    }

    appliedScale = (scaleRejections.count > 0
                        ? (scale > CGFloat(1) ? minElement(scaleRejections) : maxElement(scaleRejections))
                        : scale)
    willScaleSelectedViews()
    for view in selectedViews { view.scale(appliedScale) }
    didScaleSelectedViews()

    return appliedScale
  }

  /** Override point for subclasses to perform additional work post-scaling. */
  func didScaleSelectedViews() {}

  /// MARK: Translating
  ////////////////////////////////////////////////////////////////////////////////

  /**
  Sanity check for ensuring selected views can only be moved to reasonable locations.

  :param: fromUnion `CGRect` representing the current union of the `frame` properties of the current selection
  :param: toUnion `CGRect` representing the resulting union of the `frame` properties of the current selection when moved

  :returns: Whether the views should be moved
  */
  func shouldTranslateSelectionFrom(fromUnion: CGRect, to toUnion: CGRect) -> Bool {
    return CGRectContainsRect(contentRect, toUnion)
  }

  /**
  Captures the original union frame for the selected views before any translation and acts as an override point for subclasses
  to perform additional work pre-movement.
  */
  func willTranslateSelectedViews() {
    originalFrame = selectedViewsUnionFrameInView(view)
    currentFrame = originalFrame
  }

  /**
  Updates the `frame` property of the selected views to affect the specified translation.

  :param: translation `CGPoint` value representing the x and y axis translations to be performed on the selected views
  */
  func translateSelectedViews(translation: CGPoint) {
    if CGPointEqualToPoint(translation, CGPointZero) { return }
    let transform = CGAffineTransformMakeTranslation(translation.x, translation.y)
    let translatedFrame = CGRectApplyAffineTransform(currentFrame, transform)
    if shouldTranslateSelectionFrom(currentFrame, to: translatedFrame) {
      currentFrame = translatedFrame
      for view in selectedViews { view.frame = CGRectApplyAffineTransform(view.frame, transform) }
    }
  }

  /**
  Sends `translateSublements:translation:` to the `sourceView` to perform model-level translation and acts as an override point
  for subclasses to perform additional work post-movement.
   */
  func didTranslateSelectedViews() {
    clearCacheForViews(selectedViews)
    let translation = CGPointGetDelta(currentFrame.origin, originalFrame.origin)
    sourceView.translateSubelements(NSSet(array: selectedViews), translation: translation)
    (selectedViews as NSArray).setValue(NSNumber(unsignedChar: REEditingState.Selected.rawValue), forKeyPath: "editingState")
    movingSelectedViews = false
    updateState()
  }

  /// MARK: Debugging
  ////////////////////////////////////////////////////////////////////////////////

  /**
  logSourceViewAfter:message:

  :param: delay dispatch_time_t
  :param: message String?
  */
  func logSourceViewAfter(delay: dispatch_time_t, message: String?) {
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
      MSLogDebugTag(@"%@\n%@\n\n%@\n\n%@\n\n%@\n\n%@\n",
                    ClassTagSelectorString,
                    message,
                    [_sourceView constraintsDescription],
                    [_sourceView framesDescription],
                    @"subelements",
                    [[_sourceView.subelementViews
                      valueForKeyPath:@"constraintsDescription"]
                     componentsJoinedByString:@"\n\n"]);
    });
    */
  }

  /// MARK: Initialization
  ////////////////////////////////////////////////////////////////////////////////


  /** attachGestureRecognizers */
  func attachGestureRecognizers() {

    longPressGesture = {
      let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
      gesture.nametag = "longPressGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    pinchGesture = {
      let gesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
      gesture.nametag = "pinchGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    oneTouchDoubleTapGesture = {
      let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
      gesture.numberOfTapsRequired = 2
      gesture.nametag = "oneTouchDoubleTapGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    multiselectGesture = {
      let gesture = MSMultiselectGestureRecognizer(target: self, action: "handleSelection:")
      gesture.requireGestureRecognizerToFail(self.oneTouchDoubleTapGesture)
      gesture.nametag = "multiselectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    anchoredMultiselectGesture = {
      let gesture = MSMultiselectGestureRecognizer(target: self, action: "handleSelection:")
      gesture.numberOfAnchorTouchesRequired = 1
      self.pinchGesture.requireGestureRecognizerToFail(gesture)
      self.multiselectGesture.requireGestureRecognizerToFail(gesture)
      gesture.nametag = "anchoredMultiselectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    twoTouchPanGesture = {
      let gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
      gesture.minimumNumberOfTouches = 2
      gesture.maximumNumberOfTouches = 2
      gesture.requireGestureRecognizerToFail(self.pinchGesture)
      self.multiselectGesture.requireGestureRecognizerToFail(gesture)
      gesture.enabled = false
      gesture.nametag = "twoTouchPanGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    toolbarLongPressGesture = {
      let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
      self.longPressGesture.requireGestureRecognizerToFail(gesture)
      gesture.nametag = "toolbarLongPressGesture"
      self.undoButton?.addGestureRecognizer(gesture)
      return gesture
    }()

    createGestureManager()
  }

  /** createGestureManager */
  func createGestureManager() {
    let shouldBegin: ((UIGestureRecognizer) -> Bool) -> ((UIGestureRecognizer) -> Bool) = { p in {g in p(g)} }
    let shouldReceiveTouch: ((UIGestureRecognizer, UITouch) -> Bool) -> ((UIGestureRecognizer, UITouch) -> Bool) = {
      p in {p($0, $1)}
    }
    let shouldRecognize: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool) -> ((UIGestureRecognizer, UIGestureRecognizer) -> Bool) = {
      p in {p($0, $1)}
    }

    let noPopovers: (Void) -> Bool = { !(self.popoverActive || self.presetsActive) && self.menuState == .Default }
    let noToolbars: (UITouch) -> Bool = { t in self.toolbars.filter{t.view.isDescendantOfView($0)}.count == 0 }
    let notMoving: (Void) -> Bool = { !self.movingSelectedViews }
    let selectableClass: (UITouch) -> Bool = { t in self.dynamicType.isSubelementKind(t.view) }

    let blocks: [UIGestureRecognizer:[GestureManager.ResponseType:Any]] = [

      pinchGesture:
      [ .Begin: shouldBegin{_ in self.selectionCount > 0},
        .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      longPressGesture:
      [ .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t) && selectableClass(t)},
        .RecognizeSimultaneously: shouldRecognize{_, g in g === self.toolbarLongPressGesture} ],

      toolbarLongPressGesture:
      [ .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && t.view.isDescendantOfView(self.topToolbar)},
        .RecognizeSimultaneously: shouldRecognize{_, g in g === self.longPressGesture} ],

      twoTouchPanGesture:
      [ .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      oneTouchDoubleTapGesture:
      [ .Begin: shouldBegin{_ in notMoving() },
        .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      multiselectGesture:
      [ .Begin: shouldBegin{_ in notMoving() },
        .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)},
        .RecognizeSimultaneously: shouldRecognize{_, g in g === self.anchoredMultiselectGesture} ],

      anchoredMultiselectGesture:
      [ .Begin: shouldBegin{_ in notMoving() },
        .ReceiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)},
        .RecognizeSimultaneously: shouldRecognize{_, g in g === self.multiselectGesture} ]
    ]

    gestureManager = GestureManager(gestures: blocks)
  }

  /**
  handleTap:

  :param: gesture UITapGestureRecognizer
  */
  func handleTap(gesture: UITapGestureRecognizer) {
    if gesture.state == .Ended {
      if let tappedView = view.hitTest(gesture.locationInView(view), withEvent: nil) as? RemoteElementView{
        if self.dynamicType.isSubelementKind(tappedView) {
          if selectedViews ∌ tappedView { selectView(tappedView)}
          focusView = (focusView === tappedView ? nil : tappedView)
        }
      }
    }
  }

  /**
  handleLongPress:

  :param: gesture UILongPressGestureRecognizer
  */
  func handleLongPress(gesture: UILongPressGestureRecognizer) {
    if gesture === longPressGesture {
      switch gesture.state {
        case .Began:
          if let pressedView = view.hitTest(gesture.locationInView(view), withEvent: nil) as? RemoteElementView {
            if self.dynamicType.isSubelementKind(pressedView) {
              if selectedViews ∌ pressedView { selectView(pressedView) }
              apply(selectedViews){$0.editingState = .Moving}
              movingSelectedViews = true
              updateState()
              longPressPreviousLocation = gesture.locationInView(nil)
              willTranslateSelectedViews()
            }
          }
        case .Changed:
          let currentLocation = gesture.locationInView(nil)
          let translation = CGPointGetDelta(currentLocation, longPressPreviousLocation)
          longPressPreviousLocation = currentLocation
          translateSelectedViews(translation)
        case .Cancelled, .Failed, .Ended:
          didTranslateSelectedViews()
        default: break
      }
    } else if gesture === toolbarLongPressGesture {
      switch gesture.state {
        case .Began:
          undoButton.button.setTitle(UIFont.fontAwesomeIconForName("repeat"), forState: .Normal)
          undoButton.button.selected = true
        case .Changed:
          if !undoButton.button.pointInside(gesture.locationInView(undoButton.button), withEvent: nil) {
            undoButton.button.selected = false
            gesture.enabled = false
          }
        case .Ended:
          redo(nil)
        default:
          gesture.enabled = true
          undoButton.button.selected = false
          undoButton.button.setTitle(UIFont.fontAwesomeIconForName("undo"), forState: .Normal)
      }
    }
  }

  /**
  handlePinch:

  :param: gesture UIPinchGestureRecognizer
  */
  func handlePinch(gesture: UIPinchGestureRecognizer) {
    if gesture === pinchGesture {
      switch gesture.state {
        case .Began:
          willScaleSelectedViews()
        case .Changed:
          scaleSelectedViews(gesture.scale)
        case .Cancelled, .Failed, .Ended:
          didScaleSelectedViews()
        default: break
      }
    }
  }

  /**
  handlePan:

  :param: gesture UIPanGestureRecognizer
  */
  func handlePan(gesture: UIPanGestureRecognizer) {
    if gesture === twoTouchPanGesture {
      switch gesture.state {
        case .Began:
          startingPanOffset = sourceViewCenterYConstraint.constant
        case .Changed:
          let translation = gesture.translationInView(view)
          let adjustedOffset = startingPanOffset + translation.y
          let isInBounds = allowableSourceViewYOffset.contains(adjustedOffset)
          let newOffset = (isInBounds
                           ? adjustedOffset
                           : (adjustedOffset < allowableSourceViewYOffset.start
                              ? allowableSourceViewYOffset.start
                              : allowableSourceViewYOffset.end))
          if sourceViewCenterYConstraint.constant != newOffset {
            UIView.animateWithDuration(0.1,
                                 delay: 0.0,
                               options: .BeginFromCurrentState,
                            animations: {self.sourceViewCenterYConstraint.constant = newOffset; self.view.layoutIfNeeded() },
                            completion: nil)
          }
        default: break
      }
    }
  }

  // - (IBAction)toggleSelected:(UIButton *)sender { sender.selected = !sender.selected; }

  /**
  handleSelection:

  :param: gesture MSMultiselectGestureRecognizer
  */
  func handleSelection(gesture: MSMultiselectGestureRecognizer) {
   if gesture.state == .Ended {
    let touchLocations = OrderedSet(((gesture.touchLocationsInView(sourceView).allObjects as [NSValue]).map{$0.CGPointValue()}))
    var touchedSubelementViews = OrderedSet((gesture.touchedSubviewsInView(sourceView, ofKind: self.dynamicType.subelementClass()).allObjects as [RemoteElementView]))

     if touchedSubelementViews.count > 0 {

      let stackedViews = OrderedSet((sourceView.subelementViews as [RemoteElementView]).filter {
        v in contains(touchLocations, { v.pointInside(v.convertPoint($0, fromView: self.sourceView), withEvent: nil)})
        })

      if stackedViews.count > touchedSubelementViews.count { displayStackedViewDialogForViews(stackedViews) }

      if gesture === multiselectGesture { selectViews(touchedSubelementViews.arrayValue) }
      else if gesture === anchoredMultiselectGesture { deselectViews(touchedSubelementViews.arrayValue) }


     }

     else if selectedViews.count > 0 { deselectAll() }

   }

  }

  /**
  displayStackedViewDialogForViews:

  :param: stackedViews NSSet
  */
  func displayStackedViewDialogForViews(stackedViews: OrderedSet<RemoteElementView>) {
    /*
    MSLogDebug(@"%@ select stacked views to include: (%@)",
               ClassTagSelectorString,
               [[[stackedViews allObjects] valueForKey:@"name"]
                  componentsJoinedByString:@", "]);

    _flags.menuState = REEditingMenuStateStackedViews;

    MenuController.menuItems = [[stackedViews allObjects]
                                mapped:
                                ^UIMenuItem *(RemoteElementView * obj, NSUInteger idx) {
      SEL action = NSSelectorFromString($(@"menuAction%@:",
                                          obj.uuid));
      return MenuItem(obj.name, action);
    }];

    [MenuController setTargetRect:[self.view.window
                                   convertRect:[UIView unionFrameForViews:[stackedViews allObjects]]
                                      fromView:_sourceView]
                           inView:self.view];
    MenuController.arrowDirection = UIMenuControllerArrowDefault;
    [MenuController update];
    MenuController.menuVisible = YES;
    */
  }

  /** viewDidLoad */
  override func viewDidLoad() {
    super.viewDidLoad()

    initializeToolbars()
    attachGestureRecognizers()

    sourceViewBoundsLayer = CAShapeLayer()
    sourceViewBoundsLayer.fillColor = UIColor.clearColor().CGColor
    sourceViewBoundsLayer.lineCap = kCALineCapRound
    sourceViewBoundsLayer.lineDashPattern = [1, 1]
    sourceViewBoundsLayer.lineJoin = kCALineJoinRound
    sourceViewBoundsLayer.lineWidth = 1.0
    sourceViewBoundsLayer.strokeColor = UIColor.whiteColor().CGColor
    sourceViewBoundsLayer.hidden = true

    if CGRectIsEmpty(contentRect) {
      referenceView = view
      contentRect = view.frame
      contentRect.origin.y = topToolbar.bounds.size.height
      contentRect.size.height -= topToolbar.bounds.size.height + currentToolbar.bounds.size.height
    }

    if remoteElement != nil { sourceView = self.dynamicType.elementClass()(model: remoteElement!) }
  }

  /** didReceiveMemoryWarning */
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /** viewDidLayoutSubviews */
  override func viewDidLayoutSubviews() { updateBoundaryLayer() }

  /**
  canBecomeFirstResponder

  :returns: Bool
  */
  override func canBecomeFirstResponder() -> Bool { return true }

  /** registerForNotifications */
  func registerForNotifications() {
    NSNotificationCenter.defaultCenter().addObserverForName(UIMenuControllerDidHideMenuNotification,
      object: UIMenuController.sharedMenuController(),
      queue: NSOperationQueue.mainQueue(),
      usingBlock: {[unowned self](note: NSNotification!) -> Void in self.menuState = .Default })
  }

  /** Removes controller from notification center */
  deinit { NSNotificationCenter.defaultCenter().removeObserver(self) }

  /**
  forwardingTargetForSelector:

  :param: selector Selector

  :returns: AnyObject?
  */
  override func forwardingTargetForSelector(selector: Selector) -> AnyObject? {
    if MSSelectorInProtocol(selector, UIGestureRecognizerDelegate.self, false, true) { return gestureManager }
    else { return super.forwardingTargetForSelector(selector) }
  }

  // NSMethodSignature is unavailable
  // override func methodSignatureForSelector(selector: Selector) -> NSMethodSignature? {
  //   if selector.hasPrefix("menuAction_") { return methodSignatureForSelector("menuAction:") }
  //   else { return super.methodSignatureForSelector(selector) }
  // }

  /**
  respondsToSelector:

  :param: selector Selector

  :returns: Bool
  */
  override func respondsToSelector(selector: Selector) -> Bool {
    if String(_sel: selector).hasPrefix("menuAction_")
      || MSSelectorInProtocol(selector, UIGestureRecognizerDelegate.self, false, true)
    {
      return true
    } else { return super.respondsToSelector(selector) }
  }

  // Pretty sure NSInvocation is unavailable as well
  // - (void)forwardInvocation:(NSInvocation *)invocation {
  //   SEL        selector = [invocation selector];
  //   NSString * action   = SelectorString(selector);

  //   if ([action hasPrefix:@"menuAction_"]) {
  //     [invocation setSelector:@selector(menuAction:)];
  //     NSString * identifier = [action stringByReplacingRegEx:@"(?:menuAction)|(?::)"
  //                                                 withString:@""];
  //     RemoteElementView * view = _sourceView[identifier];
  //     assert(view);
  //     [invocation setSelector:@selector(menuAction:)];
  //     [invocation setTarget:self];
  //     [invocation setArgument:&view atIndex:2];
  //     [invocation invoke];
  //   } else
  //     [super forwardInvocation:invocation];
  // }

  /**
  canPerformAction:withSender:

  :param: action Selector
  :param: sender AnyObject?

  :returns: Bool
  */
  override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
    return menuState == .StackedViews
             ? String(_sel: action).hasPrefix("menuAction_")
             : super.canPerformAction(action, withSender: sender)
  }

  /**
  viewDidAppear:

  :param: animated Bool
  */
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
    registerForNotifications()
    let sourceHeight = sourceView.bounds.size.height
    let viewHeight = view.bounds.size.height
    let boundarySize = length(allowableSourceViewYOffset)
    twoTouchPanGesture.enabled = sourceHeight >= (viewHeight - boundarySize)
    updateState()
  }

  /**
  viewDidDisappear:

  :param: animated Bool
  */
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    resignFirstResponder()
    NSNotificationCenter.defaultCenter()
      .removeObserver(self, name: UIMenuControllerDidHideMenuNotification, object: UIMenuController.sharedMenuController())
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}

/// MARK: Selection
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /**
  selectedViewsUnionFrameInView:

  :param: view UIView

  :returns: CGRect
  */
  func selectedViewsUnionFrameInView(view: UIView) -> CGRect {
    return view.convertRect(selectedViewsUnionFrameInSourceView(), fromView: sourceView)
  }

  /**
  selectedViewsUnionFrameInSourceView

  :returns: CGRect
  */
  func selectedViewsUnionFrameInSourceView() -> CGRect {
    var unionRect = CGRectZero
    for view in selectedViews { unionRect = CGRectUnion(unionRect, view.frame) }
    return unionRect
  }

  var selectionCount: Int { return selectedViews.count }

  /**
  selectView:

  :param: view RemoteElementView
  */
  func selectView(view: RemoteElementView) { selectViews([view]) }

  /**
  selectViews:

  :param: views [RemoteElementView]
  */
  func selectViews(views: [RemoteElementView]) {
    for v in (views ∖ selectedViews) {
      v.editingState = .Selected
      sourceView.bringSubelementViewToFront(v)
    }
    selectedViews ∪= views
    updateState()
  }

  /**
  deselectView:

  :param: view RemoteElementView
  */
  func deselectView(view: RemoteElementView) { deselectViews([view]) }

  /**
  deselectViews:

  :param: views [RemoteElementView]
  */
  func deselectViews(views: [RemoteElementView]) {
    for v in (views ∩ selectedViews) { if v === focusView { focusView = nil } else { v.editingState = .NotEditing } }
    selectedViews ∖= views
    updateState()
  }

  /** deselectAll */
  func deselectAll() { focusView = nil; deselectViews(selectedViews) }

  /**
  toggleSelectionForViews:

  :param: views [RemoteElementView]
  */
  func toggleSelectionForViews(views: [RemoteElementView]) {
    selectViews(views ∖ selectedViews)
    deselectViews(views ∩ selectedViews)
  }

}

/// MARK: IBActions
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** addSubelement */
  @IBAction func addSubelement() {
    let presetVC = REPresetCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(scrollDirection: .Horizontal))
    presetVC.context = context
    addChildViewController(presetVC)
    let presetView = presetVC.collectionView
    presetView.constrainWithFormat("'height' self.height = 0")
    view.addSubview(presetView)
    view.constrainWithFormat("|[preset]| :: V:[preset]|", views: ["preset": presetView])
    view.layoutIfNeeded()
    UIView.transitionWithView(view, duration: 0.25, options: .CurveEaseInOut, animations: {
      if let c = presetView.constraintWithIdentifier("height") {
        c.constant = 200.0
        presetView.layoutIfNeeded()
      }
      },
      completion: {_ in self.presetsActive = true})
  }

  /** presets */
  @IBAction func presets() {}

  /** editBackground */
  @IBAction func editBackground() {
    let bgEditor = StoryboardProxy.backgroundEditingViewController()
    bgEditor.subject = remoteElement
    presentViewController(bgEditor, animated: true, completion: nil)
  }

  /** editSubelement */
  @IBAction func editSubelement() { if let model = selectedViews.first?.model { openSubelementInEditor(model) } }

  /** duplicate */
  @IBAction func duplicate() {}

  /** copyStyle */
  @IBAction func copyStyle() {}

  /** pasteStyle */
  @IBAction func pasteStyle() {}

  /** toggleBounds */
  @IBAction func toggleBounds() {
    showSourceBoundary = !showSourceBoundary
    sourceViewBoundsLayer.hidden = !showSourceBoundary
  }

  /** alignVerticalCenters */
  @IBAction func alignVerticalCenters() {
    willAlignSelectedViews()
    alignSelectedViews(.CenterY)
    didAlignSelectedViews()
  }

  /** alignHorizontalCenters */
  @IBAction func alignHorizontalCenters() {
    willAlignSelectedViews()
    alignSelectedViews(.CenterX)
    didAlignSelectedViews()
  }

  /** alignTopEdges */
  @IBAction func alignTopEdges() {
    willAlignSelectedViews()
    alignSelectedViews(.Top)
    didAlignSelectedViews()
  }

  /** alignBottomEdges */
  @IBAction func alignBottomEdges() {
    willAlignSelectedViews()
    alignSelectedViews(.Bottom)
    didAlignSelectedViews()
  }

  /** alignLeftEdges */
  @IBAction func alignLeftEdges() {
    willAlignSelectedViews()
    alignSelectedViews(.Left)
    didAlignSelectedViews()
  }

  /** alignRightEdges */
  @IBAction func alignRightEdges() {
    willAlignSelectedViews()
    alignSelectedViews(.Right)
    didAlignSelectedViews()
  }

  /** resizeFromFocusView */
  @IBAction func resizeFromFocusView() {
    willResizeSelectedViews()
    resizeSelectedViews(.Width)
    resizeSelectedViews(.Height)
    didResizeSelectedViews()
  }

  /** resizeHorizontallyFromFocusView */
  @IBAction func resizeHorizontallyFromFocusView() {
    willResizeSelectedViews()
    resizeSelectedViews(.Width)
    didResizeSelectedViews()
  }

  /** resizeVerticallyFromFocusView */
  @IBAction func resizeVerticallyFromFocusView() {
    willResizeSelectedViews()
    resizeSelectedViews(.Width)
    didResizeSelectedViews()
  }

  /** saveAction */
  func saveAction() {
    var success = false
    context.performBlockAndWait {
      var error: NSError?
      success = self.context.save(&error)
      MSHandleError(error)
    }
    if success {
      if delegate != nil { delegate!.editorDidSave(self) }
      else { MSRemoteAppController.sharedAppController().dismissViewController(self, completion: nil) }
    }
  }

  /** resetAction */
  func resetAction() { context.performBlockAndWait { self.context.rollback() } }

  /** cancelAction */
  func cancelAction() {
    context.performBlockAndWait { self.context.rollback() }
    if delegate != nil { delegate!.editorDidCancel(self) }
    else { MSRemoteAppController.sharedAppController().dismissViewController(self, completion: nil) }
  }

}

/// MARK: UIResponderStandardEditActions
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /**
  undo:

  :param: sender AnyObject?
  */
  func undo(sender: AnyObject?) { context.performBlockAndWait { self.context.undo() } }

  /**
  redo:

  :param: sender AnyObject?
  */
  func redo(sender: AnyObject?) { context.performBlockAndWait { self.context.redo() } }

  /**
  copy:

  :param: sender AnyObject?
  */
  override func copy(sender: AnyObject?) {}

  /**
  cut:

  :param: sender AnyObject?
  */
  override func cut(sender: AnyObject?) {}

  /**
  delete:

  :param: sender AnyObject?
  */
  override func delete(sender: AnyObject?) {
    let elementsToDelete = selectedViews.map{$0.model}
    apply(selectedViews){$0.removeFromSuperview()}
    selectedViews.removeAll()
    focusView = nil
    context.performBlockAndWait {
      self.context.deleteObjects(NSSet(array: elementsToDelete))
      self.context.processPendingChanges()
    }
    sourceView.setNeedsUpdateConstraints()
    sourceView.updateConstraintsIfNeeded()
  }

  /**
  paste:

  :param: sender AnyObject?
  */
  override func paste(sender: AnyObject?) {}

  /**
  select:

  :param: sender AnyObject?
  */
  override func select(sender: AnyObject?) {}

  /**
  selectAll:

  :param: sender AnyObject?
  */
  override func selectAll(sender: AnyObject?) {}

  /**
  toggleBoldface:

  :param: sender AnyObject?
  */
  override func toggleBoldface(sender: AnyObject?) {}

  /**
  toggleItalics:

  :param: sender AnyObject?
  */
  override func toggleItalics(sender: AnyObject?) {}

  /**
  toggleUnderline:

  :param: sender AnyObject?
  */
  override func toggleUnderline(sender: AnyObject?) {}

}


/// MARK: Toolbars
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** initializeToolbars */
  func initializeToolbars() {
    view.addSubview(topToolbar)
    view.addSubview(emptySelectionToolbar)
    view.addSubview(nonEmptySelectionToolbar)
    view.addSubview(focusSelectionToolbar)
    let format = "\n".join("|[top]|",
                           "|[empty]|",
                           "|[nonempty]|",
                           "|[focus]|",
                           "V:|[top]",
                           "V:[empty]|",
                           "V:[nonempty]|",
                           "V:[focus]|")
    let views = ["top":      topToolbar,
                 "empty":    emptySelectionToolbar,
                 "nonempty": nonEmptySelectionToolbar,
                 "focus":    focusSelectionToolbar]
    view.constrainWithFormat(format, views: views)

    populateTopToolbar()
    populateEmptySelectionToolbar()
    populateNonEmptySelectionToolbar()
    populateFocusSelectionToolbar()
    currentToolbar = emptySelectionToolbar
  }

  /** populateTopToolbar */
  func populateTopToolbar() {
    undoButton = ViewDecorator.fontAwesomeBarButtonItemWithName("undo", target: self, selector: "undo:")
    let cancelButton = ViewDecorator.fontAwesomeBarButtonItemWithName("remove", target: self, selector: "cancelAction")
    let saveButton = ViewDecorator.fontAwesomeBarButtonItemWithName("save", target: self, selector: "saveAction")
    let flexibleSpace = UIBarButtonItem.flexibleSpace()
    topToolbar.items = [cancelButton, flexibleSpace, undoButton, flexibleSpace, saveButton]
    anySelButtons += [undoButton, saveButton]
  }

  /** populateEmptySelectionToolbar */
  func populateEmptySelectionToolbar() {
    let plusButton = ViewDecorator.fontAwesomeBarButtonItemWithName("plus", target: self, selector: "addSubelement")
    let editButton = ViewDecorator.fontAwesomeBarButtonItemWithName("picture", target: self, selector: "editBackground")
    let boundsButton = ViewDecorator.fontAwesomeBarButtonItemWithName("bounds", target: self, selector: "toggleBounds")
    let presetsButton = ViewDecorator.fontAwesomeBarButtonItemWithName("hdd", target: self, selector: "presets")
    let flexibleSpace = UIBarButtonItem.flexibleSpace()
    emptySelectionToolbar.items = join(flexibleSpace, [plusButton, editButton, boundsButton, presetsButton])
    anySelButtons += [editButton, boundsButton, presetsButton]
  }

  /** populateNonEmptySelectionToolbar */
  func populateNonEmptySelectionToolbar() {
    let editButton = ViewDecorator.fontAwesomeBarButtonItemWithName("edit", target: self, selector: "editSubelement")
    let trashButton = ViewDecorator.fontAwesomeBarButtonItemWithName("trash", target: self, selector: "delete")
    let duplicateButton = ViewDecorator.fontAwesomeBarButtonItemWithName("th-large", target: self, selector: "duplicate")
    let copyButton = ViewDecorator.fontAwesomeBarButtonItemWithName("copy", target: self, selector: "copyStyle")
    let pasteButton = ViewDecorator.fontAwesomeBarButtonItemWithName("paste", target: self, selector: "pasteStyle")
    let flexibleSpace = UIBarButtonItem.flexibleSpace()
    nonEmptySelectionToolbar.items = join(flexibleSpace, [editButton, trashButton, duplicateButton, copyButton, pasteButton])
    anySelButtons += [duplicateButton, pasteButton]
    singleSelButtons += [editButton, copyButton]
  }

  /** populateFocusSelectionToolbar */
  func populateFocusSelectionToolbar() {
    let alignNames = ["align-bottom-edges",
                      "align-top-edges",
                      "align-left-edges",
                      "align-right-edges",
                      "align-center-y",
                      "align-center-x"]
    let alignTitles: [NSAttributedString] = alignNames.map{ViewDecorator.fontAwesomeTitleWithName($0, size: 48.0)}
    let alignSelectors: [Selector] = ["alignBottomEdges:",
                                      "alignTopEdges",
                                      "alignLeftEdges",
                                      "alignRightEdges",
                                      "alignVerticalCenters",
                                      "alignHorizontalCenters"]
    let align = MSPopupBarButton(title: UIFont.fontAwesomeIconForName("align-edges"), style: .Plain, target: nil, action: nil)
    let textAttributes = [NSFontAttributeName: UIFont(awesomeFontWithSize:32.0)]
    align.setTitleTextAttributes(textAttributes, forState: .Normal)
    align.setTitleTextAttributes(textAttributes, forState: .Highlighted)
    align.delegate = self
    for i in 0..<alignTitles.count {
      align.addItemWithAttributedTitle(alignTitles[i], target: self, action: alignSelectors[i])
    }
    let resizeNames = ["align-horizontal-size", "align-vertical-size", "align-size-exact"]
    let resizeTitles: [NSAttributedString] = resizeNames.map{ViewDecorator.fontAwesomeTitleWithName($0, size: 48.0)}
    let resizeSelectors: [Selector] = ["resizeHorizontallyFromFocusView:",
                                       "resizeVerticallyFromFocusView:",
                                       "resizeFromFocusView:"]
    let resize = MSPopupBarButton(title: UIFont.fontAwesomeIconForName("align-size"), style: .Plain, target: nil, action: nil)
    resize.setTitleTextAttributes(textAttributes, forState: .Normal)
    resize.setTitleTextAttributes(textAttributes, forState: .Highlighted)
    resize.delegate = self
    for i in 0..<resizeTitles.count {
      resize.addItemWithAttributedTitle(resizeTitles[i], target: self, action: resizeSelectors[i])
    }
    let flexibleSpace = UIBarButtonItem.flexibleSpace()
    focusSelectionToolbar.items = [flexibleSpace, align, flexibleSpace, resize, flexibleSpace]
    multiSelButtons += [align, resize]
  }

  /** updateToolbarDisplayed */
  func updateToolbarDisplayed() {
    if selectionCount > 0 { currentToolbar = focusView != nil ? focusSelectionToolbar : nonEmptySelectionToolbar }
    else { currentToolbar = emptySelectionToolbar }
  }

  /** updateBarButtonItems */
  func updateBarButtonItems() {
    if movingSelectedViews { apply(singleSelButtons + anySelButtons + multiSelButtons){$0.enabled = false}}
    else { apply(anySelButtons){$0.enabled = true} }
    let multipleSelections = selectionCount > 1
    apply(singleSelButtons){$0.enabled = !multipleSelections}
    apply(multiSelButtons){$0.enabled = multipleSelections}
  }

}

/// MARK: MSPopupBarButtonDelegate
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController: MSPopupBarButtonDelegate {

  /**
  popupBarButtonDidShowPopover:

  :param: popupBarButton MSPopupBarButton
  */
  func popupBarButtonDidShowPopover(popupBarButton: MSPopupBarButton) { popoverActive = true}

  /**
  popupBarButtonDidHidePopover:

  :param: popupBarButton MSPopupBarButton
  */
  func popupBarButtonDidHidePopover(popupBarButton: MSPopupBarButton) { popoverActive = false}

}

/// MARK: EditingDelegate
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController: EditingDelegate {

  /**
  editorDidCancel:

  :param: editor RemoteElementEditingController
  */
  func editorDidCancel(editor: RemoteElementEditingController) { dismissViewControllerAnimated(true, completion: nil) }

  /**
  editorDidSave:

  :param: editor RemoteElementEditingController
  */
  func editorDidSave(editor: RemoteElementEditingController) { dismissViewControllerAnimated(true, completion: nil) }

}

extension RemoteElementEditingController: UIGestureRecognizerDelegate {

}
