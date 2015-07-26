//
//  ISYDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import CoreData
import DataModel

extension ISYDevice: DelegateDetailable {
    func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {
      var sections: BankModelDetailDelegate.SectionIndex = [:]

      struct SectionKey {
        static let ID               = "ID"
        static let Model            = "Model"
        static let Manufacturer     = "Manufacturer"
        static let Nodes            = "Nodes"
        static let Groups           = "Groups"
        static let ComponentDevices = "ComponentDevices"
      }

      struct RowKey {
        static let Identifier       = "Identifier"
        static let BaseURL          = "Base URL"
        static let Model            = "Model"
        static let ModelName        = "Model Name"
        static let Number           = "Number"
        static let Description      = "Description"
        static let FriendlyName     = "Friendly Name"
        static let Manufacturer     = "Manufacturer"
        static let ManufacturerName = "Manufacturer Name"
        static let URL              = "URL"
        static let Nodes            = "Nodes"
        static let Groups           = "Groups"
        static let ComponentDevices = "Component Devices"
      }

      /** loadIDSection */
      func loadIDSection() {

        let iSYDevice = self

        /// Identification section: Identifier, Base URL
        ////////////////////////////////////////////////////////////////////////////////

        let idSection = BankCollectionDetailSection(section: 0)
        idSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Identifier"
          row.info = iSYDevice.uniqueIdentifier
          return row
        }, forKey: RowKey.Identifier)
        idSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Base URL"
          row.info = iSYDevice.baseURL
          return row
        }, forKey: RowKey.BaseURL)

        sections[SectionKey.ID] = idSection
      }

      /** loadModelSection */
      func loadModelSection() {

        let iSYDevice = self

        /// Model section: Name, Number, Description, Friendly Name
        ////////////////////////////////////////////////////////////////////////////////

        let modelSection = BankCollectionDetailSection(section: 1, title: "Model")
        modelSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Name"
          row.info = iSYDevice.modelName
          return row
        }, forKey: RowKey.ModelName)
        modelSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Number"
          row.info = iSYDevice.modelNumber
          return row
        }, forKey: RowKey.Number)
        modelSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Description"
          row.info = iSYDevice.modelDescription
          return row
        }, forKey: RowKey.Description)
        modelSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Friendly Name"
          row.info = iSYDevice.friendlyName
          return row
        }, forKey: RowKey.FriendlyName)

        sections[SectionKey.Model] = modelSection
      }

      /** loadManufacturerSection */
      func loadManufacturerSection() {

        let iSYDevice = self

        /// Manufacturer section: Name, URL
        ////////////////////////////////////////////////////////////////////////////////

        let manufacturerSection = BankCollectionDetailSection(section: 2, title: "Manufacturer")
        manufacturerSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "Name"
          row.info = iSYDevice.manufacturer
          return row
        }, forKey: RowKey.ManufacturerName)
        manufacturerSection.addRow({
          let row = BankCollectionDetailLabelRow()
          row.name = "URL"
          row.info = iSYDevice.manufacturerURL
          return row
        }, forKey: RowKey.URL)

        sections[SectionKey.Manufacturer] = manufacturerSection
      }

      /** loadNodesSection */
      func loadNodesSection() {

        let iSYDevice = self

        /// Nodes section
        ////////////////////////////////////////////////////////////////////////////////

        let nodesSection = BankCollectionDetailSection(section: 3, title: "Nodes")
        for (idx, node) in iSYDevice.nodes.sortByName().enumerate() {
          nodesSection.addRow({
            let row = BankCollectionDetailListRow()
            row.info = node
            return row
            }, forKey: "\(RowKey.Nodes)\(idx)")
        }

        sections[SectionKey.Nodes] = nodesSection
      }

      /** loadGroupsSection */
      func loadGroupsSection() {

        let iSYDevice = self

        /// Groups section
        ////////////////////////////////////////////////////////////////////////////////

        let groupsSection = BankCollectionDetailSection(section: 4, title: "Groups")
        for (idx, group) in iSYDevice.groups.sortByName().enumerate() {
          groupsSection.addRow({
            let row = BankCollectionDetailListRow()
            row.info = group
            return row
            }, forKey: "\(RowKey.Groups)\(idx)")
        }

        sections[SectionKey.Groups] = groupsSection
      }

      /** loadComponentDevicesSection */
      func loadComponentDevicesSection() {

        let iSYDevice = self

        /// Component Devices section
        ////////////////////////////////////////////////////////////////////////////////

        let componentDevicesSection = BankCollectionDetailSection(section: 5, title: "Component Devices")
        for (idx, device) in iSYDevice.componentDevices.sortByName().enumerate() {
          componentDevicesSection.addRow({
            let row = BankCollectionDetailListRow()
            row.info = device
            row.select = BankCollectionDetailRow.selectPushableItem(device)
            return row
            }, forKey: "\(RowKey.ComponentDevices)\(idx)")
        }

        sections[SectionKey.ComponentDevices] = componentDevicesSection
        }

      loadIDSection()
      loadModelSection()
      loadManufacturerSection()
      loadNodesSection()
      loadGroupsSection()
      loadComponentDevicesSection()

      return sections
    }
}