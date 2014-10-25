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

//  Abstract: Shows a consent request on behalf of the app when connecting to Microsoft Azure services or
//      other service URL(s)

#import "MSConsentsViewDelegate.h"

#import <UIKit/UIKit.h>

@interface MSConsentsViewController : UIViewController

- (void)setupConsentViewFor:(MSConsentViewType)viewType withUrls:(NSArray *)urls;

@property (assign, nonatomic) id <MSConsentsViewDelegate> delegate;

@end
