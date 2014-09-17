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


#import "MSModalPopover.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

#define INCALL_STATUS_BAR_FRAME_CHANGE_ANIMATION_DURATION   0.2f
#define ORIENTATION_CHANGE_ANIMATION_DURATION               0.4f
#define POPOVER_ANIMATION_DURATION                          0.4f
#define POPOVER_BACKGROUND_ALPHA                            0.7f

// The UI structure of MSModalPopover is:
//
//  -------------------------------------------------------------------------
// | MSModalView (i.e. self)                                                 |
// |                                                                         |
// | self.lightGrayOverlayView                                               |
// |-------------------------------------------------------------------------|
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |          self.backgroundView            || self.contentContainerView ||
// | |                                         || (and within lies:         ||
// | |                                         ||     self.contentView)     ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | |                                         ||                           ||
// | ------------------------------------------------------------------------|
//  -------------------------------------------------------------------------

@interface MSModalPopover()

@property (weak, nonatomic)   UIView   *contentView;
@property (strong, nonatomic) UIView   *contentContainerView;
@property (strong, nonatomic) UIView   *backgroundView;
@property (strong, nonatomic) UIView   *lightGrayOverlayView;
@property (assign, nonatomic) BOOL     useAnimation;
@property (assign, nonatomic) BOOL     shown;

@end

@implementation MSModalPopover

static const int32_t kBackgroundViewTag = 1100;

#pragma mark -
#pragma mark - Public Methods

- (id)initWithContentView:(UIView *)contentView
{
    return [self initWithContentView:contentView alpha:1.0];
}

- (id)initWithContentView:(UIView *)contentView alpha:(CGFloat)alpha
{
    if ((self = [super init])) {
        // "self" view covers all the screen
        // properties from the base class
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        
        // "lightGrayOverlayView" covers the screen with transparent light gray color
        // to create the effect that the application behind the popover is currently disabled
        _lightGrayOverlayView = [[UIView alloc] init];
        _lightGrayOverlayView.backgroundColor = [UIColor darkGrayColor];
        _lightGrayOverlayView.alpha = 0;
        [self addSubview:_lightGrayOverlayView];
        
        // "contentContainerView" view is a placeholder for the actual content view that
        // will be displayed in the modal popover
        _contentContainerView = [[UIView alloc] init];
        _contentContainerView.backgroundColor = [UIColor clearColor];
        _contentContainerView.userInteractionEnabled = YES;
        _contentContainerView.alpha = alpha;
        [self addSubview:_contentContainerView];
        
        // "contentView" contains the actual content (e.g. policy picker view or policy viewer view)
        _contentView = contentView;
        
        // "backgroundView" is a transparent view which is only used to capture
        // the user taps outside the content view in order to dismiss the popover
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = YES;
        [self addSubview:_backgroundView];
        
        UITapGestureRecognizer *backgroundTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
        [_backgroundView addGestureRecognizer:backgroundTapRecognizer];
        
        // register to device orientation change notification
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        // register to in-call status bar frame notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarDidChangeFrame:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
        
        _backgroundView.tag = kBackgroundViewTag;
    }
    
    return self;
}

- (void)show
{
    UIView *topView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    [self showInView:topView animated:YES];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    [[self ancestorViewForView:view] addSubview:self];
    [self.contentContainerView addSubview:self.contentView];
    [self configureView];
 
    [UIView animateWithDuration:animated ? POPOVER_ANIMATION_DURATION : 0.0f animations:^{
        self.shown = YES;
        self.lightGrayOverlayView.alpha = POPOVER_BACKGROUND_ALPHA;
        
        [self configureView];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentModalPopover:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didPresentModalPopover:self];
            });
        }
    }];

    self.useAnimation = animated;
    
    if ([self.delegate respondsToSelector:@selector(willPresentModalPopover:)]) {
        [self.delegate willPresentModalPopover:self];
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    return [self dismissAnimated:animated completion:nil];
}

- (void)dismissAnimated:(BOOL)animated completion:(void(^)())completion
{
    if ([self.delegate respondsToSelector:@selector(willDismissModalPopover:)]) {
        [self.delegate willDismissModalPopover:self];
    }
    
    [UIView animateWithDuration:animated ? POPOVER_ANIMATION_DURATION : 0.0f animations:^{
        self.shown = NO;
        self.lightGrayOverlayView.alpha = 0.0f;
        
        [self configureView];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.contentView removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(didDismissModalPopover:)]) {
            [self.delegate didDismissModalPopover:self];
        }
        
        if (completion != nil) {
            completion();
        }
    }];
}

#pragma mark -
#pragma mark - View

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Notifications

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    // obtaining the current device orientation
    UIDeviceOrientation orientation = [self interfaceOrientation];
    
    // ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    
    // responding only to changes in landscape or portrait
    [self performSelector:@selector(handleOrientationChange) withObject:self afterDelay:0];
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    [UIView animateWithDuration:INCALL_STATUS_BAR_FRAME_CHANGE_ANIMATION_DURATION animations:^{
        [self configureView];
    }];
}

#pragma mark -
#pragma mark - Private Methods

- (void)handleBackgroundTap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(willDismissModalPopoverOnBackgroundTap:)]) {
        [self.delegate willDismissModalPopoverOnBackgroundTap:self];
    }
    
    [self dismissAnimated:self.useAnimation completion:^{
        if ([self.delegate respondsToSelector:@selector(didDismissModalPopoverOnBackgroundTap:)]) {
            [self.delegate didDismissModalPopoverOnBackgroundTap:self];
        }
    }];
}

- (void)configureView
{
    // set the view's rotation trasformation based on the current device's orientation
    // note: because we are not a view controller we have to take care of the view transform's ourselves
    [self configureTransformationForCurrentOrientation];
    
    // set the modal popover frame to be the full application frame without the device's status bar
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    
    // but if a navigation bar exists and not hidden within a navigation controller do not cover it
    if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (navigationController.navigationBarHidden == NO) {
            // move the popover up or down (depending on the orientation) so it won't hide the navigation bar
            if (UIDeviceOrientationIsPortrait([self interfaceOrientation])) {
                frame.size.height -= navigationController.navigationBar.frame.size.height;
                if ([self interfaceOrientation] != UIDeviceOrientationPortraitUpsideDown) {
                    frame.origin.y += navigationController.navigationBar.frame.size.height;
                }
            }
            else if (UIDeviceOrientationIsLandscape([self interfaceOrientation])) {
                frame.size.width -= navigationController.navigationBar.frame.size.height;
                if ([self interfaceOrientation] == UIDeviceOrientationLandscapeRight) {
                    frame.origin.x += navigationController.navigationBar.frame.size.height;
                }
            }
        }
    }
    
    self.frame = frame;

    CGRect contentViewFrame; // holds the frame of the contentContainer frame
    CGRect backgroundViewFrame; // holds the frame of the backgroundView frame
    
    // for iPad we would always like the popover to appear on the the right side of the screen
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIDeviceOrientationIsPortrait([self interfaceOrientation])) {
         contentViewFrame = CGRectMake(self.frame.size.width, 0, [self viewHeightBasedOnDevice], self.frame.size.height);
         backgroundViewFrame = CGRectMake(0, 0, self.frame.size.width - [self viewHeightBasedOnDevice], self.frame.size.height);
        
        if (self.shown) {
            contentViewFrame.origin.x -= [self viewHeightBasedOnDevice];
        }
        else {
            contentViewFrame.origin.x += [self viewHeightBasedOnDevice];
        }
        
        // make sure the content always slides in from left to right
        if ([self interfaceOrientation] == UIDeviceOrientationPortraitUpsideDown) {
            contentViewFrame.origin.x = self.frame.size.width - contentViewFrame.origin.x - [self viewHeightBasedOnDevice];
            backgroundViewFrame.origin.x = contentViewFrame.origin.x + [self viewHeightBasedOnDevice];
        }
    }
    else {
        contentViewFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, [self viewHeightBasedOnDevice]);
        backgroundViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - [self viewHeightBasedOnDevice]);

        if (self.shown) {
            contentViewFrame.origin.y -= [self viewHeightBasedOnDevice];
        }
        else {
            contentViewFrame.origin.y += [self viewHeightBasedOnDevice];
        }
        
        // make sure the content always slides in from left to right
        if ([self interfaceOrientation] == UIDeviceOrientationLandscapeRight) {
            contentViewFrame.origin.y = self.frame.size.height - contentViewFrame.origin.y - [self viewHeightBasedOnDevice];
            backgroundViewFrame.origin.y = contentViewFrame.origin.y + [self viewHeightBasedOnDevice];
        }
        else if ([self interfaceOrientation] == UIDeviceOrientationPortraitUpsideDown) {
            // switch between the location (origin) of the content view and the background view
            CGPoint tempOrigin = contentViewFrame.origin;
            contentViewFrame.origin = backgroundViewFrame.origin;
            backgroundViewFrame.origin = tempOrigin;
        }
    }
    
    // update the view's location within their super views
    self.contentContainerView.frame = contentViewFrame;
    self.contentView.frame = self.contentContainerView.bounds;
    self.backgroundView.frame = backgroundViewFrame;
    self.lightGrayOverlayView.frame = self.bounds;
}

- (UIView *)ancestorViewForView:(UIView *)view
{
    while ([view superview]) {
        view = [view superview];
    }
    
    return view;
}

- (void)handleOrientationChange
{
    [UIView animateWithDuration:ORIENTATION_CHANGE_ANIMATION_DURATION animations:^{
        [self configureView];
        
        if ([self.delegate respondsToSelector:@selector(didChangeOrienation:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didChangeOrienation:self];
            });
        }
    }];
}

- (void)configureTransformationForCurrentOrientation
{
    UIDeviceOrientation orientation = [self interfaceOrientation];
    
    if (orientation == UIDeviceOrientationPortrait) {
        self.contentContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        self.contentContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft) {
        self.contentContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        self.contentContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
    }
}

- (NSUInteger)viewHeightBasedOnDevice
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? kCustomViewSizeiPhone : kCustomViewSizeiPad;
}

- (UIDeviceOrientation)interfaceOrientation
{
    return [[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation];
}

@end
