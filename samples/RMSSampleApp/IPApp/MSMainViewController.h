/**
 * Copyright © Microsoft Corporation, All Rights Reserved
 *
 * Licensed under MICROSOFT SOFTWARE LICENSE TERMS,
 * MICROSOFT RIGHTS MANAGEMENT SERVICE SDK UI LIBRARIES;
 * You may not use this file except in compliance with the License.
 * See the license for specific language governing permissions and limitations.
 * You may obtain a copy of the license (RMS SDK UI libraries - EULA.DOCX) at the
 * root directory of this project.
 *
 * THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 * ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
 * PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
 */

// Abstract: The main controller for the RMS sample app - supports both protected and non-protected text files
// Shows how to:
//   consume protected data from an attachment
//   publish protected data and send it as an email attachment
//   remove and change protection - if the user is the owner of the proteced data

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

// The main view controller of the application
@interface MSMainViewController : UIViewController <MFMailComposeViewControllerDelegate>

// Called by AppDelegate when user activates "Open In" flow by opening a .ptxt, .txt2 or a .txt attachment with RMS sample app
- (void)openURL:(NSURL *)url;

@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *protectionTypeSegmentedControl;
@end


