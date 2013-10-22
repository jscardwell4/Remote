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
         commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeRocker];
         commandSet.name = @"Receiver Volume";
         commandSet[@(REButtonRolePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:av[@"Volume Up"]];
         commandSet[@(REButtonRolePickerLabelBottom)] =
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
         commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeRocker];
         commandSet.name = @"DVR Channels";
         commandSet[@(REButtonRolePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:channelUp];
         commandSet[@(REButtonRolePickerLabelBottom)] =
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

         commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeRocker];
         commandSet.name = @"DVR Paging";
         commandSet[@(REButtonRolePickerLabelTop)]    =
             [SendIRCommand commandWithIRCode:pageUp];
         commandSet[@(REButtonRolePickerLabelBottom)] =
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
             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeTransport];
             commandSet[@(REButtonRoleTransportReplay)]    =
                 [SendIRCommand commandWithIRCode:ps3[@"Previous"]];
//             commandSet[@(REButtonTypeTransportStop)]        =
//                 [SendIRCommand commandWithIRCode:ps3[@"Stop"]];
//             commandSet[@(REButtonTypeTransportPlay)]        =
//                 [SendIRCommand commandWithIRCode:ps3[@"Play"]];
//             commandSet[@(REButtonTypeTransportPause)]       =
//                 [SendIRCommand commandWithIRCode:ps3[@"Pause"]];
//             commandSet[@(REButtonTypeTransportSkip)]        =
//                 [SendIRCommand commandWithIRCode:ps3[@"Next"]];
             commandSet[@(REButtonRoleTransportFF)] =
                 [SendIRCommand commandWithIRCode:ps3[@"Scan Forward"]];
             commandSet[@(REButtonRoleTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:ps3[@"Scan Reverse"]];
         }

         else if ([name isEqualToString:@"Dish Hopper"])
         {
             ComponentDevice * hopper  = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                              context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeTransport];
             commandSet[@(REButtonRoleTransportReplay)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"Prev"]];
             commandSet[@(REButtonRoleTransportStop)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Stop"]];
             commandSet[@(REButtonRoleTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Play"]];
             commandSet[@(REButtonRoleTransportPause)]       =
                 [SendIRCommand commandWithIRCode:hopper[@"Pause"]];
             commandSet[@(REButtonRoleTransportSkip)]        =
                 [SendIRCommand commandWithIRCode:hopper[@"Next"]];
             commandSet[@(REButtonRoleTransportFF)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Fast Forward"]];
             commandSet[@(REButtonRoleTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:hopper[@"Rewind"]];
             commandSet[@(REButtonRoleTransportRecord)]      =
                 [SendIRCommand commandWithIRCode:hopper[@"Record"]];

         }

         else if ([name isEqualToString:@"Samsung TV"])
         {
             ComponentDevice * samsungTV   = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                              context:moc];
             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeTransport];
             commandSet[@(REButtonRoleTransportPlay)]        =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Play"]];
             commandSet[@(REButtonRoleTransportPause)]       =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Pause"]];
             commandSet[@(REButtonRoleTransportFF)] =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Fast Forward"]];
             commandSet[@(REButtonRoleTransportRewind)]      =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Rewind"]];
             commandSet[@(REButtonRoleTransportRecord)]      =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Record"]];
         }
     }];

    return commandSet;
}


+ (CommandSet *)numberpadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    __block CommandSet * commandSet = nil;

    [moc performBlockAndWait:
     ^{
         if ([@"Dish Hopper" isEqualToString:name])
         {
             ComponentDevice * hopper  = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                              context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeNumberpad];
             commandSet[@(REButtonRoleNumberpad1)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"One"]];
             commandSet[@(REButtonRoleNumberpad2)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"Two"]];
             commandSet[@(REButtonRoleNumberpad3)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Three"]];
             commandSet[@(REButtonRoleNumberpad4)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Four"]];
             commandSet[@(REButtonRoleNumberpad5)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Five"]];
             commandSet[@(REButtonRoleNumberpad6)]   =
                 [SendIRCommand commandWithIRCode:hopper[@"Six"]];
             commandSet[@(REButtonRoleNumberpad7)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Seven"]];
             commandSet[@(REButtonRoleNumberpad8)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Eight"]];
             commandSet[@(REButtonRoleNumberpad9)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Nine"]];
             commandSet[@(REButtonRoleNumberpad0)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Zero"]];
             commandSet[@(REButtonRoleNumberpadAux1)]     =
                 [SendIRCommand commandWithIRCode:hopper[@"Exit"]];
             commandSet[@(REButtonRoleNumberpadAux2)]     =
                 [SendIRCommand commandWithIRCode:hopper[@"OK"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             // Create number pad button and add to button group
             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeNumberpad];
             commandSet[@(REButtonRoleNumberpad1)] = [SendIRCommand commandWithIRCode:ps3[@"1"]];
             commandSet[@(REButtonRoleNumberpad2)] = [SendIRCommand commandWithIRCode:ps3[@"2"]];
             commandSet[@(REButtonRoleNumberpad3)] = [SendIRCommand commandWithIRCode:ps3[@"3"]];
             commandSet[@(REButtonRoleNumberpad4)] = [SendIRCommand commandWithIRCode:ps3[@"4"]];
             commandSet[@(REButtonRoleNumberpad5)] = [SendIRCommand commandWithIRCode:ps3[@"5"]];
             commandSet[@(REButtonRoleNumberpad6)] = [SendIRCommand commandWithIRCode:ps3[@"6"]];
             commandSet[@(REButtonRoleNumberpad7)] = [SendIRCommand commandWithIRCode:ps3[@"7"]];
             commandSet[@(REButtonRoleNumberpad8)] = [SendIRCommand commandWithIRCode:ps3[@"8"]];
             commandSet[@(REButtonRoleNumberpad9)] = [SendIRCommand commandWithIRCode:ps3[@"9"]];
             commandSet[@(REButtonRoleNumberpad0)] = [SendIRCommand commandWithIRCode:ps3[@"0"]];

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

             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeDPad];
             commandSet[@(REButtonRoleDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"OK"]];
             commandSet[@(REButtonRoleDPadUp)]    =
                 [SendIRCommand commandWithIRCode:hopper[@"Up"]];
             commandSet[@(REButtonRoleDPadDown)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Down"]];
             commandSet[@(REButtonRoleDPadLeft)] =
                 [SendIRCommand commandWithIRCode:hopper[@"Right"]];
             commandSet[@(REButtonRoleDPadRight)]  =
                 [SendIRCommand commandWithIRCode:hopper[@"Left"]];
         }

         else if ([@"PS3" isEqualToString:name])
         {
             ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeDPad];
             commandSet[@(REButtonRoleDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:ps3[@"Enter"]];
//             commandSet[@(REButtonTypeDPadUp)]    =
//                 [SendIRCommand commandWithIRCode:ps3[@"Up"]];
//             commandSet[@(REButtonTypeDPadDown)]  =
//                 [SendIRCommand commandWithIRCode:ps3[@"Down"]];
//             commandSet[@(REButtonTypeDPadLeft)] =
//                 [SendIRCommand commandWithIRCode:ps3[@"Right"]];
//             commandSet[@(REButtonTypeDPadRight)]  =
//                 [SendIRCommand commandWithIRCode:ps3[@"Left"]];
         }

         else if ([@"Samsung TV" isEqualToString:name])
         {
             ComponentDevice * samsungTV = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                            context:moc];

             commandSet = [CommandSet commandSetInContext:moc type:CommandSetTypeDPad];
             commandSet[@(REButtonRoleDPadCenter)]    =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Enter"]];
             commandSet[@(REButtonRoleDPadUp)]    =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Up"]];
             commandSet[@(REButtonRoleDPadDown)]  =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Down"]];
             commandSet[@(REButtonRoleDPadLeft)] =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Right"]];
             commandSet[@(REButtonRoleDPadRight)]  =
                 [SendIRCommand commandWithIRCode:samsungTV[@"Left"]];
         }
     }];

    return commandSet;
}

@end
