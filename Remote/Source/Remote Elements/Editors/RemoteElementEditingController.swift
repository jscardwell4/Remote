//
//  RemoteElementEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import MoonKit

@objc protocol EditingDelegate: NSObjectProtocol {
  func editorDidCancel(editor: RemoteElementEditingController)
  func editorDidSave(editor: RemoteElementEditingController)
}

extension UIGestureRecognizerState: Printable {
  public var description: String {
    switch self {
      case .Began:     return "Began"
      case .Possible:  return "Possible"
      case .Changed:   return "Changed"
      case .Ended:     return "Ended"
      case .Cancelled: return "Cancelled"
      case .Failed:    return "Failed"
    }
  }
}

extension RemoteElement: EditableBackground {}

class RemoteElementEditingController: UIViewController {

  enum MenuState: Int { case Default, StackedViews }

  weak var delegate: EditingDelegate?

  /// MARK: Model-related properties
  ////////////////////////////////////////////////////////////////////////////////

  private(set) var remoteElement: RemoteElement!
  let editingTransitioningDelegate = RemoteElementEditingTransitioningDelegate()
  private(set) weak var presentedSubelementView: RemoteElementView? {
    didSet { if presentedSubelementView != nil { deselectView(presentedSubelementView!) } }
  }
  private(set) var context: NSManagedObjectContext!
  private(set) var changedModelValues: [NSObject:AnyObject]!

  /// MARK: Flag and state properties
  ////////////////////////////////////////////////////////////////////////////////

  var movingSelectedViews: Bool = false {
    didSet {
      let editingState: RemoteElementView.EditingState = movingSelectedViews ? .Moving : .Selected
      apply(selectedViews){$0.editingState = editingState}
      updateState()
    }
  }
  var popoverActive = false
  var presetsActive = false
  var menuState: MenuState = .Default

  /// MARK: Geometry
  ////////////////////////////////////////////////////////////////////////////////

  var appliedScale: CGFloat = 1.0
  var contentRect = CGRect.zeroRect
  var startingPanOffset: CGFloat = 0.0
  let allowableSourceViewYOffset = ClosedInterval<CGFloat>(-44, 44)
  var maxSizeCache: [String:CGSize] = [:]
  var minSizeCache: [String:CGSize] = [:]

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

  var topToolbar: UIToolbar!
  var emptySelectionToolbar: UIToolbar!
  var nonEmptySelectionToolbar: UIToolbar!
  var focusSelectionToolbar: UIToolbar!

  var toolbars: [UIToolbar] { return [topToolbar, emptySelectionToolbar, nonEmptySelectionToolbar, focusSelectionToolbar] }

  /// MARK: Gestures
  ////////////////////////////////////////////////////////////////////////////////

  weak var longPressGesture: LongPressGesture!
  weak var pinchGesture: UIPinchGestureRecognizer!
  weak var oneTouchDoubleTapGesture: UITapGestureRecognizer!
  weak var selectGesture: TouchTrackingGesture!
  weak var anchoredSelectGesture: TouchTrackingGesture!
  weak var twoTouchPanGesture: PanGesture!
  weak var toolbarLongPressGesture: LongPressGesture!
  // weak var oneTouchTapGesture: UITapGestureRecognizer?
  // weak var twoTouchTapGesture: UITapGestureRecognizer?
  // weak var panGesture: UIPanGestureRecognizer?
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

  var sourceView: RemoteElementView!
  var sourceViewCenterYConstraint: NSLayoutConstraint!
  weak var sourceViewWidthConstraint: NSLayoutConstraint?
  weak var sourceViewHeightConstraint: NSLayoutConstraint?
  var sourceViewSize: CGSize? {
    didSet {
      if sourceViewSize == nil {
        if let c = sourceViewWidthConstraint {
          sourceView.removeConstraint(c)
          sourceViewWidthConstraint = nil
        }
        if let c = sourceViewHeightConstraint {
          sourceView.removeConstraint(c)
          sourceViewHeightConstraint = nil
        }
      }
      // TODO: Handle updating this value for dynamic subelement movement
    }
  }
  var selectedViews: OrderedSet<RemoteElementView> = []

  /// Methods
  ////////////////////////////////////////////////////////////////////////////////

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  class func elementClass() -> RemoteElementView.Type { return RemoteElementView.self }

  /**
  Convenience method that calls the following additional methods:
  - `updateBarButtonItems`
  - `updateToolbarDisplayed`
  - `updateGesturesEnabled`
  */
  func updateState() { updateBarButtonItems(); updateToolbarDisplayed(); updateGesturesEnabled() }

  /**
  clearCacheForViews:

  :param: views [RemoteElementView]
  */
  func clearCacheForViews(views: OrderedSet<RemoteElementView>) {
    for identifier in (views.map{$0.model.uuid}) {
      maxSizeCache.removeValueForKey(identifier)
      minSizeCache.removeValueForKey(identifier)
    }
  }


  /// MARK: Initialization
  ////////////////////////////////////////////////////////////////////////////////

  /**
  editingControllerForElement:

  :param: element RemoteElement

  :returns: RemoteElementEditingController
  */
  class func editingControllerForElement(element: RemoteElement) -> RemoteElementEditingController {
    return editingControllerForElement(element, size: nil)
  }

  /**
  editingControllerForElement:

  :param: element RemoteElement

  :returns: RemoteElementEditingController
  */
  class func editingControllerForElement(element: RemoteElement, size: CGSize? = nil) -> RemoteElementEditingController {
    if let remote = element as? Remote {
      return RemoteEditingController(element: remote, size: size)
    } else if let buttonGroup = element as? ButtonGroup {
      return ButtonGroupEditingController(element: buttonGroup, size: size)
    } else if let button = element as? Button {
      return ButtonEditingController(element: button, size: size)
    } else {
      return RemoteElementEditingController(element: element, size: nil)
    }
  }

  /**
  initWithElement:

  :param: element RemoteElement
  */
  convenience init(element: RemoteElement) { self.init(element: element, size: nil) }

  /**
  initWithElement:size:

  :param: element RemoteElement
  :param: size CGSize? = nil
  */
  required init(element: RemoteElement, size: CGSize? = nil) {
    super.init()
    sourceViewSize = size
    context = CoreDataManager.childContextOfType(.MainQueueConcurrencyType, forContext: element.managedObjectContext!)
    context.performBlockAndWait {
      self.changedModelValues = element.changedValues()
      self.remoteElement = self.context.existingObjectWithID(element.objectID, error: nil) as RemoteElement
    }
    modalPresentationStyle = .Custom
    LogManager.setLogLevel(.Debug)
  }

  /** init */
  override init() { super.init() }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


  /** loadView */
  override func loadView() {

    // Create the root view
    view = UIView(frame: UIScreen.mainScreen().bounds)

    // Create the source view
    sourceView = RemoteElementView.viewWithModel(remoteElement) //self.dynamicType.elementClass()(model: remoteElement)
    if let size = sourceViewSize {
      let (widthConstraint, heightConstraint) = sourceView.constrainSize(size)
      sourceViewWidthConstraint = widthConstraint
      sourceViewHeightConstraint = heightConstraint
    }
    sourceView.editingMode = sourceView.model.elementType
    view.addSubview(sourceView)

    // Create the top toolbar
    topToolbar =  UIToolbar(frame: CGRect(size: CGSize(width: 320, height: 44)))
    topToolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    topToolbar.translucent = true
    undoButton = ViewDecorator.fontAwesomeBarButtonItemWithName("undo", target: self, selector: "resetAction")
    let cancelButton = ViewDecorator.fontAwesomeBarButtonItemWithName("remove", target: self, selector: "cancelAction")
    let saveButton = ViewDecorator.fontAwesomeBarButtonItemWithName("save", target: self, selector: "saveAction")
    let flexibleSpace = UIBarButtonItem.flexibleSpace()
    topToolbar.items = [cancelButton, flexibleSpace, undoButton, flexibleSpace, saveButton]
    anySelButtons += [undoButton, saveButton]
    view.addSubview(topToolbar)

    // Create the empty selection toolbar
    emptySelectionToolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    emptySelectionToolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    emptySelectionToolbar.translucent = true
    let plusButton = ViewDecorator.fontAwesomeBarButtonItemWithName("plus", target: self, selector: "addSubelement")
    let editButton = ViewDecorator.fontAwesomeBarButtonItemWithName("picture", target: self, selector: "editBackground")
    let boundsButton = ViewDecorator.fontAwesomeBarButtonItemWithName("bounds", target: self, selector: "toggleBounds")
    let presetsButton = ViewDecorator.fontAwesomeBarButtonItemWithName("hdd", target: self, selector: "presets")
    emptySelectionToolbar.items = join(flexibleSpace, [plusButton, editButton, boundsButton, presetsButton])
    anySelButtons += [editButton, boundsButton, presetsButton]
    view.addSubview(emptySelectionToolbar)

    // Create the non-empty selection toolbar
    nonEmptySelectionToolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    nonEmptySelectionToolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    nonEmptySelectionToolbar.translucent = true
    nonEmptySelectionToolbar.hidden = true
    let editSubelementButton = ViewDecorator.fontAwesomeBarButtonItemWithName("edit", target: self, selector: "editSubelement")
    let trashButton = ViewDecorator.fontAwesomeBarButtonItemWithName("trash", target: self, selector: "delete:")
    let duplicateButton = ViewDecorator.fontAwesomeBarButtonItemWithName("th-large", target: self, selector: "duplicate")
    let copyButton = ViewDecorator.fontAwesomeBarButtonItemWithName("copy", target: self, selector: "copyStyle")
    let pasteButton = ViewDecorator.fontAwesomeBarButtonItemWithName("paste", target: self, selector: "pasteStyle")
    nonEmptySelectionToolbar.items =
      join(flexibleSpace, [editSubelementButton, trashButton, duplicateButton, copyButton, pasteButton])
    anySelButtons += [duplicateButton, pasteButton]
    singleSelButtons += [editSubelementButton, copyButton]
    view.addSubview(nonEmptySelectionToolbar)

    // Create the focus selection toolbar
    focusSelectionToolbar = UIToolbar(frame: CGRect(x: 0, y: 436, width: 320, height: 44))
    focusSelectionToolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
    focusSelectionToolbar.translucent = true
    focusSelectionToolbar.hidden = true
    let alignNames = ["align-bottom-edges",
                      "align-top-edges",
                      "align-left-edges",
                      "align-right-edges",
                      "align-center-y",
                      "align-center-x"]
    let alignTitles: [NSAttributedString] = alignNames.map{ViewDecorator.fontAwesomeTitleWithName($0, size: 48.0)}
    let alignSelectors: [Selector] = ["alignBottomEdges",
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
    let resizeSelectors: [Selector] = ["resizeHorizontallyFromFocusView",
                                       "resizeVerticallyFromFocusView",
                                       "resizeFromFocusView"]
    let resize = MSPopupBarButton(title: UIFont.fontAwesomeIconForName("align-size"), style: .Plain, target: nil, action: nil)
    resize.setTitleTextAttributes(textAttributes, forState: .Normal)
    resize.setTitleTextAttributes(textAttributes, forState: .Highlighted)
    resize.delegate = self
    for i in 0..<resizeTitles.count {
      resize.addItemWithAttributedTitle(resizeTitles[i], target: self, action: resizeSelectors[i])
    }
    focusSelectionToolbar.items = [flexibleSpace, align, flexibleSpace, resize, flexibleSpace]
    multiSelButtons += [align, resize]
    view.addSubview(focusSelectionToolbar)

    // Add some constraints
    let format = "\n".join("|[top]|",
                           "|[empty]|",
                           "|[nonempty]|",
                           "|[focus]|",
                           "V:|[top]",
                           "V:[empty]|",
                           "V:[nonempty]|",
                           "V:[focus]|",
                           "source.center = self.center")

    let views = ["top":      topToolbar,
                 "empty":    emptySelectionToolbar,
                 "nonempty": nonEmptySelectionToolbar,
                 "focus":    focusSelectionToolbar,
                 "source":   sourceView]

    view.constrain(format, views: views)

    // Keep a refrence to the source view center y constraint
    let predicate = NSPredicate(format: "firstItem == %@" +
                                        "AND secondItem == %@ " +
                                        "AND firstAttribute == \(NSLayoutAttribute.CenterY.rawValue)" +
                                        "AND secondAttribute == \(NSLayoutAttribute.CenterY.rawValue)" +
                                        "AND relation == \(NSLayoutRelation.Equal.rawValue)", sourceView, view)
    sourceViewCenterYConstraint = view.constraintMatching(predicate)


    // Set the initial current toolbar value
    currentToolbar = emptySelectionToolbar

  }

  /** viewDidLoad */
  override func viewDidLoad() {
    super.viewDidLoad()
    attachGestureRecognizers()
    contentRect = view.frame.rectByInsetting(dx: 0.0, dy: topToolbar.bounds.height)
  }

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
    updateState()
    MSLogDebug(view.framesDescription())
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

}

/// MARK: - Selecting subelements
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /**
  selectView:

  :param: view RemoteElementView
  */
  func selectView(view: RemoteElementView) { selectViews(OrderedSet([view])) }

  /**
  selectViews:

  :param: views [RemoteElementView]
  */
  func selectViews(views: OrderedSet<RemoteElementView>) {
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
  func deselectViews(views: OrderedSet<RemoteElementView>) {
    for v in (views ∩ selectedViews) { if v === focusView { focusView = nil } else { v.editingState = .None } }
    selectedViews ∖= views
    updateState()
  }

  /** deselectAll */
  func deselectAll() { focusView = nil; deselectViews(selectedViews) }

  /**
  toggleSelectionForViews:

  :param: views [RemoteElementView]
  */
  func toggleSelectionForViews(views: OrderedSet<RemoteElementView>) {
    selectViews(views ∖ selectedViews)
    deselectViews(views ∩ selectedViews)
  }

  /** toggleBounds */
  func toggleBounds() {  }

  /**
  displayStackedViewDialogForViews:

  :param: stackedViews NSSet
  */
  func displayStackedViewDialogForViews(stackedViews: OrderedSet<RemoteElementView>) {
     println(__FUNCTION__)
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

}

/// MARK: - Exit actions
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

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

/// MARK: - Aligning subelements
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** alignVerticalCenters */
  func alignVerticalCenters() { willAlignSelectedViews(); alignSelectedViews(.CenterY); didAlignSelectedViews() }

  /** alignHorizontalCenters */
  func alignHorizontalCenters() { willAlignSelectedViews(); alignSelectedViews(.CenterX); didAlignSelectedViews() }

  /** alignTopEdges */
  func alignTopEdges() { willAlignSelectedViews(); alignSelectedViews(.Top); didAlignSelectedViews() }

  /** alignBottomEdges */
  func alignBottomEdges() { willAlignSelectedViews(); alignSelectedViews(.Bottom); didAlignSelectedViews() }

  /** alignLeftEdges */
  func alignLeftEdges() { willAlignSelectedViews(); alignSelectedViews(.Left); didAlignSelectedViews() }

  /** alignRightEdges */
  func alignRightEdges() { willAlignSelectedViews(); alignSelectedViews(.Right); didAlignSelectedViews() }

  /** Override point for subclasses to perform additional work pre-alignment. */
  func willAlignSelectedViews() {}

  /**
  Sends `alignSubelements:toSibling:attribute:` to the `sourceView` to perform actual alignment

  :param: alignment `NSLayoutAttribute` to use when aligning the `selectedViews` to the `focusView`
  */
  func alignSelectedViews(alignment: NSLayoutAttribute) {
    precondition(focusView != nil, "there must be a view to align to")
    willAlignSelectedViews()
    sourceView.alignSubelements(selectedViews ∖ [focusView!], toSibling: focusView!, attribute: alignment)
    didAlignSelectedViews()
  }

  /** Override point for subclasses to perform additional work post-alignment. */
  func didAlignSelectedViews() { clearCacheForViews(selectedViews) }

}

/// MARK: - Resizing subelements
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** resizeFromFocusView */
  func resizeFromFocusView() {
    willResizeSelectedViews()
    resizeSelectedViews(.Width)
    resizeSelectedViews(.Height)
    didResizeSelectedViews()
  }

  /** resizeHorizontallyFromFocusView */
  func resizeHorizontallyFromFocusView() { willResizeSelectedViews(); resizeSelectedViews(.Width); didResizeSelectedViews() }

  /** resizeVerticallyFromFocusView */
  func resizeVerticallyFromFocusView() { willResizeSelectedViews(); resizeSelectedViews(.Width); didResizeSelectedViews() }

  /** Override point for subclasses to perform additional work pre-sizing. */
  func willResizeSelectedViews() {}

  /**
  Sends `resizeSubelements:toSibling:attribute:` to the `sourceView` to perform actual resizing.

  :param: axis `NSLayoutAttribute` specifying whether resizing should involve width or height
  */
  func resizeSelectedViews(axis: NSLayoutAttribute) {
    precondition(focusView != nil, "there must be a view to resize to")
    willResizeSelectedViews()
    sourceView.resizeSubelements(selectedViews ∖ [focusView!], toSibling: focusView!, attribute: axis)
    didResizeSelectedViews()
  }

  /** Override point for subclasses to perform additional work pre-sizing. */
  func didResizeSelectedViews() {}

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
        let cachedMax = self.maxSizeCache[view.model.uuid]
        let cachedMin = self.minSizeCache[view.model.uuid]
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
          if !self.contentRect.contains(maxFrame) {
            let intersection = self.contentRect.rectByIntersecting(maxFrame)
            let deltaMin = CGPointGetDeltaABS(frame.origin, intersection.origin)
            let deltaMax = CGPointGetDeltaABS(CGPoint(x: frame.maxX, y: frame.maxY),
                                                CGPoint(x: intersection.maxX, y: intersection.maxY))
            max = CGSize(width: (frame.size.width + Swift.min(deltaMin.x, deltaMax.x) * CGFloat(2.0)),
                         height: (frame.size.height + Swift.min(deltaMin.y, deltaMax.y) * CGFloat(2.0)))
            if view.model.constraintManager.proportionLock {
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

          self.maxSizeCache[view.model.uuid] = max
          self.minSizeCache[view.model.uuid] = min

        }
        return (   size.width <= max.width
                && size.height <= max.height
                && size.width >= min.width
                && size.height >= min.height)
    }

    var scaleRejections: [CGFloat] = []
    for view in selectedViews {
      let scaledSize = view.bounds.size.sizeByApplyingTransform(CGAffineTransform(sx: scale, sy: scale))
      var maxSize = CGSize.zeroSize, minSize = CGSize.zeroSize
      if !isValid(view, scaledSize, &maxSize, &minSize) {
        let boundedSize = CGSize(square: (scale > CGFloat(1) ? maxSize.minAxis : minSize.maxAxis))
        let validScale = boundedSize.width / view.bounds.width
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

}

/// MARK: - Gesture-related methods
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** updateGesturesEnabled */
  func updateGesturesEnabled() {
    longPressGesture.enabled = focusView == nil
    pinchGesture.enabled = selectedViews.count > 0
    oneTouchDoubleTapGesture.enabled = !movingSelectedViews
    selectGesture.enabled = !movingSelectedViews
    anchoredSelectGesture.enabled = !movingSelectedViews
    twoTouchPanGesture.enabled = sourceView.bounds.height >= (view.bounds.height - length(allowableSourceViewYOffset))
  }

  /** attachGestureRecognizers */
  func attachGestureRecognizers() {

    // create the long press gesture recognizer
    longPressGesture = { [unowned self] in
      var previousLocation = CGPoint.nullPoint
      var appliedTranslation = CGPoint.zeroPoint
      var reverseTranslation = CGAffineTransform.identityTransform
      let longPress = LongPressGesture(handler: {
        [unowned self] gesture -> Void in

        let pressGesture = gesture as LongPressGesture

        switch pressGesture.state {
          case .Began:
            if let pressedView = self.touchedSubelementViewForGesture(pressGesture) {
              if pressGesture.pressRecognized {
                if self.selectedViews ∌ pressedView { self.selectView(pressedView) }
                previousLocation = pressGesture.locationInView(nil)
                appliedTranslation = CGPoint.zeroPoint
                self.movingSelectedViews = true
                MSLogDebug("press recognized: \n\tpreviousLocation: \(previousLocation)\n\tmoving? \(self.movingSelectedViews)")
                self.willTranslateSelectedViews()
              }
            }

          case .Changed:
            if self.movingSelectedViews {
              let currentLocation = pressGesture.locationInView(nil)
              let translation = currentLocation - previousLocation
              var didApplyTranslation = false
              var transform = CGAffineTransform.identityTransform
              if translation != CGPoint.zeroPoint && !translation.isNull {
                transform = CGAffineTransform(translation: translation)
                let fromUnion = reduce(self.selectedViews, CGRect.nullRect){$0 ∪ $1.frame}
                let fromUnionInWindow = self.sourceView.convertRect(fromUnion, toView: nil)
                let toUnion = fromUnion.rectByApplyingTransform(transform)
                let toUnionInWindow = self.sourceView.convertRect(toUnion, toView: nil)
                let shouldTranslate = self.shouldTranslateSelectionFrom(fromUnionInWindow, to: toUnionInWindow)
                if shouldTranslate {
                  let animation = {() -> Void in apply(self.selectedViews){$0.frame.transform(transform)} }
                  let options: UIViewAnimationOptions = .BeginFromCurrentState
                  UIView.animateWithDuration(0.1, delay: 0.0, options: options, animations: animation, completion: nil)
                  didApplyTranslation = true
                }

                MSLogDebug("\n\t".join("press changed:",
                                       "currentLocation: \(currentLocation)",
                                       "translation: \(translation)",
                                       "applied? \(didApplyTranslation)"))
                if didApplyTranslation {
                  appliedTranslation += translation
                  reverseTranslation += transform.inverted
                  previousLocation = currentLocation
                }
              }
            }

          case .Cancelled:
            if self.movingSelectedViews {
              self.movingSelectedViews = false
              if !reverseTranslation.isIdentity {
                  let animation = {() -> Void in apply(self.selectedViews){$0.frame.transform(reverseTranslation)} }
                  UIView.animateWithDuration(0.1, delay: 0.0, options: nil, animations: animation, completion: nil)
              }
            }
            fallthrough

          case .Ended:
            if self.movingSelectedViews {
              self.movingSelectedViews = false
              if appliedTranslation != CGPoint.zeroPoint {
                self.sourceView.translateSubelements(self.selectedViews, translation: appliedTranslation)
              }
              self.didTranslateSelectedViews()
            }
            fallthrough

          case .Failed:
            previousLocation = CGPoint.nullPoint
            appliedTranslation = CGPoint.zeroPoint
            reverseTranslation = CGAffineTransform.identityTransform
            assert(!self.movingSelectedViews)
          default: break
        }
      })
      longPress.nametag = "longPress"
      self.view.addGestureRecognizer(longPress)
      return longPress
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

    selectGesture = {
      var previousState: UIGestureRecognizerState = .Possible
      let gesture = TouchTrackingGesture(handler: {
        [unowned self] gesture -> Void in
          let trackingGesture = gesture as TouchTrackingGesture
          MSLogDebug("state: \(trackingGesture.state)")
          switch trackingGesture.state {
            case .Ended:
              if previousState != .Ended {
                let touchedSubelementViews = OrderedSet(trackingGesture.touchedSubviewsInView(self.sourceView, includeView: {
                  self.sourceView.objectIsSubelementKind($0)
                }).array as [RemoteElementView])
                if touchedSubelementViews.count > 0 { self.selectViews(touchedSubelementViews) }
                else { self.deselectAll() }
              }
            default: break
          }
          previousState = trackingGesture.state
        })
      gesture.requireGestureRecognizerToFail(self.oneTouchDoubleTapGesture)
      gesture.requireGestureRecognizerToFail(self.longPressGesture)
      gesture.nametag = "selectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    anchoredSelectGesture = {
      let gesture = TouchTrackingGesture(handler: {
        [unowned self] gesture -> Void in
          let trackingGesture = gesture as TouchTrackingGesture
          switch trackingGesture.state {
            case .Ended:
              let touchedSubelementViews = OrderedSet(trackingGesture.touchedSubviewsInView(self.sourceView, includeView: {
                self.sourceView.objectIsSubelementKind($0)
              }).array as [RemoteElementView])
              if touchedSubelementViews.count > 0 { self.deselectViews(touchedSubelementViews) }
            default: break
          }
        })
      gesture.numberOfAnchoringTouches = 1
      self.pinchGesture.requireGestureRecognizerToFail(gesture)
      self.selectGesture.requireGestureRecognizerToFail(gesture)
      gesture.requireGestureRecognizerToFail(self.longPressGesture)
      gesture.nametag = "anchoredSelectGesture"
      self.view.addGestureRecognizer(gesture)
      return gesture
    }()

    twoTouchPanGesture = { [unowned self] in

      var startingPanOffset: CGFloat = 0.0

      let panGesture = PanGesture(handler: {
        [unowned self] gesture -> Void in

        let pan = gesture as PanGesture
        switch pan.state {
          case .Began: startingPanOffset = self.sourceViewCenterYConstraint.constant
          case .Changed:
            let adjustedOffset = startingPanOffset + pan.translationInView(view: self.view).y
            let isInBounds = self.allowableSourceViewYOffset.contains(adjustedOffset)
            let newOffset = (isInBounds
                             ? adjustedOffset
                             : (adjustedOffset < self.allowableSourceViewYOffset.start
                                ? self.allowableSourceViewYOffset.start
                                : self.allowableSourceViewYOffset.end))
            if self.sourceViewCenterYConstraint.constant != newOffset {
              UIView.animateWithDuration(0.1,
                                   delay: 0.0,
                                 options: .BeginFromCurrentState,
                              animations: { self.sourceViewCenterYConstraint.constant = newOffset; self.view.layoutIfNeeded() },
                              completion: nil)
            }
          default: break
        }
      })
      panGesture.minimumNumberOfTouches = 2
      panGesture.maximumNumberOfTouches = 2
      panGesture.requireGestureRecognizerToFail(self.pinchGesture)
      self.selectGesture.requireGestureRecognizerToFail(panGesture)
      panGesture.enabled = false
      panGesture.nametag = "twoTouchPanGesture"
      self.view.addGestureRecognizer(panGesture)
      return panGesture
      }()

    // twoTouchPanGesture = {
    //   let gesture = PanGesture(handler: {[unowned self] gesture in self.handlePan(gesture as PanGesture)})
    //   gesture.minimumNumberOfTouches = 2
    //   gesture.maximumNumberOfTouches = 2
    //   gesture.requireGestureRecognizerToFail(self.pinchGesture)
    //   self.selectGesture.requireGestureRecognizerToFail(gesture)
    //   gesture.enabled = false
    //   gesture.nametag = "twoTouchPanGesture"
    //   self.view.addGestureRecognizer(gesture)
    //   return gesture
    // }();

    // create long press gesture for undo button
    toolbarLongPressGesture = { [unowned self] in

      let longPress = LongPressGesture(handler: {
        [unowned self] gesture -> Void in

          let pressGesture = gesture as LongPressGesture
          switch pressGesture.state {
            case .Began:
              if pressGesture.pressRecognized {
                self.undoButton.button.setTitle(UIFont.fontAwesomeIconForName("repeat"), forState: .Normal)
                self.undoButton.button.selected = true
              }

            case .Ended:
              if pressGesture.pressRecognized { self.redo(nil) }
              fallthrough

            default:
              self.undoButton.button.selected = false
              self.undoButton.button.setTitle(UIFont.fontAwesomeIconForName("undo"), forState: .Normal)
          }
        })
      longPress.confineToView = true
      longPress.nametag = "toolbarLongPressGesture"
      self.longPressGesture.requireGestureRecognizerToFail(longPress)
      self.undoButton?.addGestureRecognizer(longPress)
      return longPress
    }()


    createGestureManager()
  }

  /** createGestureManager */
  func createGestureManager() {

    let noPopovers: (Void) -> Bool = {
      [unowned self] in !(self.popoverActive || self.presetsActive) && self.menuState == .Default
    }
    let noToolbars: (UITouch) -> Bool = {
      [unowned self] t in self.toolbars.filter{t.view.isDescendantOfView($0)}.count == 0
    }
    let noPopoversOrToolbars: (UITouch) -> Bool = {touch in noPopovers() && noToolbars(touch)}

    let notMoving: (Void) -> Bool = {
      [unowned self] in !self.movingSelectedViews
    }
    let selectableClass: (UITouch) -> Bool = {
      [unowned self] touch in self.sourceView.objectIsSubelementKind(touch.view)
    }

    gestureManager = GestureManager(gestures: [
      pinchGesture:
        GestureManager.ResponseCollection(
          begin: {[unowned self] in self.selectedViews.count > 0},
          receiveTouch: noPopoversOrToolbars
        ),
      longPressGesture:
        GestureManager.ResponseCollection(
          receiveTouch: {touch in noPopoversOrToolbars(touch) && selectableClass(touch)},
          recognizeSimultaneously: {gesture in true} //{[unowned self] gesture in gesture === self.toolbarLongPressGesture}
        ),
      toolbarLongPressGesture:
        GestureManager.ResponseCollection(
          receiveTouch: {[unowned self] touch in noPopovers() && touch.view.isDescendantOfView(self.topToolbar)}
        ),
      twoTouchPanGesture:
        GestureManager.ResponseCollection(
          receiveTouch: noPopoversOrToolbars
        ),
      oneTouchDoubleTapGesture:
        GestureManager.ResponseCollection(
          begin: notMoving,
          receiveTouch: noPopoversOrToolbars
        ),
      selectGesture:
        GestureManager.ResponseCollection(
          begin: notMoving,
          receiveTouch: noPopoversOrToolbars,
          recognizeSimultaneously: {[unowned self] gesture in gesture === self.anchoredSelectGesture}
        ),
      anchoredSelectGesture:
        GestureManager.ResponseCollection(
          begin: notMoving,
          receiveTouch: noPopoversOrToolbars,
          recognizeSimultaneously: {[unowned self] gesture in gesture === self.selectGesture}
        )
      ])
  }

  /**
  touchedSubelementViewForGesture:

  :param: gesture UIGestureRecognizer

  :returns: RemoteElementView?
  */
  func touchedSubelementViewForGesture(gesture: UIGestureRecognizer) -> RemoteElementView? {
    var subelementView: RemoteElementView?
    if let touchedView = view.hitTest(gesture.locationInView(view), withEvent: nil) as? RemoteElementView {
      if sourceView.objectIsSubelementKind(touchedView) { subelementView = touchedView }
    }
    return subelementView
  }

  /**
  subelementViewsForLocation:

  :param: location CGPoint

  :returns: OrderedSet<RemoteElementView>
  */
  func subelementViewsForLocation(location: CGPoint) -> OrderedSet<RemoteElementView> {
    return sourceView.subelementViews.filter{$0.pointInside(location, withEvent: nil)}
  }

  /**
  subelementViewsForLocations:

  :param: locations OrderedSet<CGPoint>

  :returns: OrderedSet<RemoteElementView>
  */
  func subelementViewsForLocations(locations: OrderedSet<CGPoint>) -> OrderedSet<OrderedSet<RemoteElementView>> {
    return locations.map{self.subelementViewsForLocation($0)}
  }

  /**
  handleTap:

  :param: gesture UITapGestureRecognizer
  */
  func handleTap(gesture: UITapGestureRecognizer) {
    MSLogDebug("gesture: \(gesture.nametag), state: \(gesture.state)")
    if gesture.state == .Ended {
      if let tappedView = view.hitTest(gesture.locationInView(view), withEvent: nil) as? RemoteElementView{
        if sourceView.objectIsSubelementKind(tappedView) {
          if selectedViews ∌ tappedView { selectView(tappedView)}
          focusView = (focusView === tappedView ? nil : tappedView)
        }
      }
    }
  }

  /**
  handlePinch:

  :param: gesture UIPinchGestureRecognizer
  */
  func handlePinch(gesture: UIPinchGestureRecognizer) {
    MSLogDebug("gesture: \(gesture.nametag), state: \(gesture.state)")
    if gesture === pinchGesture {
      switch gesture.state {
        case .Began: willScaleSelectedViews()
        case .Changed: scaleSelectedViews(gesture.scale)
        case .Cancelled, .Failed, .Ended: didScaleSelectedViews()
        default: break
      }
    }
  }

  /**
  handlePan:

  :param: gesture UIPanGestureRecognizer
  */
  func handlePan(gesture: PanGesture) {
    MSLogDebug("gesture: \(gesture.nametag), state: \(gesture.state)")
    if gesture === twoTouchPanGesture {
      switch gesture.state {
        case .Began:
          startingPanOffset = sourceViewCenterYConstraint.constant
        case .Changed:
          let translation = gesture.translationInView(view: view)
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
                            animations: { self.sourceViewCenterYConstraint.constant = newOffset; self.view.layoutIfNeeded() },
                            completion: nil)
          }
        default: break
      }
    }
  }

  /**
  handleSelection:

  :param: gesture MultiselectGestureRecognizer
  */
//  func handleSelection(gesture: MultiselectGestureRecognizer) {
//    MSLogDebug("gesture: \(gesture.nametag), state: \(gesture.state)")
//   if gesture.state == .Ended {
//    let touchedSubelementViews = gesture.touchedSubviewsInView(sourceView){self.sourceView.objectIsSubelementKind($0)}
//    if touchedSubelementViews.count > 0 {
//      let touchLocations = gesture.touchLocationsInView(sourceView)
//
//      let stackedViews = OrderedSet((sourceView.subelementViews as [RemoteElementView]).filter {
//        v in contains(touchLocations, { v.pointInside(v.convertPoint($0, fromView: self.sourceView), withEvent: nil)})
//        })
//
//      if stackedViews.count > touchedSubelementViews.count { displayStackedViewDialogForViews(stackedViews) }
//
//      if gesture === selectGesture { selectViews(OrderedSet(touchedSubelementViews.array as [RemoteElementView])) }
//      else if gesture === anchoredSelectGesture { deselectViews(OrderedSet(touchedSubelementViews.array as [RemoteElementView])) }
//
//
//     }
//
//     else if selectedViews.count > 0 { deselectAll() }
//
//   }
//
//  }

}

/// MARK: - Translating subelements
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /**
  Sanity check for ensuring selected views can only be moved to reasonable locations.

  :param: fromUnion `CGRect` representing the current union of the `frame` properties of the current selection
  :param: toUnion `CGRect` representing the resulting union of the `frame` properties of the current selection when moved

  :returns: Whether the views should be moved
  */
  func shouldTranslateSelectionFrom(fromUnion: CGRect, to toUnion: CGRect) -> Bool { return contentRect.contains(toUnion) }

  /** willTranslateSelectedViews */
  func willTranslateSelectedViews() { }

  /** didTranslateSelectedViews */
  func didTranslateSelectedViews() {}

}

/// MARK: - Editing and adding subelements
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** addSubelement */
  func addSubelement() {
    let layout = UICollectionViewFlowLayout(scrollDirection: .Horizontal)
    let presetVC = REPresetCollectionViewController(collectionViewLayout: layout)
    presetVC.context = context
    addChildViewController(presetVC)
    let presetView = presetVC.collectionView!
    presetView.constrain("'height' self.height = 0")
    view.addSubview(presetView)
    view.constrain("|[preset]| :: V:[preset]|", views: ["preset": presetView])
    view.layoutIfNeeded()
    UIView.transitionWithView(view, duration: 0.25, options: .CurveEaseInOut,
      animations: {
        if let c = presetView.constraintWithIdentifier("height") {
          c.constant = 200.0
          presetView.layoutIfNeeded()
        }
      },
      completion: {_ in self.presetsActive = true})
  }

  /** presets */
  func presets() { println(__FUNCTION__) }

  /** editBackground */
  func editBackground() {
     let bgEditor = StoryboardProxy.backgroundEditingController()
     bgEditor.subject = remoteElement
     presentViewController(bgEditor, animated: true, completion: nil)
  }

  /** editSubelement */
  func editSubelement() {
    if let subelementView = selectedViews.first {
      presentedSubelementView = subelementView
      let model = subelementView.model
      let size = subelementView.bounds.size
      let controller = RemoteElementEditingController.editingControllerForElement(model, size: size)
      controller.delegate = self
      transitioningDelegate = editingTransitioningDelegate
      controller.transitioningDelegate = editingTransitioningDelegate
      presentViewController(controller, animated: true, completion: nil)
    }
  }

  /** duplicate */
  func duplicate() { println(__FUNCTION__) }

  /** copyStyle */
  func copyStyle() { println(__FUNCTION__) }

  /** pasteStyle */
  func pasteStyle() { println(__FUNCTION__) }


}

/// MARK: - UIResponderStandardEditActions
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
  override func copy(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  cut:

  :param: sender AnyObject?
  */
  override func cut(sender: AnyObject?) { println(__FUNCTION__) }

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
      self.context.deleteObjects(NSSet(array: elementsToDelete.array))
      self.context.processPendingChanges()
    }
    sourceView.setNeedsUpdateConstraints()
    sourceView.updateConstraintsIfNeeded()
  }

  /**
  paste:

  :param: sender AnyObject?
  */
  override func paste(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  select:

  :param: sender AnyObject?
  */
  override func select(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  selectAll:

  :param: sender AnyObject?
  */
  override func selectAll(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  toggleBoldface:

  :param: sender AnyObject?
  */
  override func toggleBoldface(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  toggleItalics:

  :param: sender AnyObject?
  */
  override func toggleItalics(sender: AnyObject?) { println(__FUNCTION__) }

  /**
  toggleUnderline:

  :param: sender AnyObject?
  */
  override func toggleUnderline(sender: AnyObject?) { println(__FUNCTION__) }

}


/// MARK: - Toolbars
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController {

  /** updateToolbarDisplayed */
  func updateToolbarDisplayed() {
    if selectedViews.count > 0 { currentToolbar = focusView != nil ? focusSelectionToolbar : nonEmptySelectionToolbar }
    else { currentToolbar = emptySelectionToolbar }
  }

  /** updateBarButtonItems */
  func updateBarButtonItems() {
    if movingSelectedViews { apply(singleSelButtons + anySelButtons + multiSelButtons){$0.enabled = false}}
    else { apply(anySelButtons){$0.enabled = true} }
    let multipleSelections = selectedViews.count > 1
    apply(singleSelButtons){$0.enabled = !multipleSelections}
    apply(multiSelButtons){$0.enabled = multipleSelections}
  }

}

/// MARK: - MSPopupBarButtonDelegate
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

/// MARK: - EditingDelegate
////////////////////////////////////////////////////////////////////////////////
extension RemoteElementEditingController: EditingDelegate {

  /**
  editorDidCancel:

  :param: editor RemoteElementEditingController
  */
  func editorDidCancel(editor: RemoteElementEditingController) {
    dismissViewControllerAnimated(true, completion: {self.presentedSubelementView = nil})
  }

  /**
  editorDidSave:

  :param: editor RemoteElementEditingController
  */
  func editorDidSave(editor: RemoteElementEditingController) {
    dismissViewControllerAnimated(true, completion: {self.presentedSubelementView = nil})
  }

}
