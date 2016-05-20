//
//  AppDelegate.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "AppDelegate.h"

#import "JGSpotify.h"
#import "JGStyles.h"

#import <ChameleonFramework/Chameleon.h>
#import "SIAlertView.h"
#import "SVProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup UINavigation appearance
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[JGStyles textColor]];
    [[UINavigationBar appearance] setBarTintColor:[JGStyles backgroundColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[JGStyles textColor],
                                                           NSFontAttributeName:[JGStyles boldFont:14.0]}];
    
    // Setup UITabBar appearance
    [[UITabBar appearance] setTintColor:[JGStyles textColor]];
    [[UITabBar appearance] setBarTintColor:[JGStyles backgroundColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[JGStyles textColor],
                                                        NSFontAttributeName:[JGStyles normalFont:10.0]}
                                             forState:UIControlStateSelected];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"suggestion://oauth"]];
    
    // Setup Spotify client
    NSMutableArray *scopes = [[NSMutableArray alloc] init];
    [scopes addObject:@"user-library-modify"];
    [scopes addObject:@"user-library-read"];
    [scopes addObject:@"user-top-read"];
    
    [JGSpotify initWithClientID:@"d8d8cd82ff804b749bbf7924c63c9f9c"
                   ClientSecret:@"15bf912dfcb44b61bb1e0aced260ba9e"
                         Scopes:scopes
                    CallbackUri: @"suggestion://oauth"
                 AndRedirectUri:@"suggestion://oauth"];
    
    // Setup SIAlertView appearance
    [[SIAlertView appearance] setTitleFont:[JGStyles boldFont:16.0]];
    [[SIAlertView appearance] setMessageFont:[JGStyles normalFont:14.0]];
    [[SIAlertView appearance] setTitleColor:[JGStyles textColor]];
    [[SIAlertView appearance] setMessageColor:[JGStyles textColor]];
    [[SIAlertView appearance] setCornerRadius:4];
    [[SIAlertView appearance] setShadowRadius:50];
    [[SIAlertView appearance] setViewBackgroundColor:[JGStyles backgroundColor]];
    [[SIAlertView appearance] setButtonFont:[JGStyles boldFont:14.0]];
    [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleFade];
    [[SIAlertView appearance] setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
    
    // Setup SVProgressHUD appearance
    [SVProgressHUD setCornerRadius:4.0f];
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [SVProgressHUD setBackgroundColor:[JGStyles greenColor]];
    [SVProgressHUD setForegroundColor:[JGStyles whiteColor]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setRingThickness:4.0f];
    [SVProgressHUD setRingRadius:20.0f];
    [SVProgressHUD setRingNoTextRadius:26.0f];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
