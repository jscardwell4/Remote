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

  /// Public use properties
  ////////////////////////////////////////////////////////////////////////////////

  var remoteElement: RemoteElement?
  weak var delegate: EditingDelegate?

  /// Flag properties
  ////////////////////////////////////////////////////////////////////////////////

  var testInProgress = false
  var movingSelectedViews = false
  var snapToEnabled = false
  var showSourceBoundary = true
  var popoverActive = false
  var presetsActive = false
  var menuState: MenuState = .Default
  var appliedScale: CGFloat = 1.0
  var originalFrame = CGRectZero
  var currentFrame = CGRectZero
  var longPressPreviousLocation = CGPointZero
  var contentRect = CGRectZero
  var allowableSourceViewYOffset = MSBoundary(lower: 0.0, upper: 0.0)

  /// Bar button items
  ////////////////////////////////////////////////////////////////////////////////

  var singleSelButtons: NSMutableArray?
  var anySelButtons: NSMutableArray?
  var noSelButtons: NSMutableArray?
  var multiSelButtons: NSMutableArray?
  var undoButton: MSBarButtonItem?

  /// Toolbars
  ////////////////////////////////////////////////////////////////////////////////

  weak var currentToolbar: UIToolbar!
  @IBOutlet var topToolbar: UIToolbar!
  @IBOutlet var emptySelectionToolbar: UIToolbar?
  @IBOutlet var nonEmptySelectionToolbar: UIToolbar?
  @IBOutlet var focusSelectionToolbar: UIToolbar?
  var toolbars: NSArray?

  /// Gestures
  ////////////////////////////////////////////////////////////////////////////////

  var oneTouchTapGesture: UITapGestureRecognizer?
  var oneTouchDoubleTapGesture: UITapGestureRecognizer?
  var twoTouchTapGesture: UITapGestureRecognizer?
  var panGesture: UIPanGestureRecognizer?
  var pinchGesture: UIPinchGestureRecognizer?
  var longPressGesture: UILongPressGestureRecognizer?
  var toolbarLongPressGesture: UILongPressGestureRecognizer?
  var multiselectGesture: MSMultiselectGestureRecognizer?
  var anchoredMultiselectGesture: MSMultiselectGestureRecognizer?
  var twoTouchPanGesture: UIPanGestureRecognizer?
  var gestures: NSPointerArray?
  var gestureManager: MSGestureManager?

  /// View-related properties
  ////////////////////////////////////////////////////////////////////////////////

  var focusView: RemoteElementView?
  var sourceView: RemoteElementView!
  var selectedViews: [RemoteElementView] = []
  var sourceViewBoundsLayer: CAShapeLayer!
  var startingOffsets: NSMutableDictionary?
  var mockParentSize = CGSizeZero
  var selectionInProgress: [RemoteElementView] = []
  var deselectionInProgress: [RemoteElementView] = []
  var sourceViewCenterYConstraint: NSLayoutConstraint?
  var mockParentView: UIView?
  var referenceView: UIView?
  var sourceViewBoundsObserver: MSKVOReceptionist?
  var maxSizeCache: [String:CGSize] = [:]
  var minSizeCache: [String:CGSize] = [:]

  /// Other properties
  ////////////////////////////////////////////////////////////////////////////////

  var context: NSManagedObjectContext?
  var changedModelValues: NSDictionary?

  /// Methods
  ////////////////////////////////////////////////////////////////////////////////

  /**
  subelementClass

  :returns: RemoteElementView.Type
  */
  class func subelementClass() -> RemoteElementView.Type { return RemoteElementView.self }

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  class func elementClass() -> RemoteElementView.Type { return RemoteElementView.self }

  // + (REEditingMode)editingModeForElement { return REEditingModeNotEditing; }

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

  /** updateBarButtonItems */
  func updateBarButtonItems() {

  }

  /** updateToolbarDisplayed */
  func updateToolbarDisplayed() {

  }

  /** Updates whether `sourceViewBoundsLayer` is hidden and sets its `path` from `sourceView.frame`. */
  func updateBoundaryLayer() {
    sourceViewBoundsLayer.path = UIBezierPath(rect: sourceView.frame).CGPath
    sourceViewBoundsLayer.hidden = !showSourceBoundary
  }

  /** updateGesturesEnabled */
  func updateGesturesEnabled() {

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

  /// Aligning
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-alignment. */
  func willAlignSelectedViews() {}

  /**
  Sends `alignSubelements:toSibling:attribute:` to the `sourceView` to perform actual alignment

  :param: alignment `NSLayoutAttribute` to use when aligning the `selectedViews` to the `focusView`
  */
  func alignSelectedViews(alignment: NSLayoutAttribute) {}

  /** Override point for subclasses to perform additional work post-alignment. */
  func didAlignSelectedViews() {}

  /// Resizing
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-sizing. */
  func willResizeSelectedViews() {}

  /**
  Sends `resizeSubelements:toSibling:attribute:` to the `sourceView` to perform actual resizing.

  :param: axis `NSLayoutAttribute` specifying whether resizing should involve width or height
  */
  func resizeSelectedViews(axis: NSLayoutAttribute) {}

  /** Override point for subclasses to perform additional work pre-sizing. */
  func didResizeSelectedViews() {}

  /// Scaling
  ////////////////////////////////////////////////////////////////////////////////

  /** Override point for subclasses to perform additional work pre-scaling. */
  func willScaleSelectedViews() {}

  /**
  Performs a sanity check on the scale to be applied and then sends `scaleSubelements:scale:` to the `sourceView`
  to perform actual scaling.

  :param: scale CGFloat The scale to apply to the current selection
  :param: validation (view RemoteElementView
  :param: size CGSize
  :param: max CGSize
  :param: min CGSize) -> Bool

  :returns: CGFloat The actual scale value applied to the current selection
  */
  func scaleSelectedViews(scale: CGFloat,
               validation: (view: RemoteElementView, size: CGSize, max: CGSize, min: CGSize) -> Bool) -> CGFloat
  { return 1.0 }

  /** Override point for subclasses to perform additional work post-scaling. */
  func didScaleSelectedViews() {}

  /// Translating
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

  /// Debugging
  ////////////////////////////////////////////////////////////////////////////////

  /**
  logSourceViewAfter:message:

  :param: delay dispatch_time_t
  :param: message String?
  */
  func logSourceViewAfter(delay: dispatch_time_t, message: String?) {}

  /// UIViewController
  ////////////////////////////////////////////////////////////////////////////////

  /** awakeFromNib */
  override func awakeFromNib() { initializeIVARS() }

  /** initializeIVARS */
  func initializeIVARS() {}

  /** initializeToolbars */
  func initializeToolbars() {}

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {}

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
  viewDidAppear:

  :param: animated Bool
  */
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  /**
  viewDidDisappear:

  :param: animated Bool
  */
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
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
