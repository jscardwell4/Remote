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

  override public var elementType: BaseType { return .Button }
  override public class var parentElementType: RemoteElement.Type? { return ButtonGroup.self }

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

  public var state: UIControlState {
    get {
      willAccessValueForKey("state")
      let state = primitiveValueForKey("state") as! NSNumber
      didAccessValueForKey("state")
      return UIControlState(rawValue: UInt(state.integerValue))
    }
    set {
      willChangeValueForKey("state")
      setPrimitiveValue(newValue.rawValue, forKey: "state")
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

  public var titleEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("titleEdgeInsets")
      let insets = primitiveValueForKey("titleEdgeInsets") as! NSValue
      didAccessValueForKey("titleEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("titleEdgeInsets")
      setPrimitiveValue(NSValue(UIEdgeInsets: newValue), forKey: "titleEdgeInsets")
      didChangeValueForKey("titleEdgeInsets")
    }
  }

  public var imageEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("imageEdgeInsets")
      let insets = primitiveValueForKey("imageEdgeInsets") as! NSValue
      didAccessValueForKey("imageEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("imageEdgeInsets")
      setPrimitiveValue(NSValue(UIEdgeInsets: newValue), forKey: "imageEdgeInsets")
      didChangeValueForKey("imageEdgeInsets")
    }
  }

  public var contentEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("contentEdgeInsets")
      let insets = primitiveValueForKey("contentEdgeInsets") as! NSValue
      didAccessValueForKey("contentEdgeInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("contentEdgeInsets")
      setPrimitiveValue(NSValue(UIEdgeInsets: newValue), forKey: "contentEdgeInsets")
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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let titles = ObjectJSONValue(data["titles"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in titles {
          if let titleSet = ControlStateTitleSet.importObjectWithData(jsonValue, context: moc) {
            setTitles(titleSet, forMode: mode)
          }
        }
      }

      if let icons = ObjectJSONValue(data["icons"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in icons {
          if let  imageSet = ControlStateImageSet.importObjectWithData(jsonValue, context: moc) {
            setIcons(imageSet, forMode: mode)
          }
        }
      }

      if let images = ObjectJSONValue(data["images"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in images {
          if let imageSet = ControlStateImageSet.importObjectWithData(jsonValue, context: moc) {
            setImages(imageSet, forMode: mode)
          }
        }
      }

      if let backgroundColors = ObjectJSONValue(data["backgroundColors"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in backgroundColors {
          if let colorSet = ControlStateColorSet.importObjectWithData(jsonValue, context: moc) {
            setBackgroundColors(colorSet, forMode: mode)
          }
        }
      }

      if let commands = ObjectJSONValue(data["commands"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in commands {
          if let command = Command.importObjectWithData(jsonValue, context: moc) { setCommand(command, forMode: mode) }
        }
      }

      if let longPressCommands = ObjectJSONValue(data["longPress-commands"])?.compressedMap({ObjectJSONValue($2)}) {
        for (_, mode, jsonValue) in longPressCommands {
          if let command = Command.importObjectWithData(jsonValue, context: moc){ setLongPressCommand(command, forMode: mode) }
        }
      }

      if let titleEdgeInsets = UIEdgeInsets(data["titleEdge-insets"]) { self.titleEdgeInsets = titleEdgeInsets }
      if let contentEdgeInsets = UIEdgeInsets(data["contentEdge-insets"]) { self.contentEdgeInsets = contentEdgeInsets }
      if let imageEdgeInsets = UIEdgeInsets(data["imageEdge-insets"]) { self.imageEdgeInsets = imageEdgeInsets }

    }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["backgroundColor"] = nil

    var titles            : JSONValue.ObjectValue = [:]
    var backgroundColors  : JSONValue.ObjectValue = [:]
    var icons             : JSONValue.ObjectValue = [:]
    var images            : JSONValue.ObjectValue = [:]
    var commands          : JSONValue.ObjectValue = [:]
    var longPressCommands : JSONValue.ObjectValue = [:]

    for mode in modes {
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

    obj["commands"]           = .Object(commands)
    obj["titles"]             = .Object(titles)
    obj["icons"]              = .Object(icons)
    obj["backgroundColors"]   = .Object(backgroundColors)
    obj["images"]             = .Object(images)

    obj["titleEdge-insets"]   = titleEdgeInsets.jsonValue
    obj["imageEdge-insets"]   = imageEdgeInsets.jsonValue
    obj["contentEdge-insets"] = contentEdgeInsets.jsonValue

    return obj.jsonValue
  }

}
