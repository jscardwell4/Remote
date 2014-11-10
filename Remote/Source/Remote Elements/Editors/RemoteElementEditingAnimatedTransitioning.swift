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
  snapshotFromRemoteElementView:

  :param: elementView RemoteElementView

  :returns: UIImage
  */
  private func snapshotFromRemoteElementView(elementView: RemoteElementView) -> UIImage {
    let editingState = elementView.editingState
    elementView.editingState = .NotEditing
    let image = snapshotFromView(elementView)
    elementView.editingState = editingState
    return image
  }

  /**
  snapshotFromView:

  :param: view UIView

  :returns: UIImage
  */
  private func snapshotFromView(view: UIView) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    view.layer.renderInContext(UIGraphicsGetCurrentContext())
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  /**
  snapshotViewFromRemoteElementView:frame:excludingSubview:

  :param: elementView RemoteElementView
  :param: frame CGRect? = nil
  :param: subview RemoteElementView? = nil

  :returns: UIImageView
  */
  private func snapshotViewFromRemoteElementView(elementView: RemoteElementView,
                                           frame: CGRect? = nil,
                                excludingSubview subview: RemoteElementView? = nil) -> UIImageView
  {

    var image: UIImage

    if subview == nil {
      image = snapshotFromRemoteElementView(elementView)
    } else {
      let backdropImage = snapshotFromView(elementView.subviews[0] as UIView)
      let contentImage = snapshotFromView(elementView.subviews[1] as UIView)
      var subelementImages: [(UIImage, CGRect)?] = []
      for subelementView in elementView.subelementViews {
        if subelementView == subview! { subelementImages.append(nil) }
        else { subelementImages.append((snapshotFromRemoteElementView(subelementView), subelementView.frame)) }
      }
      let overlayImage = snapshotFromView(elementView.subviews[3] as UIView)
      UIGraphicsBeginImageContextWithOptions(elementView.bounds.size, false, 0.0)
      backdropImage.drawInRect(elementView.bounds)
      contentImage.drawInRect(elementView.bounds)
      for subelementImage in subelementImages {
        if let (img, rect) = subelementImage {
          img.drawInRect(rect)
        }
      }
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }


    let snapshotView = UIImageView(image: image)
    snapshotView.frame = frame ?? elementView.frame

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
    let dismissedSourceView = dismissedController.sourceView
    let subelementView = presentingController.presentedSubelementView!
    let presentingSourceView = presentingController.sourceView

    let subelementViewSnapshot = snapshotViewFromRemoteElementView(dismissedSourceView)
    containerView.addSubview(subelementViewSnapshot)

    var finalFrame = subelementView.frame
    finalFrame.origin += presentingSourceView.frame.origin

    dismissedController.view.removeFromSuperview()

    UIView.animateWithDuration(transitionDuration(transitionContext) * 0.2,
      delay: transitionDuration(transitionContext) * 0.2,
      options: nil,
      animations: {
        _ = containerView["chrome"]?["effectMask"]?.alpha = 0.0
      },
      completion: nil)

    UIView.animateWithDuration(transitionDuration(transitionContext),
      delay: 0.0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 0.5,
      options: nil,
      animations: {
        subelementViewSnapshot.frame = finalFrame
      }) {
        (didComplete: Bool) -> Void in
          _ = presentingController.presentedSubelementView?.hidden = false
          subelementViewSnapshot.removeFromSuperview()
          containerView["chrome"]?.removeFromSuperview()
          subelementView.hidden = false
          transitionContext.completeTransition(didComplete)
    }

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

    // Get the containing view for the presentation
    let containerView = transitionContext.containerView()

    // Get the view to present
    let toView = presentedController.view

    // Get the view being presented over
    let fromView = presentingController.view

    // Get the view for the remote element being presented over
    let sourceView = presentingController.sourceView

    // Get the presenting controller's view for the subelement being presented
    let subelementView = presentingController.presentedSubelementView!

    // Create a view to serve as a blurry backdrop beneath the presented view
    let chrome = UIView(frame: containerView.bounds)
    chrome.nametag = "chrome"
    containerView.addSubview(chrome)

    // Create a view to add to the backdrop for wrapping an effect view so we can control the opacity
    let effectMask = UIView(frame: containerView.bounds, nametag: "effectMask")
    effectMask.alpha = 0.0  // Hide effect initially
    chrome.addSubview(effectMask)

    // Create a snapshot of the source view minus the subelement to present and add to backdrop
    let sourceViewSnapshot = snapshotViewFromRemoteElementView(sourceView, excludingSubview: subelementView)
    effectMask.addSubview(sourceViewSnapshot)

    // Create an effect view to blur the source view snapshot
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effectView.frame = effectMask.bounds
    effectMask.addSubview(effectView)

    // Add the view being presented to the container
    containerView.addSubview(toView)

    // Calculate the initial frame for a subelement view standin
    var initialFrame = subelementView.frame
    initialFrame.origin += sourceView.frame.origin

    // Calculate the final from for the subelement view standin
    let finalFrame = initialFrame.rectWithCenter(toView.bounds.center)

    // Hide the presented subelement's view in the presented controller
    presentedController.sourceView.hidden = true

    // Create a snapshot of the presented subelement to animate and add to container
    let subelementViewSnapshot = snapshotViewFromRemoteElementView(subelementView, frame: initialFrame)
    containerView.addSubview(subelementViewSnapshot)

    // Hide the presented subelement in the presenting controller
    subelementView.hidden = true

    // Animate
    UIView.animateWithDuration(transitionDuration(transitionContext) * 0.2,
      animations: {
        effectMask.alpha = 1.0  // Fade in backdrop
      })

    UIView.animateWithDuration(transitionDuration(transitionContext),
      delay: 0.0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 0.5,
      options: nil,
      animations: {
        subelementViewSnapshot.frame = finalFrame // Translate subelement view standin
      }) {
        (didComplete: Bool) -> Void in
          presentedController.sourceView.hidden = false // Reveal subelement view in presented controller
          subelementViewSnapshot.removeFromSuperview()  // Remove the subelement view standin
          transitionContext.completeTransition(didComplete)  // Complete transition
    }
 }

	/*
	func animationEnded(transitionCompleted: Bool) {

	}
	*/

}
