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

  func testJSONValueTypeSimple() {
    let string = "I am a string"
    let bool = true
    let number = 1
    let array = ["item1", "item2"]
    let object = ["key1": "value1", "key2": "value2"]

    let stringJSON = JSONValue(string)
    switch stringJSON { case .String: break; default: XCTFail("unexpected enumeration value, expected 'JSON.String'") }
    XCTAssertEqual(stringJSON.stringValue, "\"I am a string\"", "unexpected stringValue")

    let boolJSON = JSONValue(bool)
    switch boolJSON { case .Boolean: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Boolean'") }
    XCTAssertEqual(boolJSON.stringValue, "true", "unexpected stringValue")

    let numberJSON = JSONValue(number)
    switch numberJSON { case .Number: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Number'") }
    XCTAssertEqual(numberJSON.stringValue, "1", "unexpected stringValue")

    let arrayJSON = JSONValue(array)
    if arrayJSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch arrayJSON! { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array'") }
      XCTAssertEqual(arrayJSON!.stringValue, "[\"item1\",\"item2\"]", "unexpected stringValue")
    }

    let objectJSON = JSONValue(object)
    if objectJSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch objectJSON! { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object'") }
      XCTAssertEqual(objectJSON!.stringValue, "{\"key1\":\"value1\",\"key2\":\"value2\"}", "unexpected stringValue")
    }

  }

  func testJSONValueTypeComplex() {
    let array1 = ["item1", 2]
    let array1String = "[\"item1\",2]"
    let array2 = ["item1", "item2", "item3"]
    let array2String = "[\"item1\",\"item2\",\"item3\"]"
    let array = [array1, array2, "item3", 4]
    let arrayString = "[\(array1String),\(array2String),\"item3\",4]"
    let dict1 = ["key1": "value1", "key2": 2]
    let dict1String = "{\"key1\":\"value1\",\"key2\":2}"
    let dict2 = ["key1": "value1", "key2": "value2"]
    let dict2String = "{\"key1\":\"value1\",\"key2\":\"value2\"}"
    let dict = ["key1": dict1, "key2": dict2, "key3": "value3"]
    let dictString = "{\"key1\":\(dict1String),\"key2\":\(dict2String),\"key3\":\"value3\"}"
    let composite1 = [1, "two", array, dict]
    let composite1String = "[1,\"two\",\(arrayString),\(dictString)]"
    let composite2 = ["key1": 1, "key2": array, "key3": dict, "key4": "value4"]
    let composite2String = "{\"key1\":1,\"key4\":\"value4\",\"key2\":\(arrayString),\"key3\":\(dictString)}"

    let array1JSON = JSONValue(array1)
    if array1JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch array1JSON! { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}
      XCTAssertEqual(array1JSON!.stringValue, array1String)
    }
    let array2JSON = JSONValue(array2)
    if array2JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch array2JSON! { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}
      XCTAssertEqual(array2JSON!.stringValue, array2String)
    }
    let arrayJSON = JSONValue(array)
    if arrayJSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch arrayJSON! { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}
      XCTAssertEqual(arrayJSON!.stringValue, arrayString)
    }
    let dict1JSON = JSONValue(dict1)
    if dict1JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch dict1JSON! { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}
      XCTAssertEqual(dict1JSON!.stringValue, dict1String)
    }
    let dict2JSON = JSONValue(dict2)
    if dict2JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch dict2JSON! { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}
      XCTAssertEqual(dict2JSON!.stringValue, dict2String)
    }
    let dictJSON = JSONValue(dict)
    if dictJSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch dictJSON! { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}
      XCTAssertEqual(dictJSON!.stringValue, dictString)
    }
    let composite1JSON = JSONValue(composite1)
    if composite1JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch composite1JSON! { case .Array: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Array")}
      XCTAssertEqual(composite1JSON!.stringValue, composite1String)
    }
    let composite2JSON = JSONValue(composite2)
    if composite2JSON == nil { XCTFail("unexpected nil value when converting to `JSONValue` type")}
    else {
      switch composite2JSON! { case .Object: break; default: XCTFail("unexpected enumeration value, expected 'JSON.Object")}
      XCTAssertEqual(composite2JSON!.stringValue, composite2String)
    }

  }

  func testJSONSerialization() {
    let filePath = self.dynamicType.filePaths[0]
    var error: NSError?
    if let object: AnyObject = JSONSerialization.objectByParsingFile(filePath, error: &error)
      where !MSHandleError(error, message: "trouble parsing file '\(filePath)'")
    {
      let jsonObject = JSONValue(object)
      println(jsonObject)

    } else { XCTFail("file parse failed to create an object") }

  }

}
