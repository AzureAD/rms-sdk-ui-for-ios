//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//
#ifndef LogManager_h
#define LogManager_h

#import "ISemanticContext.h"
#import "ILogger.h"

@interface ACTLogConfiguration : NSObject

/// [optional] Url of the collector for sending events
/// default will be used if not specified
@property (nonatomic, strong, nullable) NSString* eventCollectorUri;

/// [optional] Full path of the disk file used to cache events on client side
/// Specify one to avoid/reduce potential loss of data by persisting events
/// to file storage for them to be sent in next telemetry session.
@property (nonatomic, strong, nullable) NSString* cacheFilePath;

/// [optional] Size limit of the disk file used to cache events on client side
/// Additional events might cause older events in the file cache to be dropped
/// This size limit should be larger than the cacheMemorySizeLimitInBytes below
@property (atomic, assign) unsigned long cacheFileSizeLimitInBytes;

/// [optional] The number of events kept in memory.
@property (atomic, assign) unsigned int cacheMemorySizeLimitInNumberOfEvents;

/// [optional] Cause UserSession events to be sent automatically
@property (nonatomic, assign) BOOL enableAutoUserSession;

-(nullable instancetype)init;

@end



enum ACTTransmitProfile
{
    /// Favors low transmission latency, but may consume more data bandwidth and power
    ACTTransmitProfileRealTime        = 0,
    /// Favors near real-time transmission latency. Automatically balances transmission
    /// latency with data bandwidth and power consumption
    ACTTransmitProfileNearRealTime    = 1,
    /// Favors device performance by conserving both data bandwidth and power consumption
    ACTTransmitProfileBestEffort      = 2
};



@interface ACTLogManager : NSObject

+(nullable id<ACTILogger>)initForTenant:(nonnull NSString*)aTenant;
+(nullable id<ACTILogger>)initForTenant:(nonnull NSString*)aTenant configuration:(nonnull ACTLogConfiguration*)aConfig;

+(nullable id<ACTILogger>)loggerForTenant:(nonnull NSString*)aTenant source:(nonnull NSString*)aSource;
+(nullable id<ACTILogger>)loggerForSource:(nonnull NSString*)aSource;

+(nullable id<ACTILogger>)logger;

+(void)flushAndTearDown;
+(void)flush;

+(void)pauseTransmission;
+(void)resumeTransmission;

+(void)setTransmitProfile:(enum ACTTransmitProfile)profile;

+(void)setContextWithName:(nonnull NSString*)aName stringValue:(nonnull NSString*)aString piiKind:(enum ACTPiiKind)piiKind;
+(void)setContextWithName:(nonnull NSString*)aName stringValue:(nonnull NSString*)aString;
+(void)setContextWithName:(nonnull NSString*)aName doubleValue:(double)aDouble;
+(void)setContextWithName:(nonnull NSString*)aName longValue:(long)aLong;
+(nonnull id<ACTISemanticContext>)semanticContext;

@end

#endif // LogManager_h

