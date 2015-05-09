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
import Networking
import class Bank.Bank

class LearnerAppViewController: UIViewController, MSPickerInputButtonDelegate {

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
        ConnectionManager.connectToITachDevice(device, learnerDelegate: learnerDelegate)
        learnerDelegate.enableLearner { [unowned self]
          success, _ in dispatchToMain() {[unowned self] in self.learnerEnabled.on = success }
        }
      }
    }
  }

  let context = DataManager.mainContext()

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
  @IBOutlet weak var manufacturer: MSPickerInputButton!
  @IBOutlet weak var codeSet: MSPickerInputButton!

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

  override func viewDidLoad() {
    super.viewDidLoad()
    manufacturer.setTitle("Manufacturer", forState: .Normal)
    manufacturer.titleLabel.font = Bank.actionFont
    manufacturer.titleLabel.textColor = UIColor(white: 0.49, alpha: 1.0)
    codeSet.setTitle("Code Set", forState: .Normal)
    codeSet.titleLabel.font = Bank.actionFont
    codeSet.titleLabel.textColor = UIColor(white: 0.49, alpha: 1.0)
  }

  override func prefersStatusBarHidden() -> Bool { return true }

  func pickerInput(pickerInput: MSPickerInputView!, didSelectRow row: Int, inComponent component: Int) {

  }

  func pickerInput(pickerInput: MSPickerInputView!, selectedRows: [AnyObject]!) {

  }

  func pickerInputDidCancel(pickerInput: MSPickerInputView!) {

  }

  func numberOfComponentsInPickerInput(pickerInput: MSPickerInputView!) -> Int { return 0 }

  func pickerInput(pickerInput: MSPickerInputView!, numberOfRowsInComponent component: Int) -> Int { return 0 }
}

