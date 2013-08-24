//
//  RECommandSetBuilder.m
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

@implementation RECommandSetBuilder

@end

@implementation RECommandSetBuilder (Developer)

+ (RECommandSet *)avReceiverVolumeCommandSet:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         BOComponentDevice * av = [BOComponentDevice fetchDeviceWithName:@"AV Receiver" context:moc];
         commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"Receiver Volume";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [RESendIRCommand commandWithIRCode:av[@"Volume Up"]];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [RESendIRCommand commandWithIRCode:av[@"Volume Down"]];
     }];

    return commandSet;
}

+ (RECommandSet *)dvrChannelsCommandSet:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         BOComponentDevice * dvr = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR" context:moc];
         NSSet * codes = dvr.codes;
         BOIRCode * channelUp = [codes objectPassingTest:^BOOL(BOIRCode * code) {
             return [code.name isEqualToString:@"Channel Up"];
         }];
         BOIRCode * channelDown = [codes objectPassingTest:^BOOL(BOIRCode * code) {
             return [code.name isEqualToString:@"Channel Down"];
         }];
         commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"DVR Channels";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [RESendIRCommand commandWithIRCode:channelUp];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [RESendIRCommand commandWithIRCode:channelDown];
     }];

    return commandSet;
}



+ (RECommandSet *)dvrPagingCommandSet:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         BOComponentDevice * dvr = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                  context:moc];
         NSSet * codes = dvr.codes;
         BOIRCode * pageUp = [codes objectPassingTest:^BOOL(BOIRCode * code) {
             return [code.name isEqualToString:@"Page Up"];
         }];
         BOIRCode * pageDown = [codes objectPassingTest:^BOOL(BOIRCode * code) {
             return [code.name isEqualToString:@"Page Down"];
         }];

         commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"DVR Paging";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [RESendIRCommand commandWithIRCode:pageUp];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [RESendIRCommand commandWithIRCode:pageDown];
     }];

    return commandSet;
}


+ (RECommandSet *)transportForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([name isEqualToString:@"PS3"])
         {

             BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3" context:moc];
             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportReplay)]    =
                 [RESendIRCommand commandWithIRCode:ps3[@"Previous"]];
             commandSet[@(REButtonTypeTransportStop)]        =
                 [RESendIRCommand commandWithIRCode:ps3[@"Stop"]];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [RESendIRCommand commandWithIRCode:ps3[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [RESendIRCommand commandWithIRCode:ps3[@"Pause"]];
             commandSet[@(REButtonTypeTransportSkip)]        =
                 [RESendIRCommand commandWithIRCode:ps3[@"Next"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [RESendIRCommand commandWithIRCode:ps3[@"Scan Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [RESendIRCommand commandWithIRCode:ps3[@"Scan Reverse"]];
         }

         else if ([name isEqualToString:@"Comcast DVR"])
         {
             BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];
             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportReplay)]    =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Prev"]];
             commandSet[@(REButtonTypeTransportStop)]        =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Stop"]];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Pause"]];
             commandSet[@(REButtonTypeTransportSkip)]        =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Next"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Fast Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Rewind"]];
             commandSet[@(REButtonTypeTransportRecord)]      =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Record"]];

         }

         else if ([name isEqualToString:@"Samsung TV"])
         {
             BOComponentDevice * samsungTV   = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                              context:moc];
             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Pause"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Fast Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Rewind"]];
             commandSet[@(REButtonTypeTransportRecord)]      =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Record"]];
         }
     }];

    return commandSet;
}


+ (RECommandSet *)numberPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([@"Comcast DVR" isEqualToString:name])
         {
             BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];

             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeNumberPad];
             commandSet[@(REButtonTypeNumberpad1)]   =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"One"]];
             commandSet[@(REButtonTypeNumberpad2)]   =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Two"]];
             commandSet[@(REButtonTypeNumberpad3)] =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Three"]];
             commandSet[@(REButtonTypeNumberpad4)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Four"]];
             commandSet[@(REButtonTypeNumberpad5)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Five"]];
             commandSet[@(REButtonTypeNumberpad6)]   =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Six"]];
             commandSet[@(REButtonTypeNumberpad7)] =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Seven"]];
             commandSet[@(REButtonTypeNumberpad8)] =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Eight"]];
             commandSet[@(REButtonTypeNumberpad9)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Nine"]];
             commandSet[@(REButtonTypeNumberpad0)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Zero"]];
             commandSet[@(REButtonTypeNumberpadAux1)]     =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Exit"]];
             commandSet[@(REButtonTypeNumberpadAux2)]     =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"OK"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             // Create number pad button and add to button group
             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeNumberPad];
             commandSet[@(REButtonTypeNumberpad1)] = [RESendIRCommand commandWithIRCode:ps3[@"1"]];
             commandSet[@(REButtonTypeNumberpad2)] = [RESendIRCommand commandWithIRCode:ps3[@"2"]];
             commandSet[@(REButtonTypeNumberpad3)] = [RESendIRCommand commandWithIRCode:ps3[@"3"]];
             commandSet[@(REButtonTypeNumberpad4)] = [RESendIRCommand commandWithIRCode:ps3[@"4"]];
             commandSet[@(REButtonTypeNumberpad5)] = [RESendIRCommand commandWithIRCode:ps3[@"5"]];
             commandSet[@(REButtonTypeNumberpad6)] = [RESendIRCommand commandWithIRCode:ps3[@"6"]];
             commandSet[@(REButtonTypeNumberpad7)] = [RESendIRCommand commandWithIRCode:ps3[@"7"]];
             commandSet[@(REButtonTypeNumberpad8)] = [RESendIRCommand commandWithIRCode:ps3[@"8"]];
             commandSet[@(REButtonTypeNumberpad9)] = [RESendIRCommand commandWithIRCode:ps3[@"9"]];
             commandSet[@(REButtonTypeNumberpad0)] = [RESendIRCommand commandWithIRCode:ps3[@"0"]];

         }
     }];

    return commandSet;
}

+ (RECommandSet *)dPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block RECommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([@"Comcast DVR" isEqualToString:name])
         {
             BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];

             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"OK"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [RESendIRCommand commandWithIRCode:comcastDVR[@"Left"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [RESendIRCommand commandWithIRCode:ps3[@"Enter"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [RESendIRCommand commandWithIRCode:ps3[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [RESendIRCommand commandWithIRCode:ps3[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [RESendIRCommand commandWithIRCode:ps3[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [RESendIRCommand commandWithIRCode:ps3[@"Left"]];
         }

         else if ([@"Samsung TV" isEqualToString:name])
         {
             BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                            context:moc];

             commandSet = [RECommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Enter"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [RESendIRCommand commandWithIRCode:samsungTV[@"Left"]];
         }
     }];

    return commandSet;
}

@end
