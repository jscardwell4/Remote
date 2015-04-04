// Playground - noun: a place where people can play
import Foundation
import UIKit

public func inflate(inout dict: [String:AnyObject]) {
  // First gather a list of keys to inflate
  let inflatableKeys = Array(dict.keys.filter({$0 ~= "(?:\\w\\.)+\\w"}))

  // Enumerate the list inflating each key
  for key in inflatableKeys {

    var keypath = split(key, ".")
    let first = keypath.popFirst()!          // This will become our key
    let last = keypath.popLast()!            // This will become the deepest key in our value



    let value: AnyObject

    // If our value is an array, we embed each value in the array and keep our value as an array
    if let valueArray = dict[key] as? [AnyObject] {

      value = valueArray.map {
        (obj: AnyObject) -> [String:AnyObject] in

        var dict: [String:AnyObject] = [:]  // Create a dictionary within which to embed our value
        var subdict = dict         // This will reference the dictionary to which our value entered

        // If there are stops along the way from first to last, recursively embed in dictionaries
        if !keypath.isEmpty {
          for subkey in keypath {
            subdict[subkey] = [String:AnyObject]()
            var subsubdict = subdict[subkey] as! [String:AnyObject]
            subdict = subsubdict
          }
        }

        subdict[last] = obj
        return dict

      }

    }

      // Otherwise we embed the value
    else {

      var dict: [String:AnyObject] = [:]  // Create a dictionary within which to embed our value
      var subdict = dict         // This will reference the dictionary to which our value entered

      // If there are stops along the way from first to last, recursively embed in dictionaries
      if !keypath.isEmpty {
        for subkey in keypath {
          subdict[subkey] = [String:AnyObject]()
          var subsubdict = subdict[subkey] as! [String:AnyObject]
          subdict = subsubdict
        }
      }

      subdict[last] = dict[key]
      value = dict

    }

    dict[key] = value                              // Remove the compressed key-value entry
  }
}