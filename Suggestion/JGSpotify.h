//
//  JGSpotify.h
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGSpotify : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSDate *accessTokenExpires;
@property (nonatomic, strong) NSMutableString *authorizeUri;
@property (nonatomic, strong) NSString *callbackUri;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectUri;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSMutableArray *scopes;
@property (nonatomic, strong) NSString *tokenUri;

+ (id)initWithClientID:(NSString *)clientID
          ClientSecret:(NSString *)clientSecret
                Scopes:(NSMutableArray *)scopes
           CallbackUri:(NSString *)callbackUri
        AndRedirectUri:(NSString *)redirectUri;

+ (JGSpotify *)sharedInstance;

+ (void)getArtist:(NSString *)artistID WithCompletionHandler:(void(^)(NSDictionary *tracks, NSError *error))completionHandler;
+ (void)saveTrack:(NSString *)trackID WithCompletionHandler:(void(^)(id track, NSError *error))completionHandler;
+ (void)getTopArtistsCompletionHandler:(void(^)(NSDictionary *artists, NSError *error))completionHandler;
+ (void)getTopTracksCompletionHandler:(void(^)(NSDictionary *tracks, NSError *error))completionHandler;
+ (void)getRecommendationsWithSeedArtist:(NSString *)seedArtist SeedTrack:(NSString *)seedTrack SeedGenre:(NSString *)seedGenre Popularity:(NSString *)popularity AndCompletionHandler:(void(^)(NSDictionary *recommendations, NSError *error))completionHandler;

- (void)authorizeWithCompletionHandler:(void(^)(BOOL result, NSError *error))completionHandler;

@end
