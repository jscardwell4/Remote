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
import DataModel

class ImageDetailController: BankItemDetailController {

  private struct SectionKey {
    static let Details = "Details"
    static let Preview = "Preview"
  }

  private struct RowKey {
    static let Category = "Category"
    static let Asset    = "Asset"
    static let Size     = "Size"
    static let Preview  = "Preview"
  }

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is Image, "we should have been given a image")

    loadDetailsSection()
    loadPreviewSection()

  }

  /** loadDetailsSection */
  private func loadDetailsSection() {

    let image = model as! Image

    let detailsSection = DetailSection(section: 0)

    detailsSection.addRow({
      let row = DetailLabelRow()
      row.name = "Category"
      row.info = image.imageCategory
      row.select = DetailRow.selectPushableCollection(image.imageCategory)
      return row
      }, forKey: RowKey.Category)

    detailsSection.addRow({
      let row = DetailLabelRow()
      row.name = "Asset"
      row.info = image.asset?.name
      return row
      }, forKey: RowKey.Asset)

    detailsSection.addRow({
      let row = DetailLabelRow()
      row.name = "Size"
      row.info = PrettySize(image.size)
      return row
      }, forKey: RowKey.Size)

    sections[SectionKey.Details] = detailsSection
  }

  /** loadPreviewSection */
  private func loadPreviewSection() {

    let image = model as! Image

    let previewSection = DetailSection(section: 1)
    previewSection.addRow({
      let row = DetailImageRow()
      row.info = image
      return row
      }, forKey: RowKey.Preview)

    sections[SectionKey.Preview] = previewSection

  }

}
