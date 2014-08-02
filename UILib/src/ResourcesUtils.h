/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     ResourcesUtilsUI.h
 *
 * Abstract: Utility methods for the UILIb resources
 *
 */

#import <UIKit/UIKit.h>

@interface ResourcesUtilsUI : NSObject

+ (NSBundle *)frameworkBundle;
+ (UIStoryboard *)storyboard;

@end

NSString *LocalizeString(NSString *key, NSString *comment);
