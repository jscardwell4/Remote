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

// TODO: Possibly alter panels to only support one per edge and use screen edge gestures

@objc(Remote)
public final class Remote: RemoteElement {

  override public var elementType: BaseType { return .Remote }

  @NSManaged public var topBarHidden: Bool
  @NSManaged public var activity: Activity?

  override public class var subelementType: RemoteElement.Type? { return ButtonGroup.self }

  /**
  updateWithPreset:

  - parameter preset: Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)
    topBarHidden = preset.topBarHidden ?? false
    // ???: Panel assignments?
  }

  /**
  setButtonGroup:forPanelAssignment:

  - parameter buttonGroup: ButtonGroup?
  - parameter assignment: PanelAssignment
  */
  public func setButtonGroup(buttonGroup: ButtonGroup?, forPanelAssignment assignment: PanelAssignment) {
    if buttonGroup == nil || subelements ∋ buttonGroup! {
      var assignments = panels
      assignments[assignment] = buttonGroup?.uuidIndex
      panels = assignments
    }
  }

  /**
  buttonGroupForPanelAssignment:

  - parameter assignment: PanelAssignment

  - returns: ButtonGroup?
  */
  public func buttonGroupForPanelAssignment(assignment: PanelAssignment) -> ButtonGroup? {
    if let moc = managedObjectContext, uuid = panels[assignment] { return ButtonGroup.objectWithUUID(uuid, context: moc) }
    else { return nil }
  }


  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      topBarHidden = Bool(data["topBarHidden"]) ?? false

      applyMaybe(ObjectJSONValue(data["panels"])) { _, key, json in
        if let assignment = PanelAssignment(key),
          let uuidIndex = UUIDIndex(String(json)),
          buttonGroup = ButtonGroup.objectWithUUID(uuidIndex, context: moc) where self.subelements ∋ buttonGroup
        {
          self.setButtonGroup(buttonGroup, forPanelAssignment: assignment)
        }
      }

    }

  }

  // MARK: - Panel assignments

  /** Index mapping panel assignments to button group uuids */
  public var panels: [PanelAssignment:UUIDIndex] {
    get {
      willAccessValueForKey("panels")
      let panels = primitiveValueForKey("panels") as! [Int:String]
      didAccessValueForKey("panels")

      let keys = panels.keys.map {PanelAssignment(rawValue: $0)}
      let values = panels.values.map {UUIDIndex(rawValue: $0)!}
      return zipDict(keys, values)
    }
    set {
      let keys = newValue.keys.map {$0.rawValue}
      let values = newValue.values.map {$0.rawValue}
      willChangeValueForKey("panels")
      setPrimitiveValue(zipDict(keys,values), forKey: "panels")
      didChangeValueForKey("panels")
    }
  }

  public struct PanelAssignment: OptionSetType, Hashable, StringValueConvertible,
                                 JSONValueConvertible, JSONValueInitializable, CustomStringConvertible
  {

    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue & 0b0001_1111 }
    public init(nilLiteral:()) { rawValue = 0 }

    /** Enumeration to hold the location associated with a panel assignment */
    public enum Location: Int, JSONValueConvertible, JSONValueInitializable, CustomStringConvertible {
      case Top = 1, Bottom = 2, Left = 3, Right = 4

      public enum Axis: String { case Horizontal = "Horizontal", Vertical = "Vertical" }
      public var axis: Axis {
        switch self {
          case .Top, .Bottom: return .Vertical
          case .Left, .Right: return .Horizontal
        }
      }

      public var jsonValue: JSONValue {
        switch self {
          case .Top:       return "top"
          case .Bottom:    return "bottom"
          case .Left:      return "left"
          case .Right:     return "right"
        }
      }
      public init?(_ jsonValue: JSONValue?) {
        if jsonValue != nil {
          switch jsonValue! {
            case Location.Top.jsonValue:    self = .Top
            case Location.Bottom.jsonValue: self = .Bottom
            case Location.Left.jsonValue:   self = .Left
            case Location.Right.jsonValue:  self = .Right
            default:                        return nil
          }
        } else { return nil }
      }
      public var UISwipeGestureRecognizerDirectionValue: UISwipeGestureRecognizerDirection {
        switch self {
          case .Top: return .Up
          case .Bottom: return .Down
          case .Left: return .Left
          case .Right: return .Right
        }
      }

      public var description: String { return String(jsonValue)!.capitalizedString }
    }

    /** Enumeration to hold the number of touches to associate with a panel assignment */
    public enum Trigger: Int, JSONValueConvertible, CustomStringConvertible  {
      case OneFinger = 1, TwoFinger = 2, ThreeFinger = 3
      public var jsonValue: JSONValue {
        switch self {
          case .OneFinger:   return "1"
          case .TwoFinger:   return "2"
          case .ThreeFinger: return "3"
        }
      }
      public init?(_ jsonValue: JSONValue?) {
        if jsonValue != nil {
          switch jsonValue! {
            case Trigger.OneFinger.jsonValue:   self = .OneFinger
            case Trigger.TwoFinger.jsonValue:   self = .TwoFinger
            case Trigger.ThreeFinger.jsonValue: self = .ThreeFinger
            default:                            return nil
          }
        } else { return nil }
      }

      public var description: String {
        switch self {
          case .OneFinger: return "OneFinger"
          case .TwoFinger: return "TwoFinger"
          case .ThreeFinger: return "ThreeFinger"
        }
      }
    }

    public var location: Location {
      get { return Location(rawValue: rawValue & 0b0111) ?? .Top }
      set { rawValue = (newValue.rawValue & 0b0111) | (trigger.rawValue << 3) }
    }
    public var trigger: Trigger {
      get { return Trigger(rawValue: (rawValue >> 3) & 0b0011) ?? .OneFinger }
      set { rawValue = location.rawValue | ((newValue.rawValue & 0b0011) << 3) }
    }

    /**
    initWithLocation:trigger:

    - parameter location: Location
    - parameter trigger: Trigger
    */
    public init(location: Location, trigger: Trigger) { rawValue = location.rawValue | (trigger.rawValue << 3) }

    public init?(_ stringValue: String?) {
      if let string = stringValue where string ~= ~/"(?:left|right|top|bottom)(?:1|2|3)" {
        rawValue = 0
        switch string[0..<string.characters.count-1] {
          case "left":   location = .Left
          case "right":  location = .Right
          case "top":    location = .Top
          case "bottom": location = .Bottom
        default:       assert(false)
        }
        switch string[string.characters.count-1..<string.characters.count] {
          case "1": trigger = .OneFinger
          case "2": trigger = .TwoFinger
          case "3": trigger = .ThreeFinger
          default:  assert(false)
        }
      } else { return nil }
    }

    public init?(_ jsonValue: JSONValue?) { self.init(String(jsonValue)) }

    public var description: String {
      var result = "PanelAssignment:\n"
      result += "\tlocation = \(location.description)\n"
      result += "\ttrigger = \(trigger.description)"
      return result
    }

    public var stringValue: String { return "\(String(location.jsonValue)!)\(String(trigger.jsonValue)!)" }
    public var jsonValue: JSONValue { return stringValue.jsonValue }

    public var hashValue: Int { return rawValue }

  }

  // MARK: - Descriptions

  override public var description: String {
    var result = super.description
    result += "\n\ttopBarHidden = \(topBarHidden)"
    result += "\n\tactivity = \(String(activity?.index))"
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
    obj["panels"] = .Object(OrderedDictionary(zip(panels.keys.map({$0.stringValue}), panels.values.map({$0.jsonValue}))))
    return obj.jsonValue
  }

}

// MARK: - PanelAssignment extensions

extension Remote.PanelAssignment: Equatable {}
public func ==(lhs: Remote.PanelAssignment, rhs: Remote.PanelAssignment) -> Bool { return lhs.rawValue == rhs.rawValue }

extension Remote.PanelAssignment: BitwiseOperationsType {
  static public var allZeros: Remote.PanelAssignment { return self.init(rawValue: 0) }
}
public func &(lhs: Remote.PanelAssignment, rhs: Remote.PanelAssignment) -> Remote.PanelAssignment {
  return Remote.PanelAssignment(rawValue: (lhs.rawValue & rhs.rawValue))
}
public func |(lhs: Remote.PanelAssignment, rhs: Remote.PanelAssignment) -> Remote.PanelAssignment {
  return Remote.PanelAssignment(rawValue: (lhs.rawValue | rhs.rawValue))
}
public func ^(lhs: Remote.PanelAssignment, rhs: Remote.PanelAssignment) -> Remote.PanelAssignment {
  return Remote.PanelAssignment(rawValue: (lhs.rawValue ^ rhs.rawValue))
}
public prefix func ~(x: Remote.PanelAssignment) -> Remote.PanelAssignment {
  return Remote.PanelAssignment(rawValue: ~(x.rawValue))
}
