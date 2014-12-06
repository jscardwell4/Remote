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

class ButtonPresetDetailController: PresetDetailController {

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    let preset = model as Preset


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
            let controller = TitleAttributesDetailController(item: TitleAttributesDelegate(titleAttributes: attrs))
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

}
