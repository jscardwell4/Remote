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

class PresetAttributes {

  private var storage: [String:AnyObject]
  var dictionaryValue: NSDictionary { return storage as NSDictionary }

  let context: NSManagedObjectContext?

  /**
  initWithStorage:

  :param: storage [String String]
  */
  init(storage: [String:AnyObject], context: NSManagedObjectContext?) { self.storage = storage; self.context = context }

  var baseType: RemoteElement.BaseType {
    get { return RemoteElement.BaseType(JSONValue: storage["baseType"] as? String ?? "undefined") }
    set { storage["baseType"] = newValue.JSONValue }
  }

  var role: RemoteElement.Role {
    get { return RemoteElement.Role(JSONValue: storage["role"] as? String ?? "undefined") }
    set { storage["role"] = newValue.JSONValue }
  }

  var shape: RemoteElement.Shape? {
    get { return RemoteElement.Shape(JSONValue: storage["shape"] as? String ?? "undefined") }
    set { storage["shape"] = newValue?.JSONValue }
  }

  var style: RemoteElement.Style? {
    get { return RemoteElement.Style(JSONValue: storage["style"] as? String ?? "undefined") }
    set { storage["style"] = newValue?.JSONValue }
  }

  var backgroundImage: Image? {
    get { return ImageCategory.imageForPath(storage["backgroundImage"] as? String, context: context) }
    set { storage["backgroundImage"] = newValue }
  }

  var backgroundImageAlpha: NSNumber? {
    get { return storage["backgroundImageAlpha"] as? NSNumber }
    set { storage["backgroundImageAlpha"] = newValue }
  }

  var backgroundColor: UIColor? {
    get { return UIColor(JSONValue: storage["backgroundColor"] as? String ?? "") }
    set { storage["backgroundColor"] = newValue?.JSONValue }
  }

  var subelements: [PresetAttributes]? {
    get { return (storage["subelements"] as? [[String:AnyObject]])?.map{PresetAttributes(storage: $0, context: self.context)} }
    set { storage["subelements"] = newValue?.map{$0.storage} }
  }

  var constraints: String? {
    get { return storage["constraints"] as? String }
    set { storage["constraints"] = newValue }
  }

  /// MARK: - Remote attributes
  ////////////////////////////////////////////////////////////////////////////////


  var topBarHidden: Bool? {
    get { return (storage["topBarHidden"] as? NSNumber)?.boolValue }
    set { storage["topBarHidden"] = newValue }
  }

  // panels?


  /// MARK: - ButtonGroup attributes
  ////////////////////////////////////////////////////////////////////////////////


  var autohide: Bool? {
    get { return (storage["autohide"] as? NSNumber)?.boolValue }
    set { storage["autohide"] = newValue }
  }

  var label: NSAttributedString? {
    get { return storage["label"] as? NSAttributedString }
    set { storage["label"] = newValue }
  }

  var labelAttributes: [String:AnyObject]? {
    get { return storage["labelAttributes"] as? [String:AnyObject] }
    set { storage["labelAttributes"] = newValue }
  }

  var labelConstraints: String? {
    get { return storage["labelConstraints"] as? String }
    set { storage["labelConstraints"] = newValue }
  }

  var panelAssignment: ButtonGroup.PanelAssignment? {
    get { return ButtonGroup.PanelAssignment(JSONValue: storage["panelAssignment"] as? String ?? "") }
    set { storage["panelAssignment"] = newValue?.JSONValue }
  }

  /// MARK: - Button attributes
  ////////////////////////////////////////////////////////////////////////////////


  /** titles data stored in format ["state":["attribute":"value"]] */
  var titles: [String:[String:AnyObject]]? {
    get { return storage["titles"] as? [String:[String:AnyObject]] }
    set { storage["titles"] = newValue }
  }

  /** icons data stored in format ["state":["image/color":"value"]] */
  var icons: [String:[String:AnyObject]]? {
    get { return storage["icons"] as? [String:[String:AnyObject]] }
    set { storage["icons"] = newValue }
  }

  /** images data stored in format ["state":["image/color":"value"]] */
  var images: [String:[String:AnyObject]]? {
    get { return storage["images"] as? [String:[String:AnyObject]] }
    set { storage["images"] = newValue }
  }

  /** backgroundColors data stored in format ["state":"color"] */
  var backgroundColors: [String:AnyObject]? {
    get { return storage["backgroundColors"] as? [String:AnyObject] }
    set { storage["backgroundColors"] = newValue }
  }

  var titleEdgeInsets: UIEdgeInsets? {
    get { return (storage["titleEdgeInsets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["titleEdgeInsets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

  var contentEdgeInsets: UIEdgeInsets? {
    get { return (storage["contentEdgeInsets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["contentEdgeInsets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

  var imageEdgeInsets: UIEdgeInsets? {
    get { return (storage["imageEdgeInsets"] as? NSValue)?.UIEdgeInsetsValue() }
    set { storage["imageEdgeInsets"] = newValue == nil ? nil : NSValue(UIEdgeInsets: newValue!) }
  }

}
