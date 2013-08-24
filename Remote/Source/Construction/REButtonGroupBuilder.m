//
// REButtonGroupBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_BUILDING;
#pragma unused(ddLogLevel, msLogContext)

@implementation REButtonGroupBuilder


////////////////////////////////////////////////////////////////////////////////
#pragma mark DPad
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)dPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeDPad
                                                             context:moc];

    REButton * ok = [REButton buttonWithType:REButtonTypeDPadCenter context:moc];
    REButton * _up = [REButton buttonWithType:REButtonTypeDPadUp context:moc];
    REButton * down = [REButton buttonWithType:REButtonTypeDPadDown context:moc];
    REButton * _right = [REButton buttonWithType:REButtonTypeDPadRight context:moc];
    REButton * _left = [REButton buttonWithType:REButtonTypeDPadLeft context:moc];
    [buttonGroup addSubelements:[@[ok, _up, down, _left, _right] orderedSet]];

    SetConstraints(buttonGroup,
                   @"ok.centerX = buttonGroup.centerX\n"
                   "ok.centerY = buttonGroup.centerY\n"
                   "ok.width = buttonGroup.width * 0.3\n"
                   "_up.top = buttonGroup.top\n"
                   "_up.bottom = ok.top\n"
                   "_up.left = _left.right\n"
                   "_up.right = _right.left\n"
                   "down.top = ok.bottom\n"
                   "down.bottom = buttonGroup.bottom\n"
                   "down.left = _left.right\n"
                   "down.right = _right.left\n"
                   "_left.left = buttonGroup.left\n"
                   "_left.right = ok.left\n"
                   "_left.top = _up.bottom\n"
                   "_left.bottom = down.top\n"
                   "_right.left = ok.right\n"
                   "_right.right = buttonGroup.right\n"
                   "_right.top = _up.bottom\n"
                   "_right.bottom = down.top\n"
                   "buttonGroup.width = buttonGroup.height\n"
                   "buttonGroup.height = 280",
                   ok, _up, down, _left, _right);

    SetConstraints(ok, @"ok.height = ok.width");

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Number Pad
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)numberPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeNumberpad
                                                             context:moc];

    REButton * one = [REButton buttonWithType:REButtonTypeNumberpad1 title:@"1" context:moc];
    REButton * two = [REButton buttonWithType:REButtonTypeNumberpad2 title:@"2" context:moc];
    REButton * three = [REButton buttonWithType:REButtonTypeNumberpad3 title:@"3" context:moc];
    REButton * four = [REButton buttonWithType:REButtonTypeNumberpad4 title:@"4" context:moc];
    REButton * five = [REButton buttonWithType:REButtonTypeNumberpad5 title:@"5" context:moc];
    REButton * six = [REButton buttonWithType:REButtonTypeNumberpad6 title:@"6" context:moc];
    REButton * seven = [REButton buttonWithType:REButtonTypeNumberpad7 title:@"7" context:moc];
    REButton * _eight = [REButton buttonWithType:REButtonTypeNumberpad8 title:@"8" context:moc];
    REButton * nine = [REButton buttonWithType:REButtonTypeNumberpad9 title:@"9" context:moc];
    REButton * zero = [REButton buttonWithType:REButtonTypeNumberpad0 title:@"0" context:moc];
    REButton * tuck = [REButton buttonWithType:REButtonTypeTuck title:kUpArrow context:moc];
    REButton * aux1 = [REButton buttonWithType:REButtonTypeNumberpadAux1 title:@"Exit" context:moc];
    REButton * aux2 = [REButton buttonWithType:REButtonTypeNumberpadAux2 title:@"Enter" context:moc];

    [buttonGroup addSubelements:[@[one, two, three, four, five, six,
                                   seven, _eight, nine, zero, aux1, aux2, tuck] orderedSet]];

    SetConstraints(buttonGroup,
                   @"one.left = buttonGroup.left\n"
                   "one.top = buttonGroup.top\n"
                   "one.bottom = two.bottom\n"

                   "two.left = one.right\n"
                   "two.top = buttonGroup.top\n"
                   "two.width = one.width\n"

                   "three.left = two.right\n"
                   "three.right = buttonGroup.right\n"
                   "three.top = buttonGroup.top\n"
                   "three.bottom = two.bottom\n"
                   "three.width = one.width\n"

                   "four.left = buttonGroup.left\n"
                   "four.top = one.bottom\n"
                   "four.right = one.right\n"
                   "four.bottom = five.bottom\n"

                   "five.left = two.left\n"
                   "five.top = two.bottom\n"
                   "five.right = two.right\n"
                   "five.height = two.height\n"

                   "six.left = three.left\n"
                   "six.right = buttonGroup.right\n"
                   "six.top = three.bottom\n"
                   "six.bottom = five.bottom\n"

                   "seven.left = buttonGroup.left\n"
                   "seven.top = four.bottom\n"
                   "seven.right = four.right\n"
                   "seven.bottom = _eight.bottom\n"

                   "_eight.left = five.left\n"
                   "_eight.top = five.bottom\n"
                   "_eight.right = five.right\n"
                   "_eight.height = two.height\n"

                   "nine.left = six.left\n"
                   "nine.right = six.right\n"
                   "nine.top = six.bottom\n"
                   "nine.bottom = _eight.bottom\n"

                   "aux1.left = buttonGroup.left\n"
                   "aux1.top = seven.bottom\n"
                   "aux1.bottom = zero.bottom\n"
                   "aux1.right = seven.right\n"

                   "zero.left = _eight.left\n"
                   "zero.top = _eight.bottom\n"
                   "zero.right = _eight.right\n"
                   "zero.bottom = tuck.top\n"
                   "zero.height = two.height\n"

                   "aux2.left = nine.left\n"
                   "aux2.right = buttonGroup.right\n"
                   "aux2.top = nine.bottom\n"
                   "aux2.bottom = zero.bottom\n"

                   "tuck.left = buttonGroup.left\n"
                   "tuck.right = buttonGroup.right\n"
                   "tuck.bottom = buttonGroup.bottom\n"
                   "tuck.height = two.height",
                   one, two, three, four, five, six, seven, _eight, nine, zero, aux1, aux2, tuck);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Transport
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)transportInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeTransport
                                                             context:moc];

    REButton * rewind = [REButton buttonWithType:REButtonTypeTransportRewind context:moc];
    REButton * pause = [REButton buttonWithType:REButtonTypeTransportPause context:moc];
    REButton * fastForward = [REButton buttonWithType:REButtonTypeTransportFF context:moc];
    REButton * previous = [REButton buttonWithType:REButtonTypeTransportReplay context:moc];
    REButton * play = [REButton buttonWithType:REButtonTypeTransportPlay context:moc];
    REButton * next = [REButton buttonWithType:REButtonTypeTransportSkip context:moc];
    REButton * record = [REButton buttonWithType:REButtonTypeTransportRecord context:moc];
    REButton * stop = [REButton buttonWithType:REButtonTypeTransportStop context:moc];
    REButton * tuck = [REButton buttonWithType:REButtonTypeTuck title:kDownArrow context:moc];

    [buttonGroup addSubelements:[@[play, pause, rewind, fastForward, stop,
                                   previous, tuck, next, record] orderedSet]];

    SetConstraints(buttonGroup,
                   @"record.left = buttonGroup.left\n"
                   "record.top = buttonGroup.top\n"
                   "play.left = record.right\n"
                   "play.top = buttonGroup.top\n"
                   "play.bottom = record.bottom\n"
                   "play.width = record.width\n"
                   "stop.left = play.right\n"
                   "stop.right = buttonGroup.right\n"
                   "stop.top = buttonGroup.top\n"
                   "stop.bottom = play.bottom\n"
                   "stop.width = record.width\n"
                   "rewind.left = buttonGroup.left\n"
                   "rewind.top = record.bottom\n"
                   "rewind.right = record.right\n"
                   "rewind.bottom = pause.bottom\n"
                   "pause.left = play.left\n"
                   "pause.top = play.bottom\n"
                   "pause.right = play.right\n"
                   "pause.height = play.height\n"
                   "fastForward.left = stop.left\n"
                   "fastForward.right = buttonGroup.right\n"
                   "fastForward.top = stop.bottom\n"
                   "fastForward.bottom = pause.bottom\n"
                   "previous.left = buttonGroup.left\n"
                   "previous.top = rewind.bottom\n"
                   "previous.right = rewind.right\n"
                   "previous.bottom = buttonGroup.bottom\n"
                   "tuck.left = pause.left\n"
                   "tuck.top = pause.bottom\n"
                   "tuck.right = pause.right\n"
                   "tuck.bottom = buttonGroup.bottom\n"
                   "tuck.height = play.height\n"
                   "next.left = fastForward.left\n"
                   "next.right = buttonGroup.right\n"
                   "next.top = fastForward.bottom\n"
                   "next.bottom = buttonGroup.bottom\n"
                   "buttonGroup.height = buttonGroup.width",
                   play, pause, rewind, fastForward, stop, previous, tuck, next, record);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Rocker
////////////////////////////////////////////////////////////////////////////////
+ (REPickerLabelButtonGroup *)rockerInContext:(NSManagedObjectContext *)moc
{
    REPickerLabelButtonGroup * buttonGroup = [REPickerLabelButtonGroup buttonGroupWithType:REButtonGroupTypePickerLabel
                                                                                   context:moc];

    // Create top button and add to button group
    REButton * _up = [REButton buttonWithType:REButtonTypePickerLabelTop context:moc];

    // Create bottom button and add to button group
    REButton * down = [REButton buttonWithType:REButtonTypePickerLabelBottom context:moc];

    [buttonGroup addSubelements:[@[_up, down] orderedSet]];

    SetConstraints(buttonGroup,
                   @"_up.top = buttonGroup.top\n"
                   "down.top = _up.bottom\n"
                   "down.height = _up.height\n"
                   "_up.left = buttonGroup.left\n"
                   "_up.right = buttonGroup.right\n"
                   "down.left = buttonGroup.left\n"
                   "down.right = buttonGroup.right\n"
                   "_up.height = buttonGroup.height * 0.5\n"
                   "buttonGroup.width = 70\n"
                   "buttonGroup.height ≥ 150",
                   _up, down);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark 1x3
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)oneByThreeInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeNoBackground|REThemeNoStyle;

    REButton * button1 = [REButton remoteElementInContext:moc];
    REButton * button2 = [REButton remoteElementInContext:moc];
    REButton * button3 = [REButton remoteElementInContext:moc];

    [buttonGroup addSubelements:[@[button1, button2, button3] orderedSet]];

    SetConstraints(buttonGroup,
                   @"button1.left = buttonGroup.left\n"
                   "button1.right = buttonGroup.right\n"
                   "button2.left = buttonGroup.left\n"
                   "button2.right = buttonGroup.right\n"
                   "button3.left = buttonGroup.left\n"
                   "button3.right = buttonGroup.right\n"
                   "button1.top = buttonGroup.top\n"
                   "button2.top = button1.bottom + 4\n"
                   "button3.top = button2.bottom + 4\n"
                   "button3.bottom = buttonGroup.bottom\n"
                   "button2.height = button1.height\n"
                   "button3.height = button1.height\n"
                   "buttonGroup.width ≥ 132\n"
                   "buttonGroup.height ≥ 150",
                   button1, button2, button3);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Left Panel
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)verticalPanelInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:moc];

    REButton * button1 = [REButton remoteElementInContext:moc];
    REButton * button2 = [REButton remoteElementInContext:moc];
    REButton * button3 = [REButton remoteElementInContext:moc];
    REButton * button4 = [REButton remoteElementInContext:moc];
    REButton * button5 = [REButton remoteElementInContext:moc];
    REButton * button6 = [REButton remoteElementInContext:moc];
    REButton * button7 = [REButton remoteElementInContext:moc];
    REButton * button8 = [REButton buttonWithType:REButtonTypeTuck context:moc];

    [buttonGroup addSubelements:[@[button1, button2, button3, button4,
                                   button5, button6, button7, button8] orderedSet]];

    SetConstraints(buttonGroup,
                   @"button1.left = buttonGroup.left + 4\n"
                   "button1.right = buttonGroup.right - 4\n"
                   "button2.left = buttonGroup.left + 4\n"
                   "button2.right = buttonGroup.right - 4\n"
                   "button3.left = buttonGroup.left + 4\n"
                   "button3.right = buttonGroup.right - 4\n"
                   "button4.left = buttonGroup.left + 4\n"
                   "button4.right = buttonGroup.right - 4\n"
                   "button5.left = buttonGroup.left + 4\n"
                   "button5.right = buttonGroup.right - 4\n"
                   "button6.left = buttonGroup.left + 4\n"
                   "button6.right = buttonGroup.right - 4\n"
                   "button7.left = buttonGroup.left + 4\n"
                   "button7.right = buttonGroup.right - 4\n"
                   "button8.left = buttonGroup.left + 4\n"
                   "button8.right = buttonGroup.right - 4\n"
                   "button1.top = buttonGroup.top + 4\n"
                   "button2.top = button1.bottom + 4\n"
                   "button3.top = button2.bottom + 4\n"
                   "button4.top = button3.bottom + 4\n"
                   "button5.top = button4.bottom + 4\n"
                   "button6.top = button5.bottom + 4\n"
                   "button7.top = button6.bottom + 4\n"
                   "button8.top = button7.bottom + 4\n"
                   "button8.bottom = buttonGroup.bottom - 4\n"
                   "button2.height = button1.height\n"
                   "button3.height = button1.height\n"
                   "button4.height = button1.height\n"
                   "button5.height = button1.height\n"
                   "button6.height = button1.height\n"
                   "button7.height = button1.height\n"
                   "button8.height = button1.height\n"
                   "buttonGroup.width = 150",
                   button1, button2, button3, button4, button5, button6, button7, button8);
    
    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);
    
    return buttonGroup;
}


@end
