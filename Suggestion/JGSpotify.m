//
//  JGSpotify.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "JGSpotify.h"
#import "JGSpotifyVerbs.h"
#import "JGSpotifyAuthorize_VC.h"

@implementation JGSpotify

@synthesize accessToken;
@synthesize accessTokenExpires;
@synthesize authorizeUri;
@synthesize callbackUri;
@synthesize clientID;
@synthesize clientSecret;
@synthesize redirectUri;
@synthesize refreshToken;
@synthesize scopes;
@synthesize tokenUri;

+ (id)initWithClientID:(NSString *)clientID
          ClientSecret:(NSString *)clientSecret
                Scopes:(NSMutableArray *)scopes
           CallbackUri:(NSString *)callbackUri
        AndRedirectUri:(NSString *)redirectUri
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    
    spotify.accessToken = @"";
    spotify.accessTokenExpires = [[NSDate alloc] init];
    spotify.authorizeUri = [[NSMutableString alloc] init];
    spotify.callbackUri = callbackUri;
    spotify.clientID = clientID;
    spotify.clientSecret = clientSecret;
    spotify.redirectUri = redirectUri;
    spotify.refreshToken = @"";
    spotify.scopes = [[NSMutableArray alloc] init];
    spotify.tokenUri = @"https://accounts.spotify.com/api/token";
    
    for (NSString *scope in scopes) {
        [spotify.scopes addObject:scope];
    }
    
    [JGSpotify buildAuthorizeUri];
    
    return self;
}

+ (JGSpotify *)sharedInstance
{
    static JGSpotify *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)buildAuthorizeUri
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    [spotify.authorizeUri appendString:@"https://accounts.spotify.com/authorize/"];
    [spotify.authorizeUri appendString:[NSString stringWithFormat:@"?client_id=%@", spotify.clientID]];
    [spotify.authorizeUri appendString:@"&response_type=code"];
    [spotify.authorizeUri appendString:[JGSpotify buildRedirectUriParameter:spotify.redirectUri]];
    
    if (spotify.scopes.count > 0) {
        [spotify.authorizeUri appendString:@"&scope="];
        for (NSString *scope in spotify.scopes) {
            if ([[spotify.scopes lastObject] isEqualToString:scope]) {
                [spotify.authorizeUri appendString:scope];
            } else {
                [spotify.authorizeUri appendString:[NSString stringWithFormat:@"%@%%20", scope]];
            }
        }
    }
}

+ (NSString *)buildRedirectUriParameter:(NSString *)redirectUri
{
    return [NSString stringWithFormat:@"&redirect_uri=%@", [JGSpotify encodeRedirectUri:redirectUri]];
}

+ (NSString *)encodeRedirectUri:(NSString *)redirectUri
{
    return [redirectUri stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (void)authorizeWithCompletionHandler:(void(^)(BOOL result, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *tokenUrl = [NSURL URLWithString:spotify.tokenUri];
    
    
    NSURL *authorizationUrl = [NSURL URLWithString:spotify.authorizeUri];
    NSURL *callbackUrl = [NSURL URLWithString:spotify.callbackUri];
    JGSpotifyAuthorize_VC *spotifyAuthorizeVC = [[JGSpotifyAuthorize_VC alloc] initWithAuthorizeUrl:authorizationUrl AndCallbackUrl:callbackUrl];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *viewController = window.rootViewController;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:spotifyAuthorizeVC];
    [viewController presentViewController:navController animated:YES completion:nil];
    
    spotifyAuthorizeVC.completionHandler = ^(NSURL *callbackUrl, NSError *error) {
        if (!error) {
            NSString *code = [[callbackUrl query] stringByReplacingOccurrencesOfString:@"code=" withString:@""];
            if (code.length == 0) {
                NSString *err = [[callbackUrl query] stringByReplacingOccurrencesOfString:@"error=" withString:@""];
                completionHandler(NO, [NSError errorWithDomain:@"JGSpotify" code:2 userInfo:@{NSLocalizedDescriptionKey: err}]);
                
            } else {
                NSString *payload = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@", code, spotify.redirectUri];
                [spotify getAccessToken:tokenUrl
                                Payload:payload
                      CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                 {
                     spotify.accessToken = responseObject[@"access_token"];
                     spotify.refreshToken = responseObject[@"refresh_token"];
                     spotify.accessTokenExpires = [NSDate dateWithTimeIntervalSinceNow:3500];
                     
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults setObject:spotify.accessToken forKey:@"spotifyAccessToken"];
                     [userDefaults setObject:spotify.accessTokenExpires forKey:@"spotifyAccessTokenExpires"];
                     [userDefaults setObject:spotify.refreshToken forKey:@"spotifyRefreshToken"];
                     [userDefaults synchronize];
                     
                     completionHandler(YES, nil);
                 }];
            }
        } else {
            completionHandler(NO, error);
        }
    };
}

- (void)refreshTokenWithCompletionHandler:(void(^)(BOOL result, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *tokenUrl = [NSURL URLWithString:spotify.tokenUri];
    NSString *payload = [NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@", spotify.refreshToken];
    [spotify getAccessToken:tokenUrl
                    Payload:payload
          CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
     {
         spotify.accessToken = responseObject[@"access_token"];
         spotify.refreshToken = responseObject[@"refresh_token"];
         spotify.accessTokenExpires = [NSDate dateWithTimeIntervalSinceNow:3500];
         
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setObject:spotify.accessToken forKey:@"spotifyAccessToken"];
         [userDefaults setObject:spotify.accessTokenExpires forKey:@"spotifyAccessTokenExpires"];
         [userDefaults setObject:spotify.refreshToken forKey:@"spotifyRefreshToken"];
         [userDefaults synchronize];
         
         completionHandler(YES, nil);
     }];
}


+ (void)getTopArtistsCompletionHandler:(void(^)(NSDictionary *artists, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/me/top/artists?limit=50"];
    [JGSpotifyVerbs JGSpotifyGetVerb:url  AuthorizationCode:spotify.accessToken CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

+ (void)saveTrack:(NSString *)trackID WithCompletionHandler:(void(^)(id track, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/me/tracks?ids=%@", trackID]];
    [JGSpotifyVerbs JGSpotifyPutVerb:url Payload:@"" AuthorizationCode:spotify.accessToken CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

- (void)getAccessToken:(NSURL *)tokenUrl
               Payload:(NSString *)payload
     CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    [JGSpotifyVerbs JGSpotifyPostVerb:(NSURL *)tokenUrl
                              Payload:payload
                    WithAuthorization:(BOOL)YES
                             ClientID:(NSString *)spotify.clientID
                         ClientSecret:(NSString *)spotify.clientSecret
                            CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
    {
        completionHandler(response, responseObject, error);
    }];
}

+ (void)getTopTracksCompletionHandler:(void(^)(NSDictionary *tracks, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/me/top/tracks?limit=50"];
    [JGSpotifyVerbs JGSpotifyGetVerb:url  AuthorizationCode:spotify.accessToken CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

+ (void)getArtist:(NSString *)artistID WithCompletionHandler:(void(^)(NSDictionary *tracks, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/artists/%@", artistID]];
    [JGSpotifyVerbs JGSpotifyGetVerb:url  AuthorizationCode:spotify.accessToken CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

+ (void)refreshAccessTokenWithCompletionHandler:(void(^)(BOOL result, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSURL *tokenUrl = [NSURL URLWithString:spotify.tokenUri];
    NSString *payload = [NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@", spotify.refreshToken];
    [spotify getAccessToken:tokenUrl
                    Payload:payload
          CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
     {
         completionHandler(YES, nil);
     }];
}

+ (void)getRecommendationsWithSeedArtist:(NSString *)seedArtist SeedTrack:(NSString *)seedTrack SeedGenre:(NSString *)seedGenre Popularity:(NSString *)popularity AndCompletionHandler:(void(^)(NSDictionary *recommendations, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSString *recommendations = [NSString stringWithFormat:@"https://api.spotify.com/v1/recommendations?seed_artists=%@&seed_tracks=%@&seed_genres=%@min_popularity=%@",
                                 seedArtist, seedTrack, seedGenre, popularity];
    
    NSURL *url = [NSURL URLWithString:recommendations];
    [JGSpotifyVerbs JGSpotifyGetVerb:url  AuthorizationCode:spotify.accessToken CompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

@end
