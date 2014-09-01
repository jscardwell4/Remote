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

  self.model.selected = [ConnectionManager isWifiAvailable];

  __weak ConnectionStatusButtonView * weakself = self;
  self.receptionist = [MSNotificationReceptionist
                       receptionistWithObserver:self
                                      forObject:[ConnectionManager class]
                               notificationName:CMConnectionStatusNotification
                                          queue:MainQueue
                                        handler:^(MSNotificationReceptionist * receptionist) {
                                          
                                          ConnectionStatusButtonView * view =
                                            (ConnectionStatusButtonView *)receptionist.observer;
                                          BOOL selected = view.model.selected;
                                          NSDictionary * userInfo = receptionist.notification.userInfo;
                                          NSNumber * value = userInfo[CMConnectionStatusWifiAvailableKey];
                                          BOOL wifiAvailable = BOOLValue(value);

                                          if (selected != wifiAvailable) view.model.selected = !selected;
                                        }];
}

@end
