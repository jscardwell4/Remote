//
//  BackgroundEditingController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/31/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

@objc protocol EditableBackground {
  var backgroundColor: UIColor? { get set }
  var backgroundImage: Image? { get set }
  var managedObjectContext: NSManagedObjectContext { get }
}

class BackgroundEditingController: UIViewController {

  var subject: EditableBackground? {
    didSet {
      collectionVC?.context = subject?.managedObjectContext
      resetToInitialState()
    }
  }

  @IBOutlet weak var colorBox: UIButton!
  @IBOutlet weak var bottomToolbar: UIToolbar!
  @IBOutlet weak var colorSelectionContainer: UIView!
  @IBOutlet weak var colorSelectionConstraint: NSLayoutConstraint!
  
  private weak var collectionVC: REBackgroundCollectionViewController! {
    didSet {
      collectionVC?.context = subject?.managedObjectContext
      resetToInitialState()
    }
  }

  private weak var colorSelectionVC: ColorSelectionController! {
    didSet {
      colorSelectionVC.delegate = self
      resetToInitialState()
    }
  }

  /** resetToInitialState */
  private func resetToInitialState() {
    if subject != nil {
      collectionVC?.initialImage = subject!.backgroundImage
      colorBox?.backgroundColor = subject!.backgroundColor
      colorSelectionVC?.initialColor = subject!.backgroundColor ?? UIColor.whiteColor()
    }
  }

  /** cancelAction */
  @IBAction func cancelAction() { dismissViewControllerAnimated(true, completion: nil) }

  /** resetAction */
  @IBAction func resetAction() { resetToInitialState() }

  /** saveAction */
  @IBAction func saveAction() {
    subject?.backgroundColor = colorBox.backgroundColor
    subject?.backgroundImage = collectionVC.selectedImage
    dismissViewControllerAnimated(true, completion: nil)
  }

  /** toggleColorSelection */
  @IBAction func toggleColorSelection() {
    let c = colorSelectionConstraint.constant == 0 ? -colorSelectionContainer.bounds.size.height : 0
    view.layoutIfNeeded()
    UIView.animateWithDuration(1.0) {
      self.colorSelectionConstraint.constant = c
      self.view.layoutIfNeeded()
    }
  }

  /**
  prepareForSegue:sender:

  :param: segue UIStoryboardSegue
  :param: sender AnyObject?
  */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Embed Background Collection" {
      collectionVC = segue.destinationViewController as REBackgroundCollectionViewController
    } else if segue.identifier == "Embed Color Selection" {
      colorSelectionVC = segue.destinationViewController as ColorSelectionController
    }
  }

}

extension BackgroundEditingController: ColorSelectionControllerDelegate {

  /**
  colorSelectionController:didSelectColor:

  :param: controller ColorSelectionController
  :param: color UIColor
  */
  func colorSelectionController(controller: ColorSelectionController, didSelectColor color: UIColor) {
    colorBox.backgroundColor = color
    toggleColorSelection()
  }

  /**
  colorSelectionControllerDidCancel:

  :param: controller ColorSelectionController
  */
  func colorSelectionControllerDidCancel(controller: ColorSelectionController) { toggleColorSelection() }

}
