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

class RemoteElementEditingAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

  let forDismissal: Bool

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
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval { return 0.5 }

	/**
	animateTransition:

	:param: transitionContext UIViewControllerContextTransitioning
	*/
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
			as RemoteElementEditingController
		let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
			as RemoteElementEditingController

    if forDismissal {
      animateForDismissalOfController(fromController, presentingController: toController, transitionContext: transitionContext)
    } else {
      animateForPresentationOfController(toController, presentingController: fromController, transitionContext: transitionContext)
    }

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
    println(containerView.framesDescription())

    presentingController.selectedViews.first?.hidden = false
    dismissedController.view.removeFromSuperview()
    transitionContext.completeTransition(true)
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

    let toView = presentedController.view
    let fromView = presentingController.view

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effectView.frame = fromView.frame

    let presentingElementView = presentingController.selectedViews.first!
    presentingElementView.hidden = true

    let presentingElementViewStandIn = presentingElementView.snapshotViewAfterScreenUpdates(false)
    presentingElementViewStandIn.frame = presentingElementView.frame

    let fromViewStandIn = fromView.snapshotViewAfterScreenUpdates(false)
    fromViewStandIn.frame = fromView.frame

    effectView.contentView.addSubview(fromViewStandIn)
    effectView.contentView.addSubview(presentingElementViewStandIn)

    let containerView = transitionContext.containerView()
    containerView.addSubview(effectView)
    presentedController.sourceView.hidden = true
    containerView.addSubview(toView)

    println(containerView.framesDescription())

    UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
      () -> Void in
        presentingElementViewStandIn.frame = presentingElementViewStandIn.frame.rectWithCenter(toView.bounds.center)
        fromViewStandIn.alpha = 0.0
      }) {
        (didComplete: Bool) -> Void in
          presentingElementViewStandIn.removeFromSuperview()
          fromViewStandIn.removeFromSuperview()
          presentedController.sourceView.hidden = false
          transitionContext.completeTransition(didComplete)
    }

  }

	/*
	func animationEnded(transitionCompleted: Bool) {

	}
	*/

}
