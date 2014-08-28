//
// ConnectionStatusButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "Button.h"
#import "ConnectionManager.h"

@interface ConnectionStatusButtonView ()
@property (nonatomic, strong) MSNotificationReceptionist * receptionist;
@end

@implementation ConnectionStatusButtonView

- (void)initializeIVARs {
  [super initializeIVARs];

  self.selected = [ConnectionManager isWifiAvailable];

  __weak ConnectionStatusButtonView * weakself = self;
  self.receptionist = [MSNotificationReceptionist
                       receptionistForObject:[ConnectionManager class]
                            notificationName:CMConnectionStatusNotification
                                       queue:MainQueue
                                     handler:^(MSNotificationReceptionist *rec, NSNotification *note) {
                                       BOOL selected = weakself.model.selected;
                                       BOOL wifiAvailable = BOOLValue(note.userInfo[CMConnectionStatusWifiAvailable]);
                                       if (selected != wifiAvailable) weakself.model.selected = !selected;
                                     }];
}

@end
