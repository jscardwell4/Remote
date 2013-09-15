//
// ButtonGroupBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_BUILDING;
#pragma unused(ddLogLevel, msLogContext)

@implementation ButtonGroupBuilder


////////////////////////////////////////////////////////////////////////////////
#pragma mark DPad
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)dPadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithType:REButtonGroupTypeDPad
                                                             context:moc];

    Button * ok = [Button buttonWithType:REButtonTypeDPadCenter context:moc];
    Button * _up = [Button buttonWithType:REButtonTypeDPadUp context:moc];
    Button * down = [Button buttonWithType:REButtonTypeDPadDown context:moc];
    Button * _right = [Button buttonWithType:REButtonTypeDPadRight context:moc];
    Button * _left = [Button buttonWithType:REButtonTypeDPadLeft context:moc];
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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Number Pad
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)numberPadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithType:REButtonGroupTypeNumberpad
                                                             context:moc];

    Button * one = [Button buttonWithType:REButtonTypeNumberpad1 title:@"1" context:moc];
    Button * two = [Button buttonWithType:REButtonTypeNumberpad2 title:@"2" context:moc];
    Button * three = [Button buttonWithType:REButtonTypeNumberpad3 title:@"3" context:moc];
    Button * four = [Button buttonWithType:REButtonTypeNumberpad4 title:@"4" context:moc];
    Button * five = [Button buttonWithType:REButtonTypeNumberpad5 title:@"5" context:moc];
    Button * six = [Button buttonWithType:REButtonTypeNumberpad6 title:@"6" context:moc];
    Button * seven = [Button buttonWithType:REButtonTypeNumberpad7 title:@"7" context:moc];
    Button * _eight = [Button buttonWithType:REButtonTypeNumberpad8 title:@"8" context:moc];
    Button * nine = [Button buttonWithType:REButtonTypeNumberpad9 title:@"9" context:moc];
    Button * zero = [Button buttonWithType:REButtonTypeNumberpad0 title:@"0" context:moc];
    Button * tuck = [Button buttonWithType:REButtonTypeTuck title:kUpArrow context:moc];
    Button * aux1 = [Button buttonWithType:REButtonTypeNumberpadAux1 title:@"Exit" context:moc];
    Button * aux2 = [Button buttonWithType:REButtonTypeNumberpadAux2 title:@"Enter" context:moc];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Transport
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)transportInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithType:REButtonGroupTypeTransport
                                                             context:moc];

    Button * rewind = [Button buttonWithType:REButtonTypeTransportRewind context:moc];
    Button * pause = [Button buttonWithType:REButtonTypeTransportPause context:moc];
    Button * fastForward = [Button buttonWithType:REButtonTypeTransportFF context:moc];
    Button * previous = [Button buttonWithType:REButtonTypeTransportReplay context:moc];
    Button * play = [Button buttonWithType:REButtonTypeTransportPlay context:moc];
    Button * next = [Button buttonWithType:REButtonTypeTransportSkip context:moc];
    Button * record = [Button buttonWithType:REButtonTypeTransportRecord context:moc];
    Button * stop = [Button buttonWithType:REButtonTypeTransportStop context:moc];
    Button * tuck = [Button buttonWithType:REButtonTypeTuck title:kDownArrow context:moc];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Rocker
////////////////////////////////////////////////////////////////////////////////
+ (PickerLabelButtonGroup *)rockerInContext:(NSManagedObjectContext *)moc
{
    PickerLabelButtonGroup * buttonGroup = [PickerLabelButtonGroup buttonGroupWithType:REButtonGroupTypePickerLabel
                                                                                   context:moc];

    // Create top button and add to button group
    Button * _up = [Button buttonWithType:REButtonTypePickerLabelTop context:moc];

    // Create bottom button and add to button group
    Button * down = [Button buttonWithType:REButtonTypePickerLabelBottom context:moc];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark 1x3
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)oneByThreeInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeNoBackground|REThemeNoStyle;

    Button * button1 = [Button remoteElementInContext:moc];
    Button * button2 = [Button remoteElementInContext:moc];
    Button * button3 = [Button remoteElementInContext:moc];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Left Panel
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)verticalPanelInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup remoteElementInContext:moc];

    Button * button1 = [Button remoteElementInContext:moc];
    Button * button2 = [Button remoteElementInContext:moc];
    Button * button3 = [Button remoteElementInContext:moc];
    Button * button4 = [Button remoteElementInContext:moc];
    Button * button5 = [Button remoteElementInContext:moc];
    Button * button6 = [Button remoteElementInContext:moc];
    Button * button7 = [Button remoteElementInContext:moc];
    Button * button8 = [Button buttonWithType:REButtonTypeTuck context:moc];

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
    
    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);
    
    return buttonGroup;
}


@end
