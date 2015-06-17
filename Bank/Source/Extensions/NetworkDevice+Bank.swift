//
//  NetworkDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/21/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel
import CoreData
import Networking

private var discoveryCallbackToken: ConnectionManager.DiscoveryCallbackToken?

extension NetworkDevice: DiscoverCreatable {

  /** beginDiscovery */
  static func beginDiscovery(context context: NSManagedObjectContext, presentForm: (Form, ProcessedForm) -> Void) -> Bool {
    if !ConnectionManager.wifiAvailable || discoveryCallbackToken != nil { return false }
    else {
      let discoveryCallback: ConnectionManager.DiscoveryCallback = {
        (networkDevice: NetworkDevice) -> Void in
        if discoveryCallbackToken != nil {
          self.endDiscovery()
          dispatchToMain {
            presentForm(networkDevice.discoveryConfirmationForm()) {
              form in
              if let name = form.values?["Name"] as? String { networkDevice.name = name }
              let (success, error) = DataManager.saveContext(context)
              MSHandleError(error)
              return success
            }
          }
        }
      }
      discoveryCallbackToken = ConnectionManager.startDetectingNetworkDevices(context: context, discovery: discoveryCallback)
      return true
    }
  }

  /** endDiscovery */
  static func endDiscovery() {
    MSLogDebug("discoveryCallbackToken = \(toString(discoveryCallbackToken))")
    if discoveryCallbackToken != nil {
      ConnectionManager.stopDetectingNetworkDevices(discoveryCallbackToken: discoveryCallbackToken!)
      discoveryCallbackToken = nil
    }
  }
}

extension NetworkDevice {

  /**
  discoveryConfirmationFormFields

  - returns: Form
  */
  func discoveryConfirmationForm() -> Form {
    var fields: OrderedDictionary<String, FieldTemplate> = [:]
    if let moc = managedObjectContext {
      let validation = self.dynamicType.nameFormFieldTemplate(context: moc).values["validation"] as? (String?) -> Bool
      fields["Name"] = .Text(value: "", placeholder: uniqueIdentifier, validation: validation, editable: true)
      fields["UUID"] = .Text(value: uniqueIdentifier, placeholder: nil, validation: nil, editable: false)

      switch self {
        case let d as ITachDevice:
          fields["Configuration URL"] = .Text(value: d.configURL, placeholder: nil, validation: nil, editable: false)
          fields["Make"]              = .Text(value: d.make,      placeholder: nil, validation: nil, editable: false)
          fields["Model"]             = .Text(value: d.model,     placeholder: nil, validation: nil, editable: false)
          fields["PCB PN"]            = .Text(value: d.pcbPN,     placeholder: nil, validation: nil, editable: false)
          fields["Package Level"]     = .Text(value: d.pkgLevel,  placeholder: nil, validation: nil, editable: false)
          fields["Revision"]          = .Text(value: d.revision,  placeholder: nil, validation: nil, editable: false)
          fields["SDK Class"]         = .Text(value: d.sdkClass,  placeholder: nil, validation: nil, editable: false)
          fields["Status"]            = .Text(value: d.status,    placeholder: nil, validation: nil, editable: false)
        case let d as ISYDevice:
          fields["Base URL"]          = .Text(value: d.baseURL,          placeholder: nil, validation: nil, editable: false)
          fields["Model Number"]      = .Text(value: d.modelNumber,      placeholder: nil, validation: nil, editable: false)
          fields["Model Name"]        = .Text(value: d.modelName,        placeholder: nil, validation: nil, editable: false)
          fields["Model Description"] = .Text(value: d.modelDescription, placeholder: nil, validation: nil, editable: false)
          fields["Manufacturer URL"]  = .Text(value: d.manufacturerURL,  placeholder: nil, validation: nil, editable: false)
          fields["Manufacturer"]      = .Text(value: d.manufacturer,     placeholder: nil, validation: nil, editable: false)
          fields["Friendly Name"]     = .Text(value: d.friendlyName,     placeholder: nil, validation: nil, editable: false)
          fields["Device Type"]       = .Text(value: d.deviceType,       placeholder: nil, validation: nil, editable: false)

        default:
          fatalError("apocalypse hath arriven, I love the smell of napalm in the morning")
      }
    }

    return Form(templates: fields)
  }

}