//
//  Button.swift
//  Remote
//
//  Created by Jason Cardwell on 11/09/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Button)
public final class Button: RemoteElement {

//  public struct State: RawOptionSetType {
//
//    private(set) var rawValue: Int
//    init(rawValue: Int) { self.rawValue = rawValue & 0b0111 }
//    init(nilLiteral:()) { rawValue = 0 }
//
//    static var Default:     State = State(rawValue: 0b0000)
//    static var Normal:      State = State.Default
//    static var Highilghted: State = State(rawValue: 0b0001)
//    static var Disabled:    State = State(rawValue: 0b0010)
//    static var Selected:    State = State(rawValue: 0b0100)
//
//  }

  override public var elementType: BaseType { return .Button }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)

    if let moc = managedObjectContext {

      if let titlesData = preset.titles {
        setTitles(ControlStateTitleSet.importObjectWithData(titlesData, context: moc),
          forMode: RemoteElement.DefaultMode)
      }

      if let iconsData = preset.icons {
        setIcons(ControlStateImageSet.importObjectWithData(iconsData, context: moc),
         forMode: RemoteElement.DefaultMode)
      }

      if let imagesData = preset.images {
        setImages(ControlStateImageSet.importObjectWithData(imagesData, context: moc),
          forMode: RemoteElement.DefaultMode)
      }

      if let backgroundColorsData = preset.backgroundColors {
        setBackgroundColors(ControlStateColorSet.importObjectWithData(backgroundColorsData, context: moc),
                    forMode: RemoteElement.DefaultMode)
      }

      titleEdgeInsets = preset.titleEdgeInsets
      contentEdgeInsets = preset.contentEdgeInsets
      imageEdgeInsets = preset.imageEdgeInsets

      if let commandData = preset.command {
        setCommand(Command.importObjectWithData(commandData, context: moc), forMode: RemoteElement.DefaultMode)
      }

    }

  }

  @NSManaged public var title:            NSAttributedString?
  @NSManaged public var icon:             ImageView?
  @NSManaged public var image:            ImageView?
  @NSManaged public var titles:           ControlStateTitleSet?
  @NSManaged public var icons:            ControlStateImageSet?
  @NSManaged public var backgroundColors: ControlStateColorSet?
  @NSManaged public var images:           ControlStateImageSet?
  @NSManaged public var command:          Command?
  @NSManaged public var longPressCommand: Command?

  @NSManaged var primitiveState: NSNumber
  public var state: UIControlState {
    get {
      willAccessValueForKey("state")
      let state = primitiveState
      didAccessValueForKey("state")
      return UIControlState(rawValue: UInt(state.integerValue))
    }
    set {
      willChangeValueForKey("state")
      primitiveState = newValue.rawValue
      didChangeValueForKey("state")
    }
  }

  public var selected: Bool {
    get {
      willAccessValueForKey("selected")
      let selected = state & UIControlState.Selected != nil
      didAccessValueForKey("selected")
      return selected
    }
    set {
      willChangeValueForKey("selected")
      if newValue { state |= UIControlState.Selected } else { state &= ~UIControlState.Selected }
      didChangeValueForKey("selected")
    }
  }

  public var highlighted: Bool {
    get {
      willAccessValueForKey("highlighted")
      let highlighted = state & UIControlState.Highlighted != nil
      didAccessValueForKey("highlighted")
      return highlighted
    }
    set {
      willChangeValueForKey("highlighted")
      if newValue { state |= UIControlState.Highlighted } else { state &= ~UIControlState.Highlighted }
      didChangeValueForKey("highlighted")
    }
  }

  public var enabled: Bool {
    get {
      willAccessValueForKey("enabled")
      let enabled = state & UIControlState.Disabled == nil
      didAccessValueForKey("enabled")
      return enabled
    }
    set {
      willChangeValueForKey("enabled")
      if !newValue { state |= UIControlState.Disabled } else { state &= ~UIControlState.Disabled }
      didChangeValueForKey("enabled")
    }
  }

  @NSManaged var primitiveTitleEdgeInsets: NSValue
  public var titleEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("titleEdgeInsets")
      let insets = primitiveTitleEdgeInsets
      didAccessValueForKey("titleEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("titleEdgeInsets")
      primitiveTitleEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("titleEdgeInsets")
    }
  }

  @NSManaged var primitiveImageEdgeInsets: NSValue
  public var imageEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("imageEdgeInsets")
      let insets = primitiveImageEdgeInsets
      didAccessValueForKey("imageEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("imageEdgeInsets")
      primitiveImageEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("imageEdgeInsets")
    }
  }

  @NSManaged var primitiveContentEdgeInsets: NSValue
  public var contentEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("contentEdgeInsets")
      let insets = primitiveContentEdgeInsets
      didAccessValueForKey("contentEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("contentEdgeInsets")
      primitiveContentEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("contentEdgeInsets")
    }
  }

  /**
   executeCommandWithOption:

   :param: options CommandOptions
   :param: completion ((Bool, NSError?) -> Void)?
   */
   public func executeCommandWithOption(option: Command.Option, completion: ((Bool, NSError?) -> Void)?) {
     var c: Command?

     switch option {
       case .Default:   c = command
       case .LongPress: c = longPressCommand
     }

     if c != nil { c!.execute(completion: completion) } else { completion?(true, nil) }
   }

  /**
  setCommand:forMode:

  :param: command Command?
  :param: mode String
  */
  public func setCommand(command: Command?, forMode mode: String) {
    setURIForObject(command, forKey: "command", forMode: mode)
  }

  /**
  setLongPressCommand:forMode:

  :param: command Command?
  :param: mode String
  */
  public func setLongPressCommand(command: Command?, forMode mode: String) {
    setURIForObject(command, forKey: "longPressCommand", forMode: mode)
  }

  /**
  setTitles:forMode:

  :param: titleSet ControlStateTitleSet?
  :param: mode String
  */
  public func setTitles(titleSet: ControlStateTitleSet?, forMode mode: String) {
    setURIForObject(titleSet, forKey: "titles", forMode: mode)
  }

  /**
  setBackgroundColors:forMode:

  :param: colorSet ControlStateColorSet?
  :param: mode String
  */
  public func setBackgroundColors(colorSet: ControlStateColorSet?, forMode mode: String) {
    setURIForObject(colorSet, forKey: "backgroundColors", forMode: mode)
  }

  /**
  setIcons:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  public func setIcons(imageSet: ControlStateImageSet?, forMode mode: String) {
    setURIForObject(imageSet, forKey: "icons", forMode: mode)
  }

  /**
  setImages:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  public func setImages(imageSet: ControlStateImageSet?, forMode mode: String) {
    setURIForObject(imageSet, forKey: "images", forMode: mode)
  }

  /**
  commandForMode:

  :param: mode String

  :returns: Command?
  */
  public func commandForMode(mode: String) -> Command? {
    return faultedObjectForKey("command", forMode: mode) as? Command
  }

  /**
  longPressCommandForMode:

  :param: mode String

  :returns: Command?
  */
  public func longPressCommandForMode(mode: String) -> Command? {
    return faultedObjectForKey("longPressCommand", forMode: mode) as? Command
  }

  /**
  titlesForMode:

  :param: mode String

  :returns: ControlStateTitleSet?
  */
  public func titlesForMode(mode: String) -> ControlStateTitleSet? {
    return faultedObjectForKey("titles", forMode: mode) as? ControlStateTitleSet
  }

  /**
  backgroundColorsForMode:

  :param: mode String

  :returns: ControlStateColorSet?
  */
  public func backgroundColorsForMode(mode: String) -> ControlStateColorSet? {
    return faultedObjectForKey("backgroundColors", forMode: mode) as? ControlStateColorSet
  }

  /**
  iconsForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func iconsForMode(mode: String) -> ControlStateImageSet? {
    return faultedObjectForKey("icons", forMode: mode) as? ControlStateImageSet
  }

  /**
  imagesForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func imagesForMode(mode: String) -> ControlStateImageSet? {
    return faultedObjectForKey("images", forMode: mode) as? ControlStateImageSet
  }

  /** updateButtonForState */
  public func updateButtonForState() {
    let idx = state.rawValue
    title = titles?.attributedStringForState(state)
    icon = icons?[idx] as? ImageView
    image = images?[idx] as? ImageView
    backgroundColor = backgroundColors?[idx] as? UIColor
  }

  /**
  updateForMode:

  :param: mode String
  */
  override public func updateForMode(mode: String) {
    super.updateForMode(mode)
    command          = commandForMode(mode)          ?? commandForMode(RemoteElement.DefaultMode)
    longPressCommand = longPressCommandForMode(mode) ?? longPressCommandForMode(RemoteElement.DefaultMode)
    titles           = titlesForMode(mode)           ?? titlesForMode(RemoteElement.DefaultMode)
    icons            = iconsForMode(mode)            ?? iconsForMode(RemoteElement.DefaultMode)
    images           = imagesForMode(mode)           ?? imagesForMode(RemoteElement.DefaultMode)
    backgroundColors = backgroundColorsForMode(mode) ?? backgroundColorsForMode(RemoteElement.DefaultMode)

    updateButtonForState()
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let titles = data["titles"] as? [String:[String:AnyObject]] {
        for (mode, values) in titles {
          if let titleSet: ControlStateTitleSet = ControlStateTitleSet.importObjectWithData(values, context: moc) {
            setTitles(titleSet, forMode: mode)
          }
        }
      }

      if let icons = data["icons"] as? [String:[String:AnyObject]] {
        for (mode, values) in icons {
          setIcons(ControlStateImageSet.importObjectWithData(values, context: moc), forMode: mode)
        }
      }

      if let images = data["images"] as? [String:[String:AnyObject]] {
        for (mode, values) in images {
          setImages(ControlStateImageSet.importObjectWithData(values, context: moc), forMode: mode)
        }
      }

      if let backgroundColors = data["background-colors"] as? [String:[String:AnyObject]] {
        for (mode, values) in backgroundColors {
          setBackgroundColors(ControlStateColorSet.importObjectWithData(values, context: moc), forMode: mode)
        }
      }

      if let commands = data["commands"] as? [String:[String:AnyObject]] {
        for (mode, values) in commands {
          setCommand(Command.importObjectWithData(values, context: moc), forMode: mode)
        }
      }

      if let longPressCommands = data["long-press-commands"] as? [String:[String:AnyObject]] {
        for (mode, values) in longPressCommands {
          setCommand(Command.importObjectWithData(values, context: moc), forMode: mode)
        }
      }

      if let titleEdgeInsets = data["title-edge-insets"] as? String {
        self.titleEdgeInsets = UIEdgeInsetsFromString(titleEdgeInsets)
      }

      if let contentEdgeInsets = data["content-edge-insets"] as? String {
        self.contentEdgeInsets = UIEdgeInsetsFromString(contentEdgeInsets)
      }

      if let imageEdgeInsets = data["image-edge-insets"] as? String {
        self.imageEdgeInsets = UIEdgeInsetsFromString(imageEdgeInsets)
      }

    }

  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    dict["background-color"] = nil

    var titles            : JSONValue.ObjectValue = [:]
    var backgroundColors  : JSONValue.ObjectValue = [:]
    var icons             : JSONValue.ObjectValue = [:]
    var images            : JSONValue.ObjectValue = [:]
    var commands          : JSONValue.ObjectValue = [:]
    var longPressCommands : JSONValue.ObjectValue = [:]

    for mode in modes as [String] {
      if let modeTitles = titlesForMode(mode)?.jsonValue { titles[mode] = modeTitles }
      if let modeBackgroundColors = backgroundColorsForMode(mode)?.jsonValue {
        backgroundColors[mode] = modeBackgroundColors
      }
      if let modeIcons = iconsForMode(mode)?.jsonValue { icons[mode] = modeIcons }
      if let modeImages = imagesForMode(mode)?.jsonValue { images[mode] = modeImages }
      if let modeCommand = commandForMode(mode)?.jsonValue { commands[mode] = modeCommand }
      if let modeLongPressCommand = longPressCommandForMode(mode)?.jsonValue {
        longPressCommands[mode] = modeLongPressCommand
      }
    }

    dict["commands"]           = .Object(commands)
    dict["titles"]             = .Object(titles)
    dict["icons"]              = .Object(icons)
    dict["background-colors"]  = .Object(backgroundColors)
    dict["images"]             = .Object(images)

    appendValueForKey("titleEdgeInsets", toDictionary: &dict)
    appendValueForKey("imageEdgeInsets", toDictionary: &dict)
    appendValueForKey("contentEdgeInsets", toDictionary: &dict)
    return .Object(dict)
  }

  /**
  deepDescriptionDictionary

  :returns: MSDictionary
  */
/*
  override func deepDescriptionDictionary() -> MSDictionary {

    let element = faultedObject()

    let stringFromDescription: (String?) -> String = {
      string in string == nil || string!.isEmpty ? "nil" : string!.stringByShiftingLeft(4)
    }

    let dd = super.deepDescriptionDictionary()

    dd["titles"]            = stringFromDescription(element.titles?.deepDescription())
    dd["icons"]             = stringFromDescription(element.icons?.deepDescription())
    dd["backgroundColors"]  = stringFromDescription(element.backgroundColors?.deepDescription())
    dd["images"]            = stringFromDescription(element.images?.deepDescription())
    dd["command"]           = stringFromDescription(element.command?.deepDescription())
    dd["longPressCommand"]  = stringFromDescription(element.longPressCommand?.deepDescription())
    dd["titleEdgeInsets"]   = "\(element.titleEdgeInsets)"
    dd["imageEdgeInsets"]   = "\(element.imageEdgeInsets)"
    dd["contentEdgeInsets"] = "\(element.contentEdgeInsets)"


    return dd
  }
*/

}

/// MARK: - Presets
////////////////////////////////////////////////////////////////////////////////
// extension Button {

//   public protocol ButtonPreset: Preset {
//     var titles:            ControlStateTitleSet? { get set }
//     var icons:             ControlStateImageSet? { get set }
//     var backgroundColors:  ControlStateColorSet? { get set }
//     var images:            ControlStateImageSet? { get set }
//     var titleEdgeInsets:   UIEdgeInsets?         { get set }
//     var imageEdgeInsets:   UIEdgeInsets?         { get set }
//     var contentEdgeInsets: UIEdgeInsets?         { get set }
//   }

//   public enum PresetType {
//     case None
//     case ConnectionStatus, BatteryStatus                                         // Toolbar
//     case Top, Bottom                                                             // Rocker
//     case Tuck, SelectionPanel                                                    // Panel
//     case Up, Down, Left, Right, Center                                           // DPad
//     case One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Zero, Aux1, Aux2  // Numberpad
//     case Play, Stop, Pause, Skip, Replay, FF, Rewind, Record                     // Transport


//   }

//   /**
//   initWithPresetType:context:

//   :param: presetType PresetType
//   :param: context NSManagedObjectContext
//   */
//   convenience init(presetType: PresetType, context: NSManagedObjectContext) {
//     self.init(context: context)
//     switch presetType {
//       case .ConnectionStatus, .BatteryStatus:
//       case .Top, .Bottom:
//       case .Up, .Down, .Left, .Right, .Center:
//       case .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .Aux1, .Aux2:
//       case .Play, .Stop, .Pause, .Skip, .Replay, .FF, .Rewind, .Record:
//       default: break
//     }
//   }

// }

//extension Button.State: Equatable {}
//func ==(lhs: Button.State, rhs: Button.State) -> Bool { return lhs.rawValue == rhs.rawValue }
//
//extension Button.State: BitwiseOperationsType {
//  static var allZeros: Button.State { return self(rawValue: 0) }
//}
//func &(lhs: Button.State, rhs: Button.State) -> Button.State {
//  return Button.State(rawValue: (lhs.rawValue & rhs.rawValue))
//}
//func |(lhs: Button.State, rhs: Button.State) -> Button.State {
//  return Button.State(rawValue: (lhs.rawValue | rhs.rawValue))
//}
//func ^(lhs: Button.State, rhs: Button.State) -> Button.State {
//  return Button.State(rawValue: (lhs.rawValue ^ rhs.rawValue))
//}
//prefix func ~(x: Button.State) -> Button.State { return Button.State(rawValue: ~(x.rawValue)) }
