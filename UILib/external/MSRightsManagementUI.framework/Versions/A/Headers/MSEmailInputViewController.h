/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSEmailInputViewController.h
 *
 */

//  Abstract: Gets an email address from the user to be used for authentication and authorization calls
//      The email address is cached within the app's sandbox once authenticated.

#import <UIKit/UIKit.h>
#import "MSEmailInputDelegate.h"

@interface MSEmailInputViewController : UIViewController

@property (assign, nonatomic) id <MSEmailInputDelegate> delegate;

@end


