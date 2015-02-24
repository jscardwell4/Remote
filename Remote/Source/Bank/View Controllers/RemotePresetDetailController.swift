//
//  RemotePresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemotePresetDetailController: PresetDetailController {

  private struct SectionKey {
    static let RemoteAttributes = "Remote Attributes"
  }

  private struct RowKey {
    static let TopBarHidden = "Top Bar Hidden"
  }

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    loadRemoteAttributesSection()

  }

 /** loadRemoteAttributesSection */
 private func loadRemoteAttributesSection() {

   let preset = model as Preset

   let remoteAttributesSection = DetailSection(section: 2, title: "Remote Attributes")

   remoteAttributesSection.addRow({
    var row = DetailSwitchRow()
    row.name = "Top Bar Hidden"
    row.info = NSNumber(bool: preset.topBarHidden ?? false)
    row.valueDidChange = { preset.topBarHidden = ($0 as? NSNumber)?.boolValue }

    return row
   }, forKey: RowKey.TopBarHidden)

   sections[SectionKey.RemoteAttributes] = remoteAttributesSection
 }


}
