//
//  JGSpotifyAuthorize_VC.h
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGSpotifyAuthorize_VC : UIViewController

@property (nonatomic, strong) NSURL *authorizeUrl;
@property (nonatomic, strong) NSURL *callbackUrl;
@property (nonatomic, strong) void (^completionHandler)(NSURL *callbackUrl, NSError *error);
@property (nonatomic, strong) UIWebView *spotifyAuthorizeWebview;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (instancetype)initWithAuthorizeUrl:(NSURL *)authorizeUrl
                      AndCallbackUrl:(NSURL *)callbackUrl;

@end
