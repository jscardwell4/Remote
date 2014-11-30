//
//  RemoteElement.swift
//  Remote
//
//  Created by Jason Cardwell on 11/14/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(RemoteElement)
class RemoteElement: NamedModelObject {

  /**
  remoteElementFromPreset:context:

  :param: attributes PresetAttributes
  :param: context NSManagedObjectContext

  :returns: RemoteElement?
  */
  class func remoteElementFromPreset(attributes: PresetAttributes, context: NSManagedObjectContext) -> RemoteElement? {
    var element: RemoteElement?

    switch attributes.baseType {
      case .Remote:      element = Remote(attributes: attributes, context: context)
      case .ButtonGroup: element = ButtonGroup(attributes: attributes, context: context)
      case .Button:      element = Button(attributes: attributes, context: context)
      default: break
    }

    return element
  }

  /**
  initWithAttributes:context:

  :param: attributes PresetAttributes
  :param: context NSManagedObjectContext
  */
  convenience init(attributes: PresetAttributes, context: NSManagedObjectContext) {
    self.init(context: context)
    role = attributes.role
    shape = attributes.shape
    style = attributes.style
    setBackgroundColor(attributes.backgroundColor, forMode: RemoteElement.DefaultMode)
    setBackgroundImage(attributes.backgroundImage, forMode: RemoteElement.DefaultMode)
    setBackgroundImageAlpha(attributes.backgroundImageAlpha, forMode: RemoteElement.DefaultMode)
    var elements: OrderedSet<RemoteElement> = []
    if let elementsData = attributes.subelements {
      for subelementAttributes in elementsData {
        if let element = RemoteElement.remoteElementFromPreset(subelementAttributes, context: context) { elements.append(element) }
      }
    }
    childElements = elements
    if let constraints = attributes.constraints {
      constraintManager.setConstraintsFromString(constraints)
    }
  }

  @NSManaged var tag: NSNumber
  @NSManaged var key: String?
  var identifier: String { return "_" + filter(uuid){$0 != "-"} }

  @NSManaged var constraints: NSSet
  var ownedConstraints: [Constraint] {
    get { return constraints.allObjects as? [Constraint] ?? [] }
    set { constraints = NSSet(array: newValue) }
  }

  @NSManaged var firstItemConstraints: NSSet
  var firstOrderConstraints: [Constraint] {
    get { return firstItemConstraints.allObjects as? [Constraint] ?? [] }
    set { firstItemConstraints = NSSet(array: newValue) }
  }

  @NSManaged var secondItemConstraints: NSSet
  var secondOrderConstraints: [Constraint] {
    get { return secondItemConstraints.allObjects as? [Constraint] ?? [] }
    set { secondItemConstraints = NSSet(array: newValue) }
  }

  @NSManaged var backgroundImageAlpha: NSNumber
  @NSManaged var backgroundColor: UIColor?
  @NSManaged var backgroundImage: Image?

  @NSManaged var subelements: NSOrderedSet

  var childElements: OrderedSet<RemoteElement> {
    get { return OrderedSet(subelements.array as? [RemoteElement] ?? []) }
    set { subelements = NSOrderedSet(array: newValue.array) }
  }

  lazy var constraintManager: ConstraintManager = ConstraintManager(element: self)

  var modes: [String] {
    var modes = Array(configurations.keys) as [String]
    if modes ∌ RemoteElement.DefaultMode { modes.append(RemoteElement.DefaultMode) }
    return modes
  }

  dynamic var currentMode: String = RemoteElement.DefaultMode {
    didSet {
      if !hasMode(currentMode) { addMode(currentMode) }
      updateForMode(currentMode)
      apply(childElements){$0.currentMode = self.currentMode}
    }
  }

  @NSManaged var parentElement: RemoteElement?

  @NSManaged var primitiveRole: NSNumber
  var role: Role {
    get {
      willAccessValueForKey("role")
      let role = Role(rawValue: primitiveRole.integerValue)
      didAccessValueForKey("role")
      return role
    }
    set {
      willChangeValueForKey("role")
      primitiveRole = newValue.rawValue
      didChangeValueForKey("role")
    }
  }

  @NSManaged var primitiveShape: NSNumber
  var shape: Shape {
    get {
      willAccessValueForKey("shape")
      let shape = Shape(rawValue: primitiveShape.integerValue)
      didAccessValueForKey("shape")
      return shape ?? .Undefined
    }
    set {
      willChangeValueForKey("shape")
      primitiveShape = newValue.rawValue
      didChangeValueForKey("shape")
    }
  }

  @NSManaged var primitiveStyle: NSNumber
  var style: Style {
    get {
      willAccessValueForKey("style")
      let style = Style(rawValue: primitiveStyle.integerValue)
      didAccessValueForKey("style")
      return style
    }
    set {
      willChangeValueForKey("style")
      primitiveStyle = newValue.rawValue
      didChangeValueForKey("style")
    }
  }

  @NSManaged var primitiveConfigurations: NSMutableDictionary
  var configurations: [String:[String:AnyObject]] {
    get {
      willAccessValueForKey("configurations")
      let configurations = (primitiveConfigurations as NSDictionary) as? [String:[String:AnyObject]]
      didAccessValueForKey("configurations")
      return configurations ?? [:]
    }
    set {
      willChangeValueForKey("configurations")
      primitiveConfigurations = NSMutableDictionary(dictionary: newValue)
      didChangeValueForKey("configurations")
    }
  }

  class var DefaultMode: String { return "default" }

  /** awakeFromFetch */
  override func awakeFromFetch() {
    super.awakeFromFetch()
    refresh()
  }

  /** prepareForDeletion */
  override func prepareForDeletion() {
    if let moc = managedObjectContext {
      apply(flattened(Array(configurations.values).map{Array($0.values).filter{$0 is NSURL}})){moc.deleteObject($0 as NSManagedObject)}
      moc.processPendingChanges()
    }
  }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]
  */
  override func updateWithData(data: [NSObject:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let roleJSON = data["role"]   as? String   { role  = Role(JSONValue: roleJSON)   }
      if let keyJSON = data["key"]     as? String   { key   = keyJSON                     }
      if let shapeJSON = data["shape"] as? String   { shape = Shape(JSONValue: shapeJSON) }
      if let styleJSON = data["style"] as? String   { style = Style(JSONValue: styleJSON) }
      if let tagJSON = data["tag"]     as? NSNumber { tag   = tagJSON                     }

      if let backgroundColorJSON = data["background-color"] as? [String:String] {
        for (mode, value) in backgroundColorJSON { setObject(UIColor(string: value), forKey: "backgroundColor", forMode: mode) }
      }

      if let backgroundImageAlphaJSON = data["background-image-alpha"] as? [String:NSNumber] {
        for (mode, value) in backgroundImageAlphaJSON { setObject(value, forKey: "backgroundImageAlpha", forMode: mode) }
      }

      if let backgroundImageJSON = data["background-image"] as? [String:[String:AnyObject]] {
        for (mode, value) in backgroundImageJSON {
          setURIForObject(Image.importObjectFromData(value, context: moc), forKey: "backgroundImage", forMode: mode)
        }
      }

      if let subelementsJSON = data["subelements"] as? [[NSObject:AnyObject]] {
        if elementType == .Remote {
          childElements = OrderedSet(subelementsJSON.map{ButtonGroup.importObjectFromData($0, context: moc)})
        } else if elementType == .ButtonGroup {
          childElements = OrderedSet(subelementsJSON.map{Button.importObjectFromData($0,  context: moc)})
        }
      }

      if let constraintsJSON = data["constraints"] as? [String:AnyObject] {
        ownedConstraints = Constraint.importObjectsFromData(constraintsJSON, context: moc) as [Constraint]
      }

    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    func ifNotDefaultSetValue(value: @autoclosure () -> NSObject?, forKey key: String) {
      if let v = value() {
        if !attributeValueIsDefault(key) {
          dictionary[key.camelCaseToDashCase()] = v
        }
      }
    }

    if name != nil { dictionary["name"] = name! }
    if key != nil  { dictionary["key"] = key!   }

    ifNotDefaultSetValue(tag,             forKey: "tag"  )
    ifNotDefaultSetValue(role.JSONValue,  forKey: "role" )
    ifNotDefaultSetValue(shape.JSONValue, forKey: "shape")
    ifNotDefaultSetValue(style.JSONValue, forKey: "style")

    var backgroundColors:      [String:String]   = [:]
    var backgroundImages:      [String:String]   = [:]
    var backgroundImageAlphas: [String:NSNumber] = [:]

    for mode in modes {
      if let color = backgroundColorForMode(mode)?.string { backgroundColors[mode] = color }
      if let image = backgroundImageForMode(mode)?.commentedUUID { backgroundImages[mode] = image }
      if let alpha = backgroundImageAlphaForMode(mode) { backgroundImageAlphas[mode] = alpha }
    }

    if backgroundColors.count > 0      { dictionary["background-color"]       = backgroundColors      }
    if backgroundImages.count > 0      { dictionary["background-image"]       = backgroundImages      }
    if backgroundImageAlphas.count > 0 { dictionary["background-image-alpha"] = backgroundImageAlphas }

    let subelementDictionaries = childElements.map{$0.JSONDictionary()}.array
    if subelementDictionaries.count > 0 { dictionary["subelements"] = subelementDictionaries}

    let constraints = ownedConstraints
    if constraints.count > 0 {

      let firstItemUUIDs = OrderedSet<String>(constraints.map{$0.firstItem.uuid})
      let secondItemUUIDs = OrderedSet<String>(constraints.filter{$0.secondItem != nil}.map{$0.secondItem!.uuid})
      let uuids = firstItemUUIDs + secondItemUUIDs
      var uuidIndex: [String:String] = [name!.camelCase(): uuid]
      for uuid in uuids {
        if uuid == self.uuid { continue }
        if let element = childElements.filter({$0.uuid == uuid}).first {
          uuidIndex[element.name!.camelCase()] = uuid
        }
      }
      var constraintsDictionary: [String:AnyObject] = [:]
      if uuidIndex.count == 1 {
        let k = uuidIndex.keys.first!
        let v: AnyObject = uuidIndex[k]!
        constraintsDictionary["index.\(k)"] = v
      }
      else {
        constraintsDictionary["index"] = uuidIndex
      }
      var format: [String] = constraints.map{$0.description}
      format.sort(<)
      constraintsDictionary["format"] = format.count == 1 ? format[0] : format
      dictionary["constraints"] = constraintsDictionary
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  backgroundColorForMode:

  :param: mode String

  :returns: UIColor?
  */
  func backgroundColorForMode(mode: String) -> UIColor? {
    return objectForKey("backgroundColor", forMode: mode) as? UIColor
  }

  /**
  setBackgroundColor:forMode:

  :param: color UIColor?
  :param: mode String
  */
  func setBackgroundColor(color: UIColor?, forMode mode: String) {
    setObject(color, forKey: "backgroundColor", forMode: mode)
  }

  /**
  backgroundImageAlphaForMode:

  :param: mode String

  :returns: NSNumber?
  */
  func backgroundImageAlphaForMode(mode: String) -> NSNumber? {
    return objectForKey("backgroundImageAlpha", forMode: mode) as? NSNumber
  }

  /**
  setBackgroundImageAlpha:forMode:

  :param: alpha NSNumber?
  :param: mode String
  */
  func setBackgroundImageAlpha(alpha: NSNumber?, forMode mode: String) {
    setObject(alpha, forKey: "backgroundImageAlpha", forMode: mode)
  }

  /**
  backgroundImageForMode:

  :param: mode String

  :returns: Image?
  */
  func backgroundImageForMode(mode: String) -> Image? {
    return faultedObjectForKey("backgroundImage", forMode: mode) as? Image
  }

  /**
  setBackgroundImage:forMode:

  :param: image Image?
  :param: mode String
  */
  func setBackgroundImage(image: Image?, forMode mode: String) {
    setURIForObject(image, forKey: "backgroundImage", forMode: mode)
  }

  /**
  updateForMode:

  :param: mode String
  */
  func updateForMode(mode: String) {
    backgroundColor = backgroundColorForMode(mode) ?? backgroundColorForMode(RemoteElement.DefaultMode)
    backgroundImage = backgroundImageForMode(mode) ?? backgroundImageForMode(RemoteElement.DefaultMode)
    backgroundImageAlpha = (backgroundImageAlphaForMode(mode) ?? backgroundImageAlphaForMode(RemoteElement.DefaultMode)) ?? 1.0
  }

  /**
  elementType

  :returns: BaseType
  */
  var elementType: BaseType { return .Undefined }

  /** autoGenerateName */
  override func autoGenerateName() -> String {
    let roleName = (role != RemoteElement.Role.Undefined
                   ? String(map(role.JSONValue){(c:Character) -> Character in c == "-" ? " " : c}).capitalizedString + " "
                   : "")
    let baseName = entity.managedObjectClassName
    let generatedName = roleName + baseName
    return generatedName
  }

  /**
  isIdentifiedByString:

  :param: string String

  :returns: Bool
  */
  func isIdentifiedByString(string: String) -> Bool {
    return uuid == string  || identifier == string || (key != nil && key! == string)
  }

  /**
  subscript:

  :param: idx Int

  :returns: RemoteElement?
  */
  subscript(idx: Int) -> RemoteElement? {
    get {
      let elements = childElements
      return contains(0 ..< elements.count, idx) ? elements[idx] : nil
    }
    set {
      var elements = childElements
      if idx == elements.count && newValue != nil {
        elements.append(newValue!)
        childElements = elements
      }
      else if contains(0 ..< elements.count, idx) {
        if newValue == nil {
          elements.removeAtIndex(idx)
          childElements = elements
        } else {
          elements.insert(newValue!, atIndex: idx)
          childElements = elements
        }
      }
    }
  }

  /**
  subscript:

  :param: key String

  :returns: RemoteElement?
  */
  subscript(key: String) -> AnyObject? {
    get {
      let keypath = split(key){$0 == "."}
      if keypath.count == 2 {
        let mode = keypath.first!
        let property = keypath.last!
        return hasMode(mode) ? configurations[mode]?[property] : configurations[RemoteElement.DefaultMode]?[property]
      } else {
        return childElements.filter{$0.isIdentifiedByString(key)}.first
      }
    }
    set {
      let keypath = split(key){$0 == "."}
      if keypath.count == 2 {
        let mode = keypath.first!
        let property = keypath.last!

        var configs = configurations
        var values: [String:AnyObject] = configs[mode] ?? [:]
        values[property] = newValue
        configs[mode] = values
        configurations = configs
      }
    }
  }

  /**
  addMode:

  :param: mode String
  */
  func addMode(mode: String) {
    if !hasMode(mode) {
      var configs = configurations
      configs[mode] = [:]
      configurations = configs
    }
  }

  /**
  hasMode:

  :param: mode String

  :returns: Bool
  */
  func hasMode(mode: String) -> Bool { return Array(configurations.keys) ∋ mode }

  /** refresh */
  func refresh() { updateForMode(currentMode) }

  /**
  faultedObjectForKey:mode:

  :param: key String
  :param: mode String

  :returns: NSManagedObject?
  */
  func faultedObjectForKey(key: String, forMode mode: String) -> NSManagedObject? {
    var object: NSManagedObject?
    if let uri = objectForKey(key, forMode: mode) as? NSURL {
      if let obj = managedObjectContext?.objectForURI(uri) as? NSManagedObject {
        object = obj.faultedObject()
      }
    }
    return object
  }

  /**
  objectForKey:forMode:

  :param: key String
  :param: mode String

  :returns: NSObject?
  */
  func objectForKey(key: String, forMode mode: String) -> NSObject? {
    return self["\(mode).\(key)"] as? NSObject
  }

  /**
  setURIForObject:key:mode:

  :param: object NSManagedObject?
  :param: key String
  :param: mode String
  */
  func setURIForObject(object: NSManagedObject?, forKey key: String, forMode mode: String) {
    setObject(object?.permanentURI(), forKey: key, forMode: mode)
  }

  /**
  setObject:forKey:forMode:

  :param: object NSObject?
  :param: key String
  :param: mode String
  */
  func setObject(object: NSObject?, forKey key: String, forMode mode: String) {
    self["\(mode).\(key)"] = object
  }

  enum BaseType: Int  {
    case Undefined, Remote, ButtonGroup, Button
    init(rawValue: Int) {
      switch rawValue {
        case 1:  self = .Remote
        case 2:  self = .ButtonGroup
        case 3:  self = .Button
        default: self = .Undefined
      }
    }
  }


  enum Shape: Int {
    case Undefined, RoundedRectangle, Oval, Rectangle, Triangle, Diamond
    init(rawValue: Int) {
      switch rawValue {
        case 1: self = .RoundedRectangle
        case 2: self = .Oval
        case 3: self = .Rectangle
        case 4: self = .Triangle
        case 5: self = .Diamond
        default: self = .Undefined
      }
    }
    static var allShapes: [Shape] { return [.Undefined, .RoundedRectangle, .Oval, .Rectangle, .Triangle, .Diamond] }

  }


  struct Style: RawOptionSetType {

    private(set) var rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue & 0b0011_1111 }
    init(nilLiteral:()) { rawValue = 0 }
    static var allZeros:       Style { return Style.Undefined }
    static var Undefined:      Style = Style(rawValue: 0b0000_0000)
    static var ApplyGloss:     Style = Style(rawValue: 0b0000_0001)
    static var DrawBorder:     Style = Style(rawValue: 0b0000_0010)
    static var Stretchable:    Style = Style(rawValue: 0b0000_0100)
    static var GlossStyle1:    Style = Style.ApplyGloss
    static var GlossStyle2:    Style = Style(rawValue: 0b0000_1001)
    static var GlossStyle3:    Style = Style(rawValue: 0b0001_0001)
    static var GlossStyle4:    Style = Style(rawValue: 0b0010_0001)
    static var GlossStyleMask: Style = Style(rawValue: 0b0011_1001)

  }

  struct Role: RawOptionSetType {

    private(set) var rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue & 0b1111_1111 }
    init(nilLiteral:()) { rawValue = 0 }
    static var allZeros: Role { return Role.Undefined }

    static var Undefined:            Role = Role(rawValue: 0b0000_0000)

    // button group roles
    static var SelectionPanel:       Role = Role(rawValue: 0b0000_0011)
    static var Toolbar:              Role = Role(rawValue: 0b0000_0010)
    static var DPad:                 Role = Role(rawValue: 0b0000_0100)
    static var Numberpad:            Role = Role(rawValue: 0b0000_0110)
    static var Transport:            Role = Role(rawValue: 0b0000_1000)
    static var Rocker:               Role = Role(rawValue: 0b0000_1010)

    // toolbar buttons
    static var ToolbarButton:        Role = Role(rawValue: 0b0000_0010)
    static var ConnectionStatus:     Role = Role(rawValue: 0b0001_0010)
    static var BatteryStatus:        Role = Role(rawValue: 0b0010_0010)
    static var ToolbarButtonMask:    Role = Role(rawValue: 0b0000_0010)

    // picker label buttons
    static var RockerButton:         Role = Role(rawValue: 0b0000_1010)
    static var Top:                  Role = Role(rawValue: 0b0001_1010)
    static var Bottom:               Role = Role(rawValue: 0b0010_1010)
    static var RockerButtonMask:     Role = Role(rawValue: 0b0000_1010)

    // panel buttons
    static var PanelButton:          Role = Role(rawValue: 0b0000_0001)
    static var Tuck:                 Role = Role(rawValue: 0b0001_0001)
    static var SelectionPanelButton: Role = Role(rawValue: 0b0000_0011)
    static var PanelButtonMask:      Role = Role(rawValue: 0b0000_0001)

    // dpad buttons
    static var DPadButton:           Role = Role(rawValue: 0b0000_0100)
    static var Up:                   Role = Role(rawValue: 0b0001_0100)
    static var Down:                 Role = Role(rawValue: 0b0010_0100)
    static var Left:                 Role = Role(rawValue: 0b0011_0100)
    static var Right:                Role = Role(rawValue: 0b0100_0100)
    static var Center:               Role = Role(rawValue: 0b0101_0100)
    static var DPadButtonMask:       Role = Role(rawValue: 0b0000_0100)


    // numberpad buttons
    static var NumberpadButton:      Role = Role(rawValue: 0b0000_0110)
    static var One:                  Role = Role(rawValue: 0b0001_0110)
    static var Two:                  Role = Role(rawValue: 0b0010_0110)
    static var Three:                Role = Role(rawValue: 0b0011_0110)
    static var Four:                 Role = Role(rawValue: 0b0100_0110)
    static var Five:                 Role = Role(rawValue: 0b0101_0110)
    static var Six:                  Role = Role(rawValue: 0b0111_0110)
    static var Seven:                Role = Role(rawValue: 0b1000_0110)
    static var Eight:                Role = Role(rawValue: 0b1001_0110)
    static var Nine:                 Role = Role(rawValue: 0b1010_0110)
    static var Zero:                 Role = Role(rawValue: 0b1011_0110)
    static var Aux1:                 Role = Role(rawValue: 0b1100_0110)
    static var Aux2:                 Role = Role(rawValue: 0b1100_1110)
    static var NumberpadButtonMask:  Role = Role(rawValue: 0b0000_0110)

    // transport buttons
    static var TransportButton:      Role = Role(rawValue: 0b0000_1000)
    static var Play:                 Role = Role(rawValue: 0b0001_1000)
    static var Stop:                 Role = Role(rawValue: 0b0010_1000)
    static var Pause:                Role = Role(rawValue: 0b0011_1000)
    static var Skip:                 Role = Role(rawValue: 0b0100_1000)
    static var Replay:               Role = Role(rawValue: 0b0101_1000)
    static var FF:                   Role = Role(rawValue: 0b0111_1000)
    static var Rewind:               Role = Role(rawValue: 0b1000_1000)
    static var Record:               Role = Role(rawValue: 0b1001_1000)
    static var TransportButtonMask:  Role = Role(rawValue: 0b0000_1000)

    static var buttonGroupRoles: [Role] { return [.SelectionPanel, .Toolbar, .DPad, .Numberpad, .Transport, .Rocker] }
    static var buttonRoles: [Role] {
      return [.ConnectionStatus, .BatteryStatus, .Top, .Bottom, .Tuck, .SelectionPanelButton, .Up, .Down, .Left, .Right,
        .Center, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .Aux1, .Aux2, .Play, .Stop,
        .Pause, .Skip, .Replay, .FF, .Rewind, .Record]
    }
  }

}

extension RemoteElement.BaseType: JSONValueConvertible {
  var JSONValue: String {
    switch self {
      case .Undefined:   return ""
      case .Remote:      return "remote"
      case .ButtonGroup: return "button-group"
      case .Button:      return "button"
    }
  }


  init(JSONValue: String) {
    switch JSONValue {
      case RemoteElement.BaseType.Remote.JSONValue:      self = .Remote
      case RemoteElement.BaseType.ButtonGroup.JSONValue: self = .ButtonGroup
      case RemoteElement.BaseType.Button.JSONValue:      self = .Button
      default:                           self = .Undefined
    }
  }
}


extension RemoteElement.Shape: JSONValueConvertible {
  var JSONValue: String {
    switch self {
      case .Undefined:        return ""
      case .RoundedRectangle: return "rounded-rectangle"
      case .Oval:             return "oval"
      case .Rectangle:        return "rectangle"
      case .Triangle:         return "triangle"
      case .Diamond:          return "diamond"
    }
  }

  init(JSONValue: String) {
    switch JSONValue {
      case RemoteElement.Shape.RoundedRectangle.JSONValue: self = .RoundedRectangle
      case RemoteElement.Shape.Oval.JSONValue:             self = .Oval
      case RemoteElement.Shape.Rectangle.JSONValue:        self = .Rectangle
      case RemoteElement.Shape.Triangle.JSONValue:         self = .Triangle
      case RemoteElement.Shape.Diamond.JSONValue:          self = .Diamond
      default:                                             self = .Undefined
    }
  }

}

extension RemoteElement.Style: JSONValueConvertible {

  var JSONValue: String {
    var segments: [String] = []
    if self & RemoteElement.Style.ApplyGloss != nil {
      var k = "gloss"
      if self & RemoteElement.Style.GlossStyle2 != nil { k += "2" }
      else if self & RemoteElement.Style.GlossStyle3 != nil { k += "3" }
      else if self & RemoteElement.Style.GlossStyle4 != nil { k += "4" }
      segments.append(k)
    }
    if self & RemoteElement.Style.DrawBorder != nil { segments.append("border") }
    if self & RemoteElement.Style.Stretchable != nil { segments.append("stretchable") }
    return " ".join(segments)
  }

  init(JSONValue: String) {
    let components = split(JSONValue){$0 == " "}
    var style = RemoteElement.Style.Undefined
    for component in components {
      switch component {
        case "border":          style = style | RemoteElement.Style.DrawBorder
        case "stretchable":     style = style | RemoteElement.Style.Stretchable
        case "gloss", "gloss1": style = style | RemoteElement.Style.GlossStyle1
        case "gloss2":          style = style | RemoteElement.Style.GlossStyle2
        case "gloss3":          style = style | RemoteElement.Style.GlossStyle3
        case "gloss4":          style = style | RemoteElement.Style.GlossStyle4
        default: break
      }
    }
    self = style
  }

}

extension RemoteElement.Role: JSONValueConvertible {

  var JSONValue: String {
    switch self {
      case RemoteElement.Role.SelectionPanel:       return "selection-panel"
      case RemoteElement.Role.Toolbar:              return "toolbar"
      case RemoteElement.Role.DPad:                 return "dpad"
      case RemoteElement.Role.Numberpad:            return "numberpad"
      case RemoteElement.Role.Transport:            return "transport"
      case RemoteElement.Role.Rocker:               return "rocker"
      case RemoteElement.Role.ToolbarButton:        return "toolbar"
      case RemoteElement.Role.ConnectionStatus:     return "connection-status"
      case RemoteElement.Role.BatteryStatus:        return "battery-status"
      case RemoteElement.Role.RockerButton:         return "rocker"
      case RemoteElement.Role.Top:                  return "top"
      case RemoteElement.Role.Bottom:               return "bottom"
      case RemoteElement.Role.PanelButton:          return "panel"
      case RemoteElement.Role.Tuck:                 return "tuck"
      case RemoteElement.Role.SelectionPanelButton: return "selection-panel"
      case RemoteElement.Role.DPadButton:           return "dpad"
      case RemoteElement.Role.Up:                   return "up"
      case RemoteElement.Role.Down:                 return "down"
      case RemoteElement.Role.Left:                 return "left"
      case RemoteElement.Role.Right:                return "right"
      case RemoteElement.Role.Center:               return "center"
      case RemoteElement.Role.NumberpadButton:      return "numberpad"
      case RemoteElement.Role.One:                  return "one"
      case RemoteElement.Role.Two:                  return "two"
      case RemoteElement.Role.Three:                return "three"
      case RemoteElement.Role.Four:                 return "four"
      case RemoteElement.Role.Five:                 return "five"
      case RemoteElement.Role.Six:                  return "six"
      case RemoteElement.Role.Seven:                return "seven"
      case RemoteElement.Role.Eight:                return "eight"
      case RemoteElement.Role.Nine:                 return "nine"
      case RemoteElement.Role.Zero:                 return "zero"
      case RemoteElement.Role.Aux1:                 return "aux1"
      case RemoteElement.Role.Aux2:                 return "aux2"
      case RemoteElement.Role.TransportButton:      return "transport"
      case RemoteElement.Role.Play:                 return "play"
      case RemoteElement.Role.Stop:                 return "stop"
      case RemoteElement.Role.Pause:                return "pause"
      case RemoteElement.Role.Skip:                 return "skip"
      case RemoteElement.Role.Replay:               return "replay"
      case RemoteElement.Role.FF:                   return "fast-forward"
      case RemoteElement.Role.Rewind:               return "rewind"
      case RemoteElement.Role.Record:               return "record"
      default:                                      return ""
    }
  }

  init(JSONValue: String) {
    switch JSONValue {
      case RemoteElement.Role.SelectionPanel.JSONValue:       self = RemoteElement.Role.SelectionPanel
      case RemoteElement.Role.Toolbar.JSONValue:              self = RemoteElement.Role.Toolbar
      case RemoteElement.Role.DPad.JSONValue:                 self = RemoteElement.Role.DPad
      case RemoteElement.Role.Numberpad.JSONValue:            self = RemoteElement.Role.Numberpad
      case RemoteElement.Role.Transport.JSONValue:            self = RemoteElement.Role.Transport
      case RemoteElement.Role.Rocker.JSONValue:               self = RemoteElement.Role.Rocker
      case RemoteElement.Role.ToolbarButton.JSONValue:        self = RemoteElement.Role.ToolbarButton
      case RemoteElement.Role.ConnectionStatus.JSONValue:     self = RemoteElement.Role.ConnectionStatus
      case RemoteElement.Role.BatteryStatus.JSONValue:        self = RemoteElement.Role.BatteryStatus
      case RemoteElement.Role.RockerButton.JSONValue:         self = RemoteElement.Role.RockerButton
      case RemoteElement.Role.Top.JSONValue:                  self = RemoteElement.Role.Top
      case RemoteElement.Role.Bottom.JSONValue:               self = RemoteElement.Role.Bottom
      case RemoteElement.Role.PanelButton.JSONValue:          self = RemoteElement.Role.PanelButton
      case RemoteElement.Role.Tuck.JSONValue:                 self = RemoteElement.Role.Tuck
      case RemoteElement.Role.SelectionPanelButton.JSONValue: self = RemoteElement.Role.SelectionPanelButton
      case RemoteElement.Role.DPadButton.JSONValue:           self = RemoteElement.Role.DPadButton
      case RemoteElement.Role.Up.JSONValue:                   self = RemoteElement.Role.Up
      case RemoteElement.Role.Down.JSONValue:                 self = RemoteElement.Role.Down
      case RemoteElement.Role.Left.JSONValue:                 self = RemoteElement.Role.Left
      case RemoteElement.Role.Right.JSONValue:                self = RemoteElement.Role.Right
      case RemoteElement.Role.Center.JSONValue:               self = RemoteElement.Role.Center
      case RemoteElement.Role.NumberpadButton.JSONValue:      self = RemoteElement.Role.NumberpadButton
      case RemoteElement.Role.One.JSONValue:                  self = RemoteElement.Role.One
      case RemoteElement.Role.Two.JSONValue:                  self = RemoteElement.Role.Two
      case RemoteElement.Role.Three.JSONValue:                self = RemoteElement.Role.Three
      case RemoteElement.Role.Four.JSONValue:                 self = RemoteElement.Role.Four
      case RemoteElement.Role.Five.JSONValue:                 self = RemoteElement.Role.Five
      case RemoteElement.Role.Six.JSONValue:                  self = RemoteElement.Role.Six
      case RemoteElement.Role.Seven.JSONValue:                self = RemoteElement.Role.Seven
      case RemoteElement.Role.Eight.JSONValue:                self = RemoteElement.Role.Eight
      case RemoteElement.Role.Nine.JSONValue:                 self = RemoteElement.Role.Nine
      case RemoteElement.Role.Zero.JSONValue:                 self = RemoteElement.Role.Zero
      case RemoteElement.Role.Aux1.JSONValue:                 self = RemoteElement.Role.Aux1
      case RemoteElement.Role.Aux2.JSONValue:                 self = RemoteElement.Role.Aux2
      case RemoteElement.Role.TransportButton.JSONValue:      self = RemoteElement.Role.TransportButton
      case RemoteElement.Role.Play.JSONValue:                 self = RemoteElement.Role.Play
      case RemoteElement.Role.Stop.JSONValue:                 self = RemoteElement.Role.Stop
      case RemoteElement.Role.Pause.JSONValue:                self = RemoteElement.Role.Pause
      case RemoteElement.Role.Skip.JSONValue:                 self = RemoteElement.Role.Skip
      case RemoteElement.Role.Replay.JSONValue:               self = RemoteElement.Role.Replay
      case RemoteElement.Role.FF.JSONValue:                   self = RemoteElement.Role.FF
      case RemoteElement.Role.Rewind.JSONValue:               self = RemoteElement.Role.Rewind
      case RemoteElement.Role.Record.JSONValue:               self = RemoteElement.Role.Record
      default:                                                self = RemoteElement.Role.Undefined
    }
  }
}
