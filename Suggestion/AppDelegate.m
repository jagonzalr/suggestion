//
//  AppDelegate.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "AppDelegate.h"

#import "JGSpotify.h"

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
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:@"414141"]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"F9F9F9"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"414141"],
                                                           NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:14.0f]}];
    
    // Setup UITabBar appearance
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:@"414141"]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"F9F9F9"]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"414141"],
                                                        NSFontAttributeName:[UIFont fontWithName:@"Avenir Next" size:10.0f]} forState:UIControlStateSelected];
    
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
    [[SIAlertView appearance] setTitleFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"Avenir Next" size:14.0f]];
    [[SIAlertView appearance] setTitleColor:[UIColor colorWithHexString:@"414141"]];
    [[SIAlertView appearance] setMessageColor:[UIColor colorWithHexString:@"414141"]];
    [[SIAlertView appearance] setCornerRadius:4];
    [[SIAlertView appearance] setShadowRadius:50];
    [[SIAlertView appearance] setViewBackgroundColor:[UIColor colorWithHexString:@"F9F9F9"]];
    [[SIAlertView appearance] setButtonFont:[UIFont fontWithName:@"AvenirNext-Bold" size:14.0f]];
    [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleFade];
    [[SIAlertView appearance] setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
    
    // Setup SVProgressHUD appearance
    [SVProgressHUD setCornerRadius:4.0f];
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithHexString:@"1ED760"]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithHexString:@"FEFEFE"]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setRingThickness:4.0f];
    [SVProgressHUD setRingRadius:20.0f];
    [SVProgressHUD setRingNoTextRadius:26.0f];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifyAccessToken"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifyAccessTokenExpires"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifyRefreshToken"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

@end
