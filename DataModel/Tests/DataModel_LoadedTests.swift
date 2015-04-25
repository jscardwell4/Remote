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

infix operator ⊇ {}


class DataModel_LoadedTests: QuickSpec {

  static let context = DataManager.isolatedContext()

  override func spec() {

    let moc = self.dynamicType.context

    beforeSuite {
      LogManager.logLevel = .Debug
      let rootDir = "/Users/Moondeer/Projects/MSRemote/Remote/Bank/Resources/JSON/"

      let loadInfo: [(String,ModelObject.Type,DataManager.LogFlags)] =  [
        ("Manufacturer",       Manufacturer.self,         DataManager.LogFlags.Default),
        ("ComponentDevice",    ComponentDevice.self,      DataManager.LogFlags.Default),
        ("ImageCategory",      ImageCategory.self,        DataManager.LogFlags.Default),
        ("Activity",           Activity.self,             DataManager.LogFlags.Default),
        ("NetworkDevice",      NetworkDevice.self,        DataManager.LogFlags.Default),
        ("Preset",             PresetCategory.self,       DataManager.LogFlags.Default),
        ("Remote",             Remote.self,               DataManager.LogFlags.Default),
        ("ActivityController", ActivityController.self,   DataManager.LogFlags.Default)
      ]
      for (file, type, flags) in loadInfo {
        DataManager.loadJSONFileAtPath(rootDir + file + ".json", forModel: type, context: moc, logFlags:flags)
      }
    }

    describe("the manufacturers") {
      describe("the Dish manufacturer") {
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Dish"), context: moc)
          expect(manufacturer) != nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'Dish'") {
          expect(manufacturer?.codeSets.count) == 1
          codeSet = manufacturer?.codeSets.first
          expect(codeSet) != nil
        }
        describe("the code set") {
          it("has the expected values") {
            expect(codeSet?.name) == "Dish"
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count) == 47
          }
          var code: IRCode?
          it("has a code named 'Favorites'") {
            code = IRCode.objectWithIndex(ModelIndex("Dish/Dish/Favorites"), context: moc)
            expect(code) != nil
          }
          describe("the code") {
            it("has the expected values") {
              expect(code?.name) == "Favorites"
              expect(code?.frequency) == 38343
              expect(code?.onOffPattern) == "344,173,19,172,19,86BCBCCCCCCCCBCB19,1183,345,86,19,3834"
            }
          }
        }
      }
      describe("the Sony manufacturer") {
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Sony"), context: moc)
          expect(manufacturer) != nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'AV Receiver''") {
          expect(manufacturer?.codeSets.count) == 1
          codeSet = manufacturer?.codeSets.first
          expect(codeSet) != nil
        }
        describe("the code set") {
          it("has the expected values") {
            expect(codeSet?.name) == "AV Receiver"
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count) == 14
          }
          var code: IRCode?
          it("has a code named 'Volume Up'") {
            code = IRCode.objectWithIndex(ModelIndex("Sony/AV%20Receiver/Volume%20Up"), context: moc)
            expect(code) != nil
          }
          describe("the code") {
            it("has the expected values") {
              expect(code?.name) == "Volume Up"
              expect(code?.frequency) == 40192
              expect(code?.offset) == 5
              expect(code?.onOffPattern) == "96,24,24,24,48,24BBCBBBBBBCCB24,888ABCBBCBBBBBBCCBDABCBBCBBBBBBCCB24,4019"
            }
          }
        }
      }
      describe("the Samsung manufacturer") {
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(ModelIndex("Samsung"), context: moc)
          expect(manufacturer) != nil
        }
        var codeSet: IRCodeSet?
        it("has a code set named 'Samsung TV'") {
          expect(manufacturer?.codeSets.count) == 1
          codeSet = manufacturer?.codeSets.first
          expect(codeSet) != nil
        }
        describe("the code set") {
          it("has the expected values") {
            expect(codeSet?.name) == "Samsung TV"
            expect(codeSet?.user).to(beTrue())
            expect(codeSet?.codes.count) == 54
          }
          var code: IRCode?
          it("has a code named 'Mute'") {
            code = IRCode.objectWithIndex(ModelIndex("Samsung/Samsung%20TV/Mute"), context: moc)
            expect(code) != nil
          }
          describe("the code") {
            it("has the expected values") {
              expect(code?.name) == "Mute"
              expect(code?.frequency) == 38109
              expect(code?.onOffPattern) == "171,171,21,64BB21,21CCCCBBBCCCCCBBBBCCCCCCCCBBBB21,1776ABBBCCCCCBBBCCCCCBBBBCCCCCC21,22CBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBBDABBBCCCCCBBBCCCCCBBBBCCCCCCCCBBBB21,4878"
            }
          }
        }
      }
    }

    describe("the component devices") {
      describe("the Dish Hopper device") {
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("Dish%20Hopper"), context: moc)
          expect(componentDevice) != nil
        }
        it("has the expected values") {
          expect(componentDevice?.name) == "Dish Hopper"
          expect(componentDevice?.codeSet?.name) == "Dish"
          expect(componentDevice?.manufacturer.name) == "Dish"
          expect(componentDevice?.alwaysOn).to(beTrue())
        }
      }
      describe("the PS3 device") {
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("PS3"), context: moc)
          expect(componentDevice) != nil
        }
        it("has the expected values") {
          expect(componentDevice?.name) == "PS3"
          expect(componentDevice?.codeSet?.name).to(beNil())
          expect(componentDevice?.manufacturer.name) == "Sony"
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
      describe("the Samsung TV device") {
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("Samsung%20TV"), context: moc)
          expect(componentDevice) != nil
        }
        it("has the expected values") {
          expect(componentDevice?.name) == "Samsung TV"
          expect(componentDevice?.codeSet?.name) == "Samsung TV"
          expect(componentDevice?.manufacturer.name) == "Samsung"
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
      describe("the AV Receiver device") {
        var componentDevice: ComponentDevice?
        it("can be retrieved by index") {
          componentDevice = ComponentDevice.objectWithIndex(ModelIndex("AV%20Receiver"), context: moc)
          expect(componentDevice) != nil
        }
        it("has the expected values") {
          expect(componentDevice?.name) == "AV Receiver"
          expect(componentDevice?.codeSet?.name) == "AV Receiver"
          expect(componentDevice?.manufacturer.name) == "Sony"
          expect(componentDevice?.alwaysOn).to(beFalse())
        }

      }
    }

    describe("the image categories") {
      var imageCategory: ImageCategory?
      describe("the Backgrounds category") {
        it("can be retrieved by index") {
          imageCategory = ImageCategory.objectWithIndex(ModelIndex("Backgrounds"), context: moc)
          expect(imageCategory) != nil
        }
        var image: Image?
        it("has an image") {
          expect(imageCategory?.images.count) == 1
          image = imageCategory?.images.first
        }
        describe("the image") {
          it("is named and indexed") {
            expect(image?.name) == "Pro Dots"
            expect(image?.index.rawValue) == "Backgrounds/Pro%20Dots"
          }
          var asset: Asset?
          it("has an asset") {
            expect(image?.asset) != nil
            asset = image?.asset
          }
          describe("the asset") {
            it("has a name but no location") {
              expect(asset?.name) == "Pro Dots"
              expect(asset?.location) == "$bank"
            }
          }
        }
      }
      describe("the Icons category") {
        it("can be retrieved by index") {
          imageCategory = ImageCategory.objectWithIndex(ModelIndex("Icons"), context: moc)
          expect(imageCategory) != nil
        }
        it("has no images") {
          expect(imageCategory?.images.count) == 0
        }
        it("has child categories") {
          let names = map(imageCategory!.childCategories, {$0.name})
          expect(names) ⊇ ["Glyphish 3", "Glyphish 4", "Glyphish 6", "Glyphish 7"]
        }

        it("has nested images retrievable by index") {
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%207/Large/Normal/Battery"), context: moc)) != nil
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%206/Large/Normal/Home"), context: moc)) != nil
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%206/Large/Normal/Pencil"), context: moc)) != nil
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%206/Large/Normal/Arrow%20Down"), context: moc)) != nil
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%204/Power%20Plug"), context: moc)) != nil
          expect(Image.objectWithIndex(ModelIndex("Icons/Glyphish%203/Outlet"), context: moc)) != nil
        }

      }

    }

    describe("the activities") {
      var activity: Activity?
      describe("the hopper activity") {
        it("can be retrieved by index") {
          activity = Activity.objectWithIndex(ModelIndex("Dish%20Hopper%20Activity"), context: moc)
          expect(activity) != nil
        }
        var launchMacro: MacroCommand?
        it("has a launch macro") {
          launchMacro = activity?.launchMacro
          expect(launchMacro) != nil
        }
        describe("the macro") {
          it("has sendir, power, delay, sendir commands") {
            expect(launchMacro?.commands.count) == 4
          }
        }
      }
    }

    describe("the network devices") {
      it("total of two") {
        let devices = NetworkDevice.objectsInContext(moc) as! [NetworkDevice]
        expect(devices.count) == 2
        describe("the devices are properly modeled") {
          let (device1, device2) = disperse2(devices)
          let device1AsItach = device1 as? ITachDevice, device2AsItach = device2 as? ITachDevice
          expect(device1AsItach == nil && device2AsItach == nil).toNot(beTrue())
          let device1AsISY = device1 as? ISYDevice, device2AsISY = device2 as? ISYDevice
          expect(device1AsISY == nil && device2AsISY == nil).toNot(beTrue())
        }

      }
      describe("the iTach device"){
        var iTachDevice: ITachDevice?
        it("can be retrieved by index") {
          iTachDevice = ITachDevice.objectWithIndex(ModelIndex("GlobalCache-iTachIP2IR"), context: moc)
          expect(iTachDevice) != nil
        }
        it("has the expected values") {
          expect(iTachDevice?.uuid) == "A7582E04-16F3-4319-9F21-41A17C922AC9"
          expect(iTachDevice?.name) == "GlobalCache-iTachIP2IR"
          expect(iTachDevice?.uniqueIdentifier) == "GlobalCache_000C1E022AED"
          expect(iTachDevice?.pcbPN) == "025-0028-03"
          expect(iTachDevice?.pkgLevel) == "GCPK002"
          expect(iTachDevice?.sdkClass) == "Utility"
          expect(iTachDevice?.make) == "GlobalCache"
          expect(iTachDevice?.model) == "iTachIP2IR"
          expect(iTachDevice?.status) == "Ready"
          expect(iTachDevice?.configURL) == "192.168.1.45"
          expect(iTachDevice?.revision) == "710-1005-05"
        }
      }
      describe("the isy device"){
        var isyDevice: ISYDevice?
        it("can be retrieved by index") {
          isyDevice = ISYDevice.objectWithIndex(ModelIndex("ISYDevice1"), context: moc)
          expect(isyDevice) != nil
        }
        it("has the expected values") {
          expect(isyDevice?.name) == "ISYDevice1"
          expect(isyDevice?.uniqueIdentifier) == "uuid:00:21:b9:01:f2:b6"
          expect(isyDevice?.modelNumber) == "1120"
          expect(isyDevice?.modelName) == "ISY 994i 256"
          expect(isyDevice?.modelDescription) == "X_Insteon_Lighting_Device:1"
          expect(isyDevice?.manufacturerURL) == "http://www.universal-devices.com"
          expect(isyDevice?.manufacturer) == "Universal Devices Inc."
          expect(isyDevice?.friendlyName) == "ISY"
          expect(isyDevice?.deviceType) == "urn:udi-com:device:X_Insteon_Lighting_Device:1"
          expect(isyDevice?.baseURL) == "http://192.168.1.9"
        }
        describe("the nodes") {
          var nodes: Set<ISYDeviceNode>?
          it("has 4 nodes"){
            nodes = isyDevice?.nodes
            expect(nodes) != nil
            expect(nodes?.count) == 4
          }
          describe("it has a node named '20.12.40.1'") {
            var node1: ISYDeviceNode?
            it("exists") {
              node1 = findFirst(nodes, {$0.name == "20.12.40.1"})
              expect(node1) != nil
            }
            it("has the expected values") {
              expect(node1?.name) == "20.12.40.1"
              expect(node1?.flag) == 128
              expect(node1?.address) == "20 12 40 1"
              expect(node1?.type) == "1.58.193.0"
              expect(node1?.enabled).to(beTrue())
              expect(node1?.pnode) == "20 12 40 1"
              expect(node1?.propertyID) == "ST"
              expect(node1?.propertyValue) == 255
              expect(node1?.propertyUOM) == "%/on/off"
              expect(node1?.propertyFormatted) == "On"
              expect(node1?.groups.count) == 1
            }
          }
          describe("it has a node named '18.F0.08.1'") {
            var node2: ISYDeviceNode?
            it("exists") {
              node2 = findFirst(nodes, {$0.name == "18.F0.08.1"})
              expect(node2) != nil
            }
            it("has the expected values") {
              expect(node2?.name) == "18.F0.08.1"
              expect(node2?.flag) == 128
              expect(node2?.address) == "18 F0 8 1"
              expect(node2?.type) == "1.7.56.0"
              expect(node2?.enabled).to(beFalse())
              expect(node2?.pnode) == "18 F0 8 1"
              expect(node2?.propertyID) == "ST"
              expect(node2?.propertyValue) == 0
              expect(node2?.propertyUOM) == "%/on/off"
              expect(node2?.propertyFormatted) == ""
              expect(node2?.groups.count) == 1
            }
          }
          describe("it has a node named 'Sofa Table Lamp'") {
            var node3: ISYDeviceNode?
            it("exists") {
              node3 = findFirst(nodes, {$0.name == "Sofa Table Lamp"})
              expect(node3) != nil
            }
            it("has the expected values") {
              expect(node3?.name) == "Sofa Table Lamp"
              expect(node3?.flag) == 128
              expect(node3?.address) == "23 78 77 1"
              expect(node3?.type) == "1.14.65.0"
              expect(node3?.enabled).to(beTrue())
              expect(node3?.pnode) == "23 78 77 1"
              expect(node3?.propertyID) == "ST"
              expect(node3?.propertyValue) == 255
              expect(node3?.propertyUOM) == "%/on/off"
              expect(node3?.propertyFormatted) == "On"
              expect(node3?.groups.count) == 1
            }
          }
          describe("it has a node named 'Front Door Table Lamp'") {
            var node4: ISYDeviceNode?
            it("exists") {
              node4 = findFirst(nodes, {$0.name == "Front Door Table Lamp"})
              expect(node4) != nil
            }
            it("has the expected values") {
              expect(node4?.name) == "Front Door Table Lamp"
              expect(node4?.flag) == 128
              expect(node4?.address) == "1B 6E B2 1"
              expect(node4?.type) == "2.23.57.0"
              expect(node4?.enabled).to(beTrue())
              expect(node4?.pnode) == "1B 6E B2 1"
              expect(node4?.propertyID) == "ST"
              expect(node4?.propertyValue) == 255
              expect(node4?.propertyUOM) == "on/off"
              expect(node4?.propertyFormatted) == "On"
              expect(node4?.groups.count) == 1
            }
          }
        }
        describe("the device's groups") {
          var groups: Set<ISYDeviceGroup>?
          it("contains two groups") {
            groups = isyDevice?.groups
            expect(groups) != nil
          }
          describe("the isy group") {
            var isyGroup: ISYDeviceGroup?
            it("exists") {
              isyGroup = findFirst(groups, {$0.name == "ISY"})
              expect(isyGroup) != nil
            }
            it("has the expected values") {
              expect(isyGroup?.name) == "ISY"
              expect(isyGroup?.flag) == 12
              expect(isyGroup?.address) == "00:21:b9:01:f2:b6"
              expect(isyGroup?.family) == 6
              expect(map(isyGroup?.members ?? [], {$0.name})) ⊇ ["20.12.40.1", "Front Door Table Lamp",
                                                                 "18.F0.08.1", "Sofa Table Lamp"]
            }
          }
          describe("the auto dr group") {
            var autoDRGroup: ISYDeviceGroup?
            it("exists") {
              autoDRGroup = findFirst(groups, {$0.name == "Auto DR"})
              expect(autoDRGroup) != nil
            }
            it("has the expected values") {
              expect(autoDRGroup?.name) == "Auto DR"
              expect(autoDRGroup?.flag) == 132
              expect(autoDRGroup?.address) == "ADR0001"
              expect(autoDRGroup?.family) == 5
              expect(autoDRGroup?.members.count) == 0
            }
          }
        }
      }
    }

    describe("the activity controller") {
      var activityController: ActivityController?
      it("can be retrieved") {
        activityController = ActivityController.sharedController(moc)
        expect(activityController) != nil
      }
      it("has a home remote") {
        expect(activityController?.homeRemote) != nil
      }
      var topToolbar: ButtonGroup?
      it("has a top toolbar") {
        topToolbar = activityController?.topToolbar
        expect(topToolbar) != nil
      }
      describe("the top toolbar") {
        it("has the expected values") {
          expect(topToolbar?.name) == "Top Toolbar"
          expect(topToolbar?.role) == RemoteElement.Role.Toolbar
          expect(topToolbar?.shape) == RemoteElement.Shape.Rectangle
          expect(topToolbar?.constraints.count) == 14
          expect(topToolbar?.backgroundColorForMode(RemoteElement.DefaultMode)?.jsonValue) == "gray@50%"
          expect(topToolbar?.subelements.count) == 5
        }
        var subelements: OrderedSet<RemoteElement>?
        describe("the toolbar buttons") {
          it("can be retrieved") {
            subelements = topToolbar?.childElements
            expect(subelements) != nil
            expect(subelements?.count) == 5
          }
          var button: Button?
          describe("the home button") {
            it("is the first button") {
              button = subelements?[0] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              expect(button?.name) == "Home Button"
              expect(button?.role) == RemoteElement.Role.ToolbarButton
              expect(button?.constraints.count) == 1
              expect(button?.commandForMode(RemoteElement.DefaultMode)) != nil
              expect(button?.iconsForMode(RemoteElement.DefaultMode)?.normal?.image?.name) == "Home"
            }
          }
          describe("the settings button") {
            it("is the second button") {
              button = subelements?[1] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              expect(button?.name) == "Settings Button"
              expect(button?.role) == RemoteElement.Role.ToolbarButton
              expect(button?.commandForMode(RemoteElement.DefaultMode)) != nil
              expect(button?.iconsForMode(RemoteElement.DefaultMode)?.normal?.image?.name) == "Gear"
            }
          }
          describe("the edit remote button") {
            it("is the third button") {
              button = subelements?[2] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              expect(button?.name) == "Edit Remote Button"
              expect(button?.role) == RemoteElement.Role.ToolbarButton
              expect(button?.commandForMode(RemoteElement.DefaultMode)) != nil
              expect(button?.iconsForMode(RemoteElement.DefaultMode)?.normal?.image?.name) == "Pencil"
            }
          }
          describe("the battery status button") {
            it("is the fourth button") {
              button = subelements?[3] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              expect(button?.name) == "Battery Status Button"
              expect(button?.role) == RemoteElement.Role.BatteryStatus
              expect(button?.iconsForMode(RemoteElement.DefaultMode)?.normal?.image?.name) == "Battery"
            }
          }
          describe("the connection status button") {
            it("is the fifth button") {
              button = subelements?[4] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              expect(button?.name) == "Connection Status Button"
              expect(button?.role) == RemoteElement.Role.ConnectionStatus
              expect(button?.iconsForMode(RemoteElement.DefaultMode)?.normal?.image?.name) == "Wifi Signal"
            }
          }
        }
      }
    }

    describe("the presets") {
      it("can be fetched") {
        let presetCategories = PresetCategory.objectsInContext(moc) as? [PresetCategory]
        expect(presetCategories) != nil
        expect(presetCategories?.count) > 0
      }

      var presetCategory: PresetCategory?
      describe("the Remote category") {
        it("can be retrieved by index") {
          presetCategory = PresetCategory.objectWithIndex(ModelIndex("Remote"), context: moc)
          expect(presetCategory) != nil
        }
      }
      describe("the Button Group category") {
        it("can be retrieved by index") {
          presetCategory = PresetCategory.objectWithIndex(ModelIndex("Button%20Group"), context: moc)
          expect(presetCategory) != nil
        }
        it("contains 8 presets") {
          expect(presetCategory?.presets.count) == 8
        }

        var preset: Preset?
        it("has a preset named '1 x 3'") {
          preset = Preset.objectWithIndex(ModelIndex("Button%20Group/1%20x%203"), context: moc)
          expect(preset) != nil
        }
        describe("the '1 x 3' preset") {
          it("has the expected values") {
            expect(preset?.name) == "1 x 3"
            expect(preset?.baseType) == RemoteElement.BaseType.ButtonGroup
            expect(preset?.constraints) ==  "$0.height ≥ 150\n$0.width ≥ 132\n$1.left = $0.left :: $1.right = $0.right :: $1.top = $0.top\n$2.height = $1.height :: $2.left = $0.left :: $2.right = $0.right :: $2.top = $1.bottom + 4\n$3.bottom = $0.bottom :: $3.height = $1.height :: $3.left = $0.left :: $3.right = $0.right :: $3.top = $2.bottom + 4"
            expect(preset?.subelements?.count) == 3
          }
        }

      }
    }

    fdescribe("the remotes") {
      it("can be fetched") {
        let remotes = Remote.objectsInContext(moc) as? [Remote]
        expect(remotes) != nil
        expect(remotes?.count) == 2
      }
      var remote: Remote?
      describe("the dish hopper remote") {
        it("can be retrieved by index") {
          remote = Remote.objectWithIndex(ModelIndex("Dish%20Hopper%20Activity"), context: moc)
          expect(remote) != nil
        }
        it("has the expected values") {
          expect(remote?.key) == "activity1"
          expect(remote?.name) == "Dish Hopper Activity"
          expect(remote?.topBarHidden).to(beTrue())
          expect(remote?.constraints.count) == 22
          expect(remote?.backgroundColorForMode(RemoteElement.DefaultMode)?.jsonValue.rawValue) == "\"black\""
          expect(remote?.backgroundImageForMode(RemoteElement.DefaultMode)?.image?.index.rawValue) == "Backgrounds/Pro%20Dots"
          expect(remote?.subelements.count) == 8
          expect(remote?.panels.count) == 4
        }
      }
      describe("the home screen remote") {
        it("can be retrieved by index") {
          remote = Remote.objectWithIndex(ModelIndex("Home%20Screen"), context: moc)
          expect(remote) != nil
        }
        it("has the expected values") {
          expect(remote?.name) == "Home Screen"
          expect(remote?.constraints.count) == 5
          expect(remote?.subelements.count) == 2
        }
        var buttonGroup: ButtonGroup?
        describe("the activities button group") {
          it("can be retrieved") {
            buttonGroup = remote?.subelements[0] as? ButtonGroup
            expect(buttonGroup) != nil
          }
          it("has the expected values") {
            expect(buttonGroup?.constraints.count) == 14
            expect(buttonGroup?.subelements.count) == 4
          }

          var button: Button?
          describe("the Dish button") {
            it("can be retrieved") {
              button = buttonGroup?.subelements[0] as? Button
              expect(button) != nil
            }
            it("has the expected values") {
              let titles = button?.titlesForMode(RemoteElement.DefaultMode)
              expect(titles) != nil
              let titleAttributes: TitleAttributes? = titles?.titleAttributesForState(.Normal)
              expect(titleAttributes == nil) == false
              expect(titleAttributes?.text) == "Dish"
            }
          }
        }
      }
    }

  }

}
