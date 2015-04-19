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

private var _existingFiles: [String] = []
private let _importExportQueue = dispatch_queue_create("com.moondeerstudios.import-export",
                                                      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                                                                                                QOS_CLASS_BACKGROUND,
                                                                                                -1))
private let _textColor = UIColor(RGBAHexString:"#9FA0A4FF")
private let _invalidTextColor = UIColor(name: "fire-brick")

private var nameValidator: ImportExportFileManager.FileNameValidator?

class ImportExportFileManager {

  /** refreshExistingFiles */
  class func refreshExistingFiles() {
    dispatch_async(_importExportQueue) {
      _existingFiles = MoonFunctions.documentsDirectoryContents().filter{$0.hasSuffix(".json")}.map{$0[0..<($0.length - 5)]}
    }
  }

  class var existingFiles: [String] { return _existingFiles }

  private class FileNameValidator: NSObject, UITextFieldDelegate {

    weak var exportAlertAction: UIAlertAction?

    /**
    init:

    :param: exportAlertAction UIAlertAction
    */
    init(_ exportAlertAction: UIAlertAction) { super.init(); self.exportAlertAction = exportAlertAction }

    /**
    textFieldShouldEndEditing:

    :param: textField UITextField

    :returns: Bool
    */
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
      if _existingFiles ∋ textField.text {
        textField.textColor = _invalidTextColor
        return false
      }
      return true
    }

    /**
    textField:shouldChangeCharactersInRange:replacementString:

    :param: textField UITextField
    :param: range NSRange
    :param: string String

    :returns: Bool
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String)
      -> Bool
    {
      let text = (range.length == 0
        ? textField.text + string
        : (textField.text as NSString).stringByReplacingCharactersInRange(range, withString:string))
      let nameInvalid = _existingFiles ∋ text
      textField.textColor = nameInvalid ? _invalidTextColor : _textColor
      exportAlertAction?.enabled = !nameInvalid
      return true
    }

    /**
    textFieldShouldReturn:

    :param: textField UITextField

    :returns: Bool
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool { return false }

    /**
    textFieldShouldClear:

    :param: textField UITextField

    :returns: Bool
    */
    func textFieldShouldClear(textField: UITextField) -> Bool { return true }
  }

  /**
  confirmExportOfItems:

  :param: items [MSJSONExport]
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
      precondition(text.length > 0 && text ∉ _existingFiles, "text field should not be empty or match an existing file")
      self.exportItems(items, toFile: MoonFunctions.documentsPathToFile(text + ".json")!)
      completion?(true)
      alert.dismissViewControllerAnimated(true, completion: nil)
    }


    nameValidator = FileNameValidator(exportAlertAction)

    // Add the text field
    alert.addTextFieldWithConfigurationHandler{
      $0.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      $0.textColor = _textColor
      $0.delegate = nameValidator
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

  :param: items [MSJSONExport]
  :param: file String
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

  :param: named String

  :returns: NSURL
  */
  class func urlForFile(named: String) -> NSURL? {
    if let filePath = MoonFunctions.documentsPathToFile("\(named).json") {
      return NSURL(fileURLWithPath: filePath)
    } else {
      return nil
    }
  }

}