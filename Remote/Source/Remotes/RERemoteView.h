//
// RemoteView.h
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "REButtonGroupView.h"

/* Dictionary keys defined by implementation */
MSKIT_EXTERN_STRING   kTopPanelOneKey;
MSKIT_EXTERN_STRING   kBottomPanelOneKey;
MSKIT_EXTERN_STRING   kLeftPanelOneKey;
MSKIT_EXTERN_STRING   kRightPanelOneKey;
MSKIT_EXTERN_STRING   kTopPanelTwoKey;
MSKIT_EXTERN_STRING   kBottomPanelTwoKey;
MSKIT_EXTERN_STRING   kLeftPanelTwoKey;
MSKIT_EXTERN_STRING   kRightPanelTwoKey;
MSKIT_EXTERN_STRING   kTopPanelThreeKey;
MSKIT_EXTERN_STRING   kBottomPanelThreeKey;
MSKIT_EXTERN_STRING   kLeftPanelThreeKey;
MSKIT_EXTERN_STRING   kRightPanelThreeKey;

#import "REView.h"

#import "RERemote.h"

@interface RERemoteView : REView

@property (nonatomic, assign) BOOL   buttonGroupsLocked;

/**
 * Returns the button group registered for the specified panel.
 * @param panelKey The panel for which the registered button group should be returned.
 * @return The `ButtonGroupView` registered for the specified panel or nil if it doesn't exist.
 */
- (REButtonGroupView *)panelForKey:(NSString *)panelKey;

/**
 * Called by a `ButtonGroupView` object registered as a panel to indicate it should be
 * hidden.
 */
- (void)tuckRequestFromButtonGroupView:(REButtonGroupView *)buttonGroupView;

@property (nonatomic, strong) RERemote * model;

@end

@interface RERemoteView (RemoteProperties)

@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL   topBarHiddenOnLoad;

@end
