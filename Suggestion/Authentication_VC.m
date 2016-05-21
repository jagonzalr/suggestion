//
//  ViewController.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

// Classes
#import "Authentication_VC.h"

// Helpers
#import "JGSpotify.h"
#import "JGStyles.h"

// Libraries
#import <SafariServices/SafariServices.h>
#import <ChameleonFramework/Chameleon.h>
#import "SIAlertView.h"
#import "SVProgressHUD.h"

@interface Authentication_VC () <SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *spotifyLoginbtn;

@end

@implementation Authentication_VC

#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeUI];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *accessToken = [userDefaults objectForKey:@"spotifyAccessToken"];
//    
//    if (accessToken != nil) {
//        [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result,
//                                                            NSError *error)
//        {
//            if (result) {
//                [SVProgressHUD dismiss];
//                [self showTracks];
//            }
//        }];
//    }
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


# pragma mark - Functions

- (void)customizeUI
{
    self.view.backgroundColor = [JGStyles textColor];
    self.spotifyLoginbtn.tintColor = [JGStyles backgroundColor];
    self.spotifyLoginbtn.backgroundColor = [JGStyles textColor];
}

- (void)showTracks
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *initialNavController = [main instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:initialNavController
                       animated:YES
                     completion:nil];
}


# pragma mark - IBActions

- (IBAction)login:(UIButton *)sender
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    [spotify authorizeWithCompletionHandler:^(BOOL result,
                                              NSError *error)
    {
        if (!error) {
            [self showTracks];
        } else {
            NSString *title = @"Error";
            NSString *message = @"An error occurred. Please try again.";
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                             andMessage:message];
            
            [alertView addButtonWithTitle:@"Ok"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:nil];
            
            [alertView show];
        }
    }];
}

@end
