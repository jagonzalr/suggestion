//
//  JGSpotifyVerbs.h
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGSpotifyVerbs : NSObject

+ (void)JGSpotifyGetVerb:(NSURL *)url
                AuthorizationCode:(NSString *)authorizationCode
       CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

+ (void)JGSpotifyPostVerb:(NSURL *)url
                  Payload:(NSString *)payload
        WithAuthorization:(BOOL)withAuthorization
                 ClientID:(NSString *)clientID
             ClientSecret:(NSString *)clientSecret
        CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

+ (void)JGSpotifyPutVerb:(NSURL *)url
                 Payload:(NSString *)payload
       AuthorizationCode:(NSString *)authorizationCode
       CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end
