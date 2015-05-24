//
//  PhotoCollectionBrowser.swift
//  Remote
//
//  Created by Jason Cardwell on 5/23/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import Photos
import MoonKit

private let reuseIdentifier = "Cell"
private let imageViewNametag = "image"

class PhotoCollectionBrowser: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  // MARK: - Properties

  @IBOutlet weak var scaleSlider: UISlider!

  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var collectionViewLayout: PhotoBrowserLayout!

  /** An enumeration to assist with translating scale slider values to collection view layout item size */
  private enum ItemLayout: Float {
    case OneAcross = 1, TwoAcross, ThreeAcross, FourAcross, FiveAcross, SixAcross, SevenAcross, EightAcross

    static var minScale: ItemLayout { return .EightAcross }
    static var maxScale: ItemLayout { return .OneAcross }
    static var sliderStep: Float { return 100/(minScale.rawValue - 1) }

    var itemSize: CGSize { return CGSize(square: UIScreen.mainScreen().bounds.width/CGFloat(rawValue)) }
    var sliderValue: Float { return ItemLayout.sliderStep * (ItemLayout.minScale.rawValue - rawValue) }

    var interval: ClosedInterval<Float> {
      let halfStep = half(ItemLayout.sliderStep)
      let value = sliderValue
      return ClosedInterval(max(value - halfStep, 0), min(value + halfStep, 100))
    }

    static var all: [ItemLayout] {
      return [.OneAcross, .TwoAcross, .ThreeAcross, .FourAcross, .FiveAcross, .SixAcross, .SevenAcross, .EightAcross]
    }

    init(rawValue: Float) {
      if let layout = findFirst(ItemLayout.all, {$0.interval.contains(rawValue)}) { self = layout }
      else if ItemLayout.minScale.rawValue > rawValue { self = ItemLayout.minScale }
      else { self = ItemLayout.maxScale }
    }
  }

  /** Specifies how many items per row to display */
  private var itemLayout: ItemLayout = .EightAcross {
    didSet {
      collectionViewLayout.itemSize = itemLayout.itemSize
      collectionViewLayout.invalidateLayout()
      apply(collectionView.indexPathsForVisibleItems().filter({self.sizes[self.itemLayout]![$0.row] == CGSize.zeroSize})) {
        self.requestImageAtIndex($0.row, forItemLayout: self.itemLayout)
      }
    }
  }

  /** The `PHAsset` objects fetched from the `PHAssetCollection` passed to `initWithCollection:` */
  let assets: PHFetchResult

  /** Property of  convenience */
  private let manager = PHImageManager.defaultManager()

  /** Holds IDs of outstanding `PHImageManager` requests */
  private var requests: Set<PHImageRequestID> = []

  private lazy var sizes: [ItemLayout:[CGSize]] = {
    let array = [CGSize](count: self.assets.count, repeatedValue: CGSize.zeroSize)
    var sizes: [ItemLayout:[CGSize]] = [:]
    apply(ItemLayout.all) {sizes[$0] = array}
    return sizes
  }()

  // MARK: - Actions

  /**
  Scales from 8 cells across to just 1 cell across

  :param: sender UISlider
  */
  @IBAction func updateScale(sender: UISlider) {
    let newItemLayout = ItemLayout(rawValue: sender.value)
    if newItemLayout != itemLayout { itemLayout = newItemLayout }
  }

  /** Dismiss the controller */
  @IBAction func cancel() { dismissViewControllerAnimated(true, completion: nil) }

  // MARK: - Initialization

  /**
  initWithCollection:

  :param: collection PHAssetCollection
  */
  init(collection: PHAssetCollection) {
    assets = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
    super.init(nibName: "PhotoCollectionBrowser", bundle: Bank.bundle)
    MSLogDebug("assets = \(toString(assets))")
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    scaleSlider.minimumValue = ItemLayout.minScale.sliderValue
    scaleSlider.maximumValue = ItemLayout.maxScale.sliderValue
    scaleSlider.value = itemLayout.sliderValue

    collectionViewLayout.itemSize = itemLayout.itemSize

    // Register cell classes
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

  }

  /**
  viewWillDisappear:

  :param: animated Bool
  */
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    apply(requests){[manager = self.manager] in manager.cancelImageRequest($0)}
  }


  // MARK: - UICollectionViewDataSource

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return 1 }


  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return assets.count }

  /**
  Method for setting various aspects of a collection view cell for display

  :param: cell UICollectionViewCell
  */
  private func decorateCell(cell: UICollectionViewCell) {
    if let imageView = cell.contentView.subviewWithNametag(imageViewNametag) as? UIImageView {
      imageView.image = nil
    } else {
      let imageView = UIImageView(autolayout: true)
      imageView.nametag = imageViewNametag
      imageView.contentMode = .ScaleAspectFill
      imageView.clipsToBounds = true
      imageView.backgroundColor = UIColor.clearColor()
      imageView.opaque = false
      cell.contentView.addSubview(imageView)
      cell.contentView.constrain(𝗩|imageView|𝗩, 𝗛|imageView|𝗛)
    }
  }

  typealias RequestResult = (image: UIImage!, info: [NSObject:AnyObject]!)

  /**
  Request the image for the asset at the specified index for the specified cell

  :param: index Int
  */
  private func requestImageAtIndex(index: Int, forItemLayout itemLayout: ItemLayout) {
    precondition(index < assets.count, "index out of range")
    let asset = assets[index] as! PHAsset
    let size = itemLayout.itemSize
    let mode: PHImageContentMode = .AspectFit
    let handler: (UIImage!, [NSObject:AnyObject]!) -> Void = { [weak self] in
      self?.handleRequestResult((image: $0, info: $1),
                   forIndexPath: NSIndexPath(forRow: index, inSection: 0),
                     itemLayout: itemLayout)
    }
    let id = manager.requestImageForAsset(asset, targetSize: size, contentMode: mode, options: nil, resultHandler: handler)
    requests.insert(id)
  }

  /**
  A handler for `PHImageManager` request result. Updates cell's image view's image, logs cancellation, or handles error.

  :param: result RequestResult
  :param: cell UICollectionViewCell
  :param: idx Int
  :param: layout ItemLayout
  */
  private func handleRequestResult(result: RequestResult,
                      forIndexPath indexPath: NSIndexPath,
                        itemLayout layout: ItemLayout)
  {
    let requestID = (result.info[PHImageResultRequestIDKey] as! NSNumber).intValue
    if let isCancelled = result.info[PHImageCancelledKey] as? Bool where isCancelled == true {
      MSLogDebug("request with id \(requestID) cancelled")
    } else if let error = result.info[PHImageErrorKey] as? NSError {
      MSHandleError(error, message: "problem encountered loading image with request id \(requestID)")
    } else if let image = result.image {
      requests.remove(requestID)

      sizes[layout]![indexPath.row] = result.image.size
      if let cell = collectionView.cellForItemAtIndexPath(indexPath),
        imageView = cell.contentView.subviewWithNametag(imageViewNametag) as? UIImageView
      {
        if indexPath == collectionViewLayout.zoomedItem {
          UIView.animateWithDuration(0.5, animations: { () -> Void in
            imageView.contentMode = .ScaleAspectFit
            imageView.clipsToBounds = false
          })
        }
        imageView.image = image
      }
    }
}

  /**
  collectionView:cellForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath

  :returns: UICollectionViewCell
  */
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                        forIndexPath: indexPath) as! UICollectionViewCell
    decorateCell(cell)
    requestImageAtIndex(indexPath.row,
          forItemLayout: indexPath == collectionViewLayout.zoomedItem ? ItemLayout.maxScale : itemLayout)

    return cell
  }

  // MARK: - UICollectionViewDelegate

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if collectionViewLayout.zoomedItem != nil {
      if let cell = collectionView.cellForItemAtIndexPath(indexPath),
      imageView = cell.contentView.subviewWithNametag(imageViewNametag) as? UIImageView
      {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
          imageView.contentMode = .ScaleAspectFill
          imageView.clipsToBounds = true
        })
      }
      collectionViewLayout.zoomedItem = nil
    }
    else {
      let layout = ItemLayout.maxScale
      if sizes[layout]![indexPath.row] == CGSize.zeroSize {
        requestImageAtIndex(indexPath.row, forItemLayout: layout)
      }
      collectionViewLayout.zoomedItem = indexPath
    }
  }

  // MARK: - UICollectionViewFlowLayoutDelegate

  /**
  collectionView:layout:sizeForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: collectionViewLayout UICollectionViewLayout
  :param: indexPath NSIndexPath

  :returns: CGSize
  */
  func collectionView(collectionView: UICollectionView,
               layout collectionViewLayout: UICollectionViewLayout,
sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    if indexPath == self.collectionViewLayout.zoomedItem,
      let size = sizes[ItemLayout.maxScale]?[indexPath.row] where size != CGSize.zeroSize
    {
      return size.aspectMappedToWidth(itemLayout.itemSize.width)
    } else {
      return itemLayout.itemSize
    }
  }

}
