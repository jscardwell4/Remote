//
//  ITachDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import CoreData
import DataModel

extension ITachDevice: DelegateDetailable {
    func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {
      var sections: BankModelDetailDelegate.SectionIndex = [:]

      struct SectionKey {
        static let Details = "Details"
        static let ComponentDevices = "ComponentDevices"
      }

      struct RowKey {
        static let Identifier       = "Identifier"
        static let Make             = "Make"
        static let Model            = "Model"
        static let ConfigURL        = "Config-URL"
        static let Revision         = "Revision"
        static let Pcb_PN           = "Pcb_PN"
        static let Pkg_Level        = "Pkg_Level"
        static let SDKClass         = "SDKClass"
        static let ComponentDevices = "ComponentDevices"
      }

      /** loadDetailsSection */
      func loadDetailsSection() {

        /// Main section: Identifier, Make, Model, Config-URL, Revision, Pcb_PN, Pkg_Level, SDKClass
        ////////////////////////////////////////////////////////////////////////////////////////////

        let iTachDevice = self

        let mainSection = BankCollectionDetailSection(section: 0)

        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Identifier"
          row.info = iTachDevice.uniqueIdentifier
          return row
          }, forKey: RowKey.Identifier)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Make"
          row.info = iTachDevice.make
          return row
          }, forKey: RowKey.Make)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Model"
          row.info = iTachDevice.model
          return row
          }, forKey: RowKey.Model)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Config-URL"
          row.info = iTachDevice.configURL
          return row
          }, forKey: RowKey.ConfigURL)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Revision"
          row.info = iTachDevice.revision
          return row
          }, forKey: RowKey.Revision)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Pcb_PN"
          row.info = iTachDevice.pcbPN
          return row
          }, forKey: RowKey.Pcb_PN)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Pkg_Level"
          row.info = iTachDevice.pkgLevel
          return row
          }, forKey: RowKey.Pkg_Level)
        mainSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "SDKClass"
          row.info = iTachDevice.sdkClass
          return row
          }, forKey: RowKey.SDKClass)

        sections[SectionKey.Details] = mainSection

      }

      /** loadComponentDevicesSection */
      func loadComponentDevicesSection() {

        let iTachDevice = self

        /// Component Devices section
        ////////////////////////////////////////////////////////////////////////////////

        let componentDevicesSection = BankCollectionDetailSection(section: 1, title: "Component Devices")
        for (idx, device) in iTachDevice.componentDevices.sortByName().enumerate() {
          componentDevicesSection.addRow({
           let row = BankCollectionDetailListRow()
           row.info = device
           row.select = BankCollectionDetailRow.selectPushableItem(device)
           return row
           }, forKey: "\(RowKey.ComponentDevices)\(idx)")
        }

        sections[SectionKey.ComponentDevices] = componentDevicesSection
      }

      loadDetailsSection()
      loadComponentDevicesSection()

      return sections
    }
}