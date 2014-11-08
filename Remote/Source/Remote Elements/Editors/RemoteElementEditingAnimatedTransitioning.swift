//
//  RemoteElementEditingAnimatedTransitioning.swift
//  Remote
//
//  Created by Jason Cardwell on 11/03/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

extension UIView {
  subscript(nametag: String) -> UIView? {
    return viewWithNametag(nametag)
  }
}

class RemoteElementEditingAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

  let forDismissal: Bool

  /**
  snapshotFromRemoteElementView:

  :param: elementView RemoteElementView

  :returns: UIImage
  */
  private func snapshotFromRemoteElementView(elementView: RemoteElementView) -> UIImage {
    let editingState = elementView.editingState
    elementView.editingState = .NotEditing
    UIGraphicsBeginImageContextWithOptions(elementView.bounds.size, false, 0.0)
    elementView.layer.renderInContext(UIGraphicsGetCurrentContext())
    let layerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIEdgeInsets
    UIGraphicsEndImageContext()
    let rect = CGRect(origin: CGPoint.zeroPoint, size: CGSize.zeroSize)
    elementView.editingState = editingState
    return layerImage
  }

  /**
  snapshotViewFromRemoteElementView:

  :param: elementView RemoteElementView

  :returns: UIImageView
  */
  private func snapshotViewFromRemoteElementView(elementView: RemoteElementView) -> UIImageView {
    let snapshotView = UIImageView(image: snapshotFromRemoteElementView(elementView))
    snapshotView.frame = elementView.frame
    return snapshotView
  }

  /**
  initWithForDismissal:

  :param: forDismissal Bool = false
  */
  init(forDismissal: Bool = false) { self.forDismissal = forDismissal; super.init() }

	/**
	transitionDuration:

	:param: transitionContext UIViewControllerContextTransitioning

	:returns: NSTimeInterval
	*/
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval { return 1.0 }

	/**
	animateTransition:

	:param: transitionContext UIViewControllerContextTransitioning
	*/
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		let to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as RemoteElementEditingController
		let from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as RemoteElementEditingController

    if forDismissal { animateForDismissalOfController(from, presentingController: to, transitionContext: transitionContext) }
    else { animateForPresentationOfController(to, presentingController: from, transitionContext: transitionContext) }

	}

  /**
  animateForDismissalOfController:presentingController:transitionContext:

  :param: dismissedController RemoteElementEditingController
  :param: presentingController RemoteElementEditingController
  :param: transitionContext UIViewControllerContextTransitioning
  */
  func animateForDismissalOfController(dismissedController: RemoteElementEditingController,
                  presentingController: RemoteElementEditingController,
                     transitionContext: UIViewControllerContextTransitioning)
  {

    let containerView = transitionContext.containerView()

    let subelementViewSnapshot = snapshotViewFromRemoteElementView(dismissedController.sourceView)
    containerView.addSubview(subelementViewSnapshot)

    dismissedController.view.removeFromSuperview()

    UIView.animateWithDuration(transitionDuration(transitionContext) * 0.8,
      delay: 0.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0,
      options: nil,
      animations: {
        subelementViewSnapshot.frame = presentingController.presentedSubelementView!.frame
        containerView["chrome"]?["effectMask"]?.alpha = 0.0
      }) {
        (didComplete: Bool) -> Void in
          _ = presentingController.presentedSubelementView?.hidden = false
          subelementViewSnapshot.removeFromSuperview()
          containerView["chrome"]?.removeFromSuperview()
         transitionContext.completeTransition(didComplete)
    }

    // UIView.animateWithDuration(transitionDuration(transitionContext) * 0.2,
    //   delay: transitionDuration(transitionContext) * 0.8,
    //   usingSpringWithDamping: 1.0,
    //   initialSpringVelocity: 0.5,
    //   options: nil,
    //   animations: {
    //     _ = containerView["chrome"]?["effectMask"]?.alpha = 0.0
    //   },
    //   completion: nil)


  }

  /**
  animateForPresentationOfController:presentingController:transitionContext:

  :param: presentedController RemoteElementEditingController
  :param: presentingController RemoteElementEditingController
  :param: transitionContext UIViewControllerContextTransitioning
  */
  func animateForPresentationOfController(presentedController: RemoteElementEditingController,
                     presentingController: RemoteElementEditingController,
                        transitionContext: UIViewControllerContextTransitioning)
  {


    let containerView = transitionContext.containerView()
    let toView = presentedController.view
    let fromView = presentingController.view

    let chrome = UIView(frame: containerView.bounds)
    chrome.nametag = "chrome"
    containerView.addSubview(chrome)

    let effectMask = UIView(frame: containerView.bounds, nametag: "effectMask")
    effectMask.alpha = 0.0
    chrome.addSubview(effectMask)

    effectMask.addSubview(snapshotViewFromRemoteElementView(presentingController.sourceView))

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effectView.frame = effectMask.bounds
    effectMask.addSubview(effectView)

    containerView.addSubview(toView)

    let subelementViewSnapshot = snapshotViewFromRemoteElementView(presentingController.presentedSubelementView!)
    containerView.addSubview(subelementViewSnapshot)

    presentedController.sourceView.hidden = true

    // UIView.animateWithDuration(transitionDuration(transitionContext) * 0.2,
    //   animations: {
    //     if let view = presentingController.presentedSubelementView {
    //       view.editingState = .NotEditing
    //     }
    //   }) { _ in _ =  presentingController.presentedSubelementView?.hidden = true }


    UIView.animateWithDuration(transitionDuration(transitionContext),
      delay: 0.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.5,
      options: nil,
      animations: {
        effectMask.alpha = 1.0
        subelementViewSnapshot.frame = subelementViewSnapshot.frame.rectWithCenter(toView.bounds.center)
      }) {
        (didComplete: Bool) -> Void in
          presentedController.sourceView.hidden = false
          subelementViewSnapshot.removeFromSuperview()
          transitionContext.completeTransition(didComplete)
    }
 }

	/*
	func animationEnded(transitionCompleted: Bool) {

	}
	*/

}
