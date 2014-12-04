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

class ImageDetailController: BankItemDetailController {

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is Image, "we should have been given a image")

    let image = model as Image

    let detailsSection = DetailSection(section: 0)

    detailsSection.addRow { DetailLabelRow(pushableCategory: image.imageCategory, label: "Category") }
    detailsSection.addRow { DetailLabelRow(label: "Asset", value: image.assetName) }
    detailsSection.addRow { DetailLabelRow(label: "Size", value: PrettySize(image.size)) }

    let previewSection = DetailSection(section: 1)
    previewSection.addRow { DetailImageRow(previewableItem: image) }

    sections = [detailsSection, previewSection]

  }

}
