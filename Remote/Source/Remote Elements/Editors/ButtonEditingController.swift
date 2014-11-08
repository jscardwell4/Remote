//
//  ButtonEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonEditingController: RemoteElementEditingController {

  /**
  isSubelementKind:

  :param: obj AnyObject

  :returns: Bool
  */
  override class func isSubelementKind(obj: AnyObject) -> Bool { return false }

  /**
  elementClass

  :returns: RemoteElementView.Type
  */
  override class func elementClass() -> RemoteElementView.Type { return ButtonView.self }

  /**
  editingModeForElement

  :returns: REEditingMode
  */
  override class func editingModeForElement() -> REEditingMode { return .Button }

  /**
  openSubelementInEditor:

  :param: subelement RemoteElement
  */
  override func openSubelementInEditor(subelement: RemoteElement) {}

}
