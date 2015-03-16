//
//  Remote.swift
//  Remote
//
//  Created by Jason Cardwell on 11/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Remote)
class Remote: RemoteElement {

  override var elementType: BaseType { return .Remote }

  @NSManaged var topBarHidden: Bool
  @NSManaged var activity: Activity?

  @NSManaged var panels: NSDictionary
  var panelAssignments: [NSNumber:String] {
    get { return panels as? [NSNumber:String] ?? [:] }
    set { panels = newValue }
  }

  override var parentElement: RemoteElement? { get { return nil } set {} }

  /**
  initWithPreset:

  :param: preset Preset
  */
  override init(preset: Preset) {
    super.init(preset: preset)

    topBarHidden = preset.topBarHidden ?? false
  }

  required init(context: NSManagedObjectContext, insert: Bool) {
      fatalError("init(context:insert:) has not been implemented")
  }

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
//  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//    super.init(entity: entity, insertIntoManagedObjectContext: context)
//  }

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
//  override init(context: NSManagedObjectContext) {
//    super.init(context: context)
//  }

  /**
  setButtonGroup:forPanelAssignment:

  :param: buttonGroup ButtonGroup?
  :param: assignment ButtonGroup.PanelAssignment
  */
  func setButtonGroup(buttonGroup: ButtonGroup?, forPanelAssignment assignment: ButtonGroup.PanelAssignment) {
    var assignments = panelAssignments
    if assignment != ButtonGroup.PanelAssignment.Unassigned { assignments[assignment.rawValue] = buttonGroup?.uuid }
    panelAssignments = assignments
  }

  /**
  buttonGroupForPanelAssignment:

  :param: assignment ButtonGroup.PanelAssignment

  :returns: ButtonGroup?
  */
  func buttonGroupForPanelAssignment(assignment: ButtonGroup.PanelAssignment) -> ButtonGroup? {
    var buttonGroup: ButtonGroup?
    if managedObjectContext != nil {
      if let uuid = panelAssignments[assignment.rawValue] {
        buttonGroup = ButtonGroup.existingObjectWithUUID(uuid, context: managedObjectContext!)
      }
    }
    return buttonGroup
  }


  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      if let topBarHidden = data["top-bar-hidden"] as? NSNumber { self.topBarHidden = topBarHidden.boolValue }

      if let panels = data["panels"] as? [String:String] {
        for (key, uuid) in panels {
          if let buttonGroup = subelements.objectPassingTest({($0.0 as! RemoteElement).uuid == uuid}) as? ButtonGroup {
            let assignment = ButtonGroup.PanelAssignment(JSONValue: key)
            if assignment != ButtonGroup.PanelAssignment.Unassigned {
              setButtonGroup(buttonGroup, forPanelAssignment: assignment)
            }
          }
        }
      }

    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    let panels = MSDictionary()

    for (number, uuid) in panelAssignments {
      let assignment = ButtonGroup.PanelAssignment(rawValue: number.integerValue)
      if let commentedUUID = buttonGroupForPanelAssignment(assignment)?.commentedUUID {
        panels[assignment.JSONValue] = commentedUUID
      }
    }

    if panels.count > 0 { dictionary["panels"] = panels }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
