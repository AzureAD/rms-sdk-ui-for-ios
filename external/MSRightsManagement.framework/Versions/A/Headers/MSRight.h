/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSRight.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237823(v=vs.85).aspx
 
 */

@interface MSCommonRights : NSObject

+ (NSString *)owner;
+ (NSString *)view;

@end

@interface MSEditableDocumentRights : NSObject

+ (NSString *)edit;
+ (NSString *)exportable;
+ (NSString *)extract;
+ (NSString *)print;
+ (NSString *)comment;
+ (NSArray *)all;

@end

@interface MSEmailRights : NSObject

+ (NSString *)reply;
+ (NSString *)replyAll;
+ (NSString *)forward;
+ (NSString *)extract;
+ (NSString *)print;
+ (NSArray *)all;

@end
