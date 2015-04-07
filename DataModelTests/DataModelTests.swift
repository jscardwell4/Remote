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

class DataModelTests: XCTestCase {

  static let context = DataManager.rootContext

  override class func initialize() {
    if self === DataModelTests.self {
      MSLog.addTaggingASLLogger()
      MSLog.addTaggingTTYLogger()
    }
  }

  func testLoadManufacturersFromFile() {
    let moc = self.dynamicType.context
    let expectation = expectationWithDescription("load manufacturers")
    DataManager.loadDataFromFile("Manufacturer_Test",
                            type: Manufacturer.self,
                         context: moc,
                      completion: {(success: Bool, error: NSError?) -> Void in
                        XCTAssertTrue(success, "loading data from file triggered an error")
                        DataManager.saveRootContext(completion: { (success: Bool, error: NSError?) -> Void in
                          XCTAssertTrue(success, "saving context triggered an error")
                          expectation.fulfill()
                        })
                      })
    waitForExpectationsWithTimeout(10, handler: {(error: NSError?) -> Void in _ = MSHandleError(error)})
    let manufacturers = Manufacturer.objectsInContext(moc) as! [Manufacturer]
    XCTAssertTrue(manufacturers.count > 0, "where are the manufacturer objects?")
    XCTAssertEqual(manufacturers[0].name, "Dish", "unexpected name")
    let codeSets = manufacturers[0].codeSets
    XCTAssertEqual(codeSets.count, 1, "where is the code set?")
    let codeSet = IRCodeSet.objectMatchingPredicate(∀"manufacturer.name == 'Dish'", context: moc)
    XCTAssertNotNil(codeSet, "where is the code set?")
    if codeSet != nil {
      XCTAssertEqual(codeSet!.codes.count, 47, "unexpected count for code set's codes array")
    }
  }

  func testDictionaryStorage() {
    let moc = self.dynamicType.context
    let storage = DictionaryStorage(context: moc)
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
    let moc = self.dynamicType.context
    let storage = JSONStorage(context: moc)
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
}
