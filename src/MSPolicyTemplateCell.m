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

#import "MSPolicyTemplateCell.h"
#import "MSModalPopover.h"

@implementation MSPolicyTemplateCell

- (void)drawRect:(CGRect)rect
{
    NSUInteger cellWidth = self.frame.size.width;
    
    // on iPad we always get the table view frame that takes the full screen, because the table view's delegate methods are called
    // before the table view is actually viewed on the screen in the modal popover.
    // therefore we use this hack which takes the pre-defined width of the popover's frame on iPad so
    // we can use it to draw the labels appropriately.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        cellWidth = kCustomViewSizeiPad;
    }
    
    // this property affects the size of the label when layout constraints are applied to it. During layout,
    // if the text expands beyond the width specified by this property, the additional text moved to new lines, increasing the height of the label.
    self.policyTitle.preferredMaxLayoutWidth = cellWidth - (POLICY_TITLE_PADDING * 2);
    self.policyDescription.preferredMaxLayoutWidth = cellWidth - (POLICY_DESCRIPTION_PADDING * 2);
    
    [super drawRect:rect];
}

@end
