//
//  DataModelTests.swift
//  DataModelTests
//
//  Created by Jason Cardwell on 4/5/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import XCTest
import DataModel
import MoonKit

class DataModelTests: XCTestCase {

  static let context = DataManager.rootContext

  override class func initialize() {
    if self === DataModelTests.self {
      MSLog.addTaggingASLLogger()
      MSLog.addTaggingTTYLogger()
      NSLog("loggers should have been added")
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

}
