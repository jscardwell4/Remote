//
// RemoteViewController.h
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"

/**
 * `RemoteViewController` is the `UIViewController` subclass responsible for controlling the overall
 * display of the home theater remote control user interface. It utilizes the <RemoteController>
 * model object to coordinate the switching in and out of <RemoteView> subviews that provide the
 * various screens of the overall controller. It also maintains it's own toolbar providing such
 * actions as launching its <RemoteEditingViewController> for editing the current remote and basics
 * like returning to the launch screen.
 */
@interface RERemoteViewController : UIViewController <REEditingDelegate, UIGestureRecognizerDelegate>

/// @name ￼Getting the RemoteViewController

/**
 * Making the `RemoteViewController` a singleton class gives more flexibility when it comes to
 * maintaining view caches, etc. for speeding up transitions to and from an active remote.
 * @return The shared instance of `RemoteViewController`.
 */
// + (RemoteViewController *)sharedRemoteViewController;

/**
 * `IBAction` for toggling the view controller's top toolbar in and out of view.
 * @param sender Object responsible for invoking the method.
 */

- (IBAction)toggleTopToolbarAction:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)editCurrentRemote:(id)sender;

@property (nonatomic, readonly, getter = isTopToolbarVisible) BOOL   topToolbarVisible;

@end
