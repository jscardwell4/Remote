//
//  RemoteElementViewConstraint.swift
//  Remote
//
//  Created by Jason Cardwell on 11/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class RemoteElementViewConstraint: NSLayoutConstraint {

  private var contextReceptionist: MSContextChangeReceptionist?
  private var kvoReceptionist: MSKVOReceptionist?

  private(set) var owner: RemoteElementView!
  private(set) var model: Constraint! {
    didSet {
      if contextReceptionist != nil { contextReceptionist = nil }
      if kvoReceptionist != nil { kvoReceptionist = nil }
      if model != nil {
        contextReceptionist = MSContextChangeReceptionist(
          observer: self,
          forObject: model,
          notificationName: NSManagedObjectContextObjectsDidChangeNotification,
          updateHandler: {
            (receptionist: MSContextChangeReceptionist!) -> Void in
              if let modelConstraint = receptionist.object as? Constraint {
                if let viewConstraint = receptionist.observer as? RemoteElementViewConstraint {
                  if viewConstraint.model == modelConstraint && !viewConstraint.valid { viewConstraint.removeFromOwner() }
                }
              }
            },
          deleteHandler: {
            (receptionist: MSContextChangeReceptionist!) -> Void in
              if let modelConstraint = receptionist.object as? Constraint {
                if let viewConstraint = receptionist.observer as? RemoteElementViewConstraint {
                  if viewConstraint.model == modelConstraint { viewConstraint.removeFromOwner() }
                }
              }
            })
        kvoReceptionist = MSKVOReceptionist(
          observer: self,
          forObject: model,
          keyPath: "constant",
          options: .New,
          queue: NSOperationQueue.mainQueue(),
          handler: {
            (receptionist: MSKVOReceptionist!) -> Void in
              if let modelConstraint = receptionist.object as? Constraint {
                if let viewConstraint = receptionist.observer as? RemoteElementViewConstraint {
                  if viewConstraint.model == modelConstraint { viewConstraint.constant = modelConstraint.constant }
                }
              }
            })
      }
    }
  }

  var firstElement: RemoteElementView { return firstItem as RemoteElementView }
  var secondElement: RemoteElementView? { return secondItem as? RemoteElementView }

  /** removeFromOwner */
  func removeFromOwner() { MSRunSyncOnMain({
      [unowned self] () -> Void in
        if self.owner != nil {
          if let constraints = self.owner.constraints() as? [NSLayoutConstraint] {
            if constraints ∋ self {
              self.owner.removeConstraint(self)
            }
          }
        }
    })
  }

  var valid: Bool {
    if model.owner == nil || model.owner! != owner.model { return false }
    if model.firstItem != firstElement.model { return false }
    if model.firstAttribute != firstAttribute { return false }
    if model.relation != relation { return false }
    if model.secondItem == nil && secondElement != nil { return false }
    if model.secondItem != nil && secondElement == nil { return false }
    if model.secondItem != nil && secondElement != nil && model.secondItem! != secondElement!.model { return false }
    if model.secondAttribute != secondAttribute { return false }
    if model.multiplier != multiplier { return false }
    return true
  }

  /**
  constraintWithModel:owningView:

  :param: model Constraint
  :param: owningView RemoteElementView

  :returns: RemoteElementViewConstraint?
  */
  class func constraintWithModel(model: Constraint, owningView: RemoteElementView) -> RemoteElementViewConstraint? {
    if model.owner == nil || owningView.model != model.owner! { return nil }
    if let view1 = owningView[model.firstItem.uuid] {
      var view2: RemoteElementView?
      if !model.staticConstraint { if let view = owningView[model.secondItem!.uuid] { view2 = view } else { return nil } }
      let constraint = RemoteElementViewConstraint(item: view1,
                                                   attribute: model.firstAttribute,
                                                   relatedBy: model.relation,
                                                   toItem: view2,
                                                   attribute: model.secondAttribute,
                                                   multiplier: model.multiplier,
                                                   constant: model.constant)
      constraint.priority = model.priority
      constraint.tag = model.tag
      constraint.identifier = model.key
      constraint.owner = owningView
      constraint.model = model
      return constraint
    } else { return nil }
  }

  override var description: String {
    let item1 = firstElement.model.name.camelCase()
    let attr1 = NSLayoutConstraint.pseudoNameForAttribute(firstAttribute)
    let relatedBy = NSLayoutConstraint.pseudoNameForRelation(relation)
    let item2 = secondElement?.model.name.camelCase()
    let attr2 = secondAttribute == .NotAnAttribute
                                ? nil
                                : NSLayoutConstraint.pseudoNameForAttribute(secondAttribute)
    let operatorString = constant < 0.0 ? "-" : "+"
    var string = "\(item1).\(attr1) \(relatedBy) "
    if item2 != nil && attr2 != nil { string += "\(item2!).\(attr2!) " }
    if multiplier != 1.0 { string += "* \(multiplier) " }
    if constant != 0.0 { string += "\(operatorString) \(abs(constant)) "}
    string += "@\(priority)"
    return string
  }

}
