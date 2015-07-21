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

@objc class BankItemCreationDelegate {

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
      default: presentPopOverForTransactions(transactions)
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
      default: presentPopOverForTransactions(transactions)
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

    let customController = transaction.controller(didCancel: dismissController, didCreate: didCreate)

    viewController.presentViewController(customController, animated: true, completion: nil)

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

  typealias PopOverActions = [String:(PopOverView) -> Void]

  /**
  presentPopOverForTransactions:

  - parameter transactions: [ItemCreationTransaction]
  */
  private func presentPopOverForTransactions(transactions: [ItemCreationTransaction]) {
    let actions = PopOverActions(
      transactions.map {
        [unowned self] (transaction:ItemCreationTransaction) -> (String, (PopOverView) -> Void) in
          return (transaction.label, {$0.removeFromSuperview(); self.transact(transaction)})
      }
    )
    guard actions.count > 0 else { return }
    presentPopOverWithActions(actions, location: .Top)
  }

  /**
  Creates a fresh `PopOverView` with the specified actions

  - parameter actions: PopOverActions

  - returns: PopOverView
  */
  private func popOverWithActions(actions: PopOverActions, location: PopOverView.Location) -> PopOverView {
    let popOverView = PopOverView(autolayout: true)
    popOverView.location = location
    popOverView.highlightedTextColor = Bank.actionColor
    apply(actions) {popOverView.addLabel(label: $0, withAction: $1)}
    return popOverView
  }


  /**
  presentPopOverWithActions:button:location:

  - parameter actions: PopOverActions
  - parameter location: PopOverView.Location
  */
  private func presentPopOverWithActions(actions: PopOverActions, location: PopOverView.Location) {
    // TODO: Add animation and more appearance customization
    let popOverView = popOverWithActions(actions, location: location)

    if let presentingView = presentingController?.createItemBarButton?.customView,
      view = (presentingController as? UIViewController)?.view
    {
      view.window?.addSubview(popOverView)
      view.window?.constrain(popOverView.centerX => presentingView.centerX, popOverView.bottom => presentingView.top)
    }

  }

}