//
//  RemoteElementEditingTransitioningDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 11/03/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteElementEditingTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

	/**
	animationControllerForPresentedController:presentingController:sourceController:

	:param: presented UIViewController
	:param: presenting UIViewController
	:param: source UIViewController

	:returns: UIViewControllerAnimatedTransitioning?
	*/
	func animationControllerForPresentedController(presented: UIViewController,
		                        presentingController presenting: UIViewController,
		                            sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		return RemoteElementEditingAnimatedTransitioning()
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return RemoteElementEditingAnimatedTransitioning(forDismissal: true)
	}

	/*
	func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning)
		-> UIViewControllerInteractiveTransitioning?
	{

	}
	*/

	/*
	func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning)
		 -> UIViewControllerInteractiveTransitioning?
	 {

	 }
	 */

	/**
	presentationControllerForPresentedViewController:presentingViewController:sourceViewController:

	:param: presented UIViewController
	:param: presenting UIViewController!
	:param: source UIViewController

	:returns: UIPresentationController?
	*/
	func presentationControllerForPresentedViewController(presented: UIViewController,
	                             presentingViewController presenting: UIViewController!,
	                                 sourceViewController source: UIViewController) -> UIPresentationController?
	{
		return RemoteElementEditingPresentationController(presentedViewController: presented, presentingViewController: presenting)
	}

}
