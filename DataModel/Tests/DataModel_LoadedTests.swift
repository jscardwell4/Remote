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
  static var dataLoaded = false

  override func spec() {
    beforeSuite {
      let loadInfo: [(String,ModelObject.Type)] =  [("Manufacturer_Test", Manufacturer.self),
                                                    ("ComponentDevice", ComponentDevice.self),
                                                    ("Glyphish", ImageCategory.self),
                                                    ("Activity", Activity.self),
                                                    ("NetworkDevice", NetworkDevice.self),
                                                    ("ActivityController", ActivityController.self),
                                                    ("Preset", Preset.self),
                                                    ("Remote_Demo", Remote.self)]
      for (file, type) in loadInfo {
        DataManager.loadDataFromFile(file,
                                type: type,
                             context: self.dynamicType.context)
      }
      self.dynamicType.dataLoaded = true
    }

    describe("the manufacturers") {
      describe("the Dish manufacturer") {
        var pending = false
        var manufacturer: Manufacturer?
        it("can be retrieved by index") {
          manufacturer = Manufacturer.objectWithIndex(PathIndex("Dish")!, context: self.dynamicType.context)
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
            code = IRCode.objectWithIndex(PathIndex("Dish/Dish/Favorites")!, context: self.dynamicType.context)
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
      xdescribe("the Sony manufacturer") {}
      xdescribe("the samsung manufacturer") {}
    }

    xdescribe("the component devices") {

    }

    xdescribe("the image categories") {

    }

    xdescribe("the activities") {

    }

    xdescribe("the newtork devices") {

    }

    xdescribe("the activity controller") {

    }

    xdescribe("the presets") {

    }

    xdescribe("the remotes") {
      
    }

  }

}
