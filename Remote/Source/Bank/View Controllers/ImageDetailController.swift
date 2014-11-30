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

  var image: Image { return model as Image }

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    precondition(model is Image, "we should have been given a image")

    let detailsSection = DetailSection(sectionNumber: 0)

    detailsSection.addRow { return DetailLabelRow(pushableCategory: self.image.imageCategory, label: "Category") }
    detailsSection.addRow { return DetailLabelRow(label: "Asset", value: self.image.assetName) }
    detailsSection.addRow { return DetailLabelRow(label: "Size", value: PrettySize(self.image.size)) }

    let previewSection = DetailSection(sectionNumber: 1)
    previewSection.addRow { return DetailImageRow(previewableItem: self.image) }

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
