//
//  ImageDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

@objc(ImageDetailController)
class ImageDetailController: BankItemDetailController {

  var image: Image { return item as Image }

  lazy var categories: [String] = []/*
{ [unowned self] in
    var categories: [String] = []
    if let fetchedCategories = Image.allValuesForAttribute("category") as? [String] { categories += fetchedCategories }
    return categories
    }()
*/

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is Image, "we should have been given a image")

    let detailsSection = BankItemDetailSection(sectionNumber: 0, createRows: {

      let categoryRow = BankItemDetailRow(identifier: .TextField, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Category"
          cell.info = self.image.imageCategory
          cell.pickerNilSelectionTitle = "Uncategorized"
          cell.pickerData = self.categories
      })

      let fileRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Asset"
          cell.info = self.image.assetName
      })

      let sizeRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Size"
          cell.info = PrettySize(self.image.size)
      })

      return [categoryRow, fileRow, sizeRow]

    })

    let previewSection = BankItemDetailSection(sectionNumber: 1, createRows: {
      let previewRow = BankItemDetailRow(identifier: .Image, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.info = self.image.preview
      })

      return [previewRow]
    })

    sections = [detailsSection, previewSection]

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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
