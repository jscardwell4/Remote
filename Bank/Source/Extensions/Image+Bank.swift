//
//  Image+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData
import Photos

extension Image: Previewable {}

extension Image: Detailable {
  func detailController() -> UIViewController { return ImageDetailController(model: self) }
}

extension Image: CustomCreatable {
  static func creationControllerWithContext(context: NSManagedObjectContext,
                        cancellationHandler didCancel: () -> Void,
                            creationHandler didCreate: (ModelObject) -> Void) -> UIViewController
  {
    let userPhotoLibrary =
      PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum,
                                              subtype: .SmartAlbumUserLibrary,
                                              options: nil)?.firstObject as! PHAssetCollection

    return PhotoCollectionBrowser(collection: userPhotoLibrary) {
      controller, selection in

        // Create the image if a selection has been made
        if let data = selection?.data, image = UIImage(data: data) {
          let form = Form(templates: ["Name": self.nameFormFieldTemplate(context: context)])
          let didSubmit: FormViewController.Submission = {
            if let name = $0.values?["Name"] as? String {
              context.performBlock {
                let imageModel = Image(image: image, context: context)
                imageModel.name = name
                didCreate(imageModel)
              }
            } else { didCancel() }
          }
          let formViewController = FormViewController(form: form, didSubmit: didSubmit, didCancel: didCancel)
          controller.presentViewController(formViewController, animated: true, completion: nil)
        }

        // Otherwise call the cancellation handler
        else { didCancel() }
    }
  }
}
