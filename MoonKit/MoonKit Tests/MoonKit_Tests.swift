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

  func testJSONType() {
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

    let stringJSONString = stringJSON.stringValue
    XCTAssertEqual(stringJSONString, "\"I am a string\"", "unexpected stringValue")
    let boolJSONString = boolJSON.stringValue
    XCTAssertEqual(boolJSONString, "true", "unexpected stringValue")
    let numberJSONString = numberJSON.stringValue
    XCTAssertEqual(numberJSONString, "1", "unexpected stringValue")
    let arrayJSONString = arrayJSON.stringValue
    XCTAssertEqual(arrayJSONString, "[\"item1\",\"item2\"]", "unexpected stringValue")
    let objectJSONString = objectJSON.stringValue
    XCTAssertEqual(objectJSONString, "{\"key1\":\"value1\",\"key2\":\"value2\"}", "unexpected stringValue")

  }

//  func testJSONSerialization() {
//    let filePath = self.dynamicType.filePaths[0]
//    println(filePath)
//  }

}
