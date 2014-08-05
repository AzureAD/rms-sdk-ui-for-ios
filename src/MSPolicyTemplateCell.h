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

#import <UIKit/UIKit.h>

#define CELL_CONTENT_MARGIN 25.0f
#define POLICY_TITLE_PADDING 20.0f
#define POLICY_DESCRIPTION_PADDING 30.0f

@interface MSPolicyTemplateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *policyTitle;
@property (weak, nonatomic) IBOutlet UILabel *policyDescription;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerLabelConstraint;

@end
