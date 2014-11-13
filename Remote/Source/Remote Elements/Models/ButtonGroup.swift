//
//  ButtonGroup.swift
//  Remote
//
//  Created by Jason Cardwell on 11/11/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
`ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
theater remote control. Its main function is to manage a collection of <Button> objects and to
interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
*/
class ButtonGroup: RemoteElement {

  struct PanelAssignment {
    enum Location: Int { case Undefined, Top, Bottom, Left, Right }
    enum Trigger: Int  { case Undefined, OneFinger, TwoFinger, ThreeFinger }

    var location: Location
    var trigger: Trigger

    var numberValue: NSNumber {
      let l = location.rawValue
      let t = trigger.rawValue
      if l > 0 && t > 0 { return NSNumber(integer: l | (t >> 3)) }
      else { return NSNumber(integer: -1) }
    }

    /**
    initWithLocation:trigger:

    :param: location Location
    :param: trigger Trigger
    */
    init(location: Location, trigger: Trigger) { self.location = location; self.trigger = trigger }

    /**
    initWithNumberValue:

    :param: numberValue NSNumber
    */
    init?(numberValue: NSNumber) {
      let i = numberValue.integerValue
      location = Location(rawValue: i & 3)
      t = i << 2
      if t > 0 && t < 4 { trigger = Trigger(rawValue: t) }
      else { trigger = .Undefined }

      if location == .Undefined || trigger == .Undefined { return nil }
    }

  }

  @NSManaged var commandContainer: CommandContainer

  @NSManaged var primitivePanelAssignment: NSNumber
  var panelAssignment: PanelAssignment? {
    get {
      willAccessValueForKey("panelAssignment")
      let panelAssignment = PanelAssignment(numberValue: primitivePanelAssignment)
      didAccessValueForKey("panelAssignment")
      return panelAssignment
    }
    set {
      willChangeValueForKey("panelAssignment")
      primitivePanelAssignment = newValue?.numberValue ?? NSNumber(integer: -1)
      didChangeValueForKey("panelAssignment")
    }
  }

}
