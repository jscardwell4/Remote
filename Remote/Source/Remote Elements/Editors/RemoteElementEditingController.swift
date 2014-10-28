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

protocol EditingDelegate: class {
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
      if let element = remoteElement {
        context = CoreDataManager.childContextOfType(.MainQueueConcurrencyType, forContext: element.managedObjectContext!)
        context.nametag = _stdlib_getDemangledTypeName(self)
        context.performBlockAndWait {
          self.changedModelValues = element.changedValues()
          self.remoteElement = self.context.existingObjectWithID(element.objectID, error: nil) as? RemoteElement
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
  var allowableSourceViewYOffset = MSBoundary(lower: 0.0, upper: 0.0)
  var maxSizeCache: [String:CGSize] = [:]
  var minSizeCache: [String:CGSize] = [:]
  var startingOffsets: NSMutableDictionary?
  var mockParentSize = CGSizeZero

  /// MARK: Bar button items
  ////////////////////////////////////////////////////////////////////////////////

  var singleSelButtons: NSMutableArray?
  var anySelButtons: NSMutableArray?
  var noSelButtons: NSMutableArray?
  var multiSelButtons: NSMutableArray?
  var undoButton: MSBarButtonItem?

  /// MARK: Toolbars
  ////////////////////////////////////////////////////////////////////////////////

  weak var currentToolbar: UIToolbar! {
    didSet {
      /*
        if (currentToolbar && _currentToolbar && _currentToolbar != currentToolbar) {
          currentToolbar.frame = _currentToolbar.frame;
          [UIView animateWithDuration:0.25
                           animations:^{
                             _currentToolbar.hidden = YES;
                             currentToolbar.hidden  = NO;
                           }

                           completion:^(BOOL finished) {
                             if (finished) _currentToolbar = currentToolbar;
                           }];
      */
    }
  }
  @IBOutlet var topToolbar: UIToolbar!
  @IBOutlet var emptySelectionToolbar: UIToolbar?
  @IBOutlet var nonEmptySelectionToolbar: UIToolbar?
  @IBOutlet var focusSelectionToolbar: UIToolbar?
  var toolbars: [UIToolbar]!

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
  var gestureManager: MSGestureManager?

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
          allowableSourceViewYOffset = MSBoundary(lower: -barHeight, upper: barHeight)
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
                                   "'\(centerYIdentifier)' source.centerY = self.centerY + \(allowableSourceViewYOffset.upper)")
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
  var sourceViewCenterYConstraint: NSLayoutConstraint?
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

  /** awakeFromNib */
  override func awakeFromNib() { initializeIVARS() }

  /** initializeIVARS */
  func initializeIVARS() {}

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {

    longPressGesture = {
      let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
      gesture.delegate = self
      gesture.nametag = "longPressGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    pinchGesture = {
      let gesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
      gesture.delegate = self
      gesture.nametag = "pinchGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    oneTouchDoubleTapGesture = {
      let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
      gesture.delegate = self
      gesture.numberOfTapsRequired = 2
      gesture.nametag = "oneTouchDoubleTapGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    multiselectGesture = {
      let gesture = MSMultiselectGestureRecognizer(target: self, action: "handleSelection:")
      gesture.delegate = self
      gesture.requireGestureRecognizerToFail(self.oneTouchDoubleTapGesture)
      gesture.nametag = "multiselectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    anchoredMultiselectGesture = {
      let gesture = MSMultiselectGestureRecognizer(target: self, action: "handleSelection:")
      gesture.delegate = self
      gesture.numberOfAnchorTouchesRequired = 1
      self.pinchGesture.requireGestureRecognizerToFail(gesture)
      self.multiselectGesture.requireGestureRecognizerToFail(gesture)
      gesture.nametag = "anchoredMultiselectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    twoTouchPanGesture = {
      let gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
      gesture.delegate = self
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
      gesture.delegate = self
      self.longPressGesture.requireGestureRecognizerToFail(gesture)
      gesture.nametag = "toolbarLongPressGesture"
      self.undoButton?.addGestureRecognizer(gesture)
      return gesture
    }()
  }

  /** createGestureManager */
  func createGestureManager() {
    let gestures = [pinchGesture, longPressGesture, toolbarLongPressGesture, twoTouchPanGesture, oneTouchDoubleTapGesture,
                    multiselectGesture, anchoredMultiselectGesture]
    let shouldBegin: ((UIGestureRecognizer) -> Bool) -> MSGestureManagerBlock = { p in {g, _ in p(g)} }
    let shouldReceiveTouch: ((UIGestureRecognizer, UITouch) -> Bool) -> MSGestureManagerBlock = { p in {p($0, $1 as UITouch)} }
    let shouldRecognize: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool) -> MSGestureManagerBlock = {
      p in {p($0, $1 as UIGestureRecognizer)}
    }

    let noPopovers: (Void) -> Bool = { !(self.popoverActive || self.presetsActive) && self.menuState == .Default }
    let noToolbars: (UITouch) -> Bool = { t in self.toolbars.filter{t.view.isDescendantOfView($0)}.count == 0 }
    let notMoving: (Void) -> Bool = { !self.movingSelectedViews }
    let selectableClass: (UITouch) -> Bool = { t in self.dynamicType.isSubelementKind(t.view) }

    let begin = MSGestureManagerResponseType.Begin.rawValue
    let receiveTouch = MSGestureManagerResponseType.ReceiveTouch.rawValue
    let recognizeSimultaneously = MSGestureManagerResponseType.RecognizeSimultaneously.rawValue

    let gestureBlocks: [[NSNumber:MSGestureManagerBlock]] = [

      // pinch
      [ begin: shouldBegin{_ in self.selectionCount > 0},
        receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      // long press
      [ receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t) && selectableClass(t)},
        recognizeSimultaneously: shouldRecognize{_, g in g === self.toolbarLongPressGesture} ],

      // toolbar long press
      [ receiveTouch: shouldReceiveTouch{_, t in noPopovers() && t.view.isDescendantOfView(self.topToolbar)},
        recognizeSimultaneously: shouldRecognize{_, g in g === self.longPressGesture} ],

      // two touch pan
      [ receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      // one touch double tap
      [ begin: shouldBegin{_ in notMoving() },
        receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)} ],

      // multi-select
      [ begin: shouldBegin{_ in notMoving() },
        receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)},
        recognizeSimultaneously: shouldRecognize{_, g in g === self.anchoredMultiselectGesture} ],

      // anchored multi-select
      [ begin: shouldBegin{_ in notMoving() },
        receiveTouch: shouldReceiveTouch{_, t in noPopovers() && noToolbars(t)},
        recognizeSimultaneously: shouldRecognize{_, g in g === self.multiselectGesture} ]
    ]

    gestureManager = MSGestureManager(forGestures: gestures, blocks: gestureBlocks)
  }

  /**
  handleTap:

  :param: gesture UITapGestureRecognizer
  */
  func handleTap(gesture: UITapGestureRecognizer) {
    if gesture.state == .Ended {
      if let tappedView = view.hitTest(gesture.locationInView(view), withEvent: nil) {
        if self.dynamicType.isSubelementKind(tappedView) {
          if selectedViews ∌ (tappedView as RemoteElementView) { selectView(tappedView as RemoteElementView)}
          focusView = (focusView === tappedView ? nil : (tappedView as RemoteElementView))
        }
      }
    }
  }

  /**
  handleLongPress:

  :param: gesture UILongPressGestureRecognizer
  */
  func handleLongPress(gesture: UILongPressGestureRecognizer) {

  }

  /**
  handlePinch:

  :param: gesture UIPinchGestureRecognizer
  */
  func handlePinch(gesture: UIPinchGestureRecognizer) {

  }

  /**
  handlePan:

  :param: gesture UIPanGestureRecognizer
  */
  func handlePan(gesture: UIPanGestureRecognizer) {

  }

  /**
  handleSelection:

  :param: gesture MSMultiselectGestureRecognizer
  */
  func handleSelection(gesture: MSMultiselectGestureRecognizer) {

  }

  /**
  displayStackedViewDialogForViews:

  :param: stackedViews NSSet
  */
  func displayStackedViewDialogForViews(stackedViews: NSSet) {

  }

  /** viewDidLoad */
  override func viewDidLoad() {
    super.viewDidLoad()

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
    let boundarySize = CGFloat(MSBoundarySizeOfBoundary(allowableSourceViewYOffset))
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
  func selectView(view: RemoteElementView) {

  }

  /**
  selectViews:

  :param: views [RemoteElementView]
  */
  func selectViews(views: [RemoteElementView]) {

  }

  /**
  deselectView:

  :param: view RemoteElementView
  */
  func deselectView(view: RemoteElementView) {

  }

  /**
  deselectViews:

  :param: views [RemoteElementView]
  */
  func deselectViews(views: [RemoteElementView]) {

  }

  /** deselectAll */
  func deselectAll() {

  }

}

/// MARK: IBActions
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** addSubelement */
  @IBAction func addSubelement() {

  }

  /** presets */
  @IBAction func presets() {

  }

  /** editBackground */
  @IBAction func editBackground() {

  }

  /** editSubelement */
  @IBAction func editSubelement() {

  }

  /** duplicateSubelements */
  @IBAction func duplicateSubelements() {

  }

  /** copyStyle */
  @IBAction func copyStyle() {

  }

  /** pasteStyle */
  @IBAction func pasteStyle() {

  }

  /** toggleBoundsVisibility */
  @IBAction func toggleBoundsVisibility() {

  }

  /** alignVerticalCenters */
  @IBAction func alignVerticalCenters() {

  }

  /** alignHorizontalCenters */
  @IBAction func alignHorizontalCenters() {

  }

  /** alignTopEdges */
  @IBAction func alignTopEdges() {

  }

  /** alignBottomEdges */
  @IBAction func alignBottomEdges() {

  }

  /** alignLeftEdges */
  @IBAction func alignLeftEdges() {

  }

  /** alignRightEdges */
  @IBAction func alignRightEdges() {

  }

  /** resizeFromFocusView */
  @IBAction func resizeFromFocusView() {

  }

  /** resizeHorizontallyFromFocusView */
  @IBAction func resizeHorizontallyFromFocusView() {

  }

  /** resizeVerticallyFromFocusView */
  @IBAction func resizeVerticallyFromFocusView() {

  }

  /** saveAction */
  @IBAction func saveAction() {

  }

  /** resetAction */
  @IBAction func resetAction() {

  }

  /** cancelAction */
  @IBAction func cancelAction() {

  }

}

/// MARK: UIResponderStandardEditActions
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /**
  undo:

  :param: sender AnyObject?
  */
  func undo(sender: AnyObject?) {

  }

  /**
  redo:

  :param: sender AnyObject?
  */
  func redo(sender: AnyObject?) {

  }

  /**
  copy:

  :param: sender AnyObject?
  */
  override func copy(sender: AnyObject?) {

  }

  /**
  cut:

  :param: sender AnyObject?
  */
  override func cut(sender: AnyObject?) {

  }

  /**
  delete:

  :param: sender AnyObject?
  */
  override func delete(sender: AnyObject?) {

  }

  /**
  paste:

  :param: sender AnyObject?
  */
  override func paste(sender: AnyObject?) {

  }

  /**
  select:

  :param: sender AnyObject?
  */
  override func select(sender: AnyObject?) {

  }

  /**
  selectAll:

  :param: sender AnyObject?
  */
  override func selectAll(sender: AnyObject?) {

  }

  /**
  toggleBoldface:

  :param: sender AnyObject?
  */
  override func toggleBoldface(sender: AnyObject?) {

  }

  /**
  toggleItalics:

  :param: sender AnyObject?
  */
  override func toggleItalics(sender: AnyObject?) {

  }

  /**
  toggleUnderline:

  :param: sender AnyObject?
  */
  override func toggleUnderline(sender: AnyObject?) {

  }

}


/// MARK: Toolbars
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** initializeToolbars */
  func initializeToolbars() {

  }

  /** populateTopToolbar */
  func populateTopToolbar() {

  }

  /** populateEmptySelectionToolbar */
  func populateEmptySelectionToolbar() {

  }

  /** populateNonEmptySelectionToolbar */
  func populateNonEmptySelectionToolbar() {

  }

  /** populateFocusSelectionToolbar */
  func populateFocusSelectionToolbar() {

  }

  /** updateToolbarDisplayed */
  func updateToolbarDisplayed() {

  }

  /** updateBarButtonItems */
  func updateBarButtonItems() {

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
