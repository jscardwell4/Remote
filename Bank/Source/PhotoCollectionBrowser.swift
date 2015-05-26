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

// TODO: Add selection callback or delegate protocol
// TODO: Remember previously used item scale

private let reuseIdentifier = "Cell"
private let imageViewNametag = "image"

class PhotoCollectionBrowser: UIViewController, PhotoBrowserLayoutDelegate, UICollectionViewDataSource {

  // MARK: - Properties

  @IBOutlet weak var scaleSlider: UISlider!

  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var collectionViewLayout: PhotoBrowserLayout!

  typealias ItemScale = PhotoBrowserLayout.ItemScale

  /** The `PHAsset` objects fetched from the `PHAssetCollection` passed to `initWithCollection:` */
  let assets: PHFetchResult

  /** Property of  convenience */
  private let manager = PHImageManager.defaultManager()

  /** Holds IDs of outstanding `PHImageManager` requests */
  private var requests: Set<PHImageRequestID> = []

  private let sizes: [(width: Int, height: Int)]

  // MARK: - Actions

  /**
  Scales from 8 cells across to just 1 cell across

  :param: sender UISlider
  */
  @IBAction func updateScale(sender: UISlider) {
    collectionViewLayout.itemScale = ItemScale(rawValue: sender.value)
    apply(collectionView.indexPathsForVisibleItems() as! [NSIndexPath]){self.requestImageAtIndexPath($0)}
  }

  /** Dismiss the controller */
  @IBAction func cancel() { dismissViewControllerAnimated(true, completion: nil) }

  /** Right toolbar button for the top toolbar */
  @IBOutlet weak var selectButton: UIBarButtonItem!

  /** Selects the zoomed item */
  @IBAction func select() { MSLogDebug("picked an image muthafucka!!!!") }

  // MARK: - Initialization

  /**
  initWithCollection:

  :param: collection PHAssetCollection
  */
  init(collection: PHAssetCollection) {
    let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
    sizes = map(0..<fetchResult.count){
      let asset = fetchResult[$0] as! PHAsset
      return (width: asset.pixelWidth, height: asset.pixelHeight)
    }
    assets = fetchResult
    super.init(nibName: "PhotoCollectionBrowser", bundle: Bank.bundle)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    scaleSlider.minimumValue = ItemScale.minScale.normalized
    scaleSlider.maximumValue = ItemScale.maxScale.normalized
    scaleSlider.value = collectionViewLayout.itemScale.normalized

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
      cell.backgroundColor = UIColor.clearColor()
      cell.opaque = false
      cell.contentView.backgroundColor = UIColor.clearColor()
      cell.contentView.opaque = false

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
  :param: size CGSize
  :param: mode PHImageContentMode
  */
  private func requestImageAtIndexPath(indexPath: NSIndexPath) {
    precondition(indexPath.row < assets.count, "index out of range")

    let asset = assets[indexPath.row] as! PHAsset

    let handler: (UIImage!, [NSObject:AnyObject]!) -> Void = { [weak self] in
      self?.handleRequestResult((image: $0, info: $1), forIndexPath: indexPath)
    }

    let mode: PHImageContentMode
    let size: CGSize

    if indexPath == collectionViewLayout.zoomedItem { size = sizeForZoomedItemAtIndexPath(indexPath); mode = .AspectFit }
    else { size = collectionViewLayout.itemScale.itemSize; mode = .AspectFill }

    requests.insert(manager.requestImageForAsset(asset, targetSize: size, contentMode: mode, options: nil, resultHandler: handler))
  }

  /**
  A handler for `PHImageManager` request result. Updates cell's image view's image, logs cancellation, or handles error.

  :param: result RequestResult
  :param: indexPath NSIndexPath
  */
  private func handleRequestResult(result: RequestResult, forIndexPath indexPath: NSIndexPath) {

    let requestID = (result.info[PHImageResultRequestIDKey] as! NSNumber).intValue

    if let isCancelled = result.info[PHImageCancelledKey] as? Bool where isCancelled == true {
      MSLogDebug("request with id \(requestID) cancelled")
    }

    else if let error = result.info[PHImageErrorKey] as? NSError {
      MSHandleError(error, message: "problem encountered loading image with request id \(requestID)")
    }

    else if let image = result.image {
      requests.remove(requestID)

      if let imageView = collectionView.cellForItemAtIndexPath(indexPath)?.contentView[imageViewNametag] as? UIImageView {
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

    let scale = indexPath == collectionViewLayout.zoomedItem ? ItemScale.maxScale : collectionViewLayout.itemScale
    requestImageAtIndexPath(indexPath)

    return cell
  }

  // MARK: - UICollectionViewDelegate

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if collectionViewLayout.zoomedItem != nil { collectionViewLayout.zoomedItem = nil }
    else { collectionViewLayout.zoomedItem = indexPath; requestImageAtIndexPath(indexPath) }
    selectButton.enabled = collectionViewLayout.zoomedItem != nil
  }

  // MARK: - PhotoBrowserLayoutDelegate

  /**
  sizeForZoomedItemInCollectionView:layout:

  :param: collectionView UICollectionView
  :param: layout PhotoBrowserLayout

  :returns: CGSize
  */
  func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
    let ratio = Ratio(sizes[indexPath.row].width, sizes[indexPath.row].height)
    let width  = ItemScale.maxScale.itemSize.width
    let height = ratio.denominatorForNumerator(width)
    return CGSize(width: width, height: height)
  }

}
