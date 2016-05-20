//
//  SuggestionStyles.h
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

extern NSString * const kBoldFontName;
extern NSString * const kLightFontName;
extern NSString * const kNormalFontName;

extern NSString * const kBackgroundColor;
extern NSString * const kGreenColor;
extern NSString * const kGreyDarkColor;
extern NSString * const kGreyLightColor;
extern NSString * const kTextColor;
extern NSString * const kWhiteColor;


@interface JGStyles : NSObject

+ (JGStyles *)sharedStyles;

+ (UIColor *)backgroundColor;
+ (UIColor *)greenColor;
+ (UIColor *)greyDarkColor;
+ (UIColor *)greyLightColor;
+ (UIColor *)textColor;
+ (UIColor *)whiteColor;

+ (UIFont *)boldFont:(CGFloat)size;
+ (UIFont *)lightFont:(CGFloat)size;
+ (UIFont *)normalFont:(CGFloat)size;

@end
