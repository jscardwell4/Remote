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
import DataModel

class ButtonPresetDetailController: PresetDetailController {

  private enum SectionKey: String {
    case Title           = "Title"
    case Icon            = "Icon"
    case Image           = "Image"
    case BackgroundColor = "Background Color"

    /**
    rowKeyForState:

    :param: state UIControlState
    */
    func rowKeyForState(state: UIControlState) -> String {
      return "\(rawValue) - \(state.stringValue.titlecaseString)"
    }
  }

  private var pushedTitleAttributesKey: String?

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    let commonAttributesSection = sections["Common Attributes"]
    commonAttributesSection?.removeRowForKey("Background Image")
    commonAttributesSection?.removeRowForKey("Background Image Alpha")
    commonAttributesSection?.removeRowForKey("Background Color")

    precondition(model is Preset, "we should have been given a preset")

    loadBackgroundColorSection()
    loadTitleSection()
    loadIconSection()
    loadImageSection()
    // TODO: titleEdgeInsets
    // TODO: contentEdgeInsets
    // TODO: imageEdgeInsets
    // TODO: command

  }

  /// MARK: - Background Colors
  ////////////////////////////////////////////////////////////////////////////////


  private var backgroundColorState: UIControlState = .Normal

  /**
  generateBackgroundColorDisplayRowForState:

  :param: state UIControlState

  :returns: DetailColorRow
  */
  private func generateBackgroundColorDisplayRowForState(state: UIControlState) -> DetailColorRow {
    let preset = model as! Preset

    let row = DetailColorRow()
    row.tag = state
    if let backgroundColorsJSON = preset.backgroundColors, backgroundColorJSON = backgroundColorsJSON[state.stringValue] {
      row.info = UIColor(backgroundColorJSON)
    }
    row.valueDidChange = {
      var backgroundColorsJSON = preset.backgroundColors ?? ObjectJSONValue([:])
      backgroundColorsJSON[state.stringValue] = ($0 as? UIColor)?.jsonValue
      preset.backgroundColors = backgroundColorsJSON
    }
    row.delete = {
      if var backgroundColorsJSON = preset.backgroundColors {
        backgroundColorsJSON[state.stringValue] = nil
        preset.backgroundColors = backgroundColorsJSON
        if let indexPath = row.indexPath { self.reloadRowsAtIndexPaths([indexPath]) }
      }
    }
    return row
  }

  /**
  generateBackgroundColorCreationRowForState:

  :param: state UIControlState

  :returns: DetailListRow
  */
  private func generateBackgroundColorCreationRowForState(state: UIControlState) -> DetailListRow {
    let preset = model as! Preset
    let row = DetailListRow()
    row.tag = state
    row.infoDataType = .AttributedStringData

    var attributes = [
      NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
      NSForegroundColorAttributeName: DetailController.actionColor,
      NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
    ]

    let attributedString = NSAttributedString(string: UIFont.fontAwesomeIconForName("plus"),
                                              attributes: attributes).mutableCopy() as! NSMutableAttributedString

    attributes[NSFontAttributeName] = DetailController.actionFont
    attributedString.appendAttributedString(NSAttributedString(string: " Add Background Color", attributes: attributes))

    row.info = attributedString

    row.select = {
      //???: why do we do this?
      var backgroundColorsJSON = preset.backgroundColors ?? ObjectJSONValue([:])
      backgroundColorsJSON[state.stringValue] = UIColor.clearColor().jsonValue
      preset.backgroundColors = backgroundColorsJSON

      self.reloadSection(self.sections[SectionKey.BackgroundColor.rawValue]!)
    }

    return row
  }

  /**
  generateBackgroundColorRowForState:

  :param: state UIControlState

  :returns: DetailRow
  */
  private func generateBackgroundColorRowForState(state: UIControlState) -> DetailRow {
    let row = ((model as! Preset).backgroundColors?.keys.array ?? []) ∋ state.stringValue
                ? generateBackgroundColorDisplayRowForState(state)
                : generateBackgroundColorCreationRowForState(state)
    return row
  }

  /** loadBackgroundColorSection */
  func loadBackgroundColorSection() {

    var backgroundColorSection = sections[SectionKey.BackgroundColor.rawValue] as? FilteringDetailSection
    backgroundColorSection?.removeAllRows(keepCapacity: true)

    if backgroundColorSection == nil {

      backgroundColorSection = FilteringDetailSection(section: 2, title: "Background Color", controller: self)
      backgroundColorSection!.singleRowDisplay = true
      backgroundColorSection!.predicates = [
        FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
          ($0.tag as! UIControlState) & .Highlighted != nil
        },
        active: self.backgroundColorState & .Highlighted != nil),
        FilteringDetailSection.Predicate(name: "Selected", includeRow: {
          ($0.tag as! UIControlState) & .Selected != nil
        },
        active: self.backgroundColorState & .Selected != nil),
        FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
          ($0.tag as! UIControlState) & .Disabled != nil
        },
        active: self.backgroundColorState & .Disabled != nil)
      ]
      backgroundColorSection!.activePredicatesDidChange = {
        var state = UIControlState.Normal
        for predicate in $0.predicates {
          switch predicate.name {
            case "Highlighted" where predicate.active: state |= .Highlighted
            case "Selected" where predicate.active:    state |= .Selected
            case "Disabled" where predicate.active:    state |= .Disabled
            default: break
          }
        }
        self.backgroundColorState = state
      }
      sections[SectionKey.BackgroundColor.rawValue] = backgroundColorSection!
    }

    apply(((0..<8).map{UIControlState(UInt($0))})) {
      state in backgroundColorSection!.addRow({ self.generateBackgroundColorRowForState(state) },
                                       forKey: SectionKey.BackgroundColor.rowKeyForState(state))
    }

  }

  /// MARK: - Titles
  ////////////////////////////////////////////////////////////////////////////////


  private var titleState: UIControlState = .Normal

  /**
  generateTitleDisplayRowForState:

  :param: state UIControlState

  :returns: DetailAttributedTextRow
  */
  private func generateTitleDisplayRowForState(state: UIControlState) -> DetailAttributedTextRow {
    let preset = model as! Preset
    
    let normalAttributes = TitleAttributes(preset.titles?["normal"]) ?? TitleAttributes()
    let stateAttributes = TitleAttributes(preset.titles?[state.stringValue]) ?? TitleAttributes()
    let mergedAttributes = stateAttributes.mergedWithTitleAttributes(normalAttributes)
    let row = DetailAttributedTextRow()
    row.tag = state
    row.info = mergedAttributes.string
    row.select = {
      let attributesDelegate = TitleAttributesDelegate(titleAttributes: mergedAttributes, observer: self)

      self.pushedTitleAttributesKey = state.stringValue

      let controller = TitleAttributesDetailController(item: attributesDelegate)
      controller.title = state.stringValue.titlecaseString
      self.pushController(controller)
    }
    row.delete = {
      if var titles = preset.titles {
        titles[state.stringValue] = nil
        preset.titles = titles
        if let indexPath = row.indexPath { self.reloadRowsAtIndexPaths([indexPath]) }
      }
    }
    return row
  }

  /**
  generateTitleCreationRowForState:

  :param: state UIControlState

  :returns: DetailListRow
  */
  private func generateTitleCreationRowForState(state: UIControlState) -> DetailListRow {
    let preset = model as! Preset
    let row = DetailListRow()
    row.infoDataType = .AttributedStringData
    row.tag = state

    var attributes = [
      NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
      NSForegroundColorAttributeName: DetailController.actionColor,
      NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
    ]

    let attributedString = NSAttributedString(string: UIFont.fontAwesomeIconForName("plus"), attributes: attributes).mutableCopy() as! NSMutableAttributedString
    attributes[NSFontAttributeName] = DetailController.actionFont
    attributedString.appendAttributedString(NSAttributedString(string: " Add Title", attributes: attributes))

    row.info = attributedString

    row.select = {
      var titles = preset.titles ?? ObjectJSONValue([:])
      titles[state.stringValue] = ObjectJSONValue([:]).jsonValue
      preset.titles = titles

      self.reloadSection(self.sections[SectionKey.Title.rawValue]!)
    }

    return row
  }

  /**
  generateTitleRowForState:

  :param: state UIControlState

  :returns: DetailRow
  */
  private func generateTitleRowForState(state: UIControlState) -> DetailRow {
    let row = ((model as! Preset).titles?.keys.array ?? []) ∋ state.stringValue
                ? generateTitleDisplayRowForState(state)
                : generateTitleCreationRowForState(state)
    return row
  }

  /** loadTitleSection */
  func loadTitleSection() {

    var titleSection = sections[SectionKey.Title.rawValue] as? FilteringDetailSection
    titleSection?.removeAllRows(keepCapacity: true)

    if titleSection == nil {

      titleSection = FilteringDetailSection(section: 3, title: "Title", controller: self)
      titleSection!.singleRowDisplay = true
      titleSection!.predicates = [
        FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
          ($0.tag as! UIControlState) & .Highlighted != nil
        },
        active: self.titleState & .Highlighted != nil),
        FilteringDetailSection.Predicate(name: "Selected", includeRow: {
          ($0.tag as! UIControlState) & .Selected != nil
        },
        active: self.titleState & .Selected != nil),
        FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
          ($0.tag as! UIControlState) & .Disabled != nil
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
      sections[SectionKey.Title.rawValue] = titleSection!
    }

    apply(((0..<8).map{UIControlState(UInt($0))})) {
      state in titleSection!.addRow({ self.generateTitleRowForState(state) },
                             forKey: SectionKey.Title.rowKeyForState(state))
    }

  }

  /// MARK: - Icons
  ////////////////////////////////////////////////////////////////////////////////


  private var iconState: UIControlState = .Normal

  /**
  generateIconDisplayRowForState:

  :param: state UIControlState

  :returns: DetailImageRow
  */
  private func generateIconDisplayRowForState(state: UIControlState) -> DetailImageRow {

    let preset = model as! Preset
    let json = preset.icons?[state.stringValue]
    var image: Image?
    if let path = String(json?["image"]), moc = preset.managedObjectContext {
      image = Image.objectWithIndex(ModelIndex(path), context: moc)
    }

    let row = DetailImageRow()
    row.tag = state
    row.info = image?.templateImage ?? DrawingKit.imageOfNoImage(frame: CGRect(size: CGSize(square: 32)))
    row.imageTint = UIColor(json?["color"])
    row.select = {
      if self.editing {
        MSLogDebug("now would be a great time to pop up some kind of icon selection interface")
      } else if image != nil {
        self.pushController(image!.detailController())
      }
    }
    row.delete = {
      var icons = preset.icons!
      icons[state.stringValue] = nil
      preset.icons = icons
      if let indexPath = row.indexPath { self.reloadRowsAtIndexPaths([indexPath]) }
    }
    return row
  }

  /**
  generateIconCreationRowForState:

  :param: state UIControlState

  :returns: DetailListRow
  */
  private func generateIconCreationRowForState(state: UIControlState) -> DetailListRow {
    let preset = model as! Preset
    let row = DetailListRow()
    row.tag = state
    row.infoDataType = .AttributedStringData

    var attributes = [
      NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
      NSForegroundColorAttributeName: DetailController.actionColor,
      NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
    ]

    let attributedString = NSAttributedString(string: UIFont.fontAwesomeIconForName("plus"), attributes: attributes).mutableCopy() as! NSMutableAttributedString
    attributes[NSFontAttributeName] = DetailController.actionFont
    attributedString.appendAttributedString(NSAttributedString(string: " Add Icon", attributes: attributes))

    row.info = attributedString

    row.select = {
      var icons = preset.icons ?? ObjectJSONValue([:])
      icons[state.stringValue] = ObjectJSONValue([:]).jsonValue
      preset.icons = icons

      self.reloadSection(self.sections[SectionKey.Icon.rawValue]!)
    }

    return row
  }

  /**
  generateIconRowForState:

  :param: state UIControlState

  :returns: DetailRow
  */
  private func generateIconRowForState(state: UIControlState) -> DetailRow {
    let row = ((model as! Preset).icons?.keys.array ?? []) ∋ state.stringValue
                ? generateIconDisplayRowForState(state)
                : generateIconCreationRowForState(state)
    return row
  }

  /** loadIconSection */
  func loadIconSection() {

    var iconSection = sections[SectionKey.Icon.rawValue] as? FilteringDetailSection
    iconSection?.removeAllRows(keepCapacity: true)

    if iconSection == nil {

      iconSection = FilteringDetailSection(section: 4, title: "Icon", controller: self)
      iconSection!.singleRowDisplay = true
      iconSection!.predicates = [
        FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
          ($0.tag as! UIControlState) & .Highlighted != nil
        },
        active: self.iconState & .Highlighted != nil),
        FilteringDetailSection.Predicate(name: "Selected", includeRow: {
          ($0.tag as! UIControlState) & .Selected != nil
        },
        active: self.iconState & .Selected != nil),
        FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
          ($0.tag as! UIControlState) & .Disabled != nil
        },
        active: self.iconState & .Disabled != nil)
      ]
      iconSection!.activePredicatesDidChange = {
        var state = UIControlState.Normal
        for predicate in $0.predicates {
          switch predicate.name {
            case "Highlighted" where predicate.active: state |= .Highlighted
            case "Selected" where predicate.active:    state |= .Selected
            case "Disabled" where predicate.active:    state |= .Disabled
            default: break
          }
        }
        self.iconState = state
      }
      sections[SectionKey.Icon.rawValue] = iconSection!
    }

    apply(((0..<8).map{UIControlState(UInt($0))})) {
      state in iconSection!.addRow({ self.generateIconRowForState(state) },
                            forKey: SectionKey.Icon.rowKeyForState(state))
    }

  }

  /// MARK: - Images
  ////////////////////////////////////////////////////////////////////////////////

  private var imageState: UIControlState = .Normal

  /**
  generateImageDisplayRowForState:

  :param: state UIControlState

  :returns: DetailImageRow
  */
  private func generateImageDisplayRowForState(state: UIControlState) -> DetailImageRow {
    let preset = model as! Preset
    let json = preset.images?[state.stringValue]
    var image: Image?
    if let path = String(json?["image"]), moc = preset.managedObjectContext {
      image = Image.modelWithIndex(PathIndex(path), context: moc)
    }

    let row = DetailImageRow()
    row.tag = state
    row.info = image?.templateImage ?? DrawingKit.imageOfNoImage(frame: CGRect(size: CGSize(square: 32)))
    row.imageTint = UIColor(json?["color"])
    row.select = {
      if self.editing {
        MSLogDebug("now would be a great time to pop up some kind of image selection interface")
      } else if image != nil {
        self.pushController(image!.detailController())
      }
    }
    row.delete = {
      var images = preset.images!
      images[state.stringValue] = nil
      preset.images = images
      if let indexPath = row.indexPath { self.reloadRowsAtIndexPaths([indexPath]) }
    }
    return row
  }

  /**
  generateImageCreationRowForState:

  :param: state UIControlState

  :returns: DetailListRow
  */
  private func generateImageCreationRowForState(state: UIControlState) -> DetailListRow {
    let preset = model as! Preset
    let row = DetailListRow()
    row.tag = state
    row.infoDataType = .AttributedStringData

    var attributes = [
      NSFontAttributeName: UIFont(awesomeFontWithSize: 15),
      NSForegroundColorAttributeName: DetailController.actionColor,
      NSParagraphStyleAttributeName: NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
    ]

    let attributedString = NSAttributedString(string: UIFont.fontAwesomeIconForName("plus"), attributes: attributes).mutableCopy() as! NSMutableAttributedString
    attributes[NSFontAttributeName] = DetailController.actionFont
    attributedString.appendAttributedString(NSAttributedString(string: " Add Image", attributes: attributes))

    row.info = attributedString

    row.select = {
      var images = preset.images ?? ObjectJSONValue([:])
      images[state.stringValue] = ObjectJSONValue([:]).jsonValue
      preset.images = images

      self.reloadSection(self.sections[SectionKey.Image.rawValue]!)
    }

    return row
  }

  /**
  generateImageRowForState:

  :param: state UIControlState

  :returns: DetailRow
  */
  private func generateImageRowForState(state: UIControlState) -> DetailRow {
    let row = ((model as! Preset).images?.keys.array ?? []) ∋ state.stringValue
                ? generateImageDisplayRowForState(state)
                : generateImageCreationRowForState(state)
    return row
  }

  /** loadImageSection */
  func loadImageSection() {

    var imageSection = sections[SectionKey.Image.rawValue] as? FilteringDetailSection
    imageSection?.removeAllRows(keepCapacity: true)

    if imageSection == nil {

      imageSection = FilteringDetailSection(section: 5, title: "Image", controller: self)
      imageSection!.singleRowDisplay = true
      imageSection!.predicates = [
        FilteringDetailSection.Predicate(name: "Highlighted", includeRow: {
          ($0.tag as! UIControlState) & .Highlighted != nil
        },
        active: self.imageState & .Highlighted != nil),
        FilteringDetailSection.Predicate(name: "Selected", includeRow: {
          ($0.tag as! UIControlState) & .Selected != nil
        },
        active: self.imageState & .Selected != nil),
        FilteringDetailSection.Predicate(name: "Disabled", includeRow: {
          ($0.tag as! UIControlState) & .Disabled != nil
        },
        active: self.imageState & .Disabled != nil)
      ]
      imageSection!.activePredicatesDidChange = {
        var state = UIControlState.Normal
        for predicate in $0.predicates {
          switch predicate.name {
            case "Highlighted" where predicate.active: state |= .Highlighted
            case "Selected" where predicate.active:    state |= .Selected
            case "Disabled" where predicate.active:    state |= .Disabled
            default: break
          }
        }
        self.imageState = state
      }
      sections[SectionKey.Image.rawValue] = imageSection!
    }

    apply(((0..<8).map{UIControlState(UInt($0))})) {
      state in imageSection!.addRow({ self.generateImageRowForState(state) },
                             forKey: SectionKey.Image.rowKeyForState(state))
    }

  }

}

extension ButtonPresetDetailController: TitleAttributesDelegateObserver {

  /**
  saveInvokedForTitleAttributesDelegate:

  :param: titleAttributesDelegate TitleAttributesDelegate
  */
  func saveInvokedForTitleAttributesDelegate(titleAttributesDelegate: TitleAttributesDelegate) {
    assert(pushedTitleAttributesKey != nil)
    let preset = model as! Preset
    if var titles = preset.titles {
      titles[pushedTitleAttributesKey!] = titleAttributesDelegate.titleAttributes.jsonValue
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
    let preset = model as! Preset
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
