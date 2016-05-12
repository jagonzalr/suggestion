//
//  Recommendations_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 11/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "Recommendations_TVC.h"
#import "JGSpotify.h"
#include <EZAudio/EZAudio.h>

@interface Recommendations_TVC () <EZAudioPlayerDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableArray *recommendations;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation Recommendations_TVC

- (NSMutableArray *)recommendations
{
    if (!_recommendations) _recommendations = [[NSMutableArray alloc] init];
    return _recommendations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JGSpotify getRecommendationsWithSeedArtist:self.recommendationsParameters[4] SeedTrack:self.recommendationsParameters[3] SeedGenre:@"" Popularity:@"50" AndCompletionHandler:^(NSDictionary *recommendations, NSError *error) {
        for (NSDictionary *recommendationInfo in recommendations[@"tracks"]) {
            [self.recommendations addObject:@[recommendationInfo[@"name"], recommendationInfo[@"artists"][0][@"name"], recommendationInfo[@"preview_url"]]];
        }
        [self.tableView reloadData];
    }];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];

    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
//    [session setActive:YES error:&error];
//    if (error)
//    {
//        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
//    }
    
    //
    // Override the output to the speaker
    //
//    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
//    if (error)
//    {
//        NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
//    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recommendations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendationCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.recommendations objectAtIndex:indexPath.row][0];
    cell.detailTextLabel.text = [self.recommendations objectAtIndex:indexPath.row][1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSURL *url = [NSURL URLWithString:[self.recommendations objectAtIndex:indexPath.row][2]];
//    NSLog(@"%@", url);
//    self.audioFile = [EZAudioFile audioFileWithURL:url];
//    NSLog(@"%@", url);
//    [self.player setAudioFile:self.audioFile];
//    
//    [self.player play];
    
    self.player = [[AVPlayer alloc] initWithURL:url];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0f;
    [self.player play];
    NSLog(@"playing");
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
