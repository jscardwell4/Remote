//
//  LearnerAppViewController.swift
//  LearnerApp
//
//  Created by Jason Cardwell on 5/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import class DataModel.ITachDevice
import class DataModel.DataManager
import class DataModel.Manufacturer
import class DataModel.IRCodeSet
import class DataModel.IRCode
import Networking
import Elysio
import Chameleon

class LearnerAppViewController: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource {

  var device: ITachDevice? {
    didSet {
      if let device = self.device {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: ConnectionManager.NetworkDeviceDiscoveryNotification,
                                                            object: ConnectionManager.self)
        uniqueIdentifier.text = device.uniqueIdentifier
        configURL.text = device.configURL
        make.text = device.make
        model.text = device.model
        pcbPN.text = device.pcbPN
        pkgLVL.text = device.pkgLevel
        revision.text = device.revision
        sdkClass.text = device.sdkClass
        status.text = device.status
        if learnerDelegate.connectToDevice(device) {
          learnerDelegate.enableLearner { [unowned self]
            success, _ in dispatchToMain() {[unowned self] in self.learnerEnabled.on = success }
          }
        }
      }
    }
  }

  let context = DataManager.mainContext()

  lazy var manufacturers: [Manufacturer] = {
    return Manufacturer.objectsInContext(self.context, sortBy: "name", ascending: true) as! [Manufacturer]
    }()

  var manufacturer: Manufacturer? {
    didSet {
      if let m = manufacturer where manufacturers ∌ m {
        manufacturers.append(m)
        sortByName(&manufacturers)
        manufacturerPicker.reloadData()
        if let idx = find(manufacturers, m) {
          manufacturerPicker.selectItem(idx, animated: true)
        }
      }
      codeSetPicker.reloadData()
    }
  }
  var codeSets: [IRCodeSet]  { return sortedByName(manufacturer?.codeSets ?? []) }

  var codeSet: IRCodeSet? {
    didSet {
      if let c = codeSet {
        assert(manufacturer != nil && manufacturer! === c.manufacturer)
        let idx = find(codeSets, c)
        assert(idx != nil)
        codeSetPicker.selectItem(idx!, animated: true)
      }
      codeSetPicker.reloadData()
    }
  }

  var learnerDelegate: ITachLearnerDelegate = ITachLearnerDelegate()

  @IBOutlet weak var uniqueIdentifier: UILabel!
  @IBOutlet weak var configURL: UILabel!
  @IBOutlet weak var make: UILabel!
  @IBOutlet weak var model: UILabel!
  @IBOutlet weak var pcbPN: UILabel!
  @IBOutlet weak var pkgLVL: UILabel!
  @IBOutlet weak var revision: UILabel!
  @IBOutlet weak var sdkClass: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var learnerEnabled: UISwitch!
  @IBOutlet weak var lastCapturedCommand: UILabel!
  @IBOutlet weak var manufacturerPicker: AKPickerView!
  @IBOutlet weak var codeSetPicker: AKPickerView!

  func setup() {
    learnerDelegate.didCaptureCommand = { [unowned self]
      string in
      NSOperationQueue.mainQueue().addOperationWithBlock { [unowned self] in
        self.lastCapturedCommand.text = string
      }
    }

    NSNotificationCenter.defaultCenter().addObserverForName(ConnectionManager.NetworkDeviceDiscoveryNotification,
      object: ConnectionManager.self, queue: NSOperationQueue.mainQueue()) { [unowned self]
        note in
        if let uuid = note.userInfo?[ConnectionManager.NetworkDeviceKey] as? String,
          device = ITachDevice.objectWithUUID(uuid, context: self.context)
        {
          self.device = device
        }
    }
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }

  @IBAction func switchValueDidChange(sender: UISwitch) {
    if sender.on {
      learnerDelegate.enableLearner { [unowned self]
        success, _ in dispatchToMain() {[unowned self] in self.learnerEnabled.on = success }
      }
    } else {
      learnerDelegate.disableLearner { [unowned self]
        success, _ in dispatchToMain() {[unowned self] in self.learnerEnabled.on = !success }
      }
    }

  }

  private func presentFormViewController(formViewController: FormViewController) {
    formViewController.labelFont = Elysio.regularFontWithSize(16)
    formViewController.labelTextColor = UIColor(white: 0.2, alpha: 1.0)
    formViewController.controlFont = Elysio.regularItalicFontWithSize(16)
    formViewController.controlTextColor = UIColor(white: 0.49019608, alpha: 1.0)
    formViewController.controlSelectedFont = Elysio.boldItalicFontWithSize(16.0)

    presentViewController(formViewController, animated: true, completion: nil)
  }

  @IBAction func createNewManufacturer() {
    let nameValidation: (String?) -> Bool = {
      $0 != nil && !$0!.isEmpty && Manufacturer.objectWithValue($0!, forAttribute: "name", context: self.context) == nil
    }
    let placeholderText = "The manufacturer's name"
    let didCancel: () -> Void = {[unowned self] in self.dismissViewControllerAnimated(true, completion: nil) }
    let didSubmit: (OrderedDictionary<String,Any>) -> Void = {[unowned self] values in
      assert(NSThread.isMainThread())
      if let name = values["Name"] as? String {
        let manufacturer = Manufacturer(context: self.context)
        manufacturer.name = name
        self.manufacturer = manufacturer
      } else {
        assert(false)
      }
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    let nameField = FormViewController.Field.Text(initial: nil, placeholder: placeholderText, validation: nameValidation)
    let fields: OrderedDictionary<String, FormViewController.Field> = ["Name": nameField]
    presentFormViewController(FormViewController(fields: fields, didCancel: didCancel, didSubmit: didSubmit))
  }

  
  @IBAction func createNewCodeSet() {
    if let manufacturer = self.manufacturer {
      let nameValidation: (String?) -> Bool = {
        n in n != nil && !n!.isEmpty && !contains(manufacturer.codeSets, {$0.name == n!})
      }
      let placeholderText = "The code set's name"
      let didCancel: () -> Void = {[unowned self] in self.dismissViewControllerAnimated(true, completion: nil) }
      let didSubmit: (OrderedDictionary<String,Any>) -> Void = {[unowned self] values in
        assert(NSThread.isMainThread())
        if let name = values["Name"] as? String {
          let codeSet = IRCodeSet(context: self.context)
          codeSet.name = name
          codeSet.manufacturer = manufacturer
          self.codeSet = codeSet
        } else {
          assert(false)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
      }

      let nameField: FormViewController.Field = .Text(initial: nil, placeholder: placeholderText, validation: nameValidation)
      let fields: OrderedDictionary<String, FormViewController.Field> = ["Name": nameField]
      presentFormViewController(FormViewController(fields: fields, didCancel: didCancel, didSubmit: didSubmit))
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let bgColor = Chameleon.flatWhite
    let analogousColors = Chameleon.colorsForScheme(.Analogous, with: bgColor, flat: true)
    let gradientColor = Chameleon.gradientWithStyle(.Radial, withFrame: view.bounds, andColors: analogousColors)
    view.backgroundColor = gradientColor

    if let m = manufacturers.first {
      manufacturer = m
      if codeSets.count > 0 { codeSet = codeSets[0] }
    }
    let decoratePicker: (AKPickerView)-> Void = { [unowned self]
      picker in
      picker.interitemSpacing = 20.0
      picker.delegate = self
      picker.dataSource = self
      picker.font = Elysio.regularItalicFontWithSize(16.0)
      picker.textColor = UIColor(white: 0.49, alpha: 1.0)
      picker.highlightedFont = picker.font
      picker.highlightedTextColor = picker.textColor
    }
    apply([manufacturerPicker, codeSetPicker], decoratePicker)
  }

  override func prefersStatusBarHidden() -> Bool { return true }

  func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
    if pickerView === manufacturerPicker { return manufacturers.count }
    else { return codeSets.count }
  }

  func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
    if item == -1 { return "wtf" }
    if pickerView === manufacturerPicker { return item < manufacturers.count ? manufacturers[item].name : "" }
    else { return item < codeSets.count ? codeSets[item].name : "" }
  }

  func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
    if pickerView === manufacturerPicker { manufacturer = manufacturers[item] } else { codeSet = codeSets[item] }
  }

}

