//
//  DataModelTests.swift
//  DataModelTests
//
//  Created by Jason Cardwell on 4/5/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import DataModel
import MoonKit
import Nimble

class DataModelTests: XCTestCase {

  var context: NSManagedObjectContext!

  override class func initialize() {
    super.initialize()
    if self === DataModelTests.self {
      MSLog.addTaggingASLLogger()
      MSLog.addTaggingTTYLogger()
    }
  }

  override func setUp() {
    super.setUp()
    context = DataManager.isolatedContext()
  }

  func assertJSONEquality(data: ObjectJSONValue,
              forObject object: JSONValueConvertible?,
          excludingKeys excluded: [String] = [])
  {
    if let actualData = ObjectJSONValue(object?.jsonValue) {
      assertJSONEquality(data, forObject: actualData, excludingKeys: excluded)
    } else { XCTFail("failed to get object json value for specified object") }
  }

  func assertJSONEquality(data: ObjectJSONValue,
                forObject object: ObjectJSONValue,
            excludingKeys excluded: [String] = [])
  {
    let expectedData = data.filter({(k, _) in excluded ∌ k})
    if !object.contains(expectedData) {
      var foundTheProblem = false
      for (key, expectedValue) in expectedData {
        if let actualValue = object[key] {
          let equalValues = actualValue == expectedValue
          XCTAssertTrue(equalValues,
            "actual value '\(actualValue)' does not equal expected value '\(expectedValue)' for key '\(key)'")
          if !equalValues { foundTheProblem = true; break }
        } else {
          XCTFail("missing value for key '\(key)'")
          foundTheProblem = true
          break
        }
      }
      if !foundTheProblem {
        MSLogDebug("problem detected in `-[ObjectJSONValue contains:]`, false negative reported for actual data '\(object)' with expected data '\(expectedData)'")
      }
    }
  }

}

class IsolatedDataModelTests: DataModelTests {

  static let testJSON: [String:JSONValue] = {
    var filePaths: [String:JSONValue] = [:]
    if let bundlePath = NSUserDefaults.standardUserDefaults().stringForKey("XCTestedBundlePath"),
      let bundle = NSBundle(path: bundlePath)
    {
      for s in ["Activity", "ActivityController", "ComponentDevice", "Image", "ImageCategory",
                "IRCode", "IRCodeSet", "ISYDevice", "ISYDeviceGroup", "ISYDeviceNode",
                "ITachDevice", "Manufacturer", "Preset", "PresetCategory", "TitleAttributes",
                "Remote", "ButtonGroup", "Button", "ActivityCommand", "DelayCommand", "HTTPCommand",
                "MacroCommand", "PowerCommand", "SendIRCommand", "SwitchCommand", "SystemCommand",
                "CommandSet", "CommandSetCollection", "ControlStateColorSet", "ControlStateImageSet",
                "ControlStateTitleSet", "ImageView", "Constraint"]
      {
        var error: NSError?
        if let filePath = bundle.pathForResource(s, ofType: "json"),
        json = JSONSerialization.objectByParsingFile(filePath, options: .InflateKeypaths, error: &error)
        where !MSHandleError(error)
        {
          filePaths[s] = json
        }
      }
    }
    return filePaths
    }()

  func testDictionaryStorage() {
    let storage = DictionaryStorage(context: context)
    XCTAssert(storage.entityName == "DictionaryStorage", "failed to create new instance of `Dictionary Storage`")
    let key1 = "key1", key2 = "key2", key3 = "key3"
    let value1 = "value1", value2 = 2, value3 = ["value3"]
    storage[key1] = value1; storage[key2] = value2; storage[key3] = value3
    let stored1 = storage[key1] as? String, stored2 = storage[key2] as? Int, stored3 = storage[key3] as? [String]
    XCTAssertNotNil(stored1); XCTAssertNotNil(stored2); XCTAssertNotNil(stored3)
    if let s1 = stored1, s2 = stored2, s3 = stored3 {
      XCTAssert(s1 == value1); XCTAssert(s2 == value2); XCTAssert(s3 == value3)
    }
  }

  func testJSONStorage() {
    let storage = JSONStorage(context: context)
    XCTAssert(storage.entityName == "JSONStorage", "failed to create new instance of `JSON Storage`")
    let key1 = "key1", key2 = "key2", key3 = "key3"
    let value1 = "value1", value2 = 2, value3 = ["value3"]
    storage[key1] = value1.jsonValue; storage[key2] = value2.jsonValue; storage[key3] = JSONValue(value3)
    let stored1 = String(storage[key1]), stored2 = Int(storage[key2]), stored3 = compressedMap(ArrayJSONValue(storage[key3]), {String($0)})
    XCTAssertNotNil(stored1); XCTAssertNotNil(stored2); XCTAssertNotNil(stored3)
    if let s1 = stored1, s2 = stored2, s3 = stored3 {
      XCTAssert(s1 == value1); XCTAssert(s2 == value2); XCTAssert(s3 == value3)
    }
  }

  func testActivity() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Activity"]) {
      let activity = Activity(data: data, context: context)
      XCTAssert(activity != nil)
      assertJSONEquality(data, forObject: activity, excludingKeys: ["remote", "launchMacro", "haltMacro"])
      XCTAssertNotNil(activity?.launchMacro)
      XCTAssertNotNil(activity?.haltMacro)
    } else { XCTFail("could not retrieve test json for `Activity`") }
  }

  func testActivityController() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ActivityController"]) {
      let activityController = ActivityController(data: data, context: context)
      XCTAssert(activityController != nil)
      assertJSONEquality(data, forObject: activityController, excludingKeys: ["homeRemote", "topToolbar"])
      XCTAssert(activityController?.topToolbar != nil, "missing value for 'topToolbar'")
    } else { XCTFail("could not retrieve test json for `ActivityController`") }
  }

  func testComponentDevice() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ComponentDevice"]) {
      let componentDevice = ComponentDevice(data: data, context: context)
      XCTAssert(componentDevice != nil)
      assertJSONEquality(data, forObject: componentDevice, excludingKeys: ["codeSet", "manufacturer"])
    } else { XCTFail("could not retrieve test json for `ComponentDevice`") }
  }

  func testIRCode() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["IRCode"]) {
      let irCode = IRCode(data: data, context: context)
      XCTAssert(irCode != nil)
      assertJSONEquality(data, forObject: irCode)
    } else { XCTFail("could not retrieve test json for `IRCode`") }
  }

  func testIRCodeSet() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["IRCodeSet"]) {
      let irCodeSet = IRCodeSet(data: data, context: context)
      XCTAssert(irCodeSet != nil)
      assertJSONEquality(data, forObject: irCodeSet, excludingKeys: ["codes"])
    } else { XCTFail("could not retrieve test json for `IRCodeSet`") }
  }

  func testISYDevice() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ISYDevice"]) {
      let isyDevice = ISYDevice(data: data, context: context)
      XCTAssert(isyDevice != nil)
      assertJSONEquality(data, forObject: isyDevice, excludingKeys: ["nodes", "groups"])
    } else { XCTFail("could not retrieve test json for `ISYDevice`") }
  }

  func testISYDeviceGroup() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ISYDeviceGroup"]) {
      let isyDeviceGroup = ISYDeviceGroup(data: data, context: context)
      XCTAssert(isyDeviceGroup != nil)
      assertJSONEquality(data, forObject: isyDeviceGroup, excludingKeys: ["members", "device"])
    } else { XCTFail("could not retrieve test json for `ISYDeviceGroup`") }
  }

  func testISYDeviceNode() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ISYDeviceNode"]) {
      let isyDeviceNode = ISYDeviceNode(data: data, context: context)
      XCTAssert(isyDeviceNode != nil)
      assertJSONEquality(data, forObject: isyDeviceNode, excludingKeys: ["groups", "device"])
    } else { XCTFail("could not retrieve test json for `ISYDeviceNode`") }
  }

  func testITachDevice() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ITachDevice"]) {
      let iTachDevice = ITachDevice(data: data, context: context)
      XCTAssert(iTachDevice != nil)
      assertJSONEquality(data, forObject: iTachDevice)
    } else { XCTFail("could not retrieve test json for `ITachDevice`") }
  }

  func testImage() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Image"]) {
      let image = Image(data: data, context: context)
      XCTAssert(image != nil)
      assertJSONEquality(data, forObject: image, excludingKeys: [])
    } else { XCTFail("could not retrieve test json for `Image`") }
  }

  func testImageCategory() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ImageCategory"]) {
      let imageCategory = ImageCategory(data: data, context: context)
      XCTAssert(imageCategory != nil)
      assertJSONEquality(data, forObject: imageCategory, excludingKeys: ["images"])
      if let expectedImageCount = data["images"]?.arrayValue?.count,
        images = imageCategory?.images
      {
        XCTAssertEqual(expectedImageCount, images.count)
      }
    } else { XCTFail("could not retrieve test json for `ImageCategory`") }
  }

  func testManufacturer() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Manufacturer"]) {
      let manufacturer = Manufacturer(data: data, context: context)
      XCTAssert(manufacturer != nil)
      assertJSONEquality(data, forObject: manufacturer, excludingKeys: ["codeSets"])
      if let expectedCodeSetCount = data["codeSets"]?.arrayValue?.count,
        codeSets = manufacturer?.codeSets
      {
        XCTAssertEqual(expectedCodeSetCount, codeSets.count)
      }
    } else { XCTFail("could not retrieve test json for `Manufacturer`") }
  }

  func testModelIndex() {
    let uuid = "4E9FE3CD-A64C-4D6D-8E3D-F7F5B7D7EB92"
    let uuidIndex = UUIDIndex(uuid)
    XCTAssert(uuidIndex != nil)
    XCTAssert(uuidIndex?.rawValue == uuid)

    let path = "I/Am/a%20Path"
    let pathIndex = PathIndex(path)
    XCTAssert(pathIndex != nil)
    XCTAssert(pathIndex?.rawValue == path)
    XCTAssert(pathIndex?.first == "I")
    XCTAssert(pathIndex?.last == "a%20Path")
    XCTAssert(pathIndex?.count == 3)
  }

  func testPreset() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Preset"]) {
      let preset = Preset(data: data, context: context)
      XCTAssert(preset != nil)
      assertJSONEquality(data, forObject: preset, excludingKeys: ["subelements"])
      if let expectedSubelementsCount = data["subelements"]?.arrayValue?.count,
        subelements = preset?.subelements
      {
        XCTAssertEqual(expectedSubelementsCount, subelements.count)
      }
    } else { XCTFail("could not retrieve test json for `Preset`") }
  }

  func testPresetCategory() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["PresetCategory"]) {
      let presetCategory = PresetCategory(data: data, context: context)
      XCTAssert(presetCategory != nil)
      assertJSONEquality(data, forObject: presetCategory, excludingKeys: ["presets"])
      if let expectedPresetsCount = data["presets"]?.arrayValue?.count,
        presets = presetCategory?.presets
      {
        XCTAssertEqual(expectedPresetsCount, presets.count)
      }
    } else { XCTFail("could not retrieve test json for `PresetCategory`") }
  }

  func testTitleAttributes() {
    if let data = self.dynamicType.testJSON["TitleAttributes"] {
      let titleAttributes = TitleAttributes(data)
      XCTAssert(titleAttributes != nil)
      assertJSONEquality(ObjectJSONValue(data)!, forObject: titleAttributes)
    } else { XCTFail("could not retrieve test json for `TitleAttributes`") }
  }

  func testButton() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Button"]) {
      if let button = Button(data: data, context: context) {
        assertJSONEquality(data, forObject: button, excludingKeys: ["commands", "titles", "backgroundColors"])
      } else { XCTFail("failed to create button") }
    } else { XCTFail("could not retrieve test json for `Button`") }
  }

  func testButtonGroup() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ButtonGroup"]) {
      if let buttonGroup = ButtonGroup(data: data, context: context) {
        assertJSONEquality(data, forObject: buttonGroup, excludingKeys: ["subelements"])
      } else { XCTFail("failed to create buttonGroup") }
    } else { XCTFail("could not retrieve test json for `ButtonGroup`") }
  }

  func testRemote() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["Remote"]) {
      if let remote = Remote(data: data, context: context) {
        assertJSONEquality(data, forObject: remote, excludingKeys: ["subelements", "constraints", "backgroundImage"])
      } else { XCTFail("failed to create remote") }
    } else { XCTFail("could not retrieve test json for `Remote`") }
  }

  func testActivityCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ActivityCommand"]) {
      if let activityCommand = ActivityCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: activityCommand, excludingKeys: ["activity"])
      } else { XCTFail("failed to create activityCommand") }
    } else { XCTFail("could not retrieve test json for `ActivityCommand`") }
  }

  func testDelayCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["DelayCommand"]) {
      if let delayCommand = DelayCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: delayCommand, excludingKeys: [])
      } else { XCTFail("failed to create delayCommand") }
    } else { XCTFail("could not retrieve test json for `DelayCommand`") }
  }

  func testHTTPCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["HTTPCommand"]) {
      if let hTTPCommand = HTTPCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: hTTPCommand, excludingKeys: [])
      } else { XCTFail("failed to create hTTPCommand") }
    } else { XCTFail("could not retrieve test json for `HTTPCommand`") }
  }

  func testMacroCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["MacroCommand"]) {
      if let macroCommand = MacroCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: macroCommand, excludingKeys: ["commands"])
        XCTAssert(macroCommand.commands.count == data["commands"]?.arrayValue?.count, "unexpected number of commands in macro")
      } else { XCTFail("failed to create macroCommand") }
    } else { XCTFail("could not retrieve test json for `MacroCommand`") }
  }

  func testPowerCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["PowerCommand"]) {
      if let powerCommand = PowerCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: powerCommand, excludingKeys: ["device"])
      } else { XCTFail("failed to create powerCommand") }
    } else { XCTFail("could not retrieve test json for `PowerCommand`") }
  }

  func testSendIRCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["SendIRCommand"]) {
      if let sendIRCommand = SendIRCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: sendIRCommand, excludingKeys: ["code"])
      } else { XCTFail("failed to create sendIRCommand") }
    } else { XCTFail("could not retrieve test json for `SendIRCommand`") }
  }

  func testSwitchCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["SwitchCommand"]) {
      if let switchCommand = SwitchCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: switchCommand, excludingKeys: [])
      } else { XCTFail("failed to create switchCommand") }
    } else { XCTFail("could not retrieve test json for `SwitchCommand`") }
  }

  func testSystemCommand() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["SystemCommand"]) {
      if let systemCommand = SystemCommand(data: data, context: context) {
        assertJSONEquality(data, forObject: systemCommand, excludingKeys: [])
      } else { XCTFail("failed to create systemCommand") }
    } else { XCTFail("could not retrieve test json for `SystemCommand`") }
  }

  func testCommandSet() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["CommandSet"]) {
      if let commandSet = CommandSet(data: data, context: context) {
        if let commandSetJSONObject = ObjectJSONValue(commandSet.jsonValue) {
          XCTAssert(commandSetJSONObject["type"] == data["type"], "unexpected 'type' value")
          XCTAssert(commandSetJSONObject["top"] != nil, "missing value for 'top'")
          XCTAssert(commandSetJSONObject["bottom"] != nil, "missing value for 'bottom'")
        } else { XCTFail("failed to create object json for created command set") }
      } else { XCTFail("failed to create commandSet") }
    } else { XCTFail("could not retrieve test json for `CommandSet`") }
  }

  func testCommandSetCollection() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["CommandSetCollection"]) {
      if let commandSetCollection = CommandSetCollection(data: data, context: context) {
        assertJSONEquality(data, forObject: commandSetCollection, excludingKeys: ["CH", "PAGE", "VOL"])
        XCTAssertNotNil(commandSetCollection["CH"], "missing command set for 'CH' label")
        XCTAssertNotNil(commandSetCollection["PAGE"], "missing command set for 'PAGE' label")
        XCTAssertNotNil(commandSetCollection["VOL"], "missing command set for 'VOL' label")
      } else { XCTFail("failed to create commandSetCollection") }
    } else { XCTFail("could not retrieve test json for `CommandSetCollection`") }
  }

  func testControlStateColorSet() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ControlStateColorSet"]) {
      if let controlStateColorSet = ControlStateColorSet(data: data, context: context) {
        assertJSONEquality(data, forObject: controlStateColorSet, excludingKeys: ["disabled", "selected", "highlightedDisabled"])
        XCTAssert(controlStateColorSet.disabled?.rgbHexString == String(data["disabled"]), "unexpected value for 'disabled'")
        XCTAssert(controlStateColorSet.selected?.rgbHexString == String(data["selected"]), "unexpected value for 'selected'")
        XCTAssert(controlStateColorSet.highlightedDisabled?.jsonValue == "white".jsonValue, "unexpected value for 'highlightedDisabled")
      } else { XCTFail("failed to create controlStateColorSet") }
    } else { XCTFail("could not retrieve test json for `ControlStateColorSet`") }
  }

  func testControlStateImageSet() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ControlStateImageSet"]) {
      if let controlStateImageSet = ControlStateImageSet(data: data, context: context) {
        assertJSONEquality(data, forObject: controlStateImageSet, excludingKeys: ["normal", "highlighted", "disabled"])
        expect(controlStateImageSet.normal).toNot(beNil())
        expect(controlStateImageSet.highlighted).toNot(beNil())
        expect(controlStateImageSet.disabled).toNot(beNil())
      } else { XCTFail("failed to create controlStateImageSet") }
    } else { XCTFail("could not retrieve test json for `ControlStateImageSet`") }
  }

  func testControlStateTitleSet() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ControlStateTitleSet"]) {
      if let controlStateTitleSet = ControlStateTitleSet(data: data, context: context) {
        assertJSONEquality(data, forObject: controlStateTitleSet, excludingKeys: [])
      } else { XCTFail("failed to create controlStateTitleSet") }
    } else { XCTFail("could not retrieve test json for `ControlStateTitleSet`") }
  }

  func testImageView() {
    if let data = ObjectJSONValue(self.dynamicType.testJSON["ImageView"]) {
      if let imageView = ImageView(data: data, context: context) {
        assertJSONEquality(data, forObject: imageView, excludingKeys: ["image"])
      } else { XCTFail("failed to create imageView") }
    } else { XCTFail("could not retrieve test json for `ImageView`") }
  }

  func testConstraint() {
    if let data = ArrayJSONValue(self.dynamicType.testJSON["Constraint"]) {
      let constraints = Constraint.importObjectsWithData(data, context: context)
      expect(constraints.count).to(beGreaterThan(0))
    } else { XCTFail("could not retrieve test json for `Constraint`") }
  }


}

class InterdependentDataModelTests: DataModelTests {

  func expectFileLoad(name: String, type: ModelObject.Type) {
    let expectation = expectationWithDescription("load \(name)")
    DataManager.loadDataFromFile(name,
                            type: type,
                         context: context,
                      completion: {(success: Bool, error: NSError?) -> Void in
                        XCTAssertTrue(success, "loading data from file triggered an error")
                        DataManager.saveRootContext(completion: { (success: Bool, error: NSError?) -> Void in
                          XCTAssertTrue(success, "saving context triggered an error")
                          expectation.fulfill()
                        })
    })
    waitForExpectationsWithTimeout(10, handler: {(error: NSError?) -> Void in _ = MSHandleError(error)})
  }

  func testLoadManufacturersFromFile() {
    expectFileLoad("Manufacturer_Test", type: Manufacturer.self)
    let manufacturers = Manufacturer.objectsInContext(context) as! [Manufacturer]
    expect(manufacturers.count).to(equal(3))
    expect(manufacturers.map{$0.name}).to(contain("Dish", "Sony", "Samsung"))
    expect(manufacturers.map{$0.codeSets.count}).to(contain(1, 3))
    let codeSet = IRCodeSet.objectMatchingPredicate(∀"manufacturer.name == 'Dish'", context: context)
    expect(codeSet).toNot(beNil())
    expect(codeSet?.codes.count).to(equal(47))
  }

  func testLoadComponentDevicesFromFile() {
    expectFileLoad("ComponentDevice", type: ComponentDevice.self)
    let componentDevices = ComponentDevice.objectsInContext(context) as! [ComponentDevice]
    expect(componentDevices.count).to(equal(4))
    expect(componentDevices.map{$0.name}).to(contain("Dish Hopper", "PS3", "AV Receiver", "Samsung TV"))
  }

  func testLoadImagesFromFile() {
    expectFileLoad("Glyphish", type: ImageCategory.self)
    let imageCategories = ImageCategory.objectsInContext(context) as! [ImageCategory]
    expect(imageCategories.count).to(beGreaterThanOrEqualTo(19))
  }

  func testLoadNetworkDevicesFromFile() {
    expectFileLoad("NetworkDevice", type: NetworkDevice.self)
    let networkDevices = NetworkDevice.objectsInContext(context) as! [NetworkDevice]
    expect(networkDevices.count).to(equal(2))
    expect(networkDevices.map{$0.name}).to(contain("GlobalCache-iTachIP2IR", "ISYDevice1"))
  }

  func testLoadActivitiesFromFile() {
    expectFileLoad("Activity", type: Activity.self)
    let activities = Activity.objectsInContext(context) as! [Activity]
    expect(activities.count).to(equal(4))
    expect(activities.map{$0.name}).to(contain("Dish Hopper Activity", "Playstation Activity", "Sonos Activity", " TV Activity"))
  }

  func testLoadPresetsFromFile() {
    expectFileLoad("Preset", type: PresetCategory.self)
    let presetCategories = PresetCategory.objectsInContext(context) as! [PresetCategory]
    expect(presetCategories.count).to(equal(7))
  }

  func testLoadRemotesFromFile() {
    expectFileLoad("Remote_Demo", type: Remote.self)
    let remotes = Remote.objectsInContext(context) as! [Remote]
    expect(remotes.count).to(equal(2))
  }

  func testLoadActivityControllerFromFile() {
    expectFileLoad("ActivityController", type: ActivityController.self)
    let activityController = ActivityController.objectsInContext(context) as! [ActivityController]
    expect(activityController.count).to(equal(1))
  }

  func testLoadAllFiles() {
    expectFileLoad("Manufacturer_Test", type: Manufacturer.self)
    expectFileLoad("ComponentDevice", type: ComponentDevice.self)
    expectFileLoad("Glyphish", type: ImageCategory.self)
    expectFileLoad("NetworkDevice", type: NetworkDevice.self)
    expectFileLoad("Activity", type: Activity.self)
    expectFileLoad("Preset", type: PresetCategory.self)
    expectFileLoad("Remote_Demo", type: Remote.self)
    expectFileLoad("ActivityController", type: ActivityController.self)
    DataManager.dumpJSONForModelType(Manufacturer.self, context: context)
    DataManager.dumpJSONForModelType(ComponentDevice.self, context: context)
    DataManager.dumpJSONForModelType(ImageCategory.self, context: context)
    DataManager.dumpJSONForModelType(NetworkDevice.self, context: context)
    DataManager.dumpJSONForModelType(Activity.self, context: context)
    DataManager.dumpJSONForModelType(PresetCategory.self, context: context)
    DataManager.dumpJSONForModelType(Remote.self, context: context)
    DataManager.dumpJSONForModelType(ActivityController.self, context: context)
  }
}
