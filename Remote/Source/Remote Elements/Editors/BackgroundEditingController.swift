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
  var backgroundColor: UIColor! { get set }
  var backgroundImage: ImageView! { get set }
  var managedObjectContext: NSManagedObjectContext? { get }
}

class BackgroundEditingController: UIViewController {

  var subject: EditableBackground? {
    didSet { initialImage = subject?.backgroundImage?.image; resetToInitialState() }
  }

  @IBOutlet weak var colorBox: UIButton!
  @IBOutlet weak var bottomToolbar: UIToolbar!
  @IBOutlet weak var colorSelectionContainer: UIView!
  @IBOutlet weak var colorSelectionConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageCollectionContainer: UIView!

  private var initialImage: Image?
  private weak var imageCollectionVC: BankCollectionController!
  private weak var imageCollectionNav: UINavigationController! {
    didSet {
      if imageCollectionNav != nil, let moc = subject?.managedObjectContext,
        let category = ImageCategory.findFirstByAttribute("name", withValue: "Backgrounds", context: moc),
        let controller = BankCollectionController(category: category, mode: .Selection) {
          controller.selectionDelegate = self
          imageCollectionNav!.showViewController(controller, sender: self)
          imageCollectionVC = controller
      }
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
    if segue.identifier == "Embed Color Selection" {
      colorSelectionVC = segue.destinationViewController as! ColorSelectionController
    } else if segue.identifier == "Embed Image Collection" {
      imageCollectionNav = segue.destinationViewController as! UINavigationController
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

extension BackgroundEditingController: BankItemSelectionDelegate {
  func bankController(bankController: BankController, didSelectItem item: BankModel) {
    if let image = item as? Image {
      subject?.backgroundImage?.image = image
    }
  }
}
