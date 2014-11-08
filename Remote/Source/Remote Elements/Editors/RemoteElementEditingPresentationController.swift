//
//  RemoteElementEditingPresentationController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/03/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteElementEditingPresentationController: UIPresentationController {

	var presentingEditor: RemoteElementEditingController { return presentingViewController as RemoteElementEditingController }

	var presentedEditor: RemoteElementEditingController { return presentedViewController as RemoteElementEditingController }


	/**
	initWithPresentedEditor:presentingEditor:

	:param: presentedEditor RemoteElementEditingController!
	:param: presentingEditor RemoteElementEditingController!
	*/
	init(presentedEditor: RemoteElementEditingController!, presentingEditor: RemoteElementEditingController!) {
		super.init(presentedViewController: presentedEditor, presentingViewController: presentingEditor)
	}

	/** presentationTransitionWillBegin */
	override func presentationTransitionWillBegin() {
//		precondition(presentingEditor.presentedSubelementView != nil, "why don't we have a subelement view to present?")
//		if let transitionCoordinator = presentedEditor.transitionCoordinator() {
//      let maskView = UIView(frame: containerView.bounds)
//      maskView.alpha = 0.0
//      let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//      effectView.frame = containerView.bounds
//      maskView.addSubview(effectView)
//      containerView.insertSubview(maskView, atIndex: 0)
//      transitionCoordinator.animateAlongsideTransition({_ in maskView.alpha = 1.0}, completion: nil)
//		}
	}

	/** dismissalTransitionWillBegin */
	override func dismissalTransitionWillBegin() {

	}

	/** containerViewWillLayoutSubviews */
	override func containerViewWillLayoutSubviews() {

	}

	/**
	animationControllerForDismissedController:

	:param: dismissed RemoteElementEditingController!

	:returns: UIViewControllerAnimatedTransitioning!
	*/
	func animationControllerForDismissedController(dismissed: RemoteElementEditingController!)
		-> UIViewControllerAnimatedTransitioning!
	{
		return RemoteElementEditingAnimatedTransitioning()
	}

}
