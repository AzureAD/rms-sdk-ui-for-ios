//
//  AggregatedMetric.h
//  ObjCSdkDriver
//
//  Created by Admin on 12/17/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILogger.h"

@interface ACTAggregatedMetric : NSObject

-(nullable instancetype)initWithName:(nonnull NSString *)name units:(nonnull NSString *)units intervalInSec:(unsigned long)interval eventProperties:(nonnull ACTEventProperties *)properties logger:(nonnull id<ACTILogger>)logger;
-(nullable instancetype)initWithName:(nonnull NSString *)name units:(nonnull NSString *)units intervalInSec:(unsigned long)interval eventProperties:(nonnull ACTEventProperties *)properties;

-(nullable instancetype)initWithName:(nonnull NSString *)name units:(nonnull NSString *)units intervalInSec:(unsigned long)interval instanceName:(nullable NSString *)instanceName objectClass:(nullable NSString *)objectClass objectId:(nullable NSString *)objectId eventProperties:(nonnull ACTEventProperties *)properties logger:(nonnull id<ACTILogger>)logger;
-(nullable instancetype)initWithName:(nonnull NSString *)name units:(nonnull NSString *)units intervalInSec:(unsigned long)interval instanceName:(nonnull NSString *)instanceName objectClass:(nonnull NSString *)objectClass objectId:(nonnull NSString *)objectId eventProperties:(nonnull ACTEventProperties *)properties;

-(void)pushMetric:(double)value;

@end
