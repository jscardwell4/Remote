//
//  BankItemCreationDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 7/20/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

class BankItemCreationDelegate {

  weak var presentingController: BankItemCreationController?

  /**
  createBankItemWithProvider:

  - parameter provider: ItemCreationTransactionProvider
  */
  func createBankItemWithProvider(provider: ItemCreationTransactionProvider) {
    let transactions = provider.transactions.filter {$0 is DiscoveryTransaction == false }
    switch transactions.count {
      case 0:  return
      case 1:  transact(transactions[0])
      default: presentPopoverForTransactions(transactions)
    }
  }

  private var _endDiscovery: (() -> Void)?

  /** endDiscovery */
  func endDiscovery() { _endDiscovery?(); _endDiscovery = nil }

  /**
  discoverBankItemWithProvider:

  - parameter provider: ItemCreationTransactionProvider
  */
  func discoverBankItemWithProvider(provider: ItemCreationTransactionProvider) {
    let transactions = provider.transactions.filter {$0 is DiscoveryTransaction == true }
    switch transactions.count {
      case 0:  return
      case 1:  transact(transactions[0])
      default: presentPopoverForTransactions(transactions)
    }
  }

  /** toggleDiscovery */
  func toggleDiscovery(transaction: DiscoveryTransaction? = nil) {
    guard let presentingController = presentingController else { return }
    if presentingController.discoverItemBarButton?.isToggled == false { endDiscovery() }
    else if let transaction = transaction { transact(transaction) }
  }
  /**
  transact:

  - parameter transaction: ItemCreationTransaction
  */
  private func transact(transaction: ItemCreationTransaction) {
    switch transaction {
      case is FormTransaction:      presentFormTransaction(transaction as! FormTransaction)
      case is CustomTransaction:    presentCustomTransaction(transaction as! CustomTransaction)
      case is DiscoveryTransaction: beginDiscoveryTransaction(transaction as! DiscoveryTransaction)
      default:                      break
    }
  }

  /**
  presentFormTransaction:

  - parameter transaction: FormTransaction
  */
  private func presentFormTransaction(transaction: FormTransaction) {
    guard let presentingController = presentingController,
              viewController = presentingController as? UIViewController else { return }

    let dismissController = {
      viewController.dismissViewControllerAnimated(true) {
        presentingController.createItemBarButton?.isToggled = false
      }
    }

    let didSubmit: FormSubmission = {
      if transaction.processedForm($0), let context = presentingController.creationContext {
        DataManager.propagatingSaveFromContext(context)
      }
      dismissController()
    }

    let formViewController = FormViewController(form: transaction.form, didSubmit: didSubmit, didCancel: dismissController)

    viewController.presentViewController(formViewController, animated: true, completion: nil)

  }

  /**
  presentCustomTransaction:

  - parameter transaction: CustomTransaction
  */
  private func presentCustomTransaction(transaction: CustomTransaction) {
    guard let presentingController = presentingController,
              viewController = presentingController as? UIViewController else { return }

    let dismissController = {
      viewController.dismissViewControllerAnimated(true) {
        presentingController.createItemBarButton?.isToggled = false
      }
    }

    let didCreate: (ModelObject) -> Void = { _ in
      if let context = presentingController.creationContext {
        DataManager.propagatingSaveFromContext(context)
      }
      dismissController()
    }

    if let customController = transaction.controller(didCancel: dismissController, didCreate: didCreate) {
      viewController.presentViewController(customController, animated: true, completion: nil)
    }

  }

  /**
  beginDiscoveryTransaction:

  - parameter transaction: DiscoveryTransaction
  */
  private func beginDiscoveryTransaction(transaction: DiscoveryTransaction) {
    guard let presentingController = presentingController,
              viewController = presentingController as? UIViewController else { return }

    _endDiscovery = transaction.endDiscovery

    let formPresentation: (Form, ProcessedForm) -> Void = {
      form, processedForm in

      let dismissController = {
        viewController.dismissViewControllerAnimated(true) {
          presentingController.discoverItemBarButton?.isToggled = false
        }
      }

      let didSubmit: FormSubmission = {
        _ in
        if processedForm(form), let context = presentingController.creationContext {
          DataManager.propagatingSaveFromContext(context)
        }
        dismissController()
      }

      let formViewController = FormViewController(form: form, didSubmit: didSubmit, didCancel: dismissController)

      viewController.presentViewController(formViewController, animated: true, completion: nil)
    }

    transaction.beginDiscovery(formPresentation)
  }

  // MARK: Creating a popover view
  typealias PopoverItem = PopoverView.LabelData

  /**
  presentPopoverForTransactions:

  - parameter transactions: [ItemCreationTransaction]
  */
  private func presentPopoverForTransactions(transactions: [ItemCreationTransaction]) {
    let actions = transactions.map {
      [unowned self] t in
        PopoverItem(text: t.label, action: { $0.removeFromSuperview(); self.transact(t) })
    }

    guard actions.count > 0,
      let window = (presentingController as? UIViewController)?.view.window,
          presentingButton = presentingController?.createItemBarButton,
          presentingView = presentingButton.customView else { return }

    let popoverView = PopoverView(labelData: actions) { [unowned presentingButton] _ in presentingButton.isToggled = false }
    popoverView.nametag = "popover"
    popoverView.highlightedTextColor = Bank.actionColor

    window.addSubview(popoverView)

    let id = MoonKit.Identifier(self, "Popover")

    let necessaryWidth = (popoverView.intrinsicContentSize().width / 2) + 2
    let windowWidth = window.bounds.width
    let presentingViewFrame = presentingView.frame
    let halfPresentingViewWidth = presentingViewFrame.width / 2
    let spaceToLeft = presentingViewFrame.minX + halfPresentingViewWidth
    let spaceToRight = windowWidth - presentingViewFrame.maxX + halfPresentingViewWidth

    let offset: CGFloat
    switch (spaceToLeft > necessaryWidth, spaceToRight > necessaryWidth) {
      case (true, false):                offset = necessaryWidth - spaceToRight
      case (false, true):                offset = necessaryWidth - spaceToLeft
      case (true, true), (false, false): offset = 0
    }

    popoverView.xOffset = offset
    window.constrain(
      popoverView.centerX => presentingView.centerX - offset --> id,
      popoverView.bottom => presentingView.top --> id
    )

  }

}