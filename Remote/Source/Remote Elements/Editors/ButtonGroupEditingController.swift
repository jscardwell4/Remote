//
//  ButtonGroupEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonGroupEditingController: RemoteElementEditingController {

  /**
  subelementClass

  :returns: RemoteElementView.Type
  */
  override class func subelementClass() -> RemoteElementView.Type { return ButtonView.self }

  /**
  isSubelementKind:

  :param: obj AnyObject

  :returns: Bool
  */
  override class func isSubelementKind(obj: AnyObject) -> Bool { return obj is ButtonView }

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  override class func elementClass() -> RemoteElementView.Type { return ButtonGroupView.self }

  /** willTranslateSelectedViews */
  override func willTranslateSelectedViews() { super.willTranslateSelectedViews(); sourceView.locked = false }

  /** didTranslateSelectedViews */
  override func didTranslateSelectedViews() { super.didTranslateSelectedViews(); sourceView.locked = true }

  /**
  Opens the specified subelement in its Class-level editor.

  :param: subelement The element to edit
  */
  // override func openSubelementInEditor(subelement: RemoteElement) {
  //   if let button = subelement as? Button {
  //     let controller = ButtonEditingController(element: button)
  //     controller.delegate = self
  //     transitioningDelegate = editingTransitioningDelegate
  //     controller.transitioningDelegate = editingTransitioningDelegate
  //     presentViewController(controller, animated: true, completion: nil)
  //   }
  // }


}
