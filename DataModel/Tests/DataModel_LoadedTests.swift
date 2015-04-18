//
//  DataModel_LoadedTests.swift
//  DataModelTests
//
//  Created by Jason Cardwell on 4/15/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import DataModel
import MoonKit
import Quick
import Nimble

// TODO: Convert to use test bundle resource files from 'Loaded' group
class DataModel_LoadedTests: QuickSpec {

  static let context = DataManager.isolatedContext()

  override func spec() {
    beforeSuite {
      LogManager.logLevel = .Error
      if let bundlePath = NSUserDefaults.standardUserDefaults().stringForKey("XCTestedBundlePath"),
        let bundle = NSBundle(path: bundlePath)
      {
        let loadInfo: [(String,ModelObject.Type)] =  [("Manufacturer",       Manufacturer.self),
                                                      ("ComponentDevice",    ComponentDevice.self),
                                                      ("ImageCategory",      ImageCategory.self),
                                                      ("Activity",           Activity.self),
                                                      ("NetworkDevice",      NetworkDevice.self),
                                                      ("ActivityController", ActivityController.self),
                                                      ("Preset",             Preset.self),
                                                      ("Remote",             Remote.self)]
        for (file, type) in loadInfo {
          if let filePath = bundle.pathForResource(file, ofType: "json") {
            DataManager.loadJSONFileAtPath(filePath, forModel: type, context: self.dynamicType.context)
          } else {
            MSLogError("unable to locate file for name '\(file)'")
          }
        }
      } else { MSLogError("unable to locate test bundle") }
    }

    describe("the manufacturers") {
      describe("the Dish manufacturer") {
        var pending = false
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Dish"), context: self.dynamicType.context)
          expect(manufacturer).toNot(beNil())
          pending = manufacturer == nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'Dish'", flags: [Filter.pending: pending]) {
          expect(manufacturer?.codeSets.count).to(equal(1))
          codeSet = manufacturer?.codeSets.first
          expect(codeSet).toNot(beNil())
          pending = codeSet == nil
        }
        describe("the code set", flags: [Filter.pending: pending]) {
          it("has the expected values") {
            expect(codeSet?.name).to(equal("Dish"))
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count).to(equal(47))
          }
          var code: IRCode?
          it("has a code named 'Favorites'", flags: [Filter.pending: pending]) {
            code = IRCode.objectWithIndex(ModelIndex("Dish/Dish/Favorites"), context: self.dynamicType.context)
            expect(code).toNot(beNil())
            pending = code == nil
          }
          describe("the code", flags: [Filter.pending: pending]) {
            it("has the expected values") {
              expect(code?.name).to(equal("Favorites"))
              expect(code?.frequency).to(equal(38343))
              expect(code?.onOffPattern).to(equal("344,173,19,172,19,86BCBCCCCCCCCBCB19,1183,345,86,19,3834"))
            }
          }
        }
      }
      describe("the Sony manufacturer") {
        var pending = false
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Sony"), context: self.dynamicType.context)
          expect(manufacturer).toNot(beNil())
          pending = manufacturer == nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'AV Receiver''", flags: [Filter.pending: pending]) {
          expect(manufacturer?.codeSets.count).to(equal(1))
          codeSet = manufacturer?.codeSets.first
          expect(codeSet).toNot(beNil())
          pending = codeSet == nil
        }
        describe("the code set", flags: [Filter.pending: pending]) {
          it("has the expected values") {
            expect(codeSet?.name).to(equal("AV Receiver"))
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count).to(equal(14))
          }
          var code: IRCode?
          it("has a code named 'Volume Up'", flags: [Filter.pending: pending]) {
            code = IRCode.objectWithIndex(ModelIndex("Sony/AV%20Receiver/Volume%20Up"), context: self.dynamicType.context)
            expect(code).toNot(beNil())
            pending = code == nil
          }
          describe("the code", flags: [Filter.pending: pending]) {
            it("has the expected values") {
              expect(code?.name).to(equal("Volume Up"))
              expect(code?.frequency).to(equal(40192))
              expect(code?.offset).to(equal(5))
              expect(code?.onOffPattern).to(equal("96,24,24,24,48,24BBCBBBBBBCCB24,888ABCBBCBBBBBBCCBDABCBBCBBBBBBCCB24,4019"))
            }
          }
        }
      }
      describe("the Samsung manufacturer") {
        var pending = false
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Samsung"), context: self.dynamicType.context)
          expect(manufacturer).toNot(beNil())
          pending = manufacturer == nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'Samsung TV'", flags: [Filter.pending: pending]) {
          expect(manufacturer?.codeSets.count).to(equal(1))
          codeSet = manufacturer?.codeSets.first
          expect(codeSet).toNot(beNil())
          pending = codeSet == nil
        }
        describe("the code set", flags: [Filter.pending: pending]) {
          it("has the expected values") {
            expect(codeSet?.name).to(equal("Samsung TV"))
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count).to(equal(54))
          }
          var code: IRCode?
          it("has a code named 'Mute'", flags: [Filter.pending: pending]) {
            code = IRCode.objectWithIndex(ModelIndex("Samsung/Samsung%20TV/Mute"), context: self.dynamicType.context)
            expect(code).toNot(beNil())
            pending = code == nil
          }
          describe("the code", flags: [Filter.pending: pending]) {
            it("has the expected values") {
              expect(code?.name).to(equal("Mute"))
              expect(code?.frequency).to(equal(38109))
              expect(code?.onOffPattern).to(equal("171,171,21,64BB21,21CCCCBBBCCCCCBBBBCCCCCCCCBBBB21,1776ABBBCCCCCBBBCCCCCBBBBCCCCCC21,22CBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBB21,4878"))
            }
          }
        }
      }
    }

    describe("the component devices") {
      describe("the Dish Hopper device") {
        var pending = false
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("Dish%20Hopper"), context: self.dynamicType.context)
          expect(componentDevice).toNot(beNil())
          pending = componentDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(componentDevice?.name).to(equal("Dish Hopper"))
          expect(componentDevice?.codeSet?.name).to(equal("Dish"))
          expect(componentDevice?.manufacturer.name).to(equal("Dish"))
          expect(componentDevice?.alwaysOn).to(beTrue())
        }
      }
      describe("the PS3 device") {
        var pending = false
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("PS3"), context: self.dynamicType.context)
          expect(componentDevice).toNot(beNil())
          pending = componentDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(componentDevice?.name).to(equal("PS3"))
          expect(componentDevice?.codeSet?.name).to(beNil())
          expect(componentDevice?.manufacturer.name).to(equal("Sony"))
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
      describe("the Samsung TV device") {
        var pending = false
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("Samsung%20TV"), context: self.dynamicType.context)
          expect(componentDevice).toNot(beNil())
          pending = componentDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(componentDevice?.name).to(equal("Samsung TV"))
          expect(componentDevice?.codeSet?.name).to(equal("Samsung TV"))
          expect(componentDevice?.manufacturer.name).to(equal("Samsung"))
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
      describe("the AV Receiver device") {
        var pending = false
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("AV%20Receiver"), context: self.dynamicType.context)
          expect(componentDevice).toNot(beNil())
          pending = componentDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(componentDevice?.name).to(equal("AV Receiver"))
          expect(componentDevice?.codeSet?.name).to(equal("AV Receiver"))
          expect(componentDevice?.manufacturer.name).to(equal("Sony"))
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
    }

    describe("the image categories") {
      var pending = false
      var imageCategory: ImageCategory?
      describe("the Backgrounds category") {
        it("can be retrieved by index") {
          imageCategory = ImageCategory.objectWithIndex(ModelIndex("Backgrounds"), context: self.dynamicType.context)
          expect(imageCategory).toNot(beNil())
          pending = imageCategory == nil
        }
        var image: Image?
        it("has an image", flags: [Filter.pending: pending]) {
          expect(imageCategory?.images.count).to(equal(1))
          image = imageCategory?.images.first
          pending = image == nil
        }
        describe("the image", flags: [Filter.pending: pending]) {
          it("is named and indexed") {
            expect(image?.name).to(equal("Pro Dots"))
            expect(image?.index.rawValue).to(equal("Backgrounds/Pro%20Dots"))
          }
          var asset: Asset?
          it("has an asset") {
            expect(image?.asset).toNot(beNil())
            asset = image?.asset
            pending = asset == nil
          }
          describe("the asset", flags: [Filter.pending: pending]) {
            it("has a name but no location") {
              expect(asset?.name).to(equal("Pro Dots"))
              expect(asset?.location).to(beNil())
            }
          }
        }
      }
      pending = false
      describe("the Icons category") {
        it("can be retrieved by index") {
          imageCategory = ImageCategory.objectWithIndex(ModelIndex("Icons"), context: self.dynamicType.context)
          expect(imageCategory).toNot(beNil())
          pending = imageCategory == nil
        }
        it("has no images", flags: [Filter.pending: pending]) {
          expect(imageCategory?.images.count).to(equal(0))
        }
        it("has child categories", flags: [Filter.pending: pending]) {
          let names = map(imageCategory!.childCategories, {$0.name})
          expect(names).to(contain("Glyphish 3", "Glyphish 4", "Glyphish 6", "Glyphish 7"))
        }

        it("has nested images retrievable by index", flags: [Filter.pending: pending]) {
          let moc = self.dynamicType.context
          expect(ImageCategory.objectWithIndex(ModelIndex("Icons/Glyphish%207/Large/Normal/Battery"), context: moc)).to(beNil())
          expect(ImageCategory.objectWithIndex(ModelIndex("Icons/Glyphish%206/Large/Normal/Pencil"), context: moc)) .to(beNil())
          expect(ImageCategory.objectWithIndex(ModelIndex("Icons/Glyphish%206/Large/Normal/Arrow%20Down"), context: moc)).to(beNil())
          expect(ImageCategory.objectWithIndex(ModelIndex("Icons/Glyphish%204/Power%20Plug"), context: moc)).to(beNil())
          expect(ImageCategory.objectWithIndex(ModelIndex("Icons/Glyphish%203/Outlet"), context: moc)).to(beNil())
        }

      }

    }

    describe("the activities") {
      var pending = false
      var activity: Activity?
      describe("the hopper activity") {
        it("can be retrieved by index") {
          activity = Activity.objectWithIndex(ModelIndex("Dish%20Hopper%20Activity"), context: self.dynamicType.context)
          expect(activity).toNot(beNil())
          pending = activity == nil
        }
        var launchMacro: MacroCommand?
        it("has a launch macro", flags: [Filter.pending: pending]) {
          launchMacro = activity?.launchMacro
          expect(launchMacro).toNot(beNil())
          pending = launchMacro == nil
        }
        describe("the macro", flags: [Filter.pending: pending]) {
          it("has sendir, power, delay, sendir commands") {
            expect(launchMacro?.commands.count).to(equal(4))
          }
        }
      }
    }

    describe("the network devices") {
      it("total of two") {
        var pending = false
        let devices = NetworkDevice.objectsInContext(self.dynamicType.context) as! [NetworkDevice]
        expect(devices.count).to(equal(2))
        pending = devices.count != 2
        describe("the devices are properly modeled", flags: [Filter.pending: pending]) {
          let (device1, device2) = disperse2(devices)
          let device1AsItach = device1 as? ITachDevice, device2AsItach = device2 as? ITachDevice
          expect(device1AsItach == nil && device2AsItach == nil).toNot(beTrue())
          let device1AsISY = device1 as? ISYDevice, device2AsISY = device2 as? ISYDevice
          expect(device1AsISY == nil && device2AsISY == nil).toNot(beTrue())
        }

      }
      describe("the iTach device"){
        var pending = false
        var iTachDevice: ITachDevice?
        it("can be retrieved by index") {
          iTachDevice = ITachDevice.objectWithIndex(ModelIndex("GlobalCache-iTachIP2IR"), context: self.dynamicType.context)
          expect(iTachDevice).toNot(beNil())
          pending = iTachDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(iTachDevice?.uuid).to(equal("A7582E04-16F3-4319-9F21-41A17C922AC9"))
          expect(iTachDevice?.name).to(equal("GlobalCache-iTachIP2IR"))
          expect(iTachDevice?.uniqueIdentifier).to(equal("GlobalCache_000C1E022AED"))
          expect(iTachDevice?.pcbPN).to(equal("025-0028-03"))
          expect(iTachDevice?.pkgLevel).to(equal("GCPK002"))
          expect(iTachDevice?.sdkClass).to(equal("Utility"))
          expect(iTachDevice?.make).to(equal("GlobalCache"))
          expect(iTachDevice?.model).to(equal("iTachIP2IR"))
          expect(iTachDevice?.status).to(equal("Ready"))
          expect(iTachDevice?.configURL).to(equal("192.168.1.45"))
          expect(iTachDevice?.revision).to(equal("710-1005-05"))
        }
      }
      describe("the isy device"){
        var pending = false
        var isyDevice: ISYDevice?
        it("can be retrieved by index") {
          isyDevice = ISYDevice.objectWithIndex(ModelIndex("ISYDevice1"), context: self.dynamicType.context)
          expect(isyDevice).toNot(beNil())
          pending = isyDevice == nil
        }
        it("has the expected values", flags: [Filter.pending: pending]) {
          expect(isyDevice?.name).to(equal("ISYDevice1"))
          expect(isyDevice?.uniqueIdentifier).to(equal("uuid:00:21:b9:01:f2:b6"))
          expect(isyDevice?.modelNumber).to(equal("1120"))
          expect(isyDevice?.modelName).to(equal("ISY 994i 256"))
          expect(isyDevice?.modelDescription).to(equal("X_Insteon_Lighting_Device:1"))
          expect(isyDevice?.manufacturerURL).to(equal("http://www.universal-devices.com"))
          expect(isyDevice?.manufacturer).to(equal("Universal Devices Inc."))
          expect(isyDevice?.friendlyName).to(equal("ISY"))
          expect(isyDevice?.deviceType).to(equal("urn:udi-com:device:X_Insteon_Lighting_Device:1"))
          expect(isyDevice?.baseURL).to(equal("http://192.168.1.9"))
        }
        describe("the nodes", flags: [Filter.pending: pending]) {
          var nodes: Set<ISYDeviceNode>?
          it("has 4 nodes"){
            nodes = isyDevice?.nodes
            expect(nodes).toNot(beNil())
            expect(nodes?.count).to(equal(4))
            pending = nodes == nil
          }
          describe("it has a node named '20.12.40.1'") {
            var node1: ISYDeviceNode?
            it("exists") {
              node1 = findFirst(nodes, {$0.name == "20.12.40.1"})
              expect(node1).toNot(beNil())
              pending = node1 == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(node1?.name).to(equal("20.12.40.1"))
              expect(node1?.flag).to(equal(128))
              expect(node1?.address).to(equal("20 12 40 1"))
              expect(node1?.type).to(equal("1.58.193.0"))
              expect(node1?.enabled).to(beTrue())
              expect(node1?.pnode).to(equal("20 12 40 1"))
              expect(node1?.propertyID).to(equal("ST"))
              expect(node1?.propertyValue).to(equal(255))
              expect(node1?.propertyUOM).to(equal("%/on/off"))
              expect(node1?.propertyFormatted).to(equal("On"))
              expect(node1?.groups.count) == 1
            }
          }
          describe("it has a node named '18.F0.08.1'") {
            var node2: ISYDeviceNode?
            it("exists") {
              node2 = findFirst(nodes, {$0.name == "18.F0.08.1"})
              expect(node2).toNot(beNil())
              pending = node2 == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(node2?.name).to(equal("18.F0.08.1"))
              expect(node2?.flag).to(equal(128))
              expect(node2?.address).to(equal("18 F0 8 1"))
              expect(node2?.type).to(equal("1.7.56.0"))
              expect(node2?.enabled).to(beFalse())
              expect(node2?.pnode).to(equal("18 F0 8 1"))
              expect(node2?.propertyID).to(equal("ST"))
              expect(node2?.propertyValue).to(equal(0))
              expect(node2?.propertyUOM).to(equal("%/on/off"))
              expect(node2?.propertyFormatted).to(equal(""))
              expect(node2?.groups.count) == 1
            }
          }
          describe("it has a node named 'Sofa Table Lamp'") {
            var node3: ISYDeviceNode?
            it("exists") {
              node3 = findFirst(nodes, {$0.name == "Sofa Table Lamp"})
              expect(node3).toNot(beNil())
              pending = node3 == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(node3?.name).to(equal("Sofa Table Lamp"))
              expect(node3?.flag).to(equal(128))
              expect(node3?.address).to(equal("23 78 77 1"))
              expect(node3?.type).to(equal("1.14.65.0"))
              expect(node3?.enabled).to(beTrue())
              expect(node3?.pnode).to(equal("23 78 77 1"))
              expect(node3?.propertyID).to(equal("ST"))
              expect(node3?.propertyValue).to(equal(255))
              expect(node3?.propertyUOM).to(equal("%/on/off"))
              expect(node3?.propertyFormatted).to(equal("On"))
              expect(node3?.groups.count) == 1
            }
          }
          describe("it has a node named 'Front Door Table Lamp'") {
            var node4: ISYDeviceNode?
            it("exists") {
              node4 = findFirst(nodes, {$0.name == "Front Door Table Lamp"})
              expect(node4).toNot(beNil())
              pending = node4 == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(node4?.name).to(equal("Front Door Table Lamp"))
              expect(node4?.flag).to(equal(128))
              expect(node4?.address).to(equal("1B 6E B2 1"))
              expect(node4?.type).to(equal("2.23.57.0"))
              expect(node4?.enabled).to(beTrue())
              expect(node4?.pnode).to(equal("1B 6E B2 1"))
              expect(node4?.propertyID).to(equal("ST"))
              expect(node4?.propertyValue).to(equal(255))
              expect(node4?.propertyUOM).to(equal("on/off"))
              expect(node4?.propertyFormatted).to(equal("On"))
              expect(node4?.groups.count) == 1
            }
          }
        }
        describe("the device's groups", flags: [Filter.pending: pending]) {
          var groups: Set<ISYDeviceGroup>?
          it("contains two groups") {
            groups = isyDevice?.groups
            expect(groups).toNot(beNil())
            pending = groups == nil
          }
          describe("the isy group", flags: [Filter.pending: pending]) {
            var isyGroup: ISYDeviceGroup?
            it("exists") {
              isyGroup = findFirst(groups, {$0.name == "ISY"})
              expect(isyGroup).toNot(beNil())
              pending = isyGroup == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(isyGroup?.name).to(equal("ISY"))
              expect(isyGroup?.flag).to(equal(12))
              expect(isyGroup?.address).to(equal("00:21:b9:01:f2:b6"))
              expect(isyGroup?.family).to(equal(6))
              expect(map(isyGroup?.members ?? [], {$0.name})).to(contain("20.12.40.1",
                                                                         "Front Door Table Lamp",
                                                                         "18.F0.08.1",
                                                                         "Sofa Table Lamp"))
            }
          }
          describe("the auto dr group", flags: [Filter.pending: pending]) {
            var autoDRGroup: ISYDeviceGroup?
            it("exists") {
              autoDRGroup = findFirst(groups, {$0.name == "Auto DR"})
              expect(autoDRGroup).toNot(beNil())
              pending = autoDRGroup == nil
            }
            it("has the expected values", flags: [Filter.pending: pending]) {
              expect(autoDRGroup?.name).to(equal("Auto DR"))
              expect(autoDRGroup?.flag).to(equal(132))
              expect(autoDRGroup?.address).to(equal("ADR0001"))
              expect(autoDRGroup?.family).to(equal(5))
              expect(autoDRGroup?.members.count).to(equal(0))
            }
          }
        }
      }
    }

    xdescribe("the activity controller") {
      var pending = false
      var activityController: ActivityController?
      it("can be retrieved") {
        activityController = ActivityController.sharedController(self.dynamicType.context)
        expect(activityController).toNot(beNil())
        pending = activityController == nil
      }
    }

    xdescribe("the presets") {
    }

    xdescribe("the remotes") {
    }

  }

}
