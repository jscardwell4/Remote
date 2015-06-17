//
//  ImportExportFileManager.swift
//  Remote
//
//  Created by Jason Cardwell on 10/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit


final class ImportExportFileManager {

  private static var existingFiles: [String] = []
  private static let importExportQueue = dispatch_queue_create("com.moondeerstudios.import-export",
    dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
      QOS_CLASS_BACKGROUND,
      -1))

  private static var nameValidator: ImportExportFileManager.FileNameValidator?
  private static let textColor = UIColor(RGBAHexString:"#9FA0A4FF")
  private static let invalidTextColor = UIColor(name: "fire-brick")


  /** refreshExistingFiles */
  class func refreshExistingFiles() {
    dispatch_async(importExportQueue) {
      self.existingFiles = MoonFunctions.documentsDirectoryContents().filter{$0.hasSuffix(".json")}.map{$0[0..<($0.length - 5)]}
    }
  }

  private class FileNameValidator: NSObject, UITextFieldDelegate {

    weak var exportAlertAction: UIAlertAction?

    /**
    init:

    - parameter exportAlertAction: UIAlertAction
    */
    init(_ exportAlertAction: UIAlertAction) { super.init(); self.exportAlertAction = exportAlertAction }

    /**
    textFieldShouldEndEditing:

    - parameter textField: UITextField

    - returns: Bool
    */
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
      if ImportExportFileManager.existingFiles ∋ textField.text {
        textField.textColor = ImportExportFileManager.invalidTextColor
        return false
      }
      return true
    }

    /**
    textField:shouldChangeCharactersInRange:replacementString:

    - parameter textField: UITextField
    - parameter range: NSRange
    - parameter string: String

    - returns: Bool
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String)
      -> Bool
    {
      let text = (range.length == 0
        ? textField.text + string
        : (textField.text as NSString).stringByReplacingCharactersInRange(range, withString:string))
      let nameInvalid = ImportExportFileManager.existingFiles ∋ text
      textField.textColor = nameInvalid ? ImportExportFileManager.invalidTextColor : ImportExportFileManager.textColor
      exportAlertAction?.enabled = !nameInvalid
      return true
    }

    /**
    textFieldShouldReturn:

    - parameter textField: UITextField

    - returns: Bool
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool { return false }

    /**
    textFieldShouldClear:

    - parameter textField: UITextField

    - returns: Bool
    */
    func textFieldShouldClear(textField: UITextField) -> Bool { return true }
  }

  /**
  confirmExportOfItems:

  - parameter items: [MSJSONExport]
  */
  class func confirmExportOfItems(items: [JSONValueConvertible], completion: ((Bool) -> Void)? = nil) {

    refreshExistingFiles()

    // Create the controller with export title and filename message
    let alert = UIAlertController(title:          "Export Selection",
                                  message:        "Enter a name for the exported file",
                                  preferredStyle: .Alert)


    // Create the export action
    let exportAlertAction = UIAlertAction(title: "Export", style: .Default){
      (action: UIAlertAction!) -> Void in
      let text = (alert.textFields as! [UITextField])[0].text
      precondition(text.length > 0 && text ∉ ImportExportFileManager.existingFiles, "text field should not be empty or match an existing file")
      self.exportItems(items, toFile: MoonFunctions.documentsPathToFile(text + ".json")!)
      completion?(true)
      alert.dismissViewControllerAnimated(true, completion: nil)
    }


    nameValidator = FileNameValidator(exportAlertAction)

    // Add the text field
    alert.addTextFieldWithConfigurationHandler{
      $0.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      $0.textColor = ImportExportFileManager.textColor
      $0.delegate = ImportExportFileManager.nameValidator
    }

    // Add the cancel button
    alert.addAction(
      UIAlertAction(title: "Cancel", style: .Cancel) {
        (action: UIAlertAction!) -> Void in
          completion?(false)
          alert.dismissViewControllerAnimated(true, completion: nil)
      })

    alert.addAction(exportAlertAction)  // Add the action to the controller

    UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(alert,
                                                                                          animated: true,
                                                                                        completion: nil)

  }

  /**
  exportItems:toFile:

  - parameter items: [MSJSONExport]
  - parameter file: String
  */
  class func exportItems(items: [JSONValueConvertible], toFile file: String) {
    let jsonString: String?
    switch items.count {
      case 0:  jsonString = nil
      case 1:  jsonString = items.first?.jsonValue.prettyRawValue
      default: jsonString = JSONValue(items)?.prettyRawValue
    }
    jsonString?.writeToFile(file)
  }

  /**
  urlForFile:

  - parameter named: String

  - returns: NSURL
  */
  class func urlForFile(named: String) -> NSURL? {
    if let filePath = MoonFunctions.documentsPathToFile("\(named).json") {
      return NSURL(fileURLWithPath: filePath)
    } else {
      return nil
    }
  }

}