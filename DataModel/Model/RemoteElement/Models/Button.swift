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

  // MARK: - Updating the button

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      applyMaybe(ObjectJSONValue(data["titles"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setTitles(ControlStateTitleSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["icons"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setIcons(ControlStateImageSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["images"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setImages(ControlStateImageSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["backgroundColors"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setBackgroundColors(ControlStateColorSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["commands"])?.compressedMap({ObjectJSONValue($2)})) {
          self.setCommand( Command.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["longPress-commands"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setLongPressCommand(Command.importObjectWithData($2, context: moc), forMode: $1)
      }

      titleEdgeInsets = UIEdgeInsets(data["titleEdgeInsets"]) ?? UIEdgeInsets.zeroInsets
      contentEdgeInsets = UIEdgeInsets(data["contentEdgeInsets"]) ?? UIEdgeInsets.zeroInsets
      imageEdgeInsets = UIEdgeInsets(data["imageEdgeInsets"]) ?? UIEdgeInsets.zeroInsets

    }

  }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)

    if let moc = managedObjectContext {
      let mode = RemoteElement.DefaultMode
      if let titlesData = preset.titles {
        setTitles(ControlStateTitleSet.importObjectWithData(titlesData, context: moc), forMode: mode)
      }

      if let iconsData = preset.icons {
        setIcons(ControlStateImageSet.importObjectWithData(iconsData, context: moc), forMode: mode)
      }

      if let imagesData = preset.images {
        setImages(ControlStateImageSet.importObjectWithData(imagesData, context: moc), forMode: mode)
      }

      if let backgroundColorsData = preset.backgroundColors {
        setBackgroundColors(ControlStateColorSet.importObjectWithData(backgroundColorsData, context: moc), forMode: mode)
      }

      titleEdgeInsets = preset.titleEdgeInsets
      contentEdgeInsets = preset.contentEdgeInsets
      imageEdgeInsets = preset.imageEdgeInsets

      if let commandData = preset.command {
        setCommand(Command.importObjectWithData(commandData, context: moc), forMode: RemoteElement.DefaultMode)
      }

    }

  }

  override public func updateForMode(mode: Mode) {
    super.updateForMode(mode)
    title = (titlesForMode(currentMode) ?? titlesForMode(RemoteElement.DefaultMode))?.attributedStringForState(state)
    icon = (iconsForMode(currentMode) ?? iconsForMode(RemoteElement.DefaultMode))?[state.rawValue] as? ImageView
    image = (imagesForMode(currentMode) ?? imagesForMode(RemoteElement.DefaultMode))?[state.rawValue] as? ImageView
    command = commands[currentMode] ?? commands[RemoteElement.DefaultMode]
    longPressCommand = longPressCommands[currentMode] ?? longPressCommands[RemoteElement.DefaultMode]
  }

  // MARK: - Titles

  @NSManaged public private(set) var title: NSAttributedString?

  private(set) var titles: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("titles")
      storage = primitiveValueForKey("titles") as? ModalStorage
      didAccessValueForKey("titles")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "titles")
      }
      return storage
    }
    set {
      willChangeValueForKey("titles")
      setPrimitiveValue(newValue, forKey: "titles")
      didChangeValueForKey("titles")
    }
  }

  /**
  setTitles:forMode:

  :param: titleSet ControlStateTitleSet?
  :param: mode String
  */
  public func setTitles(titleSet: ControlStateTitleSet?, forMode mode: Mode) {
    setValue(titleSet, forMode: mode, inStorage: titles)
  }

  /**
  titlesForMode:

  :param: mode String

  :returns: ControlStateTitleSet?
  */
  public func titlesForMode(mode: Mode) -> ControlStateTitleSet? { return titles[mode] }


  // MARK: - Icons

  @NSManaged public private(set) var icon: ImageView?

  private(set) var icons: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("icons")
      storage = primitiveValueForKey("icons") as? ModalStorage
      didAccessValueForKey("icons")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "icons")
      }
      return storage
    }
    set {
      willChangeValueForKey("icons")
      setPrimitiveValue(newValue, forKey: "icons")
      didChangeValueForKey("icons")
    }
  }

  /**
  setIcons:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  public func setIcons(imageSet: ControlStateImageSet?, forMode mode: Mode) {
    setValue(imageSet, forMode: mode, inStorage: icons)
  }


  /**
  iconsForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func iconsForMode(mode: Mode) -> ControlStateImageSet? { return icons[mode] }

  // MARK: - Images

  @NSManaged public private(set) var image: ImageView?

  private(set) var images: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("images")
      storage = primitiveValueForKey("images") as? ModalStorage
      didAccessValueForKey("images")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "images")
      }
      return storage
    }
    set {
      willChangeValueForKey("images")
      setPrimitiveValue(newValue, forKey: "images")
      didChangeValueForKey("images")
    }
  }

  /**
  setImages:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  public func setImages(imageSet: ControlStateImageSet?, forMode mode: Mode) {
    setValue(imageSet, forMode: mode, inStorage: images)
  }

  /**
  imagesForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func imagesForMode(mode: Mode) -> ControlStateImageSet? { return images[mode] }

  // MARK: - Commands

  @NSManaged public private(set) var command: Command?

  private(set) var commands: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("commands")
      storage = primitiveValueForKey("commands") as? ModalStorage
      didAccessValueForKey("commands")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "commands")
      }
      return storage
    }
    set {
      willChangeValueForKey("commands")
      setPrimitiveValue(newValue, forKey: "commands")
      didChangeValueForKey("commands")
    }
  }

  /**
  commandForMode:

  :param: mode Mode

  :returns: Command?
  */
  public func commandForMode(mode: Mode) -> Command? { return commands[mode] }

  /**
  setCommand:forMode:

  :param: command Command?
  :param: mode Mode
  */
  public func setCommand(command: Command?, forMode mode: Mode) { setValue(command, forMode: mode, inStorage: commands) }
  

  @NSManaged public private(set) var longPressCommand: Command?

  private(set) var longPressCommands: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("longPressCommands")
      storage = primitiveValueForKey("longPressCommands") as? ModalStorage
      didAccessValueForKey("longPressCommands")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "longPressCommands")
      }
      return storage
    }
    set {
      willChangeValueForKey("longPressCommands")
      setPrimitiveValue(newValue, forKey: "longPressCommands")
      didChangeValueForKey("longPressCommands")
    }
  }


  /**
  longPressCommandForMode:

  :param: mode Mode

  :returns: Command?
  */
  public func longPressCommandForMode(mode: Mode) -> Command? { return longPressCommands[mode] }

  /**
  setLongPressCommand:forMode:

  :param: command Command?
  :param: mode Mode
  */
  public func setLongPressCommand(command: Command?, forMode mode: Mode) {
    setValue(command, forMode: mode, inStorage: longPressCommands)
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


  // MARK: - Background colors

  private(set) var backgroundColors: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("backgroundColors")
      storage = primitiveValueForKey("backgroundColors") as? ModalStorage
      didAccessValueForKey("backgroundColors")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "backgroundColors")
      }
      return storage
    }
    set {
      willChangeValueForKey("backgroundColors")
      setPrimitiveValue(newValue, forKey: "backgroundColors")
      didChangeValueForKey("backgroundColors")
    }
  }

  /**
  setBackgroundColors:forMode:

  :param: colorSet ControlStateColorSet?
  :param: mode String
  */
  public func setBackgroundColors(colorSet: ControlStateColorSet?, forMode mode: Mode) {
    setValue(colorSet, forMode: mode, inStorage: backgroundColors)
  }

  /**
  backgroundColorsForMode:

  :param: mode String

  :returns: ControlStateColorSet?
  */
  public func backgroundColorsForMode(mode: Mode) -> ControlStateColorSet? { return backgroundColors[mode] }

  /**
  backgroundColorForMode:

  :param: mode Mode

  :returns: UIColor?
  */
  override public func backgroundColorForMode(mode: Mode) -> UIColor? {
    return backgroundColorsForMode(currentMode)?[state.rawValue] as? UIColor
  }

  /**
  setBackgroundColor:forMode:

  :param: color UIColor?
  :param: mode Mode
  */
  override public func setBackgroundColor(color: UIColor?, forMode mode: Mode) {}

  // MARK: - State

  public var state: UIControlState {
    get {
      willAccessValueForKey("state")
      let state = primitiveValueForKey("state") as! NSNumber
      didAccessValueForKey("state")
      return UIControlState(rawValue: state.unsignedLongValue)
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

  // MARK: - Insets

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

  // MARK: - JSON value

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

    obj["titleEdgeInsets"]   = titleEdgeInsets.jsonValue
    obj["imageEdgeInsets"]   = imageEdgeInsets.jsonValue
    obj["contentEdgeInsets"] = contentEdgeInsets.jsonValue

    return obj.jsonValue
  }

  // MARK: - Printable

  override public var description: String {
    var result = super.description
    result += "\n\ttitles = {\n\(titles.description.indentedBy(8))\n\t}"
    result += "\n\ttitle = \(toString(title))"
    result += "\n\ticons = {\n\(icons.description.indentedBy(8))\n\t}"
    result += "\n\ticon = \(toString(icon))"
    result += "\n\tbackgroundColors = {\n\(backgroundColors.description.indentedBy(8))\n\t}"
    result += "\n\tbackgroundColor = \(toString(backgroundColor))"
    result += "\n\timages = {\n\(images.description.indentedBy(8))\n\t}"
    result += "\n\timage = \(toString(image))"
    result += "\n\tcommands = {\n\(commands.description.indentedBy(8))\n\t}"
    result += "\n\tcommand = \(toString(command))"
    result += "\n\tlongPressCommands = {\n\(longPressCommands.description.indentedBy(8))\n\t}"
    result += "\n\tlongPressCommand = \(toString(longPressCommand))"
    result += "\n\ttitleEdgeInsets = \(titleEdgeInsets)"
    result += "\n\timageEdgeInsets = \(imageEdgeInsets)"
    result += "\n\tcontentEdgeInsets = \(contentEdgeInsets)"
    result += "\n\tselected = \(selected)"
    result += "\n\thighlighted = \(highlighted)"
    result += "\n\tenabled = \(enabled)"
    return result
  }
}
