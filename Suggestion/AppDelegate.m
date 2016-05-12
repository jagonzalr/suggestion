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
    JGSpotify *spotify = [JGSpotify sharedInstance];
//    [spotify.scopes addObject:@"playlist-modify-public"];
//    [spotify.scopes addObject:@"playlist-modify-private"];
//    [spotify.scopes addObject:@"playlist-read-collaborative"];
//    [spotify.scopes addObject:@"playlist-read-private"];
    [spotify.scopes addObject:@"user-library-modify"];
    [spotify.scopes addObject:@"user-library-read"];
    [spotify.scopes addObject:@"user-top-read"];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:@"414141"]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"F9F9F9"]];
//    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"414141"],
                                                           NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]}];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"suggestion://oauth"]];
    
    NSMutableArray *scopes = [[NSMutableArray alloc] init];
    [scopes addObject:@"user-top-read"];
    
    [JGSpotify initWithClientID:@"d8d8cd82ff804b749bbf7924c63c9f9c"
                   ClientSecret:@"2d43f9cc78db4b9fb34f0457a09999fd"
                         Scopes:scopes
                    CallbackUri: @"suggestion://oauth"
                 AndRedirectUri:@"suggestion://oauth"];
    
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
    
    [SVProgressHUD setCornerRadius:4.0f];
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithHexString:@"414141"]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithHexString:@"F9F9F9"]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setRingThickness:4.0f];
    [SVProgressHUD setRingRadius:20.0f];
    [SVProgressHUD setRingNoTextRadius:26.0f];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    
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

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jagonzalr.Suggestion" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Suggestion" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Suggestion.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
