//
//  ViewController.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "ViewController.h"
#import "JGSpotify.h"

#import "TopTypes_VC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefaults objectForKey:@"spotifyAccessToken"];
    NSDate *accessTokenExpires = [userDefaults objectForKey:@"spotifyAccessTokenExpires"];
    NSString *refreshToken = [userDefaults objectForKey:@"spotifyRefreshToken"];
    
    if (accessToken != nil) {
        NSDate *now = [NSDate date];
        NSTimeInterval distanceBetweenDates = [accessTokenExpires timeIntervalSinceDate:now];
        if (distanceBetweenDates < 60) {
            NSLog(@"refresh token");
        } else {
            NSLog(@"%@", accessToken);
            JGSpotify *spotify = [JGSpotify sharedInstance];
            spotify.accessToken = accessToken;
            spotify.accessTokenExpires = accessTokenExpires;
            spotify.refreshToken = refreshToken;
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *initialNavController = [main instantiateViewControllerWithIdentifier:@"TracksNavController"];
            [self presentViewController:initialNavController animated:YES completion:nil];
        }
    } else {
        NSLog(@"show login");
    }
}

- (IBAction)login:(UIButton *)sender
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    [spotify authorizeWithCompletionHandler:^(BOOL result, NSError *error) {
        if (!error) {
            
        } else {
            NSLog(@"%@", error);
        }
    }];
}


@end
