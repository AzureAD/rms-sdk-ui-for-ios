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

#import "MSResourcesUtils.h"


@implementation MSResourcesUtils

+ (NSBundle *)frameworkBundle
{
    static NSBundle *frameworkBundle = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once( &predicate,
                  ^{
                      NSString* mainBundlePath      = [[NSBundle bundleForClass:[self class]] resourcePath];
                      NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"MSRightsManagementUIResources.bundle"];
                      
                      frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
                      
                      if (!frameworkBundle)
                      {
                          @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                               reason:@"MSRightsManagementUIResources.bundle could not be found! Please make sure to include it in the Copy Bundle Resource build phase in your project's target."
                                                             userInfo:nil];
                      }
                      
                      [frameworkBundle load];
                  });
    
    return frameworkBundle;
}

+ (UIStoryboard *)storyboard
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        // The device is an iPad running iOS 3.2 or later.
        return [UIStoryboard storyboardWithName:@"iPad_Storyboard" bundle:[[self class] frameworkBundle]];
    }
    else
    {
        // The device is an iPhone or iPod touch.
        return [UIStoryboard storyboardWithName:@"iPhone_Storyboard" bundle:[[self class] frameworkBundle]];
    }
}

@end

NSString *LocalizeStringFromBundle(NSBundle *bundle, NSString *key, NSString *tableName, NSString *comment)
{
    return [bundle localizedStringForKey:key value:nil table:tableName];
}

NSString *LocalizeString(NSString *key, NSString *comment)
{
    NSBundle *frameworkBundle = [MSResourcesUtils frameworkBundle];
    
    return LocalizeStringFromBundle(frameworkBundle, key, @"Localizeable", comment);
}

