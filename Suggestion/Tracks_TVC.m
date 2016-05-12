//
//  Tracks_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 10/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "Tracks_TVC.h"
#import "Track_TVCell.h"
#import "Recommendations_TVC.h"
#import "JGSpotify.h"

#import <ChameleonFramework/Chameleon.h>

@interface Tracks_TVC ()

@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) BOOL isPlaying;

@end

@implementation Tracks_TVC

- (NSMutableArray *)tracks
{
    if (!_tracks) _tracks = [[NSMutableArray alloc] init];
    return _tracks;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isLoadingRecommendations) {
        [JGSpotify getRecommendationsWithSeedArtist:self.recommendationsParameters[4] SeedTrack:self.recommendationsParameters[3] SeedGenre:@"" Popularity:@"50" AndCompletionHandler:^(NSDictionary *recommendations, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSDictionary *recommendationInfo in recommendations[@"tracks"]) {
                    NSLog(@"%@", recommendationInfo[@"uri"]);
                    [self.tableView beginUpdates];
                    [self.tracks addObject:@[recommendationInfo[@"name"], recommendationInfo[@"preview_url"], recommendationInfo[@"artists"][0][@"name"], recommendationInfo[@"id"], recommendationInfo[@"artists"][0][@"id"], recommendationInfo[@"uri"], recommendationInfo[@"album"][@"name"]]];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tracks.count - 1 inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    
                }
            });
            
        }];
    } else {
        [JGSpotify getTopTracksCompletionHandler:^(NSDictionary *tracks, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSDictionary *trackInfo in tracks[@"items"]) {
                    [self.tableView beginUpdates];
                    [self.tracks addObject:@[trackInfo[@"name"], trackInfo[@"preview_url"], trackInfo[@"artists"][0][@"name"], trackInfo[@"id"], trackInfo[@"artists"][0][@"id"], trackInfo[@"uri"], trackInfo[@"album"][@"name"]]];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tracks.count - 1 inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    NSLog(@"%@", trackInfo);
                }
            });
            
        }];
    }
    
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"CDCDCD"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (self.isLoadingRecommendations) {
        self.title = @"Recommendations".uppercaseString;
    } else {
        self.title = @"Top Songs".uppercaseString;
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    
    self.isPlaying = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track_TVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
    cell.song.text = [self.tracks objectAtIndex:indexPath.row][0];
    cell.artist.text = [self.tracks objectAtIndex:indexPath.row][2];
    cell.artist.text = cell.artist.text.uppercaseString;
    cell.album.text = [self.tracks objectAtIndex:indexPath.row][2];
    cell.album.text = cell.album.text.uppercaseString;
    
    cell.song.textColor = [UIColor colorWithHexString:@"414141"];
    cell.artist.textColor = [UIColor colorWithHexString:@"414141"];
    cell.backgroundColor = [UIColor clearColor];
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [UIColor colorWithHexString:@"EDEDED"];
    cell.selectedBackgroundView = cellBackgroundView;
    
    cell.mediaBtn.tag = indexPath.row;
    cell.openInSpotifyBtn.tag = indexPath.row;
    [cell.mediaBtn addTarget:self action:@selector(playPreview:) forControlEvents:UIControlEventTouchUpInside];
    [cell.openInSpotifyBtn addTarget:self action:@selector(openInSpotify:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)openInSpotify:(UIButton *)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][5]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][5]]];
    } else {
        NSLog(@"open in safari");
    }
    
}

- (void)playPreview:(UIButton *)sender
{
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [cell.mediaBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
        [cell.mediaBtn addTarget:self action:@selector(playPreview:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.isPlaying) {
        [self.player pause];
        self.player = nil;
    }
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.mediaBtn setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
    [cell.mediaBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [cell.mediaBtn addTarget:self action:@selector(stopPreview:) forControlEvents:UIControlEventTouchUpInside];
    
    NSURL *url = [NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][1]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0f;
    [self.player play];
    NSLog(@"playing");
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [cell.mediaBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
        [cell.mediaBtn addTarget:self action:@selector(playPreview:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.isPlaying = NO;
}

- (void)stopPreview:(UIButton *)sender
{
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
    
    [self.player pause];
    self.player = nil;
    self.isPlaying = !self.isPlaying;
    
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn addTarget:self action:@selector(playPreview:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSLog(@"pausing");
}

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100.0f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Tracks_TVC *newTracksTVC = [storyboard instantiateViewControllerWithIdentifier:@"TracksViewController"];
    newTracksTVC.isLoadingRecommendations = YES;
    newTracksTVC.recommendationsParameters = [self.tracks objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:newTracksTVC animated:YES];
//    [self performSegueWithIdentifier:@"showRecommendations" sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRecommendations"]) {
        Recommendations_TVC *recommendationsTVC = (Recommendations_TVC *)[segue destinationViewController];
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        recommendationsTVC.recommendationsParameters = [self.tracks objectAtIndex:indexPath.row];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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

@end
