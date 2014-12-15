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

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    loadTitleSection()

    // TODO: icons
    // TODO: images
    // TODO: backgroundColors
    // TODO: titleEdgeInsets
    // TODO: contentEdgeInsets
    // TODO: imageEdgeInsets
    // TODO: command

  }

  private var titleState: UIControlState = .Normal

  /**
  generateTitleRowForState:

  :param: state UIControlState

  :returns: DetailAttributedTextRow
  */
  private func generateTitleRowForState(state: UIControlState) -> DetailAttributedTextRow {
    let preset = model as Preset
    let normalAttributes = TitleAttributes(storage: preset.titles?["normal"] ?? [:])
    let stateAttributes = TitleAttributes(storage: preset.titles?[state.JSONValue] ?? [:])
    let mergedAttributes = stateAttributes.mergedWithTitleAttributes(normalAttributes)
    let row = DetailAttributedTextRow()
    row.info = mergedAttributes.string
    row.select = {
      let attributesDelegate = TitleAttributesDelegate(titleAttributes: mergedAttributes, observer: self)

      self.pushedTitleAttributesKey = state.JSONValue

      let controller = TitleAttributesDetailController(item: attributesDelegate)
      controller.title = state.JSONValue.titlecaseString
      self.pushController(controller)
    }
    row.delete = {
      var titles = preset.titles!
      titles[state.JSONValue] = nil
      preset.titles = titles
      if let indexPath = row.indexPath { self.reloadRowsAtIndexPaths([indexPath]) }
    }
    return row
  }

  /**
  generateTitleCreationRowForState:

  :param: state UIControlState

  :returns: DetailListRow
  */
  private func generateTitleCreationRowForState(state: UIControlState) -> DetailListRow {
    let preset = model as Preset
    let row = DetailListRow()
    row.infoDataType = .AttributedStringData

    var attributes = [
      NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
      NSForegroundColorAttributeName: DetailController.actionColor,
      NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
    ]

    let attributedString = NSMutableAttributedString(string: UIFont.fontAwesomeIconForName("plus"), attributes: attributes)
    attributes[NSFontAttributeName] = DetailController.actionFont
    attributedString.appendAttributedString(NSAttributedString(string: " Add Title", attributes: attributes))

    row.info = attributedString

    row.select = {
      var titles = preset.titles ?? [:]
      titles[state.JSONValue] = [String:[String:AnyObject]]()
      preset.titles = titles

      self.reloadSection(self.sections["Title"]!)
    }

    return row
  }

  /**
  generateRowForState:

  :param: state UIControlState

  :returns: DetailRow
  */
  private func generateRowForState(state: UIControlState) -> DetailRow {
    let row = ((model as Preset).titles?.keys.array ?? []) ∋ state.JSONValue
                ? generateTitleRowForState(state)
                : generateTitleCreationRowForState(state)
    // row.deleteRemovesRow = false
    row.tag = state
    return row
  }

  /** loadTitleSection */
  func loadTitleSection() {

    var titleSection = sections["Title"] as? FilteringDetailSection
    titleSection?.removeAllRows(keepCapacity: true)

    if titleSection == nil {

      titleSection = FilteringDetailSection(section: 1, title: "Title", controller: self)
      titleSection!.predicates = [
        FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
          ($0.tag as UIControlState) & .Highlighted != nil
        },
        active: self.titleState & .Highlighted != nil),
        FilteringDetailSection.Predicate(name: "Selected", includeRow: {
          ($0.tag as UIControlState) & .Selected != nil
        },
        active: self.titleState & .Selected != nil),
        FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
          ($0.tag as UIControlState) & .Disabled != nil
        },
        active: self.titleState & .Disabled != nil)
      ]
      titleSection!.activePredicatesDidChange = {
        var state = UIControlState.Normal
        for predicate in $0.predicates {
          switch predicate.name {
            case "Highlighted" where predicate.active: state |= .Highlighted
            case "Selected" where predicate.active:    state |= .Selected
            case "Disabled" where predicate.active:    state |= .Disabled
            default: break
          }
        }
        self.titleState = state
      }
      sections["Title"] = titleSection!
    }

    apply(((0..<8).map{UIControlState(UInt($0))})) { state in titleSection!.addRow { self.generateRowForState(state) } }

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
    if var titles = preset.titles {
      titles[pushedTitleAttributesKey!] = titleAttributesDelegate.titleAttributes.JSONValue
      preset.titles = titles
    }
    preset.save()
    loadTitleSection()
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
    loadTitleSection()
  }

  /**
  rollbackInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func rollbackInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    // TODO: Double check we don't need to rollback the preset here
  }

}
