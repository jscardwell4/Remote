//
//  RemoteEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/29/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteEditingController: RemoteElementEditingController {

  /**
  subelementClass

  :returns: RemoteElementView.Type
  */
  override class func subelementClass() -> RemoteElementView.Type { return ButtonGroupView.self }

  /**
  isSubelementKind:

  :param: obj AnyObject

  :returns: Bool
  */
  override class func isSubelementKind(obj: AnyObject) -> Bool { return obj is ButtonGroupView }

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  override class func elementClass() -> RemoteElementView.Type { return RemoteView.self }

  /**
  editingModeForElement

  :returns: REEditingMode
  */
  override class func editingModeForElement() -> REEditingMode { return .Remote }

  override var mockParentSize: CGSize { get { return UIScreen.mainScreen().bounds.size } set {} }

}
