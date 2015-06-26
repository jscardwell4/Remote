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

  // MARK: - Type overrides
  override public var elementType: BaseType { return .ButtonGroup }
  override public class var parentElementType: RemoteElement.Type? { return Remote.self }
  override public class var subelementType: RemoteElement.Type? { return Button.self }

  // MARK: - Updating the ButtonGroup

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let autohide = Bool(data["autohide"]) { self.autohide = autohide }

      applyMaybe(ObjectJSONValue(data["commandContainers"])?.compressedMap({ObjectJSONValue($2)})) {
        if $2["type"] != nil {
          self.setCommandContainer(CommandSet.importObjectWithData($2, context: moc), forMode: $1)
        } else {
          self.setCommandContainer(CommandSetCollection.importObjectWithData($2, context: moc), forMode: $1)
        }
      }

      labelConstraints = String(data["labelConstraints"])

      applyMaybe(ObjectJSONValue(data["labelAttributes"])) { self.setLabelAttributes(TitleAttributes($2), forMode: $1) }

    }

  }

  /**
  updateWithPreset:

  - parameter preset: Preset
  */
  override func updateWithPreset(preset: Preset) {
    super.updateWithPreset(preset)

    autohide = preset.autohide ?? false
    if let attributes = preset.labelAttributes { setLabelAttributes(attributes, forMode: defaultMode) }
    labelConstraints = preset.labelConstraints
    // if let panelAssignment = preset.panelAssignment { self.panelAssignment = panelAssignment }
  }

  @NSManaged public var autohide: Bool

  // MARK: - Configurations

  /**
  updateForMode:

  - parameter mode: String
  */
  override func updateForMode(mode: String) {
    super.updateForMode(mode)
    label = (labelAttributesForMode(currentMode) ?? labelAttributesForMode(defaultMode))?.string
    commandContainer = commandContainers[currentMode] ?? commandContainers[defaultMode]
    updateButtons()
  }

  override var modalStorageContainers: Set<ModalStorage> {
    return super.modalStorageContainers ∪ Set([labelAttributes, commandContainers])
  }

  /** updateButtons */
  public func updateButtons() {
    if let commands = (commandSet ?? commandSetCollection?[commandSetIndex])?.faultedObject() {
      for button in subelements.map({$0 as! Button}) {
         if button.role == RemoteElement.Role.Tuck { continue }
         button.setCommand(commands[button.role], forMode: currentMode)
         button.enabled = button.command != nil
      }
    }
  }

  // MARK: Labels

  @NSManaged public private(set) var label: NSAttributedString?

  private(set) var labelAttributes: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("labelAttributes")
      storage = primitiveValueForKey("labelAttributes") as? ModalStorage
      didAccessValueForKey("labelAttributes")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
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

  /**
  labelAttributesForMode:

  - parameter mode: Mode

  - returns: TitleAttributes?
  */
  public func labelAttributesForMode(mode: Mode) -> TitleAttributes? {
    return TitleAttributes(storage: labelAttributes[mode]?.dictionary)
  }

  /**
  setLabelAttributes:forMode:

  - parameter attributes: TitleAttributes
  - parameter mode: Mode
  */
  public func setLabelAttributes(attributes: TitleAttributes?, forMode mode: Mode) {
    if attributes == nil {
      setValue(nil, forMode: mode, inStorage: labelAttributes)
    } else {
      let modeStorage: JSONStorage
      if let storage: JSONStorage = labelAttributes[mode] { modeStorage = storage }
      else  {
        modeStorage = JSONStorage(context: managedObjectContext)
        setValue(modeStorage, forMode: mode, inStorage: labelAttributes)
      }
      modeStorage.dictionary = attributes!.storage
    }
  }

  /**
  labelForCommandSetAtIndex:

  - parameter idx: Int

  - returns: NSAttributedString?
  */
  public func labelForCommandSetAtIndex(idx: Int) -> NSAttributedString? {
    if let collection = commandSetCollection where (0 ..< Int(collection.count)).contains(idx),
     let text = collection.labelAtIndex(idx), var titleAttributes = labelAttributesForMode(currentMode)
    {
      titleAttributes.text = text
      return titleAttributes.string
    } else { return nil }
  }

  // MARK: CommandSet(Collection)s

  @NSManaged public private(set) var commandContainer: CommandContainer?
  public var commandSet: CommandSet? { return commandContainer as? CommandSet }
  public var commandSetCollection: CommandSetCollection? { return commandContainer as? CommandSetCollection }

  private(set) var commandContainers: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("commandContainers")
      storage = primitiveValueForKey("commandContainers") as? ModalStorage
      didAccessValueForKey("commandContainers")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "commandContainers")
      }
      return storage
    }
    set {
      willChangeValueForKey("commandContainers")
      setPrimitiveValue(newValue, forKey: "commandContainers")
      didChangeValueForKey("commandContainers")
    }
  }

  /**
  setCommandContainer:forMode:

  - parameter container: CommandContainer?
  - parameter mode: String
  */
  public func setCommandContainer(container: CommandContainer?, forMode mode: Mode) {
    setValue(container, forMode: mode, inStorage: commandContainers)
  }

  /**
  commandContainerForMode:

  - parameter mode: String

  - returns: CommandContainer?
  */
  public func commandContainerForMode(mode: Mode) -> CommandContainer? { return commandContainers[mode] }

  /** Holds the index for the current `CommandSet` when the `CommandContainer` is a `CommandSetCollection` */
  public var commandSetIndex: Int = 0 {
    didSet {
      if let collection = commandSetCollection {
        if !(0 ..< Int(collection.count)).contains(commandSetIndex) { commandSetIndex = 0 }
        updateButtons()
      }
    }
  }

  // MARK: - JSONValue override

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    var commandSets           : JSONValue.ObjectValue = [:]
    var commandSetCollections : JSONValue.ObjectValue = [:]
    // FIXME: We aren't actually adding any labels
    let labels                : JSONValue.ObjectValue = [:]
    
    for mode in modes {
      if let container = commandContainerForMode(mode) {
        let d = container.jsonValue
        if container is CommandSetCollection { commandSetCollections[mode] = d }
        else if container is CommandSet { commandSets[mode] = d }
      }
    }

    if commandSetCollections.count > 0 { obj["commandSet-collection"] = .Object(commandSetCollections) }
    if commandSets.count > 0 { obj["commandSet"] = .Object(commandSets) }
    if labels.count > 0 { obj["label"] = .Object(labels) }
    if let constraints = labelConstraints { obj["labelConstraints"] = constraints.jsonValue }
    obj["labelAttributes"] = labelAttributes.jsonValue

    return obj.jsonValue
  }

  // MARK: - Printable
  override public var description: String {
    var result = super.description
    result += "\n\tautohide = \(autohide)"
    result += "\n\tlabelAttributes = {\n\(labelAttributes.description.indentedBy(8))\n\t}"
    result += "\n\tlabel = \(String(label))"
    result += "\n\tcommandContainers = {\n\(commandContainers.description.indentedBy(8))\n\t}"
    if let container = commandContainer { result += "\n\tcommandContainer = {\n\(container.description.indentedBy(8))\n\t}" }
    else { result += "\n\tcommandContainer = nil" }
    result += "\n\tcommandSetIndex = \(commandSetIndex)"
    return result
  }

}

