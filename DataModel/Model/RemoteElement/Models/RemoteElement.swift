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
public class RemoteElement: IndexedModelObject {

  // MARK: - Initialization

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
  public init(preset: Preset) { super.init(context: preset.managedObjectContext); updateWithPreset(preset) }

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
  public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }

  /**
  initWithData:context:

  :param: data ObjectJSONValue
  :param: context NSManagedObjectContext
  */
  required public init?(data: ObjectJSONValue, context: NSManagedObjectContext) { super.init(data: data, context: context) }

  // MARK: - Identification

  @NSManaged public var tag: Int16
  @NSManaged public var key: String?
  public var identifier: String { return "_" + filter(uuid){$0 != "-"} }

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

  /**
  elementType

  :returns: BaseType
  */
  public var elementType: BaseType { return .Undefined }

  /** autoGenerateName */
  override func autoGenerateName() -> String {
    let roleName = (role != .Undefined ? String(map(role.stringValue){$0 == "-" ? " " : $0}).capitalizedString + " " : "")
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
    return uuid == string  || identifier == string || (key != nil && key! == string) || index.rawValue == string
  }

  // MARK: - Constraints

  @NSManaged public var constraints: Set<Constraint>
  @NSManaged public var firstItemConstraints: Set<Constraint>
  @NSManaged public var secondItemConstraints: Set<Constraint>

  public lazy var constraintManager: ConstraintManager = ConstraintManager(element: self)

  // MARK: - Background

  public typealias Background = ImageView

  private(set) var backgrounds: ModalStorage {
    get {
      var storage: ModalStorage!
      willAccessValueForKey("backgrounds")
      storage = primitiveValueForKey("backgrounds") as? ModalStorage
      didAccessValueForKey("backgrounds")
      if storage == nil {
        storage = ModalStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "backgrounds")
      }
      return storage
    }
    set {
      willChangeValueForKey("backgrounds")
      setPrimitiveValue(newValue, forKey: "backgrounds")
      didChangeValueForKey("backgrounds")
    }
  }

  @NSManaged private(set) public var background: Background?

  // MARK: - Parent and subelements

  public class var parentElementType: RemoteElement.Type? { return nil }
  public class var subelementType: RemoteElement.Type? { return nil }

  // If we try to use @NSManaged here we get 'declaration cannot be both final and dynamic' error
  public var parentElement: RemoteElement? {
    get {
      willAccessValueForKey("parentElement")
      let parentElement = primitiveValueForKey("parentElement") as? RemoteElement
      didAccessValueForKey("parentElement")
      return parentElement
    }
    set {
      let element: RemoteElement?
      if let parentType = self.dynamicType.parentElementType, parent = newValue where parent.isKindOfClass(parentType) {
        element = parent
      } else { element = nil }

      willChangeValueForKey("parentElement")
      setPrimitiveValue(element, forKey: "parentElement")
      didChangeValueForKey("parentElement")
    }
  }

  public var subelements: OrderedSet<RemoteElement> {
    get {
      willAccessValueForKey("subelements")
      let subelements = primitiveValueForKey("subelements") as? OrderedSet<RemoteElement>
      didAccessValueForKey("subelements")
      return subelements ?? []
    }
    set {
      let elements: OrderedSet<RemoteElement>
      if let subType = self.dynamicType.subelementType {
        elements = newValue.filter({$0.isKindOfClass(subType)})
      } else { elements = [] }
      willChangeValueForKey("subelements")
      setPrimitiveValue(elements as NSOrderedSet, forKey: "subelements")
      didChangeValueForKey("subelements")
    }
  }

  // MARK: - Modes and configurations

  public typealias Mode = String

  public static let DefaultMode: Mode = "default"

  public var defaultMode: Mode { return RemoteElement.DefaultMode }

  @NSManaged public private(set) var modes: Set<Mode>

  public dynamic var currentMode: Mode {
    get {
      willAccessValueForKey("currentMode")
      let currentMode = primitiveValueForKey("currentMode") as! Mode
      didAccessValueForKey("currentMode")
      return currentMode
    }
    set {
      willChangeValueForKey("currentMode")
      setPrimitiveValue(newValue, forKey: "currentMode")
      didChangeValueForKey("currentMode")
      updateForMode(newValue)
      apply(subelements){[mode = newValue] in $0.currentMode = mode}
    }
  }


  /**
  Method for determining whether any of the element's modal containers have a value for the specified `Mode`

  :param: mode Mode

  :returns: Bool
  */
  func isEmptyMode(mode: Mode) -> Bool { return findFirst(modalStorageContainers, {$0.dictionary[mode] != nil}) == nil }

  /** All modal containers, intended for subclass overrides to provide the necessary collections for `Mode` operations */
  var modalStorageContainers: Set<ModalStorage> { return Set([backgrounds]) }

  /**
  setValue:forMode:inStorage:

  :param: value T?
  :param: mode Mode
  :param: storage ModalStorage
  */
  func setValue<T:ModelObject>(value: T?, forMode mode: Mode, inStorage storage: ModalStorage) {
    // TODO: Possibly add some form of KVO compliance?
    let action = storage.setValue(value, forMode: mode)
    switch action {
      case .ValueAdded:                           modes ∪= [mode]
      case .ValueRemoved where isEmptyMode(mode): modes ∖= [mode]
      default:                                    break
    }

  }

  /**
  setBackground:forMode:

  :param: bg Background?
  :param: mode Mode
  */
  public func setBackground(bg: Background?, forMode mode: Mode) { setValue(bg, forMode: mode, inStorage: backgrounds) }

  /**
  backgroundForMode:

  :param: mode Mode

  :returns: Background?
  */
  public func backgroundForMode(mode: Mode) -> Background? { return backgrounds[mode] }

  /**
  Accessor for the `Background` associated with the specified `Mode`. If one does not exist a copy is made of the
  `Background` for `RemoteElement.Default`. If that does not exist a new `Background` is created and returned.

  :param: mode Mode

  :returns: Background
  */
  private func imageViewForMode(mode: Mode) -> Background {
    let imageView: Background
    if let i: Background = backgrounds[mode] {
      imageView = i
    } else if mode != defaultMode, let i: Background = backgrounds[defaultMode] {
      imageView = i.copy() as! Background
      setValue(imageView, forMode: mode, inStorage: backgrounds)
    } else {
      imageView = Background(context: managedObjectContext)
      setValue(imageView, forMode: mode, inStorage: backgrounds)
    }
    return imageView
  }

  // MARK: - Role

  /**
  The `Role` structure encapsulates the role an element fulfills. The currently are not any roles
  for `Remote` elements.

  Encoding:

    .0000 000 0000 000 00
    └─┬──┴─┬─┴─┬──┴─┬─┴┬─┘
    . │    │   │    │  │
    . │    │   │    │  └─────> `ButtonGroup` or `Button` role
    . │    │   │    └────────> Generalized `ButtonGroup` role
    . │    │   └─────────────> Specialized `ButtonGroup` role
    . │    └─────────────────> Generalized `Button` role
    . └──────────────────────> Specialized `Button` role

  */
  public struct Role: RawOptionSetType {

    private(set) public var rawValue: UInt16
    public init(rawValue: UInt16) { self.rawValue = rawValue & 0b1111_000_0001_111_11 }
    public init(nilLiteral:()) { rawValue = 0 }
    public static var allZeros: Role { return Role.Undefined }

    public static var Undefined:            Role = Role(rawValue: 0b0000_000_0000_000_00)

    // button group roles
    public static var Panel:                Role = Role(rawValue: 0b0000_000_0000_001_01)
    public static var SelectionPanel:       Role = Role(rawValue: 0b0000_000_0001_001_01)
    public static var Toolbar:              Role = Role(rawValue: 0b0000_000_0000_010_01)
    public static var TopToolbar:           Role = Role(rawValue: 0b0000_000_0001_010_01)
    public static var DPad:                 Role = Role(rawValue: 0b0000_000_0000_011_01)
    public static var Numberpad:            Role = Role(rawValue: 0b0000_000_0000_100_01)
    public static var Transport:            Role = Role(rawValue: 0b0000_000_0000_101_01)
    public static var Rocker:               Role = Role(rawValue: 0b0000_000_0000_110_01)

    // toolbar buttons
    public static var ToolbarButton:        Role = Role(rawValue: 0b0000_000_0000_010_11)
    public static var TopToolbarButton:     Role = Role(rawValue: 0b0000_000_0001_010_11)
    public static var ConnectionStatus:     Role = Role(rawValue: 0b0001_000_0001_010_11)
    public static var BatteryStatus:        Role = Role(rawValue: 0b0010_000_0001_010_11)
    public static var ToolbarButtonMask:    Role = Role(rawValue: 0b0011_000_0000_010_11)

    // picker label buttons
    public static var RockerButton:         Role = Role(rawValue: 0b0000_000_0000_110_11)
    public static var Top:                  Role = Role(rawValue: 0b0001_000_0000_110_11)
    public static var Bottom:               Role = Role(rawValue: 0b0010_000_0000_110_11)
    public static var RockerButtonMask:     Role = Role(rawValue: 0b0011_000_0000_110_11)

    // panel buttons
    public static var PanelButton:          Role = Role(rawValue: 0b0000_000_0000_001_11)
    public static var Tuck:                 Role = Role(rawValue: 0b0001_000_0000_001_11)
    public static var SelectionPanelButton: Role = Role(rawValue: 0b0000_000_0001_001_11)
    public static var PanelButtonMask:      Role = Role(rawValue: 0b0001_000_0001_001_11)

    // dpad buttons
    public static var DPadButton:           Role = Role(rawValue: 0b0000_000_0000_011_11)
    public static var Up:                   Role = Role(rawValue: 0b0001_000_0000_011_11)
    public static var Down:                 Role = Role(rawValue: 0b0010_000_0000_011_11)
    public static var Left:                 Role = Role(rawValue: 0b0011_000_0000_011_11)
    public static var Right:                Role = Role(rawValue: 0b0100_000_0000_011_11)
    public static var Center:               Role = Role(rawValue: 0b0101_000_0000_011_11)
    public static var DPadButtonMask:       Role = Role(rawValue: 0b0111_000_0000_011_11)


    // numberpad buttons
    public static var NumberpadButton:      Role = Role(rawValue: 0b0000_000_0000_100_11)
    public static var One:                  Role = Role(rawValue: 0b0001_000_0000_100_11)
    public static var Two:                  Role = Role(rawValue: 0b0010_000_0000_100_11)
    public static var Three:                Role = Role(rawValue: 0b0011_000_0000_100_11)
    public static var Four:                 Role = Role(rawValue: 0b0100_000_0000_100_11)
    public static var Five:                 Role = Role(rawValue: 0b0101_000_0000_100_11)
    public static var Six:                  Role = Role(rawValue: 0b0110_000_0000_100_11)
    public static var Seven:                Role = Role(rawValue: 0b0111_000_0000_100_11)
    public static var Eight:                Role = Role(rawValue: 0b1000_000_0000_100_11)
    public static var Nine:                 Role = Role(rawValue: 0b1001_000_0000_100_11)
    public static var Zero:                 Role = Role(rawValue: 0b1010_000_0000_100_11)
    public static var Aux1:                 Role = Role(rawValue: 0b1011_000_0000_100_11)
    public static var Aux2:                 Role = Role(rawValue: 0b1100_000_0000_100_11)
    public static var NumberpadButtonMask:  Role = Role(rawValue: 0b1111_000_0000_100_11)

    // transport buttons
    public static var TransportButton:      Role = Role(rawValue: 0b0000_000_0000_101_11)
    public static var Play:                 Role = Role(rawValue: 0b0001_000_0000_101_11)
    public static var Stop:                 Role = Role(rawValue: 0b0010_000_0000_101_11)
    public static var Pause:                Role = Role(rawValue: 0b0011_000_0000_101_11)
    public static var Skip:                 Role = Role(rawValue: 0b0100_000_0000_101_11)
    public static var Replay:               Role = Role(rawValue: 0b0101_000_0000_101_11)
    public static var FF:                   Role = Role(rawValue: 0b0110_000_0000_101_11)
    public static var Rewind:               Role = Role(rawValue: 0b0111_000_0000_101_11)
    public static var Record:               Role = Role(rawValue: 0b1000_000_0000_101_11)
    public static var TransportButtonMask:  Role = Role(rawValue: 0b1111_000_0000_101_11)

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

  public var role: Role {
    get {
      willAccessValueForKey("role")
      let role = (primitiveValueForKey("role")  as! NSNumber).unsignedShortValue
      didAccessValueForKey("role")
      return Role(rawValue: role)
    }
    set {
      willChangeValueForKey("role")
      setPrimitiveValue(NSNumber(unsignedShort: newValue.rawValue), forKey: "role")
      didChangeValueForKey("role")
    }
  }

  // MARK: - Shape

  public enum Shape: Int16 {
    case Undefined, RoundedRectangle, Oval, Rectangle, Triangle, Diamond
    public init(rawValue: Int16) {
      switch rawValue {
        case 1:  self = .RoundedRectangle
        case 2:  self = .Oval
        case 3:  self = .Rectangle
        case 4:  self = .Triangle
        case 5:  self = .Diamond
        default: self = .Undefined
      }
    }
    public static var allShapes: [Shape] { return [.Undefined, .RoundedRectangle, .Oval, .Rectangle, .Triangle, .Diamond] }

  }

  public var shape: Shape {
    get {
      willAccessValueForKey("shape")
      let shape = (primitiveValueForKey("shape")  as? NSNumber)?.shortValue ?? 0
      didAccessValueForKey("shape")
      return Shape(rawValue: shape)
    }
    set {
      willChangeValueForKey("shape")
      setPrimitiveValue(NSNumber(short: newValue.rawValue), forKey: "shape")
      didChangeValueForKey("shape")
    }
  }

  // MARK: - Style

  public struct Style: RawOptionSetType {

    private(set) public var rawValue: Int16
    public init(rawValue: Int16) { self.rawValue = rawValue & 0b1111 }
    public init(nilLiteral:()) { rawValue = 0 }
    public static var allZeros:       Style { return Style.None }
    public static var None:           Style = Style(rawValue: 0b0000)
    public static var ApplyGloss:     Style = Style(rawValue: 0b0001)
    public static var DrawBorder:     Style = Style(rawValue: 0b0010)
    public static var Stretchable:    Style = Style(rawValue: 0b0100)
    public static var DrawBackground: Style = Style(rawValue: 0b1000)

  }

  public var style: Style {
    get {
      willAccessValueForKey("style")
      let style = (primitiveValueForKey("style")  as! NSNumber).shortValue
      didAccessValueForKey("style")
      return Style(rawValue: style)
    }
    set {
      willChangeValueForKey("style")
      setPrimitiveValue(NSNumber(short: newValue.rawValue), forKey: "style")
      didChangeValueForKey("style")
    }
  }

  // MARK: - Lifecycle

  /** refresh */
  public func refresh() {
    updateForMode(currentMode)
  }

  /** awakeFromFetch */
  override public func awakeFromFetch() {
    super.awakeFromFetch()
    refresh()
  }

  // MARK: - Updating the remote element

  /**
  updateForMode:

  :param: mode String
  */
  func updateForMode(mode: Mode) {
    background = backgrounds[mode] ?? backgrounds[defaultMode]
  }

  /**
  updateWithPreset:

  :param: preset Preset
  */
  func updateWithPreset(preset: Preset) {
    role = preset.role
    shape = preset.shape
    style = preset.style

    let color = preset.backgroundColor
    let image = preset.backgroundImage
    let alpha = preset.backgroundImageAlpha

    if color != nil || image != nil || alpha != nil {
      let imageView = imageViewForMode(defaultMode)
      imageView.color = color
      imageView.image = image
      imageView.alpha = alpha
    }

    var elements: OrderedSet<RemoteElement> = []
    if let subelementPresets = preset.subelements {
      for subelementPreset in subelementPresets {
        if let element = RemoteElement.remoteElementFromPreset(subelementPreset) {
          elements.append(element)
        }
      }
    }
    subelements = elements
    if let constraints = preset.constraints {
      constraintManager.setConstraintsFromString(constraints)
    }
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      role = Role(data["role"]) ?? .Undefined
      key = String(data["key"])
      shape = Shape(data["shape"]) ?? .Undefined
      style = Style(data["style"]) ?? .None
      tag = Int16(data["tag"]) ?? 0


      applyMaybe(ObjectJSONValue(data["backgrounds"])?.compressedMap({ObjectJSONValue($2)})) {
        self.setBackground(Background.importObjectWithData($2, context: moc), forMode: $1)
      }

      if let subType = self.dynamicType.subelementType, subelementsJSON = ArrayJSONValue(data["subelements"]) {
        let subelementsMapped = compressedMap(subelementsJSON.value, {ObjectJSONValue($0)})
        subelements = OrderedSet(compressedMap(subelementsMapped, {subType.importObjectWithData($0, context: moc)}))
      }

      if let constraintsJSON = ObjectJSONValue(data["constraints"]) {
        constraints = Set(Constraint.importObjectsWithData(constraintsJSON, context: moc) as! [Constraint])
      }

    }

  }

  // MARK: - JSON value

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    if key != nil  { obj["key"] = .String(key!)   }

    obj["tag"] = tag.jsonValue
    if hasNonDefaultValue("role") { obj["role"] = role.jsonValue }
    if hasNonDefaultValue("shape") { obj["shape"] = shape.jsonValue }
    if hasNonDefaultValue("style") { obj["style"] = style.jsonValue }

    var backgrounds: JSONValue.ObjectValue = [:]
    apply(modes) { if let background: Background = self.backgrounds[$0] { backgrounds[$0] = background.jsonValue } }
    obj["backgrounds"] = .Object(backgrounds)

    let subelementJSON = subelements.map({$0.jsonValue})
    if subelementJSON.count > 0 { obj["subelements"] = Optional(JSONValue(subelementJSON)) }

    if constraints.count > 0 {

      let firstItemUUIDs = OrderedSet<String>(compressedMap(constraints){$0.firstItem?.uuid})
      let secondItemUUIDs = OrderedSet<String>(compressedMap(constraints){$0.secondItem?.uuid})
      var uuidIndex: JSONValue.ObjectValue = [name.camelCase(): uuid.jsonValue]
      for uuid in (firstItemUUIDs + secondItemUUIDs ∖ Set([self.uuid])) {
        if let element = findFirst(subelements, {$0.uuid == uuid}) { uuidIndex[element.name.camelCase()] = uuid.jsonValue }
      }
      var constraintsJSON: JSONValue.ObjectValue = [:]
      if uuidIndex.count == 1 {
        let (_, k, v) = uuidIndex[uuidIndex.startIndex]
        constraintsJSON["index.\(k)"] = v
      }
      else {
        constraintsJSON["index"] = .Object(uuidIndex)
      }
      let format: [JSONValue] = map(constraints, toString).sorted(<).map({$0.jsonValue})
      constraintsJSON["format"] = format.count == 1 ? format[0] : .Array(format)
      obj["constraints"] = .Object(constraintsJSON)
    }
    return obj.jsonValue
  }

  // MARK: - Subscripts

  /**
  subscript:

  :param: idx Int

  :returns: RemoteElement?
  */
  public subscript(idx: Int) -> RemoteElement? {
    get {
      let elements = subelements
      return contains(0 ..< elements.count, idx) ? elements[idx] : nil
    }
    set {
      var elements = subelements
      if idx == elements.count && newValue != nil {
        elements.append(newValue!)
        subelements = elements
      }
      else if contains(0 ..< elements.count, idx) {
        if newValue == nil {
          elements.removeAtIndex(idx)
          subelements = elements
        } else {
          elements.insert(newValue!, atIndex: idx)
          subelements = elements
        }
      }
    }
  }

  // MARK: - Printable

  override public var description: String {
    var result = super.description + "\n\t"

    result += "\n\t".join( "key = \(toString(key))", "tag = \(tag)", "role = \(role)", "shape = \(shape)", "style = \(style)" )
    result += "\n\tbackgrounds = {\n\(backgrounds.description.indentedBy(8))\n\t}"
    result += "\n\t"
    result += "\n\t".join(reduce(modes,
                                 [String](),
                                 {$0 + ["\($1).backgroundColor = \(toString(self.backgroundForMode($1)?.color?.string))"]}))
    result += "\n\t"
    result += "\n\t".join(reduce(modes,
                                 [String](),
                                 {$0 + ["\($1).backgroundImage = \(toString(self.backgroundForMode($1)?.image?.index))"]}))
    result += "\n\t"
    result += "\n\t".join(reduce(modes,
                                 [String](),
                                 {$0 + ["\($1).backgroundImageAlpha = \(toString(self.backgroundForMode($1)?.alpha))"]}))
    result += "\n\tsubelement count = \(subelements.count)"
    result += "\n\tconstraints = "
    if constraints.count == 0 { result += "nil" }
    else {
      result += "{\n\t\t" + "\n\t\t".join(map(constraints){$0.description}) + "\n\t}"
    }

    return result
  }

}

// MARK: - RemoteElement.BaseType extensions

extension RemoteElement.BaseType: Printable {
  public var description: String { return stringValue }
}

extension RemoteElement.BaseType: StringValueConvertible {
  public var stringValue: String {
    switch self {
      case .Undefined:   return "undefined"
      case .Remote:      return "remote"
      case .ButtonGroup: return "button-group"
      case .Button:      return "button"
    }
  }
}

extension RemoteElement.BaseType: JSONValueConvertible {
  public var jsonValue: JSONValue { return stringValue.jsonValue }
}

extension RemoteElement.BaseType: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if jsonValue != nil {
      switch jsonValue! {
        case RemoteElement.BaseType.Remote.jsonValue:      self = .Remote
        case RemoteElement.BaseType.ButtonGroup.jsonValue: self = .ButtonGroup
        case RemoteElement.BaseType.Button.jsonValue:      self = .Button
        default:                                           self = .Undefined
      }
    } else { return nil }
  }
}

// MARK: - RemoteElement.Shape extensions

extension RemoteElement.Shape: Printable {
  public var description: String { return stringValue }
}

extension RemoteElement.Shape: StringValueConvertible {
  public var stringValue: String {
    switch self {
      case .Undefined:        return "undefined"
      case .RoundedRectangle: return "rounded-rectangle"
      case .Oval:             return "oval"
      case .Rectangle:        return "rectangle"
      case .Triangle:         return "triangle"
      case .Diamond:          return "diamond"
    }
  }
}

extension RemoteElement.Shape: JSONValueConvertible {
  public var jsonValue: JSONValue { return stringValue.jsonValue }
}

extension RemoteElement.Shape: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if jsonValue != nil {
      switch jsonValue! {
        case RemoteElement.Shape.RoundedRectangle.jsonValue: self = .RoundedRectangle
        case RemoteElement.Shape.Oval.jsonValue:             self = .Oval
        case RemoteElement.Shape.Rectangle.jsonValue:        self = .Rectangle
        case RemoteElement.Shape.Triangle.jsonValue:         self = .Triangle
        case RemoteElement.Shape.Diamond.jsonValue:          self = .Diamond
        default:                                             self = .Undefined
      }
    } else { return nil }
  }
}

// MARK: - RemoteElement.Style extensions

extension RemoteElement.Style: Printable {
  public var description: String { return stringValue }
}

extension RemoteElement.Style: StringValueConvertible {
  public var stringValue: String { return String(jsonValue)! }
}

extension RemoteElement.Style: JSONValueConvertible {

  public var jsonValue: JSONValue {
    var segments: [String] = []
    if self & RemoteElement.Style.ApplyGloss  != nil    { segments.append("gloss")       }
    if self & RemoteElement.Style.DrawBorder  != nil    { segments.append("border")      }
    if self & RemoteElement.Style.Stretchable != nil    { segments.append("stretchable") }
    if self & RemoteElement.Style.DrawBackground != nil { segments.append("background") }
    if segments.isEmpty { segments.append("none") }
    return " ".join(segments).jsonValue
  }
}

extension RemoteElement.Style: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      let components = split(string){$0 == " "}
      var style = RemoteElement.Style.None
      for component in components {
        switch component {
          case "border":      style = style | RemoteElement.Style.DrawBorder
          case "stretchable": style = style | RemoteElement.Style.Stretchable
          case "gloss":       style = style | RemoteElement.Style.ApplyGloss
          case "background":  style = style | RemoteElement.Style.DrawBackground
          default: break
        }
      }
      self = style
    } else { return nil }
  }

}

// MARK: - RemoteElement.Role extensions

extension RemoteElement.Role: Hashable {
  public var hashValue: Int { return Int(rawValue) }
}

extension RemoteElement.Role: Printable {
  public var description: String { return String(jsonValue)! }
}

extension RemoteElement.Role: StringValueConvertible {
  public var stringValue: String { return String(jsonValue)! }
}

extension RemoteElement.Role: JSONValueConvertible {

  public var jsonValue: JSONValue {
    switch self {
      case RemoteElement.Role.Panel:                return "panel"
      case RemoteElement.Role.SelectionPanel:       return "selection-panel"
      case RemoteElement.Role.Toolbar:              return "toolbar"
      case RemoteElement.Role.TopToolbar:           return "top-toolbar"
      case RemoteElement.Role.DPad:                 return "dpad"
      case RemoteElement.Role.Numberpad:            return "numberpad"
      case RemoteElement.Role.Transport:            return "transport"
      case RemoteElement.Role.Rocker:               return "rocker"
      case RemoteElement.Role.ToolbarButton:        return "toolbar-button"
      case RemoteElement.Role.TopToolbarButton:     return "top-toolbar-button"
      case RemoteElement.Role.ConnectionStatus:     return "connection-status"
      case RemoteElement.Role.BatteryStatus:        return "battery-status"
      case RemoteElement.Role.RockerButton:         return "rocker-button"
      case RemoteElement.Role.Top:                  return "top"
      case RemoteElement.Role.Bottom:               return "bottom"
      case RemoteElement.Role.PanelButton:          return "panel-button"
      case RemoteElement.Role.Tuck:                 return "tuck"
      case RemoteElement.Role.SelectionPanelButton: return "selection-panel-button"
      case RemoteElement.Role.DPadButton:           return "dpad-button"
      case RemoteElement.Role.Up:                   return "up"
      case RemoteElement.Role.Down:                 return "down"
      case RemoteElement.Role.Left:                 return "left"
      case RemoteElement.Role.Right:                return "right"
      case RemoteElement.Role.Center:               return "center"
      case RemoteElement.Role.NumberpadButton:      return "numberpad-button"
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
      case RemoteElement.Role.TransportButton:      return "transport-button"
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
}

extension RemoteElement.Role: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if jsonValue != nil {
      switch jsonValue! {
        case RemoteElement.Role.Panel.jsonValue:                self = RemoteElement.Role.Panel
        case RemoteElement.Role.SelectionPanel.jsonValue:       self = RemoteElement.Role.SelectionPanel
        case RemoteElement.Role.Toolbar.jsonValue:              self = RemoteElement.Role.Toolbar
        case RemoteElement.Role.TopToolbar.jsonValue:           self = RemoteElement.Role.TopToolbar
        case RemoteElement.Role.DPad.jsonValue:                 self = RemoteElement.Role.DPad
        case RemoteElement.Role.Numberpad.jsonValue:            self = RemoteElement.Role.Numberpad
        case RemoteElement.Role.Transport.jsonValue:            self = RemoteElement.Role.Transport
        case RemoteElement.Role.Rocker.jsonValue:               self = RemoteElement.Role.Rocker
        case RemoteElement.Role.ToolbarButton.jsonValue:        self = RemoteElement.Role.ToolbarButton
        case RemoteElement.Role.TopToolbarButton.jsonValue:     self = RemoteElement.Role.TopToolbarButton
        case RemoteElement.Role.ConnectionStatus.jsonValue:     self = RemoteElement.Role.ConnectionStatus
        case RemoteElement.Role.BatteryStatus.jsonValue:        self = RemoteElement.Role.BatteryStatus
        case RemoteElement.Role.RockerButton.jsonValue:         self = RemoteElement.Role.RockerButton
        case RemoteElement.Role.Top.jsonValue:                  self = RemoteElement.Role.Top
        case RemoteElement.Role.Bottom.jsonValue:               self = RemoteElement.Role.Bottom
        case RemoteElement.Role.PanelButton.jsonValue:          self = RemoteElement.Role.PanelButton
        case RemoteElement.Role.Tuck.jsonValue:                 self = RemoteElement.Role.Tuck
        case RemoteElement.Role.SelectionPanelButton.jsonValue: self = RemoteElement.Role.SelectionPanelButton
        case RemoteElement.Role.DPadButton.jsonValue:           self = RemoteElement.Role.DPadButton
        case RemoteElement.Role.Up.jsonValue:                   self = RemoteElement.Role.Up
        case RemoteElement.Role.Down.jsonValue:                 self = RemoteElement.Role.Down
        case RemoteElement.Role.Left.jsonValue:                 self = RemoteElement.Role.Left
        case RemoteElement.Role.Right.jsonValue:                self = RemoteElement.Role.Right
        case RemoteElement.Role.Center.jsonValue:               self = RemoteElement.Role.Center
        case RemoteElement.Role.NumberpadButton.jsonValue:      self = RemoteElement.Role.NumberpadButton
        case RemoteElement.Role.One.jsonValue:                  self = RemoteElement.Role.One
        case RemoteElement.Role.Two.jsonValue:                  self = RemoteElement.Role.Two
        case RemoteElement.Role.Three.jsonValue:                self = RemoteElement.Role.Three
        case RemoteElement.Role.Four.jsonValue:                 self = RemoteElement.Role.Four
        case RemoteElement.Role.Five.jsonValue:                 self = RemoteElement.Role.Five
        case RemoteElement.Role.Six.jsonValue:                  self = RemoteElement.Role.Six
        case RemoteElement.Role.Seven.jsonValue:                self = RemoteElement.Role.Seven
        case RemoteElement.Role.Eight.jsonValue:                self = RemoteElement.Role.Eight
        case RemoteElement.Role.Nine.jsonValue:                 self = RemoteElement.Role.Nine
        case RemoteElement.Role.Zero.jsonValue:                 self = RemoteElement.Role.Zero
        case RemoteElement.Role.Aux1.jsonValue:                 self = RemoteElement.Role.Aux1
        case RemoteElement.Role.Aux2.jsonValue:                 self = RemoteElement.Role.Aux2
        case RemoteElement.Role.TransportButton.jsonValue:      self = RemoteElement.Role.TransportButton
        case RemoteElement.Role.Play.jsonValue:                 self = RemoteElement.Role.Play
        case RemoteElement.Role.Stop.jsonValue:                 self = RemoteElement.Role.Stop
        case RemoteElement.Role.Pause.jsonValue:                self = RemoteElement.Role.Pause
        case RemoteElement.Role.Skip.jsonValue:                 self = RemoteElement.Role.Skip
        case RemoteElement.Role.Replay.jsonValue:               self = RemoteElement.Role.Replay
        case RemoteElement.Role.FF.jsonValue:                   self = RemoteElement.Role.FF
        case RemoteElement.Role.Rewind.jsonValue:               self = RemoteElement.Role.Rewind
        case RemoteElement.Role.Record.jsonValue:               self = RemoteElement.Role.Record
        default:                                                self = RemoteElement.Role.Undefined
      }
    } else { return nil }
  }
}
