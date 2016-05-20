//
//  SuggestionStyles.m
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "JGStyles.h"
#import <ChameleonFramework/Chameleon.h>

NSString * const kBoldFontName = @"AvenirNext-Bold";
NSString * const kLightFontName = @"AvenirNext-Light";
NSString * const kNormalFontName = @"Avenir Next";

NSString * const backgroundColor = @"F9F9F9";
NSString * const greenColor = @"1ED760";
NSString * const greyDarkColor = @"CDCDCD";
NSString * const greyLightColor = @"EDEDED";
NSString * const textColor = @"414141";
NSString * const whiteColor = @"FEFEFE";

@implementation JGStyles

+ (JGStyles *)sharedStyles
{
    static JGStyles *_sharedStyles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStyles = [[self alloc] init];
    });
    
    return _sharedStyles;
}

+ (UIColor *)backgroundColor { return [UIColor colorWithHexString:backgroundColor]; }
+ (UIColor *)greenColor { return [UIColor colorWithHexString:greenColor]; }
+ (UIColor *)greyDarkColor { return [UIColor colorWithHexString:greyDarkColor]; }
+ (UIColor *)greyLightColor { return [UIColor colorWithHexString:greyLightColor]; }
+ (UIColor *)textColor { return [UIColor colorWithHexString:textColor]; }
+ (UIColor *)whiteColor { return [UIColor colorWithHexString:whiteColor]; }

+ (UIFont *)boldFont:(CGFloat)size { return [UIFont fontWithName:kBoldFontName size:size]; }
+ (UIFont *)lightFont:(CGFloat)size { return [UIFont fontWithName:kLightFontName size:size]; }
+ (UIFont *)normalFont:(CGFloat)size { return [UIFont fontWithName:kNormalFontName size:size]; }

+ (void)configureTabBar:(UITabBar *)tabBar
{
    [[tabBar.items objectAtIndex:0] setTitle:@"Songs"];
    [[tabBar.items objectAtIndex:1] setTitle:@"Artists"];
    [[tabBar.items objectAtIndex:2] setTitle:@"New Releases"];
    [[tabBar.items objectAtIndex:3] setTitle:@"Settings"];
}

+ (void)removeUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"spotifyAccessToken"];
    [userDefaults removeObjectForKey:@"spotifyAccessTokenExpires"];
    [userDefaults removeObjectForKey:@"spotifyRefreshToken"];
    [userDefaults synchronize];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
