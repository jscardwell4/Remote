//
//  DocumentSelectionController.swift
//  Remote
//
//  Created by Jason Cardwell on 10/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DocumentSelectionController: UIViewController {

  var didSelectFile: ((DocumentSelectionController) -> Void)?
  var didDismiss: ((DocumentSelectionController) -> Void)?

  private weak var imageView: UIImageView?

  private var image: UIImage? { didSet { imageView?.image = image } }

  private(set) var selectedFile: NSURL? { didSet { didSelectFile?(self) } }

  /** loadView */
  override func loadView() {
    view = UIView(frame: UIScreen.mainScreen().bounds)
    imageView = {
      let iv = UIImageView()
      iv.image = self.image
      iv.setTranslatesAutoresizingMaskIntoConstraints(false)
      self.view.addSubview(iv)
      self.view.constrainWithFormat("|[image]| :: V:|[image]|", views: ["image": iv])
      return iv
    }()

    let wrapper = UIView()
    wrapper.setTranslatesAutoresizingMaskIntoConstraints(false)
    wrapper.backgroundColor = UIColor.clearColor()
    view.addSubview(wrapper)
    view.constrainWithFormat("|-20-[wrapper]-20-| :: V:|-100-[wrapper]-100-|", views: ["wrapper": wrapper])

    let fileNameController = FileNameTableViewController()
    addChildViewController(fileNameController)
    wrapper.addSubview(fileNameController.view)
  }

  /**
  willMoveToParentViewController:

  :param: parent UIViewController?
  */
  override func willMoveToParentViewController(parent: UIViewController?) {
    super.willMoveToParentViewController(parent)
    image = parent?.view.blurredSnapshot()
  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if isBeingPresented() {
      image = presentingViewController?.view.blurredSnapshot()
    }
  }

  /// MARK: Table view controller class for displaying existing file names for selection
  //////////////////////////////////////////////////////////////////////////////////////

  private class FileNameTableViewController: UITableViewController {

    // Simple cell subclass for the table view to use
    private class DocumentCell: UITableViewCell {

      // UILabel subclass because text was getting cutoff
      private class DocumentCellLabel: UILabel {

        var gutter: CGFloat = 4.0

        /**
        drawRect:

        :param: rect CGRect
        */
        override func drawRect(rect: CGRect) {
          var newRect = rect
          newRect.origin.x = rect.origin.x + gutter
          newRect.origin.y = rect.origin.y + gutter
          newRect.size.width = rect.size.width - CGFloat(2) * gutter
          newRect.size.height = rect.size.height - CGFloat(2) * gutter
          attributedText.drawInRect(newRect)
        }

        /**
        alignmentRectInsets

        :returns: UIEdgeInsets
        */
        override func alignmentRectInsets() -> UIEdgeInsets {
          return UIEdgeInsets(top: gutter, left: gutter, bottom: gutter, right: gutter);
        }

        /**
        intrinsicContentSize

        :returns: CGSize
        */
        override func intrinsicContentSize() -> CGSize {
          var size = super.intrinsicContentSize()
          size.width += CGFloat(2) * gutter
          size.height += CGFloat(2) * gutter
          return size;
        }
      }

      lazy var label: DocumentCellLabel = {
        let view = DocumentCellLabel()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.font = Bank.boldLabelFont
        view.textColor = Bank.infoColor
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        return view
      }()

      /**
      setHighlighted:animated:

      :param: highlighted Bool
      :param: animated Bool
      */
      override func setHighlighted(highlighted: Bool, animated: Bool) {
        label.font = highlighted || selected ? Bank.boldLabelFont : Bank.labelFont
        super.setHighlighted(highlighted, animated: animated)
      }

      /**
      setSelected:animated:

      :param: selected Bool
      :param: animated Bool
      */
      override func setSelected(selected: Bool, animated: Bool) {
        label.font = highlighted || selected ? Bank.boldLabelFont : Bank.labelFont
        super.setSelected(selected, animated: animated)
      }

      /**
      initWithStyle:reuseIdentifier:

      :param: style UITableViewStyle
      :param: reuseIdentifier String
      */
      override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.opaque = false
        backgroundColor = UIColor.clearColor()
        opaque = false
        selectionStyle = .None
        contentView.constrainWithFormat("|-[label]-| :: V:|-[label]-|", views: ["label": label])
      }

      /**
      init:

      :param: aDecoder NSCoder
      */
      required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

      /**
      requiresConstraintBasedLayout

      :returns: Bool
      */
      override class func requiresConstraintBasedLayout() -> Bool { return true }

    }

    private var documentSelectionController: DocumentSelectionController? {
      return parentViewController as? DocumentSelectionController
    }

    let files = MoonFunctions.documentsDirectoryContents().filter{$0.hasSuffix(".json")}.map{$0[0..<($0.length - 5)]}

    /** loadView */
    override func loadView() {
      super.loadView()
      tableView.opaque = false
      tableView.backgroundColor = UIColor.clearColor()
      tableView.clipsToBounds = false
      tableView.separatorStyle = .None
      tableView.estimatedRowHeight = 44
      tableView.sectionHeaderHeight = 50
      tableView.registerClass(DocumentCell.self, forCellReuseIdentifier: "Cell")
    }

    /**
    numberOfSectionsInTableView:

    :param: tableView UITableView

    :returns: Int
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

    /**
    tableView:viewForHeaderInSection:

    :param: tableView UITableView
    :param: section Int

    :returns: UIView?
    */
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let view = UILabel()
      view.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.font = Bank.boldLabelFont
      view.textColor = Bank.labelColor
      view.backgroundColor = UIColor.clearColor()
      view.text = "Select a file to import:"
      view.opaque = false
      return view
    }

    /**
    tableView:numberOfRowsInSection:

    :param: tableView UITableView
    :param: section Int

    :returns: Int
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return files.count }

    /**
    tableView:cellForRowAtIndexPath:

    :param: tableView UITableView
    :param: indexPath NSIndexPath

    :returns: UITableViewCell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as DocumentCell
      cell.label.text = files[indexPath.row]
//      var margins = cell.contentView.layoutMargins
//      if indexPath.row == 0 { margins.top = 80.0 }
//      else if indexPath.row == files.count - 1 { margins.bottom = 60.0 }
//      margins.left = 40.0
//      margins.right = 40.0
//      cell.contentView.layoutMargins = margins
      return cell
    }

    /**
    tableView:didSelectRowAtIndexPath:

    :param: tableView UITableView
    :param: indexPath NSIndexPath
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      documentSelectionController?.selectedFile = ImportExportFileManager.urlForFile(files[indexPath.row])
    }

  }

}