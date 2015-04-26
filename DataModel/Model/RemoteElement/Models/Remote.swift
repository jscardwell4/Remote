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

  @NSManaged public var topBarHidden: Bool
  @NSManaged public var activity: Activity?

  public typealias PanelAssignment = ButtonGroup.PanelAssignment

  /** Index mapping panel assignments to button group uuids */
  public var panels: [PanelAssignment:UUIDIndex] {
    get {
      willAccessValueForKey("panels")
      let panels = primitiveValueForKey("panels") as! [Int:String]
      didAccessValueForKey("panels")

      let keys = map(panels.keys) {PanelAssignment(rawValue: $0)}
      let values = map(panels.values) {UUIDIndex(rawValue: $0)!}
      return zip(keys, values)
    }
    set {
      let keys = map(newValue.keys) {$0.rawValue}
      let values = map(newValue.values) {$0.rawValue}
      willChangeValueForKey("panels")
      setPrimitiveValue(zip(keys,values), forKey: "panels")
      didChangeValueForKey("panels")
    }
  }

  override public class var subelementType: RemoteElement.Type? { return ButtonGroup.self }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)
    topBarHidden = preset.topBarHidden ?? false
    // ???: Panel assignments?
  }

  /**
  setButtonGroup:forPanelAssignment:

  :param: buttonGroup ButtonGroup?
  :param: assignment PanelAssignment
  */
  public func setButtonGroup(buttonGroup: ButtonGroup?, forPanelAssignment assignment: PanelAssignment) {
    var assignments = panels
    if assignment != PanelAssignment.Unassigned { assignments[assignment] = UUIDIndex(buttonGroup?.uuid) }
    panels = assignments
  }

  /**
  buttonGroupForPanelAssignment:

  :param: assignment PanelAssignment

  :returns: ButtonGroup?
  */
  public func buttonGroupForPanelAssignment(assignment: PanelAssignment) -> ButtonGroup? {
    if let moc = managedObjectContext, uuid = panels[assignment] { return ButtonGroup.objectWithUUID(uuid, context: moc) }
    else { return nil }
  }


  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let topBarHidden = Bool(data["topBarHidden"]) { self.topBarHidden = topBarHidden }

      if let panels = ObjectJSONValue(data["panels"]) {
        for (_, key, json) in panels {
          if let uuid = UUIDIndex(String(json)),
            buttonGroup = ButtonGroup.objectWithUUID(uuid, context: moc) where subelements ∋ buttonGroup,
            let assignment = PanelAssignment(key.jsonValue) where assignment != PanelAssignment.Unassigned
          {
              setButtonGroup(buttonGroup, forPanelAssignment: assignment)
          }
        }
      }

    }

  }

  override public var description: String {
    var result = super.description
    result += "\n\ttopBarHidden = \(topBarHidden)"
    result += "\n\tactivity = \(toString(activity?.index))"
    result += "\n\tpanels = {"
    let panelEntries = keyValuePairs(panels)
    if panelEntries.count == 0 { result += "}" }
    else {
      result += "\n\t\t" + "\n\t\t".join(panelEntries.map({"\($0.stringValue) = \($1.rawValue)"})) + "\n\t}"
    }
    return result
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["panels"] = .Object(OrderedDictionary(zip(map(panels.keys, {$0.stringValue}), map(panels.values, {$0.jsonValue}))))
    return obj.jsonValue
  }

}
