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

NSString * const kBackgroundColor = @"F9F9F9";
NSString * const kGreenColor = @"46B787";
NSString * const kGreyDarkColor = @"CDCDCD";
NSString * const kGreyLightColor = @"EDEDED";
NSString * const kRedColor = @"F6504D";
NSString * const kSpotifyColor = @"1ED760";
NSString * const kTextColor = @"414141";
NSString * const kWhiteColor = @"FEFEFE";

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

+ (UIColor *)backgroundColor { return [UIColor colorWithHexString:kBackgroundColor]; }
+ (UIColor *)greenColor { return [UIColor colorWithHexString:kGreenColor]; }
+ (UIColor *)greyDarkColor { return [UIColor colorWithHexString:kGreyDarkColor]; }
+ (UIColor *)greyLightColor { return [UIColor colorWithHexString:kGreyLightColor]; }
+ (UIColor *)redColor { return [UIColor colorWithHexString:kRedColor]; }
+ (UIColor *)spotifyColor { return [UIColor colorWithHexString:kSpotifyColor]; }
+ (UIColor *)textColor { return [UIColor colorWithHexString:kTextColor]; }
+ (UIColor *)whiteColor { return [UIColor colorWithHexString:kWhiteColor]; }

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

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)roundedImage:(UIImage *)image WithRadius:(NSInteger)radius
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
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
