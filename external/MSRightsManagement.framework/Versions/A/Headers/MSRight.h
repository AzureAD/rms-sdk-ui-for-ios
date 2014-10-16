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
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758314(v=vs.85).aspx
 
 */
@interface MSCommonRights : NSObject

+ (NSString *)owner;
+ (NSString *)view;

@end

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758318(v=vs.85).aspx
 
 */
@interface MSEditableDocumentRights : NSObject

+ (NSString *)edit;
+ (NSString *)exportable;
+ (NSString *)extract;
+ (NSString *)print;
+ (NSString *)comment;
+ (NSArray *)all;

@end

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758319(v=vs.85).aspx
 
 */
@interface MSEmailRights : NSObject

+ (NSString *)reply;
+ (NSString *)replyAll;
+ (NSString *)forward;
+ (NSString *)extract;
+ (NSString *)print;
+ (NSArray *)all;

@end
