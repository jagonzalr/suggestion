//
//  Track_TVCell.h
//  Suggestion
//
//  Created by José Antonio González on 11/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Track_TVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *song;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *album;
@property (weak, nonatomic) IBOutlet UIButton *mediaBtn;
@property (weak, nonatomic) IBOutlet UIButton *openInSpotifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@end
