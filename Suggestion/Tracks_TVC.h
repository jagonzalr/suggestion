//
//  Tracks_TVC.h
//  Suggestion
//
//  Created by José Antonio González on 10/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Tracks_TVC : UITableViewController

@property (nonatomic) BOOL isLoadingRecommendations;
@property (nonatomic, strong) NSDictionary *recommendationsParameters;

@end
