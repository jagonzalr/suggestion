//
//  JGSpotifyVerbs.m
//  Suggestion
//
//  Created by José Antonio González on 02/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "JGSpotifyVerbs.h"

@implementation JGSpotifyVerbs

+ (void)JGSpotifyGetVerb:(NSURL *)url
                AuthorizationCode:(NSString *)authorizationCode
       CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json"
      forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", authorizationCode]
      forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setAllowsCellularAccess:YES];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error)
                                      {
                                          if (error) {
                                              completionHandler(response, nil, error);
                                          } else {
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:&error];
                                              
                                              completionHandler(response, json, nil);
                                          }
                                      }];
    
    [dataTask resume];

}

+ (void)JGSpotifyPostVerb:(NSURL *)url
                  Payload:(NSString *)payload
        WithAuthorization:(BOOL)withAuthorization
                 ClientID:(NSString *)clientID
             ClientSecret:(NSString *)clientSecret
        CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSData *data = [payload dataUsingEncoding:NSASCIIStringEncoding
                         allowLossyConversion:YES];
    
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[payload length]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:dataLength
      forHTTPHeaderField:@"Content-Length"];
    
    [urlRequest setValue:@"application/x-www-form-urlencoded"
      forHTTPHeaderField:@"Content-Type"];
    
    if (withAuthorization) {
        NSString *credential = [JGSpotifyVerbs credentialsToBase64WithClientID:clientID
                                                               AndClientSecret:clientSecret];
        
        [urlRequest setValue:[NSString stringWithFormat:@"Basic %@", credential]
          forHTTPHeaderField:@"Authorization"];
    }
    
    [urlRequest setHTTPBody:data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setAllowsCellularAccess:YES];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error)
    {
        if (error) {
            completionHandler(response, nil, error);
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
            
            completionHandler(response, json, nil);
        }
    }];
    
    [dataTask resume];
    
}

+ (void)JGSpotifyPutVerb:(NSURL *)url
                 Payload:(NSString *)payload
       AuthorizationCode:(NSString *)authorizationCode
       CompletionHandler:(void(^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSData *data = [payload dataUsingEncoding:NSASCIIStringEncoding
                         allowLossyConversion:YES];
    
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[payload length]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"PUT"];
    [urlRequest setValue:dataLength
      forHTTPHeaderField:@"Content-Length"];
    
    [urlRequest setValue:@"application/x-www-form-urlencoded"
      forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", authorizationCode]
      forHTTPHeaderField:@"Authorization"];
    
    [urlRequest setHTTPBody:data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setAllowsCellularAccess:YES];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error)
                                      {
                                          if (error) {
                                              completionHandler(response, nil, error);
                                          } else {
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:&error];
                                              
                                              completionHandler(response, json, nil);
                                          }
                                      }];
    
    [dataTask resume];
    
}

+ (NSString *)credentialsToBase64WithClientID:(NSString *)clientID
                              AndClientSecret:(NSString *)clientSecret
{
    NSString *credentialWithoutBase64 = [NSString stringWithFormat:@"%@:%@", clientID, clientSecret];
    NSData *credentialDataEncoded = [credentialWithoutBase64 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *credentialBase64 = [credentialDataEncoded base64EncodedStringWithOptions:0];
    return credentialBase64;
}

@end
