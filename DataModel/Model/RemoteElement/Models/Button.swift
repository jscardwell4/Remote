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

  override var modalStorageContainers: Set<ModalStorage> {
    return super.modalStorageContainers ∪ [titleSets, backgroundColorSets, iconSets, commands, longPressCommands, backgroundSets]
  }

  // MARK: - Updating the button

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      applyMaybe(ObjectJSONValue(data["titleSets"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setTitles(ControlStateTitleSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["iconSets"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setIconSet(ControlStateImageSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["backgroundSets"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setBackgroundSet(ControlStateImageSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["backgroundColorSets"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setBackgroundColorSet(ControlStateColorSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["foregroundColorSets"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setForegroundColorSet(ControlStateColorSet.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["commands"])?.compressedMap({ObjectJSONValue($2)})) {
          self.setCommand( Command.importObjectWithData($2, context: moc), forMode: $1)
      }

      applyMaybe(ObjectJSONValue(data["longPressCommands"])?.compressedMap({ObjectJSONValue($2)})) {
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
      let mode = defaultMode
      if let titlesData = preset.titles {
        setTitles(ControlStateTitleSet.importObjectWithData(titlesData, context: moc), forMode: mode)
      }

      if let iconsData = preset.icons {
        setIconSet(ControlStateImageSet.importObjectWithData(iconsData, context: moc), forMode: mode)
      }

      if let imagesData = preset.images {
        setBackgroundSet(ControlStateImageSet.importObjectWithData(imagesData, context: moc), forMode: mode)
      }

      if let backgroundColorsData = preset.backgroundColors {
        setBackgroundColorSet(ControlStateColorSet.importObjectWithData(backgroundColorsData, context: moc), forMode: mode)
      }

      titleEdgeInsets = preset.titleEdgeInsets
      contentEdgeInsets = preset.contentEdgeInsets
      imageEdgeInsets = preset.imageEdgeInsets

      if let commandData = preset.command {
        setCommand(Command.importObjectWithData(commandData, context: moc), forMode: defaultMode)
      }

    }

  }

  /**
  updateForMode:

  :param: mode Mode
  */
  override func updateForMode(mode: Mode) {
    super.updateForMode(mode)
    titleSet = titlesForMode(currentMode) ?? titlesForMode(defaultMode)
    iconSet = iconSetForMode(currentMode) ?? iconSetForMode(defaultMode)
    backgroundSet = backgroundSetForMode(currentMode) ?? backgroundSetForMode(defaultMode)
    backgroundColorSet = backgroundColorSetForMode(currentMode) ?? backgroundColorSetForMode(defaultMode)
    foregroundColorSet = foregroundColorSetForMode(currentMode) ?? foregroundColorSetForMode(defaultMode)
    command = commands[currentMode] ?? commands[defaultMode]
    longPressCommand = longPressCommands[currentMode] ?? longPressCommands[defaultMode]

    updateForState(state)
  }

  /**
  updateForState:

  :param: state UIControlState
  */
  func updateForState(state: UIControlState) {
    title = titleSet?.attributedStringForState(state)
    icon = iconSet?.imageViewForState(state)
    backgroundColor = backgroundColorSet?.colorForState(state)
    foregroundColor = foregroundColorSet?.colorForState(state)
    let bg = backgroundSet?.imageViewForState(state)
    background?.image = bg?.image
    background?.color = bg?.color
    background?.alpha = bg?.alpha
  }

  // MARK: - Titles

  @NSManaged public private(set) var title: NSAttributedString?

  @NSManaged public private(set) var titleSet: ControlStateTitleSet?

  private(set) var titleSets: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("titleSets")
      storage = primitiveValueForKey("titleSets") as? ModalStorage
      didAccessValueForKey("titleSets")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "titleSets")
      }
      return storage
    }
    set {
      willChangeValueForKey("titleSets")
      setPrimitiveValue(newValue, forKey: "titleSets")
      didChangeValueForKey("titleSets")
    }
  }

  /**
  setTitles:forMode:

  :param: titleSet ControlStateTitleSet?
  :param: mode String
  */
  public func setTitles(titleSet: ControlStateTitleSet?, forMode mode: Mode) {
    setValue(titleSet, forMode: mode, inStorage: titleSets)
    if currentMode == mode { self.titleSet = titleSet; title = titleSet?.attributedStringForState(state) }
  }

  /**
  titlesForMode:

  :param: mode String

  :returns: ControlStateTitleSet?
  */
  public func titlesForMode(mode: Mode) -> ControlStateTitleSet? { return titleSets[mode] }


  // MARK: - Icons

  public typealias Icon = ImageView

  @NSManaged public private(set) var icon: Icon?

  private(set) var iconSets: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("iconSets")
      storage = primitiveValueForKey("iconSets") as? ModalStorage
      didAccessValueForKey("iconSets")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "iconSets")
      }
      return storage
    }
    set {
      willChangeValueForKey("iconSets")
      setPrimitiveValue(newValue, forKey: "iconSets")
      didChangeValueForKey("iconSets")
    }
  }

  @NSManaged public private(set) var iconSet: ControlStateImageSet?

  /**
  setIconSet:forMode:

  :param: iconSet ControlStateImageSet?
  :param: mode String
  */
  public func setIconSet(iconSet: ControlStateImageSet?, forMode mode: Mode) {
    setValue(iconSet, forMode: mode, inStorage: iconSets)
    if currentMode == mode { self.iconSet = iconSet; icon = iconSet?.imageViewForState(state) }
  }


  /**
  iconSetForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func iconSetForMode(mode: Mode) -> ControlStateImageSet? { return iconSets[mode] }

  // MARK: - Backgrounds

  @NSManaged public private(set) var backgroundSet: ControlStateImageSet?

  private(set) var backgroundSets: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("backgroundSets")
      storage = primitiveValueForKey("backgroundSets") as? ModalStorage
      didAccessValueForKey("backgroundSets")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "backgroundSets")
      }
      return storage
    }
    set {
      willChangeValueForKey("backgroundSets")
      setPrimitiveValue(newValue, forKey: "backgroundSets")
      didChangeValueForKey("backgroundSets")
    }
  }

  /**
  setBackgroundSet:forMode:

  :param: backgroundSet ControlStateImageSet?
  :param: mode String
  */
  public func setBackgroundSet(backgroundSet: ControlStateImageSet?, forMode mode: Mode) {
    setValue(backgroundSet, forMode: mode, inStorage: backgroundSets)
    if currentMode == mode {
      self.backgroundSet = backgroundSet
      let bg = backgroundSet?.imageViewForState(state)
      background?.image = bg?.image
      background?.color = bg?.color
      background?.alpha = bg?.alpha
    }
  }

  /**
  backgroundSetForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  public func backgroundSetForMode(mode: Mode) -> ControlStateImageSet? { return backgroundSets[mode] }

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
  public func setCommand(command: Command?, forMode mode: Mode) {
    setValue(command, forMode: mode, inStorage: commands)
    if currentMode == mode { self.command = command }
  }


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
    if currentMode == mode { longPressCommand = command }
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

  @NSManaged public private(set) var backgroundColor: UIColor?

  @NSManaged public private(set) var backgroundColorSet: ControlStateColorSet?

  private(set) var backgroundColorSets: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("backgroundColorSets")
      storage = primitiveValueForKey("backgroundColorSets") as? ModalStorage
      didAccessValueForKey("backgroundColorSets")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "backgroundColorSets")
      }
      return storage
    }
    set {
      willChangeValueForKey("backgroundColorSets")
      setPrimitiveValue(newValue, forKey: "backgroundColorSets")
      didChangeValueForKey("backgroundColorSets")
    }
  }

  /**
  setBackgroundColorSet:forMode:

  :param: colorSet ControlStateColorSet?
  :param: mode String
  */
  public func setBackgroundColorSet(colorSet: ControlStateColorSet?, forMode mode: Mode) {
    setValue(colorSet, forMode: mode, inStorage: backgroundColorSets)
    if currentMode == mode { backgroundColorSet = colorSet; backgroundColor = backgroundColorSet?.colorForState(state) }
  }

  /**
  backgroundColorsForMode:

  :param: mode String

  :returns: ControlStateColorSet?
  */
  public func backgroundColorSetForMode(mode: Mode) -> ControlStateColorSet? { return backgroundColorSets[mode] }

  // MARK: - Foreground colors

  @NSManaged public private(set) var foregroundColor: UIColor?

  @NSManaged public private(set) var foregroundColorSet: ControlStateColorSet?

  private(set) var foregroundColorSets: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("foregroundColorSets")
      storage = primitiveValueForKey("foregroundColorSets") as? ModalStorage
      didAccessValueForKey("foregroundColorSets")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "foregroundColorSets")
      }
      return storage
    }
    set {
      willChangeValueForKey("foregroundColorSets")
      setPrimitiveValue(newValue, forKey: "foregroundColorSets")
      didChangeValueForKey("foregroundColorSets")
    }
  }

  /**
  setForegroundColorSet:forMode:

  :param: colorSet ControlStateColorSet?
  :param: mode String
  */
  public func setForegroundColorSet(colorSet: ControlStateColorSet?, forMode mode: Mode) {
    setValue(colorSet, forMode: mode, inStorage: foregroundColorSets)
    if currentMode == mode { foregroundColorSet = colorSet; foregroundColor = foregroundColorSet?.colorForState(state) }
  }

  /**
  foregroundColorsForMode:

  :param: mode String

  :returns: ControlStateColorSet?
  */
  public func foregroundColorSetForMode(mode: Mode) -> ControlStateColorSet? { return foregroundColorSets[mode] }

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

    var titles            : JSONValue.ObjectValue = [:]
    var backgroundColors  : JSONValue.ObjectValue = [:]
    var icons             : JSONValue.ObjectValue = [:]
    var images            : JSONValue.ObjectValue = [:]
    var commands          : JSONValue.ObjectValue = [:]
    var longPressCommands : JSONValue.ObjectValue = [:]

    for mode in modes {
      if let modeTitles = titlesForMode(mode)?.jsonValue { titles[mode] = modeTitles }
      if let modeBackgroundColors = backgroundColorSetForMode(mode)?.jsonValue {
        backgroundColors[mode] = modeBackgroundColors
      }
      if let modeIcons = iconSetForMode(mode)?.jsonValue { icons[mode] = modeIcons }
      if let modeImages = backgroundSetForMode(mode)?.jsonValue { images[mode] = modeImages }
      if let modeCommand = commandForMode(mode)?.jsonValue { commands[mode] = modeCommand }
      if let modeLongPressCommand = longPressCommandForMode(mode)?.jsonValue {
        longPressCommands[mode] = modeLongPressCommand
      }
    }

    obj["commands"]              = .Object(commands)
    obj["titleSets"]             = .Object(titles)
    obj["iconSets"]              = .Object(icons)
    obj["backgroundColorSets"]   = .Object(backgroundColors)
    obj["backgroundSets"]        = .Object(images)

    obj["titleEdgeInsets"]   = titleEdgeInsets.jsonValue
    obj["imageEdgeInsets"]   = imageEdgeInsets.jsonValue
    obj["contentEdgeInsets"] = contentEdgeInsets.jsonValue

    return obj.jsonValue
  }

  // MARK: - Printable

  override public var description: String {
    var result = super.description
    result += "\n\ttitleSets = {\n\(titleSets.description.indentedBy(8))\n\t}"
    result += "\n\ttitle = \(toString(title))"
    result += "\n\ticonSets = {\n\(iconSets.description.indentedBy(8))\n\t}"
    result += "\n\ticon = \(toString(icon))"
    result += "\n\tbackgroundColorSets = {\n\(backgroundColorSets.description.indentedBy(8))\n\t}"
    result += "\n\tbackgroundColor = \(toString((backgroundSet?[state.rawValue] as? UIColor)?.string))"
    result += "\n\tbackgroundSets = {\n\(backgroundSets.description.indentedBy(8))\n\t}"
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
