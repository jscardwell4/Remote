//
//  PresetAttributes.swift
//  Remote
//
//  Created by Jason Cardwell on 11/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

public final class PresetAttributes {

  // private var storage: [String:AnyObject]
  // var dictionaryValue: NSDictionary { return storage as NSDictionary }

  private let storage: DictionaryStorage
  public var dictionaryValue: NSDictionary { return storage.dictionary }

  public let context: NSManagedObjectContext?

  /**
  initWithStorage:

  :param: storage [String String]
  */
  // init(storage: [String:AnyObject], context: NSManagedObjectContext?) { self.storage = storage; self.context = context }


  public init(storage: DictionaryStorage) { self.storage = storage; self.context = storage.managedObjectContext }

  public var baseType: RemoteElement.BaseType {
    get { return RemoteElement.BaseType(jsonValue: (storage["baseType"] as? String ?? "undefined").jsonValue) }
    set { storage["baseType"] = newValue.jsonValue.anyObjectValue }
  }

  public var role: RemoteElement.Role {
    get { return RemoteElement.Role(jsonValue: (storage["role"] as? String ?? "undefined").jsonValue) }
    set { storage["role"] = newValue.jsonValue.anyObjectValue }
  }

  public var shape: RemoteElement.Shape {
    get { return RemoteElement.Shape(jsonValue: (storage["shape"] as? String ?? "undefined").jsonValue) }
    set { storage["shape"] = newValue.jsonValue.anyObjectValue }
  }

  public var style: RemoteElement.Style {
    get { return RemoteElement.Style(jsonValue: (storage["style"] as? String ?? "undefined").jsonValue) }
    set { storage["style"] = newValue.jsonValue.anyObjectValue }
  }

  public var backgroundImage: Image? {
    get {
      if let moc = context, path = storage["backgroundImage"] as? String {
        return Image.objectWithIndex(PathIndex(path)!, context: moc)
      } else { return nil }
    }
    set { storage["backgroundImage"] = newValue }
  }

  public var backgroundImageAlpha: NSNumber? {
    get { return storage["backgroundImage-alpha"] as? NSNumber }
    set { storage["backgroundImage-alpha"] = newValue }
  }

  public var backgroundColor: UIColor? {
    get { return UIColor(string: storage["backgroundColor"] as? String ?? "") }
    set { storage["backgroundColor"] = newValue?.string }
  }

  public var subelements: [PresetAttributes]? {
    get { return nil } // return (storage["subelements"] as? [[String:AnyObject]])?.map{PresetAttributes(storage: $0, context: self.context)} }
    set { } //storage["subelements"] = newValue?.map{$0.storage} }
  }

  public var constraints: String? {
    get {
      if let constraintsArray = storage["constraints"] as? [String] {
        return "\n".join(constraintsArray)
      } else {
        return storage["constraints"] as? String
      }
    }
    set { storage["constraints"] = newValue }
  }

  /// MARK: - Remote attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var topBarHidden: Bool? {
    get { return (storage["topBar-hidden"] as? NSNumber)?.boolValue }
    set { storage["topBar-hidden"] = newValue }
  }

  // panels?


  /// MARK: - ButtonGroup attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var autohide: Bool? {
    get { return (storage["autohide"] as? NSNumber)?.boolValue }
    set { storage["autohide"] = newValue }
  }

  public var label: NSAttributedString? {
    get { return storage["label"] as? NSAttributedString }
    set { storage["label"] = newValue }
  }

  public var labelAttributes: [String:AnyObject]? {
    get { return storage["labelAttributes"] as? [String:AnyObject] }
    set { storage["labelAttributes"] = newValue }
  }

  public var labelConstraints: String? {
    get { return storage["labelConstraints"] as? String }
    set { storage["labelConstraints"] = newValue }
  }

  public var panelAssignment: ButtonGroup.PanelAssignment? {
    get { return ButtonGroup.PanelAssignment(jsonValue: (storage["panelAssignment"] as? String ?? "").jsonValue) }
    set { storage["panelAssignment"] = newValue?.jsonValue.anyObjectValue }
  }

  /// MARK: - Button attributes
  ////////////////////////////////////////////////////////////////////////////////


  /** titles data stored in format ["state":["attribute":"value"]] */
  public var titles: [String:[String:AnyObject]]? {
    get { return storage["titles"] as? [String:[String:AnyObject]] }
    set { storage["titles"] = newValue }
  }

  /** icons data stored in format ["state":["image/color":"value"]] */
  public var icons: [String:[String:AnyObject]]? {
    get { return storage["icons"] as? [String:[String:AnyObject]] }
    set { storage["icons"] = newValue }
  }

  /** images data stored in format ["state":["image/color":"value"]] */
  public var images: [String:[String:AnyObject]]? {
    get { return storage["images"] as? [String:[String:AnyObject]] }
    set { storage["images"] = newValue }
  }

  /** backgroundColors data stored in format ["state":"color"] */
  public var backgroundColors: [String:AnyObject]? {
    get { return storage["backgroundColors"] as? [String:AnyObject] }
    set { storage["backgroundColors"] = newValue }
  }

  public var titleEdgeInsets: UIEdgeInsets? {
    get { return (storage["titleEdge-insets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["titleEdge-insets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

  public var contentEdgeInsets: UIEdgeInsets? {
    get { return (storage["contentEdge-insets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["contentEdgeInsets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

  public var imageEdgeInsets: UIEdgeInsets? {
    get { return (storage["imageEdge-insets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["imageEdge-insets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

  public var command: [String:String]? {
    get { return storage["command"] as? [String:String] }
    set { storage["command"] = newValue }
  }

}
