//
//  ViewController.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "Authentication_VC.h"
#import "JGSpotify.h"
#import <QuartzCore/QuartzCore.h>

#import <ChameleonFramework/Chameleon.h>
#import "SIAlertView.h"
#import "SVProgressHUD.h"

@interface Authentication_VC ()

@property (weak, nonatomic) IBOutlet UIButton *logInToSpotifyBtn;

@end

@implementation Authentication_VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
}

- (void)viewDidAppear:(BOOL)animated
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefaults objectForKey:@"spotifyAccessToken"];
    NSDate *accessTokenExpires = [userDefaults objectForKey:@"spotifyAccessTokenExpires"];
    
    if (accessToken != nil) {
        NSDate *now = [NSDate date];
        NSTimeInterval distanceBetweenDates = [accessTokenExpires timeIntervalSinceDate:now];
        if (distanceBetweenDates < 60) {
            [SVProgressHUD show];
            [spotify refreshTokenWithCompletionHandler:^(BOOL result, NSError *error) {
                if (result) {
                    [SVProgressHUD dismiss];
                    [self showTracks];
                }
            }];
        } else {
            [self showTracks];
        }
    }
}

- (void)showTracks
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *initialNavController = [main instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:initialNavController animated:YES completion:nil];
}

- (IBAction)login:(UIButton *)sender
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    [spotify authorizeWithCompletionHandler:^(BOOL result, NSError *error) {
        if (!error) {
            [self showTracks];
        } else {
            NSString *title = @"Error";
            NSString *message = @"An error occurred. Please try again";
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
