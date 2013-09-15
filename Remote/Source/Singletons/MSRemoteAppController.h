//
// MSRemoteAppController.h
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

/**
 * The application delegate and primary controller.
 *
 * Valid launch arguments include:
 *
 * -simulate [YES|NO]		If YES, commands are not sent over wifi and response is always success.
 * -remote [YES|NO]     If YES, the remote controller is rebuilt.
 * -replace [YES|NO]	If YES, database on device is replaced with database from bundle.
 * -rebuild [YES|NO]	If YES, database is rebuilt from scratch.
 * -uitest [YES|NO]		If YES, UI testing will begin after launch completes.
 *
 */
@interface MSRemoteAppController : NSObject <UIApplicationDelegate>

/**
 * @return The shared instance of MSRemoteAppController
 */
+ (MSRemoteAppController *)sharedAppController;

/**
 * Method for getting a string with the information about the current build, i.e. 'debug,'
 * 'debug-rebuild,'…. Info is pulled from arguments passed upon launch as well as preprocessor
 * defines.
 *
 * @return String containing the current build version
 */
+ (NSString const *)versionInfo;

- (void)showMainMenu;

- (void)showRemote;

- (void)showEditor;

- (void)showBank;

- (void)showSettings;

- (void)showHelp;

- (void)dismissViewController:(UIViewController *)viewController completion:(void (^)(void))completion;

@property (nonatomic, strong) IBOutlet UIWindow * window;

@end

#define AppController [MSRemoteAppController sharedAppController]
