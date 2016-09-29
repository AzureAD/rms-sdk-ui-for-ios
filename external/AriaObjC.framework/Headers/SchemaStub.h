//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//
#ifndef SchemaStub_h
#define SchemaStub_h

enum ACTPiiKind
{
    ACTPiiKindNone                = 0,
    ACTPiiKindDistinguishedName   = 1,
    ACTPiiKindGenericData         = 2,
    ACTPiiKindIPv4Address         = 3,
    ACTPiiKindIPv6Address         = 4,
    ACTPiiKindMailSubject         = 5,
    ACTPiiKindPhoneNumber         = 6,
    ACTPiiKindQueryString         = 7,
    ACTPiiKindSipAddress          = 8,
    ACTPiiKindSmtpAddress         = 9,
    ACTPiiKindIdentity            = 10,
    ACTPiiKindUri                 = 11,
    ACTPiiKindFqdn                = 12
};

enum ACTAppLifecycleState
{
    ACTAppLifecycleStateUnknown   = 0,
    ACTAppLifecycleStateLaunch    = 1,
    ACTAppLifecycleStateExit      = 2,
    ACTAppLifecycleStateSuspend   = 3,
    ACTAppLifecycleStateResume    = 4,
    ACTAppLifecycleStateForeground= 5,
    ACTAppLifecycleStateBackground= 6
};

enum ACTActionType
{    
    ACTActionTypeUnspecified  = 0,
    ACTActionTypeUnknown      = 1,
    ACTActionTypeOther        = 2,
    ACTActionTypeClick        = 3,
    ACTActionTypePan          = 5,
    ACTActionTypeZoom         = 6,
    ACTActionTypeHover        = 7
};

enum ACTRawActionType
{
    ACTRawActionTypeUnspecified           = 0,
    ACTRawActionTypeUnknown               = 1,
    ACTRawActionTypeOther                 = 2,
    ACTRawActionTypeLButtonDoubleClick    = 11,
    ACTRawActionTypeLButtonDown           = 12,
    ACTRawActionTypeLButtonUp             = 13,
    ACTRawActionTypeMButtonDoubleClick    = 14,
    ACTRawActionTypeMButtonDown           = 15,
    ACTRawActionTypeMButtonUp             = 16,
    ACTRawActionTypeMouseHover            = 17,
    ACTRawActionTypeMouseWheel            = 18,
    ACTRawActionTypeMouseMove             = 20,
    ACTRawActionTypeRButtonDoubleClick    = 22,
    ACTRawActionTypeRButtonDown           = 23,
    ACTRawActionTypeRButtonUp             = 24,
    ACTRawActionTypeTouchTap              = 50,
    ACTRawActionTypeTouchDoubleTap        = 51,
    ACTRawActionTypeTouchLongPress        = 52,
    ACTRawActionTypeTouchScroll           = 53,
    ACTRawActionTypeTouchPan              = 54,
    ACTRawActionTypeTouchFlick            = 55,
    ACTRawActionTypeTouchPinch            = 56,
    ACTRawActionTypeTouchZoom             = 57,
    ACTRawActionTypeTouchRotate           = 58,
    ACTRawActionTypeKeyboardPress         = 100,
    ACTRawActionTypeKeyboardEnter         = 101
};

enum ACTInputDeviceType
{
    ACTInputDeviceTypeUnspecified = 0,
    ACTInputDeviceTypeUnknown     = 1,
    ACTInputDeviceTypeOther       = 2,
    ACTInputDeviceTypeMouse       = 3,
    ACTInputDeviceTypeKeyboard    = 4,
    ACTInputDeviceTypeTouch       = 5,
    ACTInputDeviceTypeStylus      = 6,
    ACTInputDeviceTypeMicrophone  = 7,
    ACTInputDeviceTypeKinect      = 8,
    ACTInputDeviceTypeCamera      = 9
};

enum ACTTraceLevel
{
    ACTTraceLevelNone         = 0,
    ACTTraceLevelError        = 1,
    ACTTraceLevelWarning      = 2,
    ACTTraceLevelInformation  = 3,
    ACTTraceLevelVerbose      = 4
};

enum ACTPowerSource
{
    ACTPowerSourceUnknown         = 0,
    ACTPowerSourceBattery         = 1,
    ACTPowerSourceAC              = 2
};

enum ACTNetworkCost
{
    ACTNetworkCostUnknown         = 0,
    ACTNetworkCostUnmetered       = 1,
    ACTNetworkCostMetered         = 2,
    ACTNetworkCostOverDataLimit   = 3
};
enum ACTNetworkType
{
    ACTNetworkTypeUnknown         = 0,
    ACTNetworkTypeWired           = 1,
    ACTNetworkTypeWifi            = 2,
    ACTNetworkTypeWWAN            = 3
};

#endif // SchemaStub_h
