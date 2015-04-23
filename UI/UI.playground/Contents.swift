//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import CoreData

LogManager.addTTYLogger()
MSLogDebug("logger added")

import DataModel

let mom = DataManager.managedObjectModel
let stack = CoreDataStack(managedObjectModel: mom, persistentStoreURL: nil, options: nil)
let context = stack?.mainContext()
let jsonPath = NSBundle.mainBundle().pathForResource("Preset_Button_Roundish", ofType: "json")
var error: NSError?
let options = JSONSerialization.ReadOptions.InflateKeypaths|JSONSerialization.ReadOptions.IgnoreExcess
let presetJSON = JSONSerialization.objectByParsingFile(jsonPath!, options: options, error: &error)
MSHandleError(error, message: "what happened?")
println(toString(presetJSON?.prettyRawValue))
let preset = Preset(data: ObjectJSONValue(presetJSON)!, context: context!)
