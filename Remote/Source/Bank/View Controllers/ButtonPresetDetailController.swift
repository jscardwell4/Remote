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


// TODO: Swipe to delete title rows
class ButtonPresetDetailController: PresetDetailController {

  private var pushedTitleAttributesKey: String?
  private var pushedTitleAttributesRow: DetailRow?


  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    let preset = model as Preset


    let titlesSection = DetailSection(section: 1, title: "Titles")

    if let titles = preset.titles {

      let backgroundColor = UIColor(white: 0.35, alpha: 0.75)

      var attributesByState = OrderedDictionary(titles).map{TitleAttributes(storage: $1)}
      attributesByState.sort{$0 == "normal" ? true : ($1 == "normal" ? false : $0 < $1)}

      for (state, attributes) in attributesByState {

        titlesSection.addRow {

          var row = DetailAttributedLabelRow()
          row.name = state.titlecaseString
          row.info = attributes.stringWithFillers(attributesByState["normal"]?.attributes)
          row.backgroundColor = backgroundColor

          row.select = {

            let attributesDelegate = TitleAttributesDelegate(titleAttributes: attributes)
            attributesDelegate.observer = self

            self.pushedTitleAttributesKey = state
            self.pushedTitleAttributesRow = row

            let controller = TitleAttributesDetailController(item: attributesDelegate)
            controller.title = state.titlecaseString

            if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
              nav.pushViewController(controller, animated: true)
            }

          }

          row.delete = {
            var titles = preset.titles!
            titles[state] = nil
            preset.titles = titles
          }
          round(2.0)
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

extension ButtonPresetDetailController: TitleAttributesDelegateObserver {

  /**
  saveInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func saveInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    assert(pushedTitleAttributesKey != nil)
    let preset = model as Preset
    var presetAttributes = preset
    if var titles = presetAttributes.titles {
      titles[pushedTitleAttributesKey!] = titleAttributesDelegate.titleAttributes.JSONValue
      presetAttributes.titles = titles
    }
    preset.save()
    reloadRowsAtIndexPaths([pushedTitleAttributesRow!.indexPath!])
  }

  /**
  deleteInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func deleteInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    assert(pushedTitleAttributesKey != nil)
    let preset = model as Preset
    var presetAttributes = preset
    if var titles = presetAttributes.titles {
      titles[pushedTitleAttributesKey!] = nil
      presetAttributes.titles = titles
    }
    preset.save()

    let indexPath = pushedTitleAttributesRow!.indexPath!
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
  }

  /**
  rollbackInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func rollbackInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    // TODO: Double check we don't need to rollback the preset here
  }

}
