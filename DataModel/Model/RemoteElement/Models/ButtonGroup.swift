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
@objc(ButtonGroup)
public final class ButtonGroup: RemoteElement {

  public struct PanelAssignment: RawOptionSetType, JSONValueConvertible, JSONValueInitializable {

    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue & 0b0001_1111 }
    public init(nilLiteral:()) { rawValue = 0 }

    public enum Location: Int, JSONValueConvertible, JSONValueInitializable {
      case Undefined, Top, Bottom, Left, Right
      public var jsonValue: JSONValue {
        switch self {
          case .Undefined: return "undefined"
          case .Top:       return "top"
          case .Bottom:    return "bottom"
          case .Left:      return "left"
          case .Right:     return "right"
        }
      }
      public init?(_ jsonValue: JSONValue?) {
        if let string = String(jsonValue) {
          switch string {
            case "top":    self = .Top
            case "bottom": self = .Bottom
            case "left":   self = .Left
            case "right":  self = .Right
            default:       self = .Undefined
          }
        } else { return nil }
      }
    }
    public enum Trigger: Int, JSONValueConvertible  {
      case Undefined, OneFinger, TwoFinger, ThreeFinger
      public var jsonValue: JSONValue {
        switch self {
          case .Undefined:   return "undefined"
          case .OneFinger:   return "1"
          case .TwoFinger:   return "2"
          case .ThreeFinger: return "3"
        }
      }
      public init?(_ jsonValue: JSONValue?) {
        if let string = String(jsonValue) {
          switch string {
            case "1": self = .OneFinger
            case "2": self = .TwoFinger
            case "3": self = .ThreeFinger
            default:  self = .Undefined
          }
        } else { return nil }
      }
    }

    public var location: Location {
      get { return Location(rawValue: rawValue & 0b0111) ?? .Undefined }
      set { rawValue = newValue.rawValue | (trigger.rawValue >> 3) }
    }
    public var trigger: Trigger {
      get { return Trigger(rawValue: (rawValue << 3) & 0b0011) ?? .Undefined }
      set { rawValue = location.rawValue | (newValue.rawValue >> 3) }
    }

    /**
    initWithLocation:trigger:

    :param: location Location
    :param: trigger Trigger
    */
    public init(location: Location, trigger: Trigger) { rawValue = location.rawValue | (trigger.rawValue >> 3) }

    public static var Unassigned: PanelAssignment = PanelAssignment(location: .Undefined, trigger: .Undefined)

    public init?(_ jsonValue: JSONValue?) {
      if let string = String(jsonValue) {
        rawValue = 0
        let length = count(string)
        if length > 3,
          let l = Location(string[0 ..< (length - 1)].jsonValue),
          t = Trigger(string[(length - 1) ..< length].jsonValue)
        {
          location = l
          trigger = t
        } else { return nil }
      } else { return nil }
    }

    public var jsonValue: JSONValue {
      return "\(location.jsonValue.value as! String)\(trigger.jsonValue.value as! String)".jsonValue
    }

  }

  override public var elementType: BaseType { return .ButtonGroup }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)

    autohide = preset.autohide ?? false

    if let labelAttributes = preset.labelAttributes { self.labelAttributes.dictionary = labelAttributes.storage }
    labelConstraints = preset.labelConstraints
    // if let panelAssignment = preset.panelAssignment { self.panelAssignment = panelAssignment }
  }

  @NSManaged public var commandContainer: CommandContainer?
  @NSManaged public var autohide: Bool
  // @NSManaged var label: NSAttributedString?
  private(set) public var labelAttributes: JSONStorage {
    get {
      var storage: JSONStorage!
      willAccessValueForKey("labelAttributes")
      storage = primitiveValueForKey("labelAttributes") as? JSONStorage
      didAccessValueForKey("labelAttributes")
      if storage == nil {
        storage = JSONStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "labelAttributes")
      }
      return storage
    }
    set {
      willChangeValueForKey("labelAttributes")
      setPrimitiveValue(newValue, forKey: "labelAttributes")
      didChangeValueForKey("labelAttributes")
    }
  }

  @NSManaged public var labelConstraints: String?

  public var isPanel: Bool { return panelLocation != .Undefined && panelTrigger != .Undefined }

  public var panelLocation: PanelAssignment.Location {
    get { return panelAssignment.location }
    set { var assignment = panelAssignment; assignment.location = newValue; panelAssignment = assignment }
  }

  public var panelTrigger: PanelAssignment.Trigger {
    get { return panelAssignment.trigger }
    set { var assignment = panelAssignment; assignment.trigger = newValue; panelAssignment = assignment }
  }

  @NSManaged var primitivePanelAssignment: NSNumber
  public var panelAssignment: PanelAssignment {
    get {
      willAccessValueForKey("panelAssignment")
      let panelAssignment = PanelAssignment(rawValue: primitivePanelAssignment.integerValue)
      didAccessValueForKey("panelAssignment")
      return panelAssignment
    }
    set {
      willChangeValueForKey("panelAssignment")
      primitivePanelAssignment = newValue.rawValue
      didChangeValueForKey("panelAssignment")
    }
  }

  /**
  setCommandContainer:forMode:

  :param: container CommandContainer?
  :param: mode String
  */
  public func setCommandContainer(container: CommandContainer?, forMode mode: String) {
    setURIForObject(container, forKey: "commandContainer", forMode: mode)
  }

  /**
  commandContainerForMode:

  :param: mode String

  :returns: CommandContainer?
  */
  public func commandContainerForMode(mode: String) -> CommandContainer? {
    return faultedObjectForKey("commandContainer", forMode: mode) as? CommandContainer
  }

  /**
  setLabel:forMode:

  :param: label NSAttributedString?
  :param: mode String
  */
  public func setLabel(label: NSAttributedString?, forMode mode: String) {
    setObject(label, forKey: "label", forMode: mode)
  }

  /**
  labelForMode:

  :param: mode String

  :returns: NSAttributedString?
  */
  public func labelForMode(mode: String) -> NSAttributedString? {
    return objectForKey("label", forMode: mode) as? NSAttributedString
  }

    /**
  updateForMode:

  :param: mode String
  */
  override public func updateForMode(mode: String) {
    super.updateForMode(mode)
    commandContainer = commandContainerForMode(mode) ?? commandContainerForMode(RemoteElement.DefaultMode)

    updateButtons()
  }

  public var commandSetIndex: Int = 0 {
    didSet {
      if let collection = commandContainer as? CommandSetCollection {
        if !contains((0 ..< Int(collection.count)), commandSetIndex) { commandSetIndex = 0 }
        updateButtons()
      }
    }
  }

  /** updateButtons */
  public func updateButtons() {
    var commandSet: CommandSet?
    if commandContainer != nil && commandContainer! is CommandSet { commandSet = commandContainer! as? CommandSet }
    else if let collection = commandContainer as? CommandSetCollection {
      commandSet = collection.commandSetAtIndex(commandSetIndex)
    }
    commandSet = commandSet?.faultedObject()
    if commandSet != nil {
      for button in childElements.array as! [Button] {
         if button.role == RemoteElement.Role.Tuck { continue }
         button.command = commandSet![button.role]
         button.enabled = button.command != nil
      }
    }
  }

  /**
  labelForCommandSetAtIndex:

  :param: idx Int

  :returns: NSAttributedString?
  */
  public func labelForCommandSetAtIndex(idx: Int) -> NSAttributedString? {
    var commandSetLabel: NSAttributedString?
    if let collection = commandContainer as? CommandSetCollection {
      if contains(0 ..< Int(collection.count), idx) {
        if let text = collection.labelAtIndex(idx),
          var titleAttributes = TitleAttributes(labelAttributes.jsonValue)
        {
          titleAttributes.text = text
          commandSetLabel = titleAttributes.string
        }
      }
    }
    return commandSetLabel
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let autohide = Bool(data["autohide"]) { self.autohide = autohide }

      if let commandSetData = ObjectJSONValue(data["commandSet"]) {
        for (_, mode, jsonValue) in commandSetData {
          if let values = ObjectJSONValue(jsonValue),
            commandSet = CommandSet.importObjectWithData(values, context: moc)
          {
            setCommandContainer(commandSet, forMode: mode)
          }
        }
      }

      else if let collectionData = ObjectJSONValue(data["commandSet-collection"]) {
        for (_, mode, jsonValue) in collectionData {
          if let values = ObjectJSONValue(jsonValue),
            commandSetCollection = CommandSetCollection.importObjectWithData(values, context: moc)
          {
            setCommandContainer(commandSetCollection, forMode: mode)
          }
        }
      }

      labelConstraints = String(data["labelConstraints"])

      if let labelAttributesData = ObjectJSONValue(data["labelAttributes"]) {
        labelAttributes.dictionary = labelAttributesData.value
      }

    }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    var commandSets           : JSONValue.ObjectValue = [:]
    var commandSetCollections : JSONValue.ObjectValue = [:]
    var labels                : JSONValue.ObjectValue = [:]

    for mode in modes as [String] {
      if let container = commandContainerForMode(mode) {
        let d = container.jsonValue
        if container is CommandSetCollection { commandSetCollections[mode] = d }
        else if container is CommandSet { commandSets[mode] = d }
      }
      // TODO: Probably need to add jsonValue to NSAttributedString to export labels
      if let label = labelForMode(mode) { labels[mode] = JSONValue(label) }
    }

    if commandSetCollections.count > 0 { obj["commandSet-collection"] = .Object(commandSetCollections) }
    if commandSets.count > 0 { obj["commandSet"] = .Object(commandSets) }
    if labels.count > 0 { obj["label"] = .Object(labels) }
    if let constraints = labelConstraints { obj["labelConstraints"] = constraints.jsonValue }
    if !labelAttributes.dictionary.isEmpty { obj["labelAttributes"] = labelAttributes.jsonValue }
    return obj.jsonValue
  }

}

extension ButtonGroup.PanelAssignment: Equatable {}
public func ==(lhs: ButtonGroup.PanelAssignment, rhs: ButtonGroup.PanelAssignment) -> Bool { return lhs.rawValue == rhs.rawValue }

extension ButtonGroup.PanelAssignment: BitwiseOperationsType {
  static public var allZeros: ButtonGroup.PanelAssignment { return self(rawValue: 0) }
}
public func &(lhs: ButtonGroup.PanelAssignment, rhs: ButtonGroup.PanelAssignment) -> ButtonGroup.PanelAssignment {
  return ButtonGroup.PanelAssignment(rawValue: (lhs.rawValue & rhs.rawValue))
}
public func |(lhs: ButtonGroup.PanelAssignment, rhs: ButtonGroup.PanelAssignment) -> ButtonGroup.PanelAssignment {
  return ButtonGroup.PanelAssignment(rawValue: (lhs.rawValue | rhs.rawValue))
}
public func ^(lhs: ButtonGroup.PanelAssignment, rhs: ButtonGroup.PanelAssignment) -> ButtonGroup.PanelAssignment {
  return ButtonGroup.PanelAssignment(rawValue: (lhs.rawValue ^ rhs.rawValue))
}
public prefix func ~(x: ButtonGroup.PanelAssignment) -> ButtonGroup.PanelAssignment {
  return ButtonGroup.PanelAssignment(rawValue: ~(x.rawValue))
}
