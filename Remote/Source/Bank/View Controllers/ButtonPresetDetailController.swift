//
//  ButtonPresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(ButtonPresetDetailController)
class ButtonPresetDetailController: PresetDetailController {

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)

    let titlesSection = DetailSection(sectionNumber: 1, title: "Titles")

    if let titles = preset.attributes.titles {
      var attributesByState: [String: TitleAttributes] = [:]
      for (state, values) in titles { attributesByState[state] = TitleAttributes(storage: values) }

      var fillerAttributes: MSDictionary?
      let backgroundColor = UIColor(white: 0.35, alpha: 0.75)

      var normalAttributes: TitleAttributes? = attributesByState["normal"]
      if normalAttributes != nil {
        titlesSection.addRow {
          let row = DetailAttributedLabelRow(label: "Normal", value: normalAttributes!.string)
          row.backgroundColor = backgroundColor
          row.selectionHandler = {
            let controller = TitleAttributesDetailController(attributes: normalAttributes!)
            if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
              nav.pushViewController(controller, animated: true)
            }
          }
          return row
        }
        fillerAttributes = normalAttributes!.attributes
        attributesByState["normal"] = nil
      }

      for (state, attributes) in attributesByState {
        titlesSection.addRow {
          let row = DetailAttributedLabelRow()
          row.name = state.titlecaseString
          row.info = attributes.stringWithFillers(fillerAttributes)
          row.backgroundColor = backgroundColor
          row.selectionHandler = {
            let attrs = attributes.copy
            attrs.mergeWithTitleAttributes(normalAttributes)
            let controller = TitleAttributesDetailController(attributes: attrs)
            if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
              nav.pushViewController(controller, animated: true)
            }
          }
          return row
        }

        // for generatedRow in generateRowsForTitleAttributes(attributes, indentationLevel: 1) {
        //   titlesSection.addRow { generatedRow }
        // }

      }
    }

    sections.append(titlesSection)
    // TODO: icons
    // TODO: images
    // TODO: backgroundColors
    // TODO: titleEdgeInsets
    // TODO: contentEdgeInsets
    // TODO: imageEdgeInsets
    // TODO: command

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
