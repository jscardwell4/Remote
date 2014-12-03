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

    let titlesSection = DetailSection(section: 1, title: "Titles")

    if let titles = preset.attributes.titles {
      var attributesByState: OrderedDictionary<String, TitleAttributes> = [:]
      for (state, values) in titles { attributesByState[state] = TitleAttributes(storage: values) }
      attributesByState.sort { $0 == "normal" ? true : ($1 == "normal" ? false : $0 < $1) }
      var fillerAttributes: MSDictionary?
      let backgroundColor = UIColor(white: 0.35, alpha: 0.75)

      var normalAttributes: TitleAttributes? = attributesByState["normal"]
      if normalAttributes != nil { fillerAttributes = normalAttributes!.attributes }

      for (state, attributes) in attributesByState {
        titlesSection.addRow {
          var row = DetailAttributedLabelRow()
          row.name = state.titlecaseString
          row.info = attributes.stringWithFillers(fillerAttributes)
          row.backgroundColor = backgroundColor
          row.select = {
            var attrs = attributes
            attrs.mergeWithTitleAttributes(normalAttributes)
            let controller = TitleAttributesDetailController(attributesDelegate: TitleAttributesDelegate(titleAttributes: attrs))
            controller.title = state.titlecaseString
            if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
              nav.pushViewController(controller, animated: true)
            }
          }
          return row
        }

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
