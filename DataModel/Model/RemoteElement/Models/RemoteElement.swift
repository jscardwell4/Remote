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
public class RemoteElement: NamedModelObject {

  /**
  remoteElementFromPreset:

  :param: preset Preset

  :returns: RemoteElement?
  */
  public class func remoteElementFromPreset(preset: Preset) -> RemoteElement? {
    var element: RemoteElement?

    switch preset.baseType {
      case .Remote:      element = Remote(preset: preset)
      case .ButtonGroup: element = ButtonGroup(preset: preset)
      case .Button:      element = Button(preset: preset)
      default: break
    }

    return element
  }

  /**
  initWithPreset:

  :param: preset Preset
  */
  public init(preset: Preset) {
    super.init(context: preset.managedObjectContext)
    updateWithPreset(preset)
  }

  /**
  initWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext
  */
  required public init?(data: [String : AnyObject], context: NSManagedObjectContext) {
    super.init(data: data, context: context)
  }

  @NSManaged public var tag: NSNumber
  @NSManaged public var key: String?
  public var identifier: String { return "_" + filter(uuid){$0 != "-"} }

  @NSManaged public var constraints: NSSet
  public var ownedConstraints: [Constraint] {
    get { return constraints.allObjects as? [Constraint] ?? [] }
    set { constraints = NSSet(array: newValue) }
  }

  @NSManaged public var firstItemConstraints: NSSet
  public var firstOrderConstraints: [Constraint] {
    get { return firstItemConstraints.allObjects as? [Constraint] ?? [] }
    set { firstItemConstraints = NSSet(array: newValue) }
  }

  @NSManaged public var secondItemConstraints: NSSet
  public var secondOrderConstraints: [Constraint] {
    get { return secondItemConstraints.allObjects as? [Constraint] ?? [] }
    set { secondItemConstraints = NSSet(array: newValue) }
  }

  @NSManaged public var backgroundImageAlpha: NSNumber
  @NSManaged public var backgroundColor: UIColor?
  @NSManaged public var backgroundImage: ImageView?

  @NSManaged public var subelements: NSOrderedSet

  public var childElements: OrderedSet<RemoteElement> {
    get { return OrderedSet(subelements.array as? [RemoteElement] ?? []) }
    set { subelements = NSOrderedSet(array: newValue.array) }
  }

  public lazy var constraintManager: ConstraintManager = ConstraintManager(element: self)

  public var modes: [String] {
    var modes = Array(configurations.keys) as [String]
    if modes ∌ RemoteElement.DefaultMode { modes.append(RemoteElement.DefaultMode) }
    return modes
  }

  public var currentMode: String = RemoteElement.DefaultMode {
    didSet {
      if !hasMode(currentMode) { addMode(currentMode) }
      updateForMode(currentMode)
      apply(childElements){$0.currentMode = self.currentMode}
    }
  }

  public var parentElement: RemoteElement? {
    get {
      willAccessValueForKey("parentElement")
      let parentElement = primitiveValueForKey("parentElement") as? RemoteElement
      didAccessValueForKey("parentElement")
      return parentElement
    }
    set {
      willChangeValueForKey("parentElement")
      setPrimitiveValue(newValue, forKey: "parentElement")
      didChangeValueForKey("parentElement")
    }
  }

  @NSManaged var primitiveRole: NSNumber
  public var role: Role {
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
  public var shape: Shape {
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
  public var style: Style {
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
  public var configurations: [String:[String:AnyObject]] {
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

  public class var DefaultMode: String { return "default" }

  /** awakeFromFetch */
  override public func awakeFromFetch() {
    super.awakeFromFetch()
    refresh()
  }

  /** prepareForDeletion */
  override public func prepareForDeletion() {
    if let moc = managedObjectContext {
      apply(flattened(Array(configurations.values).map{Array($0.values).filter{$0 is NSURL}})){moc.deleteObject($0 as! NSManagedObject)}
      moc.processPendingChanges()
    }
  }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  func updateWithPreset(preset: Preset) {
    role = preset.role
    shape = preset.shape
    style = preset.style
    setBackgroundColor(preset.backgroundColor, forMode: RemoteElement.DefaultMode)
    setBackgroundImage(preset.backgroundImage, forMode: RemoteElement.DefaultMode)
    setBackgroundImageAlpha(preset.backgroundImageAlpha, forMode: RemoteElement.DefaultMode)
    var elements: OrderedSet<RemoteElement> = []
    if let subelementPresets = preset.subelements {
      for subelementPreset in subelementPresets.array as! [Preset] {
        if let element = RemoteElement.remoteElementFromPreset(subelementPreset) {
          elements.append(element)
        }
      }
    }
    childElements = elements
    if let constraints = preset.constraints {
      constraintManager.setConstraintsFromString(constraints)
    }
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let roleJSON = data["role"]   as? String   { role  = Role(jsonValue: roleJSON.jsonValue)   }
      if let keyJSON = data["key"]     as? String   { key   = keyJSON                     }
      if let shapeJSON = data["shape"] as? String   { shape = Shape(jsonValue: shapeJSON.jsonValue) }
      if let styleJSON = data["style"] as? String   { style = Style(jsonValue: styleJSON.jsonValue) }
      if let tagJSON = data["tag"]     as? NSNumber { tag   = tagJSON                     }

      if let backgroundColorJSON = data["background-color"] as? [String:String] {
        for (mode, value) in backgroundColorJSON { setObject(UIColor(string: value), forKey: "backgroundColor", forMode: mode) }
      }

      if let backgroundImageAlphaJSON = data["background-image-alpha"] as? [String:NSNumber] {
        for (mode, value) in backgroundImageAlphaJSON { setObject(value, forKey: "backgroundImageAlpha", forMode: mode) }
      }

      if let backgroundImageJSON = data["background-image"] as? [String:[String:AnyObject]] {
        for (mode, value) in backgroundImageJSON {
          setURIForObject(Image.importObjectWithData(value, context: moc), forKey: "backgroundImage", forMode: mode)
        }
      }

      if let subelementsJSON = data["subelements"] as? [[String:AnyObject]] {
        if elementType == .Remote {
          childElements = OrderedSet(compressed(subelementsJSON.map{ButtonGroup.importObjectWithData($0, context: moc)}))
        } else if elementType == .ButtonGroup {
          childElements = OrderedSet(compressed(subelementsJSON.map{Button.importObjectWithData($0,  context: moc)}))
        }
      }

      if let constraintsJSON = data["constraints"] as? [String:AnyObject] {
        ownedConstraints = Constraint.importObjectsWithData(constraintsJSON, context: moc) as! [Constraint]
      }

    }

  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    if key != nil  { dict["key"] = .String(key!)   }

    appendValueForKey("tag", toDictionary: &dict)
    appendValueForKey("role", ifNotDefault: true, toDictionary: &dict)
    appendValueForKey("shape", ifNotDefault: true, toDictionary: &dict)
    appendValueForKey("style", ifNotDefault: true, toDictionary: &dict)

    var backgroundColors:      JSONValue.ObjectValue = [:]
    var backgroundImages:      JSONValue.ObjectValue = [:]
    var backgroundImageAlphas: JSONValue.ObjectValue = [:]

    for mode in modes {
      if let color = backgroundColorForMode(mode) { backgroundColors[mode] = color.jsonValue }
      if let image = backgroundImageForMode(mode) { backgroundImages[mode] = image.imagePath.jsonValue }
      if let alpha = backgroundImageAlphaForMode(mode) { backgroundImageAlphas[mode] = alpha.jsonValue }
    }

    if backgroundColors.count > 0      { dict["background-color"]       = .Object(backgroundColors)      }
    if backgroundImages.count > 0      { dict["background-image"]       = .Object(backgroundImages)      }
    if backgroundImageAlphas.count > 0 { dict["background-image-alpha"] = .Object(backgroundImageAlphas) }

    let subelementJSON = childElements.array.map({$0.jsonValue})
    if subelementJSON.count > 0 { dict["subelements"] = .Array(subelementJSON) }

    let constraints = ownedConstraints
    if constraints.count > 0 {

      let firstItemUUIDs = OrderedSet<String>(constraints.map{$0.firstItem.uuid})
      let secondItemUUIDs = OrderedSet<String>(constraints.filter{$0.secondItem != nil}.map{$0.secondItem!.uuid})
      let uuids = firstItemUUIDs + secondItemUUIDs
      var uuidIndex: JSONValue.ObjectValue = [name.camelCase(): uuid.jsonValue]
      for uuid in uuids {
        if uuid == self.uuid { continue }
        if let element = findFirst(childElements, {$0.uuid == uuid}) { uuidIndex[element.name.camelCase()] = uuid.jsonValue }
      }
      var constraintsJSON: JSONValue.ObjectValue = [:]
      if uuidIndex.count == 1 {
        let k = uuidIndex.keys.first!
        let v = uuidIndex[k]!
        constraintsJSON["index.\(k)"] = v
      }
      else {
        constraintsJSON["index"] = .Object(uuidIndex)
      }
      var format: [String] = constraints.map{$0.description}
      format.sort(<)
      constraintsJSON["format"] = format.count == 1 ? format[0].jsonValue : .Array(format.map({$0.jsonValue}))
      dict["constraints"] = .Object(constraintsJSON)
    }
    return .Object(dict)
  }

  /**
  backgroundColorForMode:

  :param: mode String

  :returns: UIColor?
  */
  public func backgroundColorForMode(mode: String) -> UIColor? {
    return objectForKey("backgroundColor", forMode: mode) as? UIColor
  }

  /**
  setBackgroundColor:forMode:

  :param: color UIColor?
  :param: mode String
  */
  public func setBackgroundColor(color: UIColor?, forMode mode: String) {
    setObject(color, forKey: "backgroundColor", forMode: mode)
  }

  /**
  backgroundImageAlphaForMode:

  :param: mode String

  :returns: NSNumber?
  */
  public func backgroundImageAlphaForMode(mode: String) -> NSNumber? {
    return objectForKey("backgroundImageAlpha", forMode: mode) as? NSNumber
  }

  /**
  setBackgroundImageAlpha:forMode:

  :param: alpha NSNumber?
  :param: mode String
  */
  public func setBackgroundImageAlpha(alpha: NSNumber?, forMode mode: String) {
    setObject(alpha, forKey: "backgroundImageAlpha", forMode: mode)
  }

  /**
  backgroundImageForMode:

  :param: mode String

  :returns: ImageView?
  */
  public func backgroundImageForMode(mode: String) -> ImageView? {
    return faultedObjectForKey("backgroundImage", forMode: mode) as? ImageView
  }

  /**
  setBackgroundImage:forMode:

  :param: image Image?
  :param: mode String
  */
  public func setBackgroundImage(image: Image?, forMode mode: String) {
    setURIForObject(image, forKey: "backgroundImage", forMode: mode)
  }

  /**
  updateForMode:

  :param: mode String
  */
  public func updateForMode(mode: String) {
    backgroundColor = backgroundColorForMode(mode) ?? backgroundColorForMode(RemoteElement.DefaultMode)
    backgroundImage = backgroundImageForMode(mode) ?? backgroundImageForMode(RemoteElement.DefaultMode)
    backgroundImageAlpha = (backgroundImageAlphaForMode(mode) ?? backgroundImageAlphaForMode(RemoteElement.DefaultMode)) ?? 1.0
  }

  /**
  elementType

  :returns: BaseType
  */
  public var elementType: BaseType { return .Undefined }

  /** autoGenerateName */
  override func autoGenerateName() -> String {
    let roleName = (role != RemoteElement.Role.Undefined
                   ? String(map(role.jsonValue.value as! String){(c:Character) -> Character in c == "-" ? " " : c}).capitalizedString + " "
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
  public func isIdentifiedByString(string: String) -> Bool {
    return uuid == string  || identifier == string || (key != nil && key! == string)
  }

  /**
  subscript:

  :param: idx Int

  :returns: RemoteElement?
  */
  public subscript(idx: Int) -> RemoteElement? {
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
  public subscript(key: String) -> AnyObject? {
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
  public func addMode(mode: String) {
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
  public func hasMode(mode: String) -> Bool { return Array(configurations.keys) ∋ mode }

  /** refresh */
  public func refresh() { updateForMode(currentMode) }

  /**
  faultedObjectForKey:mode:

  :param: key String
  :param: mode String

  :returns: NSManagedObject?
  */
  public func faultedObjectForKey(key: String, forMode mode: String) -> NSManagedObject? {
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
  public func objectForKey(key: String, forMode mode: String) -> NSObject? {
    return self["\(mode).\(key)"] as? NSObject
  }

  /**
  setURIForObject:key:mode:

  :param: object NSManagedObject?
  :param: key String
  :param: mode String
  */
  public func setURIForObject(object: NSManagedObject?, forKey key: String, forMode mode: String) {
    setObject(object?.permanentURI(), forKey: key, forMode: mode)
  }

  /**
  setObject:forKey:forMode:

  :param: object NSObject?
  :param: key String
  :param: mode String
  */
  public func setObject(object: NSObject?, forKey key: String, forMode mode: String) {
    self["\(mode).\(key)"] = object
  }

  public enum BaseType: Int  {
    case Undefined, Remote, ButtonGroup, Button
    public init(rawValue: Int) {
      switch rawValue {
        case 1:  self = .Remote
        case 2:  self = .ButtonGroup
        case 3:  self = .Button
        default: self = .Undefined
      }
    }
  }


  public enum Shape: Int {
    case Undefined, RoundedRectangle, Oval, Rectangle, Triangle, Diamond
    public init(rawValue: Int) {
      switch rawValue {
        case 1: self = .RoundedRectangle
        case 2: self = .Oval
        case 3: self = .Rectangle
        case 4: self = .Triangle
        case 5: self = .Diamond
        default: self = .Undefined
      }
    }
    public static var allShapes: [Shape] { return [.Undefined, .RoundedRectangle, .Oval, .Rectangle, .Triangle, .Diamond] }

  }


  public struct Style: RawOptionSetType {

    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue & 0b0011_1111 }
    public init(nilLiteral:()) { rawValue = 0 }
    public static var allZeros:       Style { return Style.Undefined }
    public static var Undefined:      Style = Style(rawValue: 0b0000_0000)
    public static var ApplyGloss:     Style = Style(rawValue: 0b0000_0001)
    public static var DrawBorder:     Style = Style(rawValue: 0b0000_0010)
    public static var Stretchable:    Style = Style(rawValue: 0b0000_0100)
    public static var GlossStyle1:    Style = Style.ApplyGloss
    public static var GlossStyle2:    Style = Style(rawValue: 0b0000_1001)
    public static var GlossStyle3:    Style = Style(rawValue: 0b0001_0001)
    public static var GlossStyle4:    Style = Style(rawValue: 0b0010_0001)
    public static var GlossStyleMask: Style = Style(rawValue: 0b0011_1001)

  }

  public struct Role: RawOptionSetType {

    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue & 0b1111_1111 }
    public init(nilLiteral:()) { rawValue = 0 }
    public static var allZeros: Role { return Role.Undefined }

    public static var Undefined:            Role = Role(rawValue: 0b0000_0000)

    // button group roles
    public static var SelectionPanel:       Role = Role(rawValue: 0b0000_0011)
    public static var Toolbar:              Role = Role(rawValue: 0b0000_0010)
    public static var TopToolbar:           Role = Role(rawValue: 0b0000_0011)
    public static var DPad:                 Role = Role(rawValue: 0b0000_0100)
    public static var Numberpad:            Role = Role(rawValue: 0b0000_0110)
    public static var Transport:            Role = Role(rawValue: 0b0000_1000)
    public static var Rocker:               Role = Role(rawValue: 0b0000_1010)

    // toolbar buttons
    public static var ToolbarButton:        Role = Role(rawValue: 0b0000_0010)
    public static var ConnectionStatus:     Role = Role(rawValue: 0b0001_0010)
    public static var BatteryStatus:        Role = Role(rawValue: 0b0010_0010)
    public static var ToolbarButtonMask:    Role = Role(rawValue: 0b0000_0010)

    // picker label buttons
    public static var RockerButton:         Role = Role(rawValue: 0b0000_1010)
    public static var Top:                  Role = Role(rawValue: 0b0001_1010)
    public static var Bottom:               Role = Role(rawValue: 0b0010_1010)
    public static var RockerButtonMask:     Role = Role(rawValue: 0b0000_1010)

    // panel buttons
    public static var PanelButton:          Role = Role(rawValue: 0b0000_0001)
    public static var Tuck:                 Role = Role(rawValue: 0b0001_0001)
    public static var SelectionPanelButton: Role = Role(rawValue: 0b0000_0011)
    public static var PanelButtonMask:      Role = Role(rawValue: 0b0000_0001)

    // dpad buttons
    public static var DPadButton:           Role = Role(rawValue: 0b0000_0100)
    public static var Up:                   Role = Role(rawValue: 0b0001_0100)
    public static var Down:                 Role = Role(rawValue: 0b0010_0100)
    public static var Left:                 Role = Role(rawValue: 0b0011_0100)
    public static var Right:                Role = Role(rawValue: 0b0100_0100)
    public static var Center:               Role = Role(rawValue: 0b0101_0100)
    public static var DPadButtonMask:       Role = Role(rawValue: 0b0000_0100)


    // numberpad buttons
    public static var NumberpadButton:      Role = Role(rawValue: 0b0000_0110)
    public static var One:                  Role = Role(rawValue: 0b0001_0110)
    public static var Two:                  Role = Role(rawValue: 0b0010_0110)
    public static var Three:                Role = Role(rawValue: 0b0011_0110)
    public static var Four:                 Role = Role(rawValue: 0b0100_0110)
    public static var Five:                 Role = Role(rawValue: 0b0101_0110)
    public static var Six:                  Role = Role(rawValue: 0b0111_0110)
    public static var Seven:                Role = Role(rawValue: 0b1000_0110)
    public static var Eight:                Role = Role(rawValue: 0b1001_0110)
    public static var Nine:                 Role = Role(rawValue: 0b1010_0110)
    public static var Zero:                 Role = Role(rawValue: 0b1011_0110)
    public static var Aux1:                 Role = Role(rawValue: 0b1100_0110)
    public static var Aux2:                 Role = Role(rawValue: 0b1100_1110)
    public static var NumberpadButtonMask:  Role = Role(rawValue: 0b0000_0110)

    // transport buttons
    public static var TransportButton:      Role = Role(rawValue: 0b0000_1000)
    public static var Play:                 Role = Role(rawValue: 0b0001_1000)
    public static var Stop:                 Role = Role(rawValue: 0b0010_1000)
    public static var Pause:                Role = Role(rawValue: 0b0011_1000)
    public static var Skip:                 Role = Role(rawValue: 0b0100_1000)
    public static var Replay:               Role = Role(rawValue: 0b0101_1000)
    public static var FF:                   Role = Role(rawValue: 0b0111_1000)
    public static var Rewind:               Role = Role(rawValue: 0b1000_1000)
    public static var Record:               Role = Role(rawValue: 0b1001_1000)
    public static var TransportButtonMask:  Role = Role(rawValue: 0b0000_1000)

    public static var buttonGroupRoles: [Role] {
      return [.Undefined, .SelectionPanel, .Toolbar, .TopToolbar, .DPad, .Numberpad, .Transport, .Rocker]
    }
    public static var buttonRoles: [Role] {
      return [.Undefined,
              .ConnectionStatus, .BatteryStatus,
              .Top, .Bottom,
              .Tuck, .SelectionPanelButton,
              .Up, .Down, .Left, .Right, .Center,
              .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .Aux1, .Aux2,
              .Play, .Stop, .Pause, .Skip, .Replay, .FF, .Rewind, .Record]
    }
  }

}

extension RemoteElement.BaseType: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .Undefined:   return "undefined"
      case .Remote:      return "remote"
      case .ButtonGroup: return "button-group"
      case .Button:      return "button"
    }
  }


  public init(jsonValue: JSONValue) {
    switch jsonValue.value as? String ?? "" {
      case RemoteElement.BaseType.Remote.jsonValue.value as! String:      self = .Remote
      case RemoteElement.BaseType.ButtonGroup.jsonValue.value as! String: self = .ButtonGroup
      case RemoteElement.BaseType.Button.jsonValue.value as! String:      self = .Button
      default:                                                            self = .Undefined
    }
  }
}


extension RemoteElement.Shape: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .Undefined:        return "undefined"
      case .RoundedRectangle: return "rounded-rectangle"
      case .Oval:             return "oval"
      case .Rectangle:        return "rectangle"
      case .Triangle:         return "triangle"
      case .Diamond:          return "diamond"
    }
  }

  public init(jsonValue: JSONValue) {
    switch jsonValue.value as? String ?? "" {
      case RemoteElement.Shape.RoundedRectangle.jsonValue.value as! String: self = .RoundedRectangle
      case RemoteElement.Shape.Oval.jsonValue.value as! String:             self = .Oval
      case RemoteElement.Shape.Rectangle.jsonValue.value as! String:        self = .Rectangle
      case RemoteElement.Shape.Triangle.jsonValue.value as! String:         self = .Triangle
      case RemoteElement.Shape.Diamond.jsonValue.value as! String:          self = .Diamond
      default:                                                              self = .Undefined
    }
  }

}

extension RemoteElement.Style: JSONValueConvertible {

  public var jsonValue: JSONValue {
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
    return " ".join(segments).jsonValue
  }

  public init(jsonValue: JSONValue) {
    let components = split(jsonValue.value as? String ?? ""){$0 == " "}
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

extension RemoteElement.Role: Hashable {
  public var hashValue: Int { return rawValue }
}

extension RemoteElement.Role: JSONValueConvertible {

  public var jsonValue: JSONValue {
    switch self {
      case RemoteElement.Role.SelectionPanel:       return "selection-panel"
      case RemoteElement.Role.Toolbar:              return "toolbar"
      case RemoteElement.Role.TopToolbar:           return "top-toolbar"
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
      default:                                      return "undefined"
    }
  }

  public init(jsonValue: JSONValue) {
    switch jsonValue.value as? String ?? "" {
      case RemoteElement.Role.SelectionPanel.jsonValue.value as! String:       self = RemoteElement.Role.SelectionPanel
      case RemoteElement.Role.Toolbar.jsonValue.value as! String:              self = RemoteElement.Role.Toolbar
      case RemoteElement.Role.TopToolbar.jsonValue.value as! String:           self = RemoteElement.Role.TopToolbar
      case RemoteElement.Role.DPad.jsonValue.value as! String:                 self = RemoteElement.Role.DPad
      case RemoteElement.Role.Numberpad.jsonValue.value as! String:            self = RemoteElement.Role.Numberpad
      case RemoteElement.Role.Transport.jsonValue.value as! String:            self = RemoteElement.Role.Transport
      case RemoteElement.Role.Rocker.jsonValue.value as! String:               self = RemoteElement.Role.Rocker
      case RemoteElement.Role.ToolbarButton.jsonValue.value as! String:        self = RemoteElement.Role.ToolbarButton
      case RemoteElement.Role.ConnectionStatus.jsonValue.value as! String:     self = RemoteElement.Role.ConnectionStatus
      case RemoteElement.Role.BatteryStatus.jsonValue.value as! String:        self = RemoteElement.Role.BatteryStatus
      case RemoteElement.Role.RockerButton.jsonValue.value as! String:         self = RemoteElement.Role.RockerButton
      case RemoteElement.Role.Top.jsonValue.value as! String:                  self = RemoteElement.Role.Top
      case RemoteElement.Role.Bottom.jsonValue.value as! String:               self = RemoteElement.Role.Bottom
      case RemoteElement.Role.PanelButton.jsonValue.value as! String:          self = RemoteElement.Role.PanelButton
      case RemoteElement.Role.Tuck.jsonValue.value as! String:                 self = RemoteElement.Role.Tuck
      case RemoteElement.Role.SelectionPanelButton.jsonValue.value as! String: self = RemoteElement.Role.SelectionPanelButton
      case RemoteElement.Role.DPadButton.jsonValue.value as! String:           self = RemoteElement.Role.DPadButton
      case RemoteElement.Role.Up.jsonValue.value as! String:                   self = RemoteElement.Role.Up
      case RemoteElement.Role.Down.jsonValue.value as! String:                 self = RemoteElement.Role.Down
      case RemoteElement.Role.Left.jsonValue.value as! String:                 self = RemoteElement.Role.Left
      case RemoteElement.Role.Right.jsonValue.value as! String:                self = RemoteElement.Role.Right
      case RemoteElement.Role.Center.jsonValue.value as! String:               self = RemoteElement.Role.Center
      case RemoteElement.Role.NumberpadButton.jsonValue.value as! String:      self = RemoteElement.Role.NumberpadButton
      case RemoteElement.Role.One.jsonValue.value as! String:                  self = RemoteElement.Role.One
      case RemoteElement.Role.Two.jsonValue.value as! String:                  self = RemoteElement.Role.Two
      case RemoteElement.Role.Three.jsonValue.value as! String:                self = RemoteElement.Role.Three
      case RemoteElement.Role.Four.jsonValue.value as! String:                 self = RemoteElement.Role.Four
      case RemoteElement.Role.Five.jsonValue.value as! String:                 self = RemoteElement.Role.Five
      case RemoteElement.Role.Six.jsonValue.value as! String:                  self = RemoteElement.Role.Six
      case RemoteElement.Role.Seven.jsonValue.value as! String:                self = RemoteElement.Role.Seven
      case RemoteElement.Role.Eight.jsonValue.value as! String:                self = RemoteElement.Role.Eight
      case RemoteElement.Role.Nine.jsonValue.value as! String:                 self = RemoteElement.Role.Nine
      case RemoteElement.Role.Zero.jsonValue.value as! String:                 self = RemoteElement.Role.Zero
      case RemoteElement.Role.Aux1.jsonValue.value as! String:                 self = RemoteElement.Role.Aux1
      case RemoteElement.Role.Aux2.jsonValue.value as! String:                 self = RemoteElement.Role.Aux2
      case RemoteElement.Role.TransportButton.jsonValue.value as! String:      self = RemoteElement.Role.TransportButton
      case RemoteElement.Role.Play.jsonValue.value as! String:                 self = RemoteElement.Role.Play
      case RemoteElement.Role.Stop.jsonValue.value as! String:                 self = RemoteElement.Role.Stop
      case RemoteElement.Role.Pause.jsonValue.value as! String:                self = RemoteElement.Role.Pause
      case RemoteElement.Role.Skip.jsonValue.value as! String:                 self = RemoteElement.Role.Skip
      case RemoteElement.Role.Replay.jsonValue.value as! String:               self = RemoteElement.Role.Replay
      case RemoteElement.Role.FF.jsonValue.value as! String:                   self = RemoteElement.Role.FF
      case RemoteElement.Role.Rewind.jsonValue.value as! String:               self = RemoteElement.Role.Rewind
      case RemoteElement.Role.Record.jsonValue.value as! String:               self = RemoteElement.Role.Record
      default:                                                                 self = RemoteElement.Role.Undefined
    }
  }
}
