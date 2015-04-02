//
//  MoonKit_Tests.swift
//  MoonKit Tests
//
//  Created by Jason Cardwell on 4/2/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//
import Foundation
import UIKit
import XCTest
import MoonKit

class MoonKit_Tests: XCTestCase {

  static let filePaths: [String] = {
    var filePaths: [String] = []
    if let bundlePath = NSUserDefaults.standardUserDefaults().stringForKey("XCTestedBundlePath"),
      let bundle = NSBundle(path: bundlePath),
      let example1JSONFilePath = bundle.pathForResource("example1", ofType: "json")
    {
      filePaths.append(example1JSONFilePath)
    }
    return filePaths
  }()

  func testJSONTypeSimple() {
    let string = "I am a string"
    let bool = true
    let number = 1
    let array = ["item1", "item2"]
    let object = ["key1": "value1", "key2": "value2"]

    let stringJSON = toJSONValue(string)
    switch stringJSON { case .Text: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Text'") }

    let boolJSON = toJSONValue(bool)
    switch boolJSON { case .Boolean: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Boolean'") }

    let numberJSON = toJSONValue(number)
    switch numberJSON { case .Number: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Number'") }

    let arrayJSON = toJSONValue(array)
    switch arrayJSON { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array'") }

    let objectJSON = toJSONValue(object)
    switch objectJSON { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object'") }

    XCTAssertEqual(stringJSON.stringValue, "\"I am a string\"", "unexpected stringValue")
    XCTAssertEqual(boolJSON.stringValue, "true", "unexpected stringValue")
    XCTAssertEqual(numberJSON.stringValue, "1", "unexpected stringValue")
    XCTAssertEqual(arrayJSON.stringValue, "[\"item1\",\"item2\"]", "unexpected stringValue")
    XCTAssertEqual(objectJSON.stringValue, "{\"key1\":\"value1\",\"key2\":\"value2\"}", "unexpected stringValue")
  }

  func testJSONTypeComplex() {
    let array1 = ["item1", 2]
    let array2 = ["item1", "item2", "item3"]
    let array = [array1, array2, "item3", 4]
    let dict1 = ["key1": "value1", "key2": 2]
    let dict2 = ["key1": "value1", "key2": "value2"]
    let dict = ["key1": dict1, "key2": dict2, "key3": "value3"]
    let composite1 = [1, "two", array, dict]
    let composite2 = ["key1": 1, "key2": array, "key3": dict, "key4": "value4"]

    let array1JSON = toJSONValue(array1)
    switch array1JSON { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}

    let array2JSON = toJSONValue(array2)
    switch array2JSON { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}

    let arrayJSON = toJSONValue(array)
    switch arrayJSON { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}

    let dict1JSON = toJSONValue(dict1)
    switch dict1JSON { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}

    let dict2JSON = toJSONValue(dict2)
    switch dict2JSON { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}

    let dictJSON = toJSONValue(dict)
    switch dictJSON { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}

    let composite1JSON = toJSONValue(composite1)
    switch composite1JSON { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}

    let composite2JSON = toJSONValue(composite2)
    switch composite2JSON { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}

    let array1String = "[\"item1\",2]"
    let array2String = "[\"item1\",\"item2\",\"item3\"]"
    let arrayString = "[\(array1String),\(array2String),\"item3\",4]"
    let dict1String = "{\"key1\":\"value1\",\"key2\":2}"
    let dict2String = "{\"key1\":\"value1\",\"key2\":\"value2\"}"
    let dictString = "{\"key1\":\(dict1String),\"key2\":\(dict2String),\"key3\":\"value3\"}"
    let composite1String = "[1,\"two\",\(arrayString),\(dictString)]"
    let composite2String = "{\"key1\":1,\"key4\":\"value4\",\"key2\":\(arrayString),\"key3\":\(dictString)}"

    XCTAssertEqual(array1JSON.stringValue, array1String)
    XCTAssertEqual(array2JSON.stringValue, array2String)
    XCTAssertEqual(arrayJSON.stringValue, arrayString)
    XCTAssertEqual(dict1JSON.stringValue, dict1String)
    XCTAssertEqual(dict2JSON.stringValue, dict2String)
    XCTAssertEqual(dictJSON.stringValue, dictString)
    XCTAssertEqual(composite1JSON.stringValue, composite1String)
    XCTAssertEqual(composite2JSON.stringValue, composite2String)
  }
//  func testJSONSerialization() {
//    let filePath = self.dynamicType.filePaths[0]
//    println(filePath)
//  }

}
