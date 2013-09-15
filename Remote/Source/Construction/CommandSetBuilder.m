//
//  CommandSetBuilder.m
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

@implementation CommandSetBuilder

@end

@implementation CommandSetBuilder (Developer)

+ (CommandSet *)avReceiverVolumeCommandSet:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         ComponentDevice * av = [ComponentDevice fetchDeviceWithName:@"AV Receiver" context:moc];
         commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"Receiver Volume";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:av[@"Volume Up"]];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [SendIRCommand commandWithIRCode:av[@"Volume Down"]];
     }];

    return commandSet;
}

+ (CommandSet *)dvrChannelsCommandSet:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         ComponentDevice * dvr = [ComponentDevice fetchDeviceWithName:@"Comcast DVR" context:moc];
         NSSet * codes = dvr.codes;
         IRCode * channelUp = [codes objectPassingTest:^BOOL(IRCode * code) {
             return [code.name isEqualToString:@"Channel Up"];
         }];
         IRCode * channelDown = [codes objectPassingTest:^BOOL(IRCode * code) {
             return [code.name isEqualToString:@"Channel Down"];
         }];
         commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"DVR Channels";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:channelUp];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [SendIRCommand commandWithIRCode:channelDown];
     }];

    return commandSet;
}



+ (CommandSet *)dvrPagingCommandSet:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         ComponentDevice * dvr = [ComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                  context:moc];
         NSSet * codes = dvr.codes;
         IRCode * pageUp = [codes objectPassingTest:^BOOL(IRCode * code) {
             return [code.name isEqualToString:@"Page Up"];
         }];
         IRCode * pageDown = [codes objectPassingTest:^BOOL(IRCode * code) {
             return [code.name isEqualToString:@"Page Down"];
         }];

         commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeRocker];
         commandSet.name = @"DVR Paging";
         commandSet[@(REButtonTypePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:pageUp];
         commandSet[@(REButtonTypePickerLabelBottom)] =
             [SendIRCommand commandWithIRCode:pageDown];
     }];

    return commandSet;
}


+ (CommandSet *)transportForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([name isEqualToString:@"PS3"])
         {

             ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportReplay)]    =
                 [SendIRCommand commandWithIRCode:ps3[@"Previous"]];
             commandSet[@(REButtonTypeTransportStop)]        =
                 [SendIRCommand commandWithIRCode:ps3[@"Stop"]];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:ps3[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [SendIRCommand commandWithIRCode:ps3[@"Pause"]];
             commandSet[@(REButtonTypeTransportSkip)]        =
                 [SendIRCommand commandWithIRCode:ps3[@"Next"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [SendIRCommand commandWithIRCode:ps3[@"Scan Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:ps3[@"Scan Reverse"]];
         }

         else if ([name isEqualToString:@"Comcast DVR"])
         {
             ComponentDevice * comcastDVR  = [ComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportReplay)]    =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Prev"]];
             commandSet[@(REButtonTypeTransportStop)]        =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Stop"]];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Pause"]];
             commandSet[@(REButtonTypeTransportSkip)]        =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Next"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Fast Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Rewind"]];
             commandSet[@(REButtonTypeTransportRecord)]      =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Record"]];

         }

         else if ([name isEqualToString:@"Samsung TV"])
         {
             ComponentDevice * samsungTV   = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                              context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Pause"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Fast Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Rewind"]];
             commandSet[@(REButtonTypeTransportRecord)]      =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Record"]];
         }
     }];

    return commandSet;
}


+ (CommandSet *)numberPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([@"Comcast DVR" isEqualToString:name])
         {
             ComponentDevice * comcastDVR  = [ComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeNumberPad];
             commandSet[@(REButtonTypeNumberpad1)]   =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"One"]];
             commandSet[@(REButtonTypeNumberpad2)]   =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Two"]];
             commandSet[@(REButtonTypeNumberpad3)] =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Three"]];
             commandSet[@(REButtonTypeNumberpad4)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Four"]];
             commandSet[@(REButtonTypeNumberpad5)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Five"]];
             commandSet[@(REButtonTypeNumberpad6)]   =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Six"]];
             commandSet[@(REButtonTypeNumberpad7)] =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Seven"]];
             commandSet[@(REButtonTypeNumberpad8)] =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Eight"]];
             commandSet[@(REButtonTypeNumberpad9)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Nine"]];
             commandSet[@(REButtonTypeNumberpad0)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Zero"]];
             commandSet[@(REButtonTypeNumberpadAux1)]     =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Exit"]];
             commandSet[@(REButtonTypeNumberpadAux2)]     =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"OK"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             // Create number pad button and add to button group
             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeNumberPad];
             commandSet[@(REButtonTypeNumberpad1)] = [SendIRCommand commandWithIRCode:ps3[@"1"]];
             commandSet[@(REButtonTypeNumberpad2)] = [SendIRCommand commandWithIRCode:ps3[@"2"]];
             commandSet[@(REButtonTypeNumberpad3)] = [SendIRCommand commandWithIRCode:ps3[@"3"]];
             commandSet[@(REButtonTypeNumberpad4)] = [SendIRCommand commandWithIRCode:ps3[@"4"]];
             commandSet[@(REButtonTypeNumberpad5)] = [SendIRCommand commandWithIRCode:ps3[@"5"]];
             commandSet[@(REButtonTypeNumberpad6)] = [SendIRCommand commandWithIRCode:ps3[@"6"]];
             commandSet[@(REButtonTypeNumberpad7)] = [SendIRCommand commandWithIRCode:ps3[@"7"]];
             commandSet[@(REButtonTypeNumberpad8)] = [SendIRCommand commandWithIRCode:ps3[@"8"]];
             commandSet[@(REButtonTypeNumberpad9)] = [SendIRCommand commandWithIRCode:ps3[@"9"]];
             commandSet[@(REButtonTypeNumberpad0)] = [SendIRCommand commandWithIRCode:ps3[@"0"]];

         }
     }];

    return commandSet;
}

+ (CommandSet *)dPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([@"Comcast DVR" isEqualToString:name])
         {
             ComponentDevice * comcastDVR  = [ComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                              context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"OK"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [SendIRCommand commandWithIRCode:comcastDVR[@"Left"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:ps3[@"Enter"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [SendIRCommand commandWithIRCode:ps3[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [SendIRCommand commandWithIRCode:ps3[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [SendIRCommand commandWithIRCode:ps3[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [SendIRCommand commandWithIRCode:ps3[@"Left"]];
         }

         else if ([@"Samsung TV" isEqualToString:name])
         {
             ComponentDevice * samsungTV = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                            context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Enter"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Left"]];
         }
     }];

    return commandSet;
}

@end
