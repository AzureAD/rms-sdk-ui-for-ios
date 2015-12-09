/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSLicenseMetadata.h
 *
 */
// Abstract: The class facilitates adding metadata to user policies to aid in document tracking

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

typedef NS_ENUM(NSUInteger, MSNotificationType) {
    NotificationTypeDisabled = 0,
    NotificationTypeEnabled = 1,
    NotificationTypeDenyOnly = 2
};

typedef NS_ENUM(NSUInteger, MSNotificationPreference) {
    NotificationPrefDefault = 0,
    NotificationPrefDigest = 1
};

@interface MSLicenseMetadata : MSSecureCodableObject

- (id)initWithContentName:(NSString *)contentName
         notificationType:(MSNotificationType)notificationType;

@property (strong, readonly) NSString *contentName;
@property (readonly) MSNotificationType notificationType;
@property (assign) MSNotificationPreference notificationPreference;
@property (strong) NSString *contentPath;
@property (strong) NSDate *contentDateCreated;
@property (strong) NSDate *contentDateModified;

@end