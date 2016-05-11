//
//  JGSpotifyAuthorize_VC.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "JGSpotifyAuthorize_VC.h"

@interface JGSpotifyAuthorize_VC () <UIWebViewDelegate>

@end

@implementation JGSpotifyAuthorize_VC

- (instancetype)initWithAuthorizeUrl:(NSURL *)authorizeUrl
                      AndCallbackUrl:(NSURL *)callbackUrl
{
    self = [super init];
    if (self) {
        self.authorizeUrl = authorizeUrl;
        self.callbackUrl = callbackUrl;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeAuthorizeView:)];
    
    self.spotifyAuthorizeWebview = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.spotifyAuthorizeWebview.scalesPageToFit = YES;
    [self.spotifyAuthorizeWebview setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    
    self.spotifyAuthorizeWebview.delegate = self;
    [self.view addSubview:self.spotifyAuthorizeWebview];
    [self.spotifyAuthorizeWebview loadRequest:[NSURLRequest requestWithURL:self.authorizeUrl]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
}

- (void)closeAuthorizeView:(id)sender
{
    self.completionHandler(nil, [NSError errorWithDomain:@"JGSpotify" code:1 userInfo:@{NSLocalizedDescriptionKey: @"User cancel authorization"}]);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.title = [self.spotifyAuthorizeWebview stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {

    if (error.code == NSURLErrorCancelled) return;
    
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    
    self.completionHandler(nil, error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestUrl = [[request URL] host];
    
    if ([requestUrl isEqualToString:self.callbackUrl.host]) {
        [webView stopLoading];
        self.completionHandler([request URL], nil);
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
