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

//Abstract: Templates View Controller.
//Allows the user to choose which template from the available templates list
//he would like to use to protect his content.


#import <UIKit/UIKit.h>

@class MSTemplateDescriptor;
@class MSTemplatesViewController;

@protocol MSTemplatesViewControllerDelegate <NSObject>

- (void)didUserSelectTemplate:(MSTemplateDescriptor *)policyInfo isCustom:(BOOL)isCustom controller:(MSTemplatesViewController *)sender;
- (void)didUserCancelSelectTemplate:(MSTemplatesViewController *)sender;

@optional

- (void)templatesViewWillLoad:(MSTemplatesViewController *)sender;
- (void)templatesViewClosed:(MSTemplatesViewController *)sender;

@end

/*
 TemplatesViewController manages a view which is consisted of a navigation bar and a table view.
 It is atually acts almost like an UITableViewController but except for that its view is not dependent on UINavigationBarController
 And thus can show its view inside a modal popover.
 */
@interface MSTemplatesViewController : UITableViewController

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;

@property (nonatomic, strong) MSTemplateDescriptor *currentPolicyInfo; // the previously selected policy info (before the policy picker started)
@property (nonatomic, strong) NSArray *templates;
@property (assign) id<MSTemplatesViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end
