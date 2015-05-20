//
//  FormViewController.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/9/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class FormViewController: UIViewController {

  public typealias Submission = (FormViewController, Form) -> Void
  public typealias Cancellation = (FormViewController) -> Void

  // MARK: - Initializating the controller

  /**
  Default initializer takes the form and cancel/submit callbacks

  :param: form Form
  :param: submit Submission? = nil
  :param: cancel Cancellation? = nil
  */
  public init(form f: Form, didSubmit submit: Submission? = nil, didCancel cancel: Cancellation? = nil)
  {
    form = f; didSubmit = submit; didCancel = cancel
    super.init(nibName: nil, bundle: nil)
    modalTransitionStyle = .CrossDissolve
  }

  public required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: Customizing the form's appearance

  struct Appearance {
    let labelFont: UIFont
    let controlFont: UIFont
    let controlSelectedFont: UIFont
    let labelTextColor: UIColor
    let controlTextColor: UIColor
    let controlSelectedTextColor: UIColor
  }

  public let form: Form

  public dynamic var labelFont: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
  public dynamic var controlFont: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
  public dynamic var controlSelectedFont: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
  public dynamic var labelTextColor: UIColor = UIColor.blackColor()
  public dynamic var controlTextColor: UIColor = UIColor.blackColor()
  public dynamic var controlSelectedTextColor: UIColor = UIColor.blackColor()

  var formAppearance: Appearance {
    return Appearance(
      labelFont: labelFont,
      controlFont: controlFont,
      controlSelectedFont: controlSelectedFont,
      labelTextColor: labelTextColor,
      controlTextColor: controlTextColor,
      controlSelectedTextColor: controlSelectedTextColor
    )
  }

  // MARK: - The controller's private properties
  private let didSubmit: Submission?
  private let didCancel: Cancellation?

  private weak var snapshotView: UIView?
  private weak var effectView: UIVisualEffectView?
  private weak var formView: FormView?
  private weak var toolbar: UIToolbar?

  // MARK: - Loading/updating the controller's view

  public override func prefersStatusBarHidden() -> Bool { return true }

  /** loadView */
  public override func loadView() {
    self.view = UIView(frame: UIScreen.mainScreen().bounds)

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effectView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(effectView)
    self.effectView = effectView

    let formView = FormView(form: form, appearance: formAppearance)
    effectView.contentView.addSubview(formView)
    self.formView = formView

    let toolbar = UIToolbar.newForAutolayout()
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
    toolbar.tintColor = UIColor(white: 0.5, alpha: 1)
    toolbar.items = [UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAction"),
                     UIBarButtonItem.flexibleSpace(),
                     UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submitAction")]
    effectView.contentView.addSubview(toolbar)
    self.toolbar = toolbar

    view.setNeedsUpdateConstraints()

  }

  public override func viewWillAppear(animated: Bool) {
    if isBeingPresented(), let controller = presentingViewController where controller.isViewLoaded() {
      let snapshot = controller.view.snapshotViewAfterScreenUpdates(false)
      snapshotView?.removeFromSuperview()
      assert(effectView != nil)
      view.insertSubview(snapshot, belowSubview: effectView!)
      snapshotView = snapshot
    }
  }

  /** updateViewConstraints */
  public override func updateViewConstraints() {
    super.updateViewConstraints()
    let id = createIdentifier(self, "Internal")
    if let effect = effectView, form = formView, tool = toolbar {
      view.removeConstraintsWithIdentifier(id)
      view.constrain([𝗛|effect|𝗛, 𝗩|effect|𝗩] --> id)
      view.constrain([form.centerX => effect.centerX, form.centerY => effect.centerY] --> id)
      view.constrain([tool.left => form.left, tool.right => form.right, tool.top => form.bottom] --> id)
    }
  }

  // MARK: - Actions

  /** cancelAction */
  func cancelAction() { didCancel?(self) }

  /** submitAction */
  func submitAction() { if form.valid { didSubmit?(self, form) } }

}
