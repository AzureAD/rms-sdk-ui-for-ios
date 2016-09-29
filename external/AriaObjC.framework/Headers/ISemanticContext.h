#ifndef ISemanticContext_h
#define ISemanticContext_h
//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SchemaStub.h"

@protocol ACTISemanticContext<NSObject>

-(void) setAppId:(nonnull NSString*)anId;
-(void) setAppVersion:(nonnull NSString*)appVersion;
-(void) setDeviceId:(nonnull NSString*)deviceId;
-(void) setDeviceMake:(nonnull NSString*)deviceMake;
-(void) setDeviceModel:(nonnull NSString*)deviceModel;
-(void) setNetworkProvider:(nonnull NSString*)networkProvider;
-(void) setOsName:(nonnull NSString*)osName;
-(void) setOsVersion:(nonnull NSString*)osVersion;
-(void) setOsBuild:(nonnull NSString*)osBuild;
-(void) setUserId:(nonnull NSString*)userId piiKind:(enum ACTPiiKind)pii;
-(void) setUserMsaId:(nonnull NSString*)userMsaId;
-(void) setUserId:(nonnull NSString*)userId;
-(void) setUserANID:(nonnull NSString*)userANID;
-(void) setUserAdvertisingId:(nonnull NSString*)userAdvertisingId;
-(void) setUserLanguage:(nonnull NSString*)userLanguage;
-(void) setUserTimeZone:(nonnull NSString*)userTimeZone;

@end

#endif // ISemanticContext_h
