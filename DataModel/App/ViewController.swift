//
//  ViewController.swift
//  DataModelApp
//
//  Created by Jason Cardwell on 3/28/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import MoonKit
import DataModel

class ViewController: UIViewController {

  override func viewDidLoad() {
    @IBOutlet weak var uniqueIdentifier: UILabel!
    @IBOutlet weak var contentView: UIView!
    super.viewDidLoad()
    [queryTextView, resultsTextView, errorsTextView] ➤ {$0.layer.borderWidth = 1.0}
  }
  @IBOutlet weak var entityButton: UIButton!
  @IBAction func toggleEntityPicker() {
    entityPicker.hidden = !entityPicker.hidden
    entityPicker ➤ (entityPicker.hidden ? {$0.resignFirstResponder()} : {$0.becomeFirstResponder()})
    if entityPicker.hidden == false { entityPicker.becomeFirstResponder() }
  }

  @IBOutlet weak var entityPicker: UIPickerView!
  lazy var entities: [NSEntityDescription] = {
    return sorted(DataManager.managedObjectModel.entities as! [NSEntityDescription], {$0.name! < $1.name!})
  }()

  var selectedEntity: NSEntityDescription? {
    didSet { entityButton.setTitle(selectedEntity?.name! ?? "Select Entity", forState: .Normal) }
  }

  var selectedModelObjectType: ModelObject.Type? {
    if let entityClassName = selectedEntity?.managedObjectClassName,
      modelObjectClass = NSClassFromString(entityClassName) as? ModelObject.Type { return modelObjectClass }
    else { return nil }
  }

  @IBAction func dumpJSON() {
    if let type = selectedModelObjectType {
      var error: NSError?
      let query = queryTextView.text
      println("dumping json for query '\(query)' …")
      let results = type.objectsMatchingPredicate(∀query, context: context, error: &error)
      MSHandleError(error)
      if let json = JSONValue(results) { println(json.prettyRawValue) }
      else { MSLogError("failed to generate json value") }
    }
  }

  @IBOutlet weak var queryTextView: UITextView!
  @IBOutlet weak var resultsTextView: UITextView!
  @IBOutlet weak var errorsTextView: UITextView!
  @IBAction func selectPane(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: errorsTextView.hidden = true; resultsTextView.hidden = false
    default: errorsTextView.hidden = false; resultsTextView.hidden = true
    }
  }
  let context: NSManagedObjectContext = DataManager.mainContext()

  func processQuery(query: String) {
    if let type = selectedModelObjectType {
      var error: NSError?
      let results = type.objectsMatchingPredicate(∀query, context: context, error: &error)
      resultsTextView.text = resultsTextView.text == "No results" ? "" : "\(resultsTextView.text)\n"
      let i = resultsTextView.text.length
      let resultsText = "query: \(query)\nresults…\n" + "\n\n".join(enumeratingMap(results, {"\($0): \($1)"}))
      resultsTextView.text = "\(resultsTextView.text)\(resultsText)"
      resultsTextView.scrollRangeToVisible(NSRange(i...i+50))
      println(resultsText)
      if error != nil {
        errorsTextView.text = errorsTextView.text == "No errors" ? "" : "\(errorsTextView.text)\n"
        let errorText = detailedDescriptionForError(error!, depth: 0)
        errorsTextView.text = "\(errorsTextView.text)\(errorText)"
        println("error…\n\(errorText)")
      }
    }
  }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return entities.count + 1 }
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return row == 0 ? "Select Entity" : entities[row - 1].name
  }
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedEntity = row == 0 ? nil : entities[row - 1]
  }
}

extension ViewController: UITextViewDelegate {
  func textViewDidEndEditing(textView: UITextView) { if let text = textView.text { processQuery(text) } }
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if Array(text ?? "") ∋ Character("\n") { textView.resignFirstResponder(); return false } else { return true }
  }
}