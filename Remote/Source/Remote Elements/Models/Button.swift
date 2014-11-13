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

class Button: RemoteElement {

  @NSManaged var title:            NSAttributedString?
  @NSManaged var icon:             ImageView?
  @NSManaged var image:            ImageView?
  @NSManaged var titles:           ControlStateTitleSet?
  @NSManaged var icons:            ControlStateImageSet?
  @NSManaged var backgroundColors: ControlStateColorSet?
  @NSManaged var images:           ControlStateImageSet?
  @NSManaged var command:          Command?
  @NSManaged var longPressCommand: Command?

  @NSManaged var primitiveState: NSNumber
  var state: REState {
    get {
      willAccessValueForKey("state")
      let state = primitiveState
      didAccessValueForKey("state")
      return REState(rawValue: state.shortValue)!
    }
    set {
      willChangeValueForKey("state")
      primitiveState = NSNumber(short: newValue.rawValue)
      didChangeValueForKey("state")
    }
  }

  var selected: Bool {
    get {
      willAccessValueForKey("selected")
      let selected = state & REState.Selected != nil
      didAccessValueForKey("selected")
      return selected
    }
    set {
      willChangeValueForKey("selected")
      if newValue { state |= REState.Selected } else { state &= ~REState.Selected }
      didChangeValueForKey("selected")
    }
  }

  var highlighted: Bool {
    get {
      willAccessValueForKey("highlighted")
      let highlighted = state & REState.Highilghted != nil
      didAccessValueForKey("highlighted")
      return highlighted
    }
    set {
      willChangeValueForKey("highlighted")
      if newValue { state |= REState.Highilghted } else { state &= ~REState.Highilghted }
      didChangeValueForKey("highlighted")
    }
  }

  var enabled: Bool {
    get {
      willAccessValueForKey("enabled")
      let enabled = state & REState.Disabled == nil
      didAccessValueForKey("enabled")
      return enabled
    }
    set {
      willChangeValueForKey("enabled")
      if !newValue { state |= REState.Disabled } else { state &= ~REState.Disabled }
      didChangeValueForKey("enabled")
    }
  }

  @NSManaged var primitiveTitleEdgeInsets: NSValue
  var titleEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("titleEdgeInsets")
      let insets = primitiveTitleEdgeInsets
      didAccessValueForKey("titleEdgeInsets")
      return insets
    }
    set {
      willChangeValueForKey("titleEdgeInsets")
      primitiveTitleEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("titleEdgeInsets")
    }
  }

  @NSManaged var primitiveImageEdgeInsets: NSValue
  var imageEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("imageEdgeInsets")
      let insets = primitiveImageEdgeInsets
      didAccessValueForKey("imageEdgeInsets")
      return insets
    }
    set {
      willChangeValueForKey("imageEdgeInsets")
      primitiveImageEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("imageEdgeInsets")
    }
  }

  @NSManaged var primitiveContentEdgeInsets: NSValue
  var contentEdgeInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("contentEdgeInsets")
      let insets = primitiveContentEdgeInsets
      didAccessValueForKey("contentEdgeInsets")
      return insets
    }
    set {
      willChangeValueForKey("contentEdgeInsets")
      primitiveContentEdgeInsets = NSValue(UIEdgeInsets: newValue)
      didChangeValueForKey("contentEdgeInsets")
    }
  }

  /**
   executeCommandWithOptions:

   :param: options CommandOptions
   :param: completion ((Bool, NSError?) -> Void)?
   */
   func executeCommandWithOptions(options: CommandOptions, completion: ((Bool, NSError?) -> Void)?) {
     var c: Command?

     switch options {
       case .CommandOptionDefault:   c = command
       case .CommandOptionLongPress: c = longPressCommand
     }

     if c != nil { c!.execute(completion: completion) } else { completion?(true, nil) }
   }

  /**
  setCommand:forMode:

  :param: command Command?
  :param: mode String
  */
  func setCommand(command: Command?, forMode mode: String) {
    self[configurationKey(mode, "command")] = command?.permanentURI
  }

  /**
  setLongPressCommand:forMode:

  :param: command Command?
  :param: mode String
  */
  func setLongPressCommand(command: Command?, forMode mode: String) {
    self[configurationKey(mode, "longPressCommand")] = command?.permanentURI
  }

  /**
  setTitles:forMode:

  :param: titleSet ControlStateTitleSet?
  :param: mode String
  */
  func setTitles(titleSet: ControlStateTitleSet?, forMode mode: String) {
    self[configurationKey(mode, "titles")] = titleSet?.permanentURI
  }

  /**
  setBackgroundColors:forMode:

  :param: colorSet ControlStateColorSet?
  :param: mode String
  */
  func setBackgroundColors(colorSet: ControlStateColorSet?, forMode mode: String) {
    self[configurationKey(mode, "backgroundColors")] = colorSet?.permanentURI
  }

  /**
  setIcons:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  func setIcons(imageSet: ControlStateImageSet?, forMode mode: String) {
    self[configurationKey(mode, "icons")] = imageSet?.permanentURI
  }

  /**
  setImages:forMode:

  :param: imageSet ControlStateImageSet?
  :param: mode String
  */
  func setImages(imageSet: ControlStateImageSet?, forMode mode: String) {
    self[configurationKey(mode, "images")] = imageSet?.permanentURI
  }

  /**
  commandForMode:

  :param: mode String

  :returns: Command?
  */
  func commandForMode(mode: String) -> Command? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "command")])?.faultedObject()
      as? Command
  }

  /**
  longPressCommandForMode:

  :param: mode String

  :returns: Command?
  */
  func longPressCommandForMode(mode: String) -> Command? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "longPressCommand")])?.faultedObject()
      as? Command
  }

  /**
  titlesForMode:

  :param: mode String

  :returns: ControlStateTitleSet?
  */
  func titlesForMode(mode: String) -> ControlStateTitleSet? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "titles")])?.faultedObject()
      as? ControlStateTitleSet
  }

  /**
  backgroundColorsForMode:

  :param: mode String

  :returns: ControlStateColorSet?
  */
  func backgroundColorsForMode(mode: String) -> ControlStateColorSet? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "backgroundColors")])?.faultedObject()
      as? ControlStateColorSet
  }

  /**
  iconsForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  func iconsForMode(mode: String) -> ControlStateImageSet? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "icons")])?.faultedObject()
      as? ControlStateImageSet
  }

  /**
  imagesForMode:

  :param: mode String

  :returns: ControlStateImageSet?
  */
  func imagesForMode(mode: String) -> ControlStateImageSet? {
    return managedObjectContext?.objectForURI(self[configurationKey(mode, "images")])?.faultedObject()
      as? ControlStateImageSet
  }

  /** updateButtonForState */
  func updateButtonForState() {
    let state = self.state
    title = titles[state]
    icon = icons[state]
    image = images[state]
    backgroundColor = backgroundColors[state]
  }

  /**
  updateForMode:

  :param: mode String
  */
  override func updateForMode(mode: String) {
    super.updateForMode(mode)
    command          = commandForMode(mode)          ?? commandForMode(REDefaultMode)
    longPressCommand = longPressCommandForMode(mode) ?? longPressCommandForMode(REDefaultMode)
    titles           = titlesForMode(mode)           ?? titlesForMode(REDefaultMode)
    icons            = iconsForMode(mode)            ?? iconsForMode(REDefaultMode)
    images           = imagesForMode(mode)           ?? imagesForMode(REDefaultMode)
    backgroundColors = backgroundColorsForMode(mode) ?? backgroundColorsForMode(REDefaultMode)

    updateButtonForState()
  }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]
  */
  override func updateWithData(data: [NSObject:AnyObject]) {
    super.updateWithData(data)

    state = buttonStateFromImportKey(data["state"])


    let titles:            NSDictionary = data["titles"]
    let commands:          NSDictionary = data["commands"]
    let longPressCommands: NSDictionary = data["long-press-commands"]
    let icons:             NSDictionary = data["icons"]
    let images:            NSDictionary = data["images"]
    let backgroundColors:  NSDictionary = data["background-colors"]
    let titleEdgeInsets:   NSString     = data["title-edge-insets"]
    let contentEdgeInsets: NSString     = data["content-edge-insets"]
    let imageEdgeInsets:   NSString     = data["image-edge-insets"]
    let moc = managedObjectContext!

    if let titles = data["titles"] as? [String:AnyObject] {
      for mode in titles {
        if let titleSet = moc.objectForURI(configurations[mode]["titles"]) {
          moc.deleteObject(titleSet)
          self.titleSet = nil
        }
        if let titleSet = ControlStateTitleSet.importObjectFromData(titles[mode], context: moc) {
          setTitles(titleSet, forMode: mode)
        }
      }
    }

    if let icons = data["icons"] as? [String:[String:AnyObject]] {
      for mode in icons {
        if let iconSet = moc.objectForURI(configurations[mode]["icons"]) {
          moc.deleteObject(iconSet)
          self.iconSet = nil
        }
        if let iconSet = ControlStateImageSet.importObjectFromData(icons[mode], context: moc) {
          setIcons(iconSet, forMode: mode)
        }
      }
    }

    if let images = data["images"] as? [String:[String:AnyObject]] {
      for mode in images {
        if let imageSet = moc.objectForURI(configurations[mode]["images"]) {
          moc.deleteObject(imageSet)
          self.imageSet = nil
        }
        if let imageSet = ControlStateImageSet.importObjectFromData(images[mode], context: moc) {
          setImages(imageSet, forMode: mode)
        }
      }
    }

    if let backgroundColors = data["background-colors"] as? [String:[String:AnyObject]] {
      for mode in backgroundColors {
        if let colorSet = moc.objectForURI(configurations[mode]["backgroundColors"]) {
          moc.deleteObject(colorSet)
          self.colorSet = nil
        }
        if let colorSet = ControlStateColorSet.importObjectFromData(backgroundColors[mode], context: moc) {
          setBackgroundColors(colorSet, forMode: mode)
        }
      }
    }

    if let commands = data["commands"] as? [String:[String:AnyObject]] {
      for mode in commands {
        if let command = moc.objectForURI(configurations[mode]["command"]) {
          moc.deleteObject(command)
          self.command = nil
        }
        if let command = Command.importObjectFromData(commands[mode], context: moc) {
          setCommand(command, forMode: mode)
        }
      }
    }

    if let longPressCommands = data["long-press-commands"] as? [String:[String:AnyObject]] {
      for mode in longPressCommands {
        if let longPressCommand = moc.objectForURI(configurations[mode]["longPressCommand"]) {
          moc.deleteObject(longPressCommand)
          self.longPressCommand = nil
        }
        if let longPressCommand = Command.importObjectFromData(longPressCommands[mode], context: moc) {
          setCommand(longPressCommand, forMode: mode)
        }
      }
    }

    if (titleEdgeInsets)   self.titleEdgeInsets   = UIEdgeInsetsFromString(titleEdgeInsets)
    if (contentEdgeInsets) self.contentEdgeInsets = UIEdgeInsetsFromString(contentEdgeInsets)
    if (imageEdgeInsets)   self.imageEdgeInsets   = UIEdgeInsetsFromString(imageEdgeInsets)

  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    dictionary["background-color"] = NSNull()

    let setValueForKeyIfNotDefault: (value: @autoclosure () -> NSObject?, key: String) = {
      [unowned self] (value, key) in
        if value != nil && !self.attributeValueIsDefault(key) { dictionary[key.camelCaseToDashCase()] = value! }
    }

    setValueForKeyIfNotDefault(stateJSONValueForButton(self), "state")

    let titles            = MSDictionary()
    let backgroundColors  = MSDictionary()
    let icons             = MSDictionary()
    let images            = MSDictionary()
    let commands          = MSDictionary()
    let longPressCommands = MSDictionary()

    for mode in modes {
      if let modeTitles = titlesForMode(mode)?.JSONDictionary() { titles[mode] = modeTitles }
      if let modeBackgroundColors = backgroundColorsForMode(mode)?.JSONDictionary() {
        backgroundColors[mode] = modeBackgroundColors
      }
      if let modeIcons = iconsForMode(mode)?.JSONDictionary() { icons[mode] = modeIcons }
      if let modeImages = imagesForMode(mode)?.JSONDictionary() { images[mode] = modeImages }
      if let modeCommand = commandForMode(mode)?.JSONDictionary() { commands[mode] = modeCommand }
      if let modeLongPressCommand = longPressCommandForMode(mode)?.JSONDictionary() {
        longPressCommands[mode] = modeLongPressCommand
      }
    }

    dictionary["commands"]           = commands
    dictionary["titles"]             = titles
    dictionary["icons"]              = icons
    dictionary["background-colors"]  = backgroundColors
    dictionary["images"]             = images

    setValueForKeyIfNotDefault(NSStringFromUIEdgeInsets(titleEdgeInsets),   "titleEdgeInsets")
    setValueForKeyIfNotDefault(NSStringFromUIEdgeInsets(imageEdgeInsets),   "imageEdgeInsets")
    setValueForKeyIfNotDefault(NSStringFromUIEdgeInsets(contentEdgeInsets), "contentEdgeInsets")

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  deepDescriptionDictionary

  :returns: MSDictionary
  */
  override func deepDescriptionDictionary() -> MSDictionary {

    let element = faultedObject()

    let stringFromDescription: (String?) -> String = {
      string in string == nil || string!.isEmpty ? "nil" : string!.stringByShiftingLeft(4)
    }

    let dd = super.deepDescriptionDictionary()

    dd["titles"]            = stringFromDescription(element.titles.deepDescription())
    dd["icons"]             = stringFromDescription(element.icons.deepDescription())
    dd["backgroundColors"]  = stringFromDescription(element.backgroundColors.deepDescription())
    dd["images"]            = stringFromDescription(element.images.deepDescription())
    dd["command"]           = stringFromDescription(element.command.deepDescription())
    dd["longPressCommand"]  = stringFromDescription(element.longPressCommand.deepDescription())
    dd["titleEdgeInsets"]   = UIEdgeInsetsString(element.titleEdgeInsets)
    dd["imageEdgeInsets"]   = UIEdgeInsetsString(element.imageEdgeInsets)
    dd["contentEdgeInsets"] = UIEdgeInsetsString(element.contentEdgeInsets)


    return dd
  }

}
