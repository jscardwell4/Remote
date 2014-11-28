//
//  PresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(PresetDetailController)
class PresetDetailController: BankItemDetailController {

  var preset: Preset { return item as Preset }
  let element: RemoteElement!

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)

    if let preset = self.item as? Preset {
      assert(preset.managedObjectContext != nil && preset.managedObjectContext! == context)

      if let element = preset.generateElement() {
        self.element = element
        let detailsSection = BankItemDetailSection(sectionNumber: 0)

        detailsSection.addRow { return BankItemDetailLabelRow(pushableCategory: preset.presetCategory!, label: "Category") }
        detailsSection.addRow { return BankItemDetailLabelRow(label: "Base Type", value: preset.attributes.baseType.title) }
        detailsSection.addRow {
          let row = BankItemDetailButtonRow()
          row.name = "Role"
          row.info = preset.attributes.role.JSONValue.titlecaseString
          row.didSelectItem = {
            if !self.didCancel {
              var attributes = self.preset.attributes
              attributes.role = RemoteElement.Role(JSONValue: ($0 as String).dashcaseString)
              self.preset.attributes = attributes
            }
          }

          return row
        }

        // TODO: shape
        // TODO: style
        // TODO: backgroundImage
        // TODO: backgroundImageAlpha
        // TODO: backgroundColor
        // TODO: subelements
        // TODO: constraints


        let previewSection = BankItemDetailSection(sectionNumber: 1)
        previewSection.addRow { return BankItemDetailImageRow(previewableItem: preset) }

        sections = [detailsSection, previewSection]

      } else { return nil }

    } else { return nil }

  }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
