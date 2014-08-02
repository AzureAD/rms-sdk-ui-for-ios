/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     AppDelegate.m
 *
 */

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

// Called after successful application launch 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

// Used to enable "Open In" functionality, calls the MainViewController with the URL of the selected attachment
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    MainViewController *mainViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] objectAtIndex:0];
    [mainViewController openURL:url];
    return YES;
}

@end
