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

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is Image, "we should have been given a image")

    let detailsSection = BankItemDetailSection(sectionNumber: 0, createRows: {

      let categoryRow = BankItemDetailRow(pushableCategory: self.image.imageCategory, label: "Category")
      let fileRow = BankItemDetailRow(label: "Asset", value: self.image.assetName)
      let sizeRow = BankItemDetailRow(label: "Size", value: PrettySize(self.image.size))

      return [categoryRow, fileRow, sizeRow]

    })

    let previewSection = BankItemDetailSection(sectionNumber: 1, createRows: {
      return [BankItemDetailRow(previewableItem: self.image)]
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
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
