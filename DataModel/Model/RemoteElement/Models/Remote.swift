//
//  Remote.swift
//  Remote
//
//  Created by Jason Cardwell on 11/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Remote)
public final class Remote: RemoteElement {

  override public var elementType: BaseType { return .Remote }

  public var topBarHidden: Bool {
    get {
      willAccessValueForKey("topBarHidden")
      let topBarHidden = (primitiveValueForKey("topBarHidden") as? NSNumber)?.boolValue ?? false
      didAccessValueForKey("topBarHidden")
      return topBarHidden
    }
    set {
      willChangeValueForKey("topBarHidden")
      setPrimitiveValue(newValue, forKey: "topBarHidden")
      didChangeValueForKey("topBarHidden")
    }
  }
  @NSManaged public var activity: Activity?

  public var panels: [NSNumber:String] {
    get {
      willAccessValueForKey("panels")
      let panels = primitiveValueForKey("panels") as? [NSNumber:String]
      didAccessValueForKey("panels")
      return panels ?? [:]
    }
    set {
      willChangeValueForKey("panels")
      setPrimitiveValue(newValue, forKey: "panels")
      didChangeValueForKey("panels")
    }
  }

  override public var parentElement: RemoteElement? { get { return nil } set {} }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)

    topBarHidden = preset.topBarHidden ?? false
  }

  /**
  setButtonGroup:forPanelAssignment:

  :param: buttonGroup ButtonGroup?
  :param: assignment ButtonGroup.PanelAssignment
  */
  public func setButtonGroup(buttonGroup: ButtonGroup?, forPanelAssignment assignment: ButtonGroup.PanelAssignment) {
    var assignments = panels
    if assignment != ButtonGroup.PanelAssignment.Unassigned { assignments[assignment.rawValue] = buttonGroup?.uuid }
    panels = assignments
  }

  /**
  buttonGroupForPanelAssignment:

  :param: assignment ButtonGroup.PanelAssignment

  :returns: ButtonGroup?
  */
  public func buttonGroupForPanelAssignment(assignment: ButtonGroup.PanelAssignment) -> ButtonGroup? {
    var buttonGroup: ButtonGroup?
    if managedObjectContext != nil {
      if let uuid = panels[assignment.rawValue] {
        buttonGroup = ButtonGroup.objectWithUUID(uuid, context: managedObjectContext!)
      }
    }
    return buttonGroup
  }


  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let topBarHidden = Bool(data["topBarHidden"]) { self.topBarHidden = topBarHidden }

      if let panels = ObjectJSONValue(data["panels"] ?? .Null) {
        for (key, json) in panels {
          if let uuid = String(json),
            buttonGroup = subelements.objectPassingTest({($0.0 as! RemoteElement).uuid == uuid}) as? ButtonGroup {
            if let assignment = ButtonGroup.PanelAssignment(.String(key))
              where assignment != ButtonGroup.PanelAssignment.Unassigned
            {
              setButtonGroup(buttonGroup, forPanelAssignment: assignment)
            }
          }
        }
      }

    }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    var panels: JSONValue.ObjectValue = [:]

    for (number, uuid) in self.panels {
      let assignment = ButtonGroup.PanelAssignment(rawValue: number.integerValue)
      if let assignedUUID = buttonGroupForPanelAssignment(assignment)?.uuid {
        panels[assignment.jsonValue.value as! String] = .String(assignedUUID)
      }
    }

    if panels.count > 0 { obj["panels"] = .Object(panels) }
    return obj.jsonValue
  }

}
