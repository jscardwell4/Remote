//
//  ModeSelectionView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ModeSelectionView: ButtonGroupView {

  private weak var selectedButton: ButtonView!
  
  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  override func addSubelementView(view: RemoteElementView) {
    super.addSubelementView(view)
    if let buttonView = view as? ButtonView {
      if selectedButton == nil { selectButton(buttonView) }
      buttonView.tapAction = {self.handleSelection(buttonView)}
    }
  }

  /**
  selectButton:

  :param: newSelection ButtonView
  */
  func selectButton(newSelection: ButtonView) {
    if selectedButton != newSelection && newSelection.model.key != nil && !newSelection.model.key!.isEmpty {
      (selectedButton?.model as Button).selected = false
      (newSelection.model as Button).selected = true
      selectedButton = newSelection
      RemoteController(model.managedObjectContext).currentRemote?.currentMode = newSelection.model.key!
    }
  }

  /**
  handleSelection:

  :param: sender ButtonView
  */
  func handleSelection(sender: ButtonView) {
    if selectedButton != sender { selectButton(sender) }
    if (model as ButtonGroup).autohide { MSDelayedRunOnMain(1){self.tuck()} }
  }

  /**
  drawBackdropInContext:inRect:

  :param: ctx CGContextRef
  :param: inRect CGRect
  */
  override func drawBackdropInContext(ctx: CGContextRef, inRect: CGRect) {
    let panelLocation = (model as ButtonGroup).panelLocation
    CGContextClearRect(ctx, bounds)
    var roundedCorners: UIRectCorner
    switch panelLocation {
      case .Right: roundedCorners = UIRectCorner.TopLeft | UIRectCorner.BottomLeft
      case .Left: roundedCorners = UIRectCorner.TopRight | UIRectCorner.BottomRight
      default: roundedCorners = UIRectCorner(0)
    }
    var path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(square: 15))
    borderPath = path
    UIColor.darkTextColor().setFill()
    path.fillWithBlendMode(kCGBlendModeNormal, alpha: 0.9)
    let dx: CGFloat = panelLocation == .Right ? 3 : -3
    let insetRect = bounds.rectByInsetting(dx: 0, dy: 3).rectByApplyingTransform(CGAffineTransformMakeTranslation(dx, 0))
    path = UIBezierPath(roundedRect: insetRect, byRoundingCorners: roundedCorners, cornerRadii: CGSize(square: 12))
    path.lineWidth = 2.0
    path.strokeWithBlendMode(kCGBlendModeClear, alpha: 1.0)
  }

}
