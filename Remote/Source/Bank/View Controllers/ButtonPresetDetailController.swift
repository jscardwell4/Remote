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

    loadTitlesSection()

    // TODO: icons
    // TODO: images
    // TODO: backgroundColors
    // TODO: titleEdgeInsets
    // TODO: contentEdgeInsets
    // TODO: imageEdgeInsets
    // TODO: command

  }


  /** loadTitlesSection */
  func loadTitlesSection() {

    var titlesSection = sections["Titles"] as? FilteringDetailSection
    if titlesSection == nil {
      titlesSection = FilteringDetailSection(section: 1, title: "Titles")
      let highlightedPredicate = FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
        (row: DetailRow) -> Bool in
          if let controlState = UIControlState(JSONValue: row.name?.dashcaseString ?? "") {
            return controlState & .Highlighted != nil
          } else {
            return false
          }
        })
      let selectedPredicate = FilteringDetailSection.Predicate(name: "Selected", includeRow: {
        (row: DetailRow) -> Bool in
          if let controlState = UIControlState(JSONValue: row.name?.dashcaseString ?? "") {
            return controlState & .Selected != nil
          } else {
            return false
          }
        })
      let disabledPredicate = FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
        (row: DetailRow) -> Bool in
          if let controlState = UIControlState(JSONValue: row.name?.dashcaseString ?? "") {
            return controlState & .Disabled != nil
          } else {
            return false
          }
        })
      titlesSection?.predicates = [highlightedPredicate, selectedPredicate, disabledPredicate]
      sections["Titles"] = titlesSection!
    } else {
      titlesSection!.removeAllRows(keepCapacity: true)
    }

    let preset = model as Preset

    if let titles = preset.titles {

      let backgroundColor = UIColor(white: 0.35, alpha: 0.75)

      var attributesByState = OrderedDictionary(titles).map{TitleAttributes(storage: $1)}
      attributesByState.sort{$0 == "normal" ? true : ($1 == "normal" ? false : $0 < $1)}

      for (state, attributes) in attributesByState {

        titlesSection!.addRow {

          let mergedAttributes = attributes.mergedWithTitleAttributes(attributesByState["normal"])

          var row = DetailAttributedTextRow()
          row.name = state.titlecaseString
          row.info = mergedAttributes.string

          row.select = {

            let attributesDelegate = TitleAttributesDelegate(titleAttributes: mergedAttributes)
            attributesDelegate.observer = self

            self.pushedTitleAttributesKey = state
            self.pushedTitleAttributesRow = row

            let controller = TitleAttributesDetailController(item: attributesDelegate)
            controller.title = state.titlecaseString
            self.pushController(controller)

          } // end .select

          row.delete = {

            var titles = preset.titles!
            titles[state] = nil
            preset.titles = titles

          } // end .delete

          return row

        } // end .addRow

      } // end for (state, attributes)

      let allStates = UIControlState.all

      if titles.count < allStates.count {
        let existingStates = compressed(attributesByState.keys.map{UIControlState(JSONValue: $0)})
        let availableStates = allStates ∖ existingStates

        titlesSection!.addRow {
          var row = DetailListRow()
          row.infoDataType = .AttributedStringData
          var attributes = [NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
                            NSForegroundColorAttributeName: DetailController.actionColor,
                            NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)]
          let attributedString = NSMutableAttributedString(string: UIFont.fontAwesomeIconForName("plus"), attributes: attributes)
          attributes[NSFontAttributeName] = DetailController.actionFont
          let textString = NSAttributedString(string: " Add Title For Button State…", attributes: attributes)
          attributedString.appendAttributedString(textString)
          row.info = attributedString

          // row.info = UIFont.attributedFontAwesomeIconForName("plus")

          row.select = {
            println("now we should prompt user for state of title to add…")
          }

          return row
        }
      }

    } // end if let titles

  } // end loadTitlesSection()

}

extension ButtonPresetDetailController: TitleAttributesDelegateObserver {

  /**
  saveInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func saveInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    assert(pushedTitleAttributesKey != nil)
    let preset = model as Preset
    if var titles = preset.titles {
      titles[pushedTitleAttributesKey!] = titleAttributesDelegate.titleAttributes.JSONValue
      preset.titles = titles
    }
    preset.save()
    loadTitlesSection()
  }

  /**
  deleteInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func deleteInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    assert(pushedTitleAttributesKey != nil)
    let preset = model as Preset
    if var titles = preset.titles {
      titles[pushedTitleAttributesKey!] = nil
      preset.titles = titles
    }
    preset.save()
    loadTitlesSection()
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
