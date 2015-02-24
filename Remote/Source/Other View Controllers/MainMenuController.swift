//
//  MainMenuController.swift
//  Remote
//
//  Created by Jason Cardwell on 2/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class MainMenuController: UIViewController {

  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var remoteButton: UIButton!
  @IBOutlet weak var editorButton: UIButton!
  @IBOutlet weak var bankButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var helpButton: UIButton!
  @IBOutlet weak var spinner: UIActivityIndicatorView!

  private var spinning: Bool = false {
    didSet {
      if spinning { startSpinner() }
      else { stopSpinner() }
    }
  }

  /** remoteAction */
  @IBAction func remoteAction() { MSRemoteAppController.sharedAppController().showRemote() }

  /** editorAction */
  @IBAction func editorAction() { MSRemoteAppController.sharedAppController().showEditor() }

  /** bankAction */
  @IBAction func bankAction() { MSRemoteAppController.sharedAppController().showBank() }

  /** settingsAction */
  @IBAction func settingsAction() { MSRemoteAppController.sharedAppController().showSettings() }

  /** helpAction */
  @IBAction func helpAction() { MSRemoteAppController.sharedAppController().showHelp() }

  /** startSpinner */
  private func startSpinner() {
    if spinner == nil { return }
    if !spinner.isAnimating() {
      spinner.startAnimating()
      remoteButton.enabled = false
      editorButton.enabled = false
      bankButton.enabled = false
      settingsButton.enabled = false
      helpButton.enabled = false
    }
  }

  /** stopSpinner */
  private func stopSpinner() {
    if spinner == nil { return }
    if spinner.isAnimating() {
      spinner.stopAnimating()
      remoteButton.enabled = true
      editorButton.enabled = true
      bankButton.enabled = true
      settingsButton.enabled = true
      helpButton.enabled = true
    }
  }

  /** toggleSpinner */
  func toggleSpinner() { spinning = !spinning }

  /**
  viewDidAppear:

  :param: animated Bool
  */
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }

  /**
  viewDidDisappear:

  :param: animated Bool
  */
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    UIApplication.sharedApplication().statusBarStyle = .Default
  }

  /** viewDidLoad */
  override func viewDidLoad() {
    super.viewDidLoad()

    messageLabel.text = MSRemoteAppController.versionInfo()
    if spinning { startSpinner() }
  }

}
