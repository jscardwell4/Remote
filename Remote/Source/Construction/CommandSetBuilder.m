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

+ (CommandSet *)hopperChannelsCommandSet:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         ComponentDevice * hopper = [ComponentDevice fetchDeviceWithName:@"Dish Hopper" context:moc];
         NSSet * codes = hopper.codes;
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



+ (CommandSet *)hopperPagingCommandSet:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         ComponentDevice * hopper = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                  context:moc];
         NSSet * codes = hopper.codes;
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

         else if ([name isEqualToString:@"Dish Hopper"])
         {
             ComponentDevice * hopper  = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                              context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeTransport];
             commandSet[@(REButtonTypeTransportReplay)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"Prev"]];
             commandSet[@(REButtonTypeTransportStop)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Stop"]];
             commandSet[@(REButtonTypeTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Play"]];
             commandSet[@(REButtonTypeTransportPause)]       =
                 [SendIRCommand commandWithIRCode:hopper[@"Pause"]];
             commandSet[@(REButtonTypeTransportSkip)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Next"]];
             commandSet[@(REButtonTypeTransportFF)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Fast Forward"]];
             commandSet[@(REButtonTypeTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:hopper[@"Rewind"]];
             commandSet[@(REButtonTypeTransportRecord)]      =
                 [SendIRCommand commandWithIRCode:hopper[@"Record"]];

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
         if ([@"Dish Hopper" isEqualToString:name])
         {
             ComponentDevice * hopper  = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                              context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeNumberPad];
             commandSet[@(REButtonTypeNumberpad1)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"One"]];
             commandSet[@(REButtonTypeNumberpad2)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"Two"]];
             commandSet[@(REButtonTypeNumberpad3)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Three"]];
             commandSet[@(REButtonTypeNumberpad4)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Four"]];
             commandSet[@(REButtonTypeNumberpad5)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Five"]];
             commandSet[@(REButtonTypeNumberpad6)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"Six"]];
             commandSet[@(REButtonTypeNumberpad7)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Seven"]];
             commandSet[@(REButtonTypeNumberpad8)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Eight"]];
             commandSet[@(REButtonTypeNumberpad9)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Nine"]];
             commandSet[@(REButtonTypeNumberpad0)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Zero"]];
             commandSet[@(REButtonTypeNumberpadAux1)]     =
                 [SendIRCommand commandWithIRCode:hopper[@"Exit"]];
             commandSet[@(REButtonTypeNumberpadAux2)]     =
                 [SendIRCommand commandWithIRCode:hopper[@"OK"]];
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
         if ([@"Dish Hopper" isEqualToString:name])
         {
             ComponentDevice * hopper  = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                              context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:RECommandSetTypeDPad];
             commandSet[@(REButtonTypeDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"OK"]];
             commandSet[@(REButtonTypeDPadUp)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"Up"]];
             commandSet[@(REButtonTypeDPadDown)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Down"]];
             commandSet[@(REButtonTypeDPadLeft)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Right"]];
             commandSet[@(REButtonTypeDPadRight)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Left"]];
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
