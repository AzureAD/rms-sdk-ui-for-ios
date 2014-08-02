/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MainViewController.h
 *
 */
// Abstract: The main controller for the RMS sample app - supports both protected and non-protected text files
// Shows how to:
//   consume protected data from an attachment
//   publish protected data and send it as an email attachment
//   remove and change protection - if the user is the owner of the proteced data

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

// The main view controller of the application
@interface MainViewController : UIViewController <MFMailComposeViewControllerDelegate>

// Called by AppDelegate when user activates "Open In" flow by opening a .ptxt, .txt2 or a .txt attachment with RMS sample app
- (void)openURL:(NSURL *)url;

@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *protectionTypeSegmentedControl;
@end


