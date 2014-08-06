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

//  Abstract: MSModalPopover is a mimic of UIActionSheet class but with the flexibility of showing any view inside.
//  It is opened as a modal popover on both iPad and iPhone, by adding a subview to the application most top view with transparency.
//  The popover is automatically dismissed when the user taps the screen.

#import <UIKit/UIKit.h>

#define kCustomViewSizeiPhone     280
#define kCustomViewSizeiPad       320

@class MSModalPopover;
@protocol MSModalPopoverDelegate <NSObject>
@optional

- (void)willPresentModalPopover:(MSModalPopover *)view;  // before animation and showing view
- (void)didPresentModalPopover:(MSModalPopover *)view;  // after animation

- (void)willDismissModalPopover:(MSModalPopover *)view; // before animation and hiding view
- (void)didDismissModalPopover:(MSModalPopover *)view;  // after animation

- (void)didChangeOrienation:(MSModalPopover *)view; // after orienation changed
- (void)willDismissModalPopoverOnBackgroundTap:(MSModalPopover *)view; // before animation and hiding view
- (void)didDismissModalPopoverOnBackgroundTap:(MSModalPopover *)view; // after animation

@end

@interface MSModalPopover : UIView

- (id)initWithContentView:(UIView *)contentView; // the presented content view will be opaque by default
- (id)initWithContentView:(UIView *)contentView alpha:(CGFloat)alpha;

- (void)show;

- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completion:(void(^)())completion;

@property (assign) id<MSModalPopoverDelegate> delegate;

@end