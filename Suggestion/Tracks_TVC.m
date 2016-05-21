//
//  Tracks_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 10/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

// Classes
#import "Tracks_TVC.h"
#import "Track_TVCell.h"

// Helpers
#import "JGSpotify.h"
#import "JGStyles.h"

// Libraries
#import "SIAlertView.h"
#import "SVProgressHUD.h"

// Constants
static NSString *CellIdentifier = @"trackCell";

@interface Tracks_TVC ()

@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic) NSInteger tagPlaying;
@property (nonatomic, strong) NSMutableArray *tracks;

@end

@implementation Tracks_TVC

#pragma mark - Initialize Variables

- (AVAudioSession *)session
{
    return [AVAudioSession sharedInstance];
}

- (NSMutableArray *)tracks
{
    if (!_tracks) _tracks = [[NSMutableArray alloc] init];
    return _tracks;
}


#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureAVSession];
    [self customizeUI];
    [self loadTracks];
    
    self.tagPlaying = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [JGStyles configureTabBar:self.tabBarController.tabBar];
}


#pragma mark - Functions

- (void)configureAVSession
{
    NSError *error;
    [self.session setCategory:AVAudioSessionCategoryPlayback
                        error:&error];
}

- (void)configureCell:(Track_TVCell *)cell
            IndexPath:(NSIndexPath *)indexPath
{
    NSString *song = self.tracks[indexPath.row][@"name"];
    song = [song substringToIndex:MIN(35, [song length])];
    NSString *artist = self.tracks[indexPath.row][@"artists"][0][@"name"];
    artist = [artist substringToIndex:MIN(50, [artist length])].uppercaseString;
    NSString *album = self.tracks[indexPath.row][@"album"][@"name"];
    album = album.uppercaseString;
    
    cell.song.text = song;
    cell.artist.text = artist;
    cell.album.text = album;

    cell.song.textColor = [JGStyles textColor];
    cell.artist.textColor = [JGStyles textColor];
    cell.album.textColor = [JGStyles textColor];
    
    cell.saveTrackBtn.tag = indexPath.row;
    cell.mediaBtn.tag = indexPath.row;
    cell.openInSpotifyBtn.tag = indexPath.row;
    
    [cell.saveTrackBtn addTarget:self
                          action:@selector(saveTrack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell.openInSpotifyBtn addTarget:self
                              action:@selector(openInSpotify:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [cell.mediaBtn removeTarget:nil
                         action:NULL
               forControlEvents:UIControlEventTouchUpInside];
    
    if (self.tagPlaying == indexPath.row) {
        [cell.mediaBtn addTarget:self
                          action:@selector(stopPreview:)
                forControlEvents:UIControlEventTouchUpInside];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.mediaBtn setImage:[UIImage imageNamed:@"Stop"]
                           forState:UIControlStateNormal];
        });
    } else {
        [cell.mediaBtn addTarget:self
                          action:@selector(playPreview:)
                forControlEvents:UIControlEventTouchUpInside];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"]
                           forState:UIControlStateNormal];
        });
    }
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyLightColor];
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
}

- (void)configureTableView
{
    if (self.tracks.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    } else {
        self.tableView.backgroundView = [UIView new];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (void)customizeUI
{
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [JGStyles greyDarkColor];
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.view.backgroundColor = [JGStyles whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.title = self.isLoadingRecommendations ? @"Recommendations".uppercaseString : @"Songs".uppercaseString;
}

- (void)loadRecommendations
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result,
                                                        NSError *error)
    {
        if (result) {
            __block NSString *seedArtistID = @"";
            __block NSString *seedTrackID = @"";
            __block NSString *seedGenreID = @"";
            __block BOOL isArtist = self.recommendationsParameters[@"genres"] ? YES : NO;
            
            if (self.recommendationsParameters[@"artists"]) {
                seedArtistID = self.recommendationsParameters[@"artists"][0][@"id"];
            } else {
                seedArtistID = self.recommendationsParameters[@"id"];
            }
            
            [JGSpotify getArtistTopTracks:seedArtistID
                    WithCompletionHandler:^(NSDictionary *tracks,
                                            NSError *error)
            {
                NSMutableArray *trackIDs = [[NSMutableArray alloc] init];
                int tracksMaxCount = 2;
                if (!isArtist) {
                    if (self.isAlbum) {
                        [trackIDs addObject:self.recommendationsParameters[@"tracks"][@"items"][0][@"id"]];
                    } else {
                        [trackIDs addObject:self.recommendationsParameters[@"id"]];
                    }
                }
                
                for (NSDictionary *track in tracks[@"tracks"]) {
                    if (![trackIDs containsObject:track[@"id"]]) {
                        [trackIDs addObject:track[@"id"]];
                        if (trackIDs.count == tracksMaxCount) {
                            break;
                        }
                    }
                }
                
                seedTrackID = [NSString stringWithFormat:@"%@,%@", trackIDs[0], trackIDs[1]];
                [JGSpotify getRecommendationsWithSeedArtist:seedArtistID
                                                  SeedTrack:seedTrackID
                                                  SeedGenre:seedGenreID
                                                 Popularity:@"50"
                                       AndCompletionHandler:^(NSDictionary *recommendations,
                                                              NSError *error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         for (NSDictionary *recommendation in recommendations[@"tracks"]) {
                             [self.tableView beginUpdates];
                             [self.tracks addObject:recommendation];
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tracks.count - 1
                                                                         inSection:0];
                             
                             [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                                   withRowAnimation:UITableViewRowAnimationFade];
                             
                             [self.tableView endUpdates];
                         }
                         [SVProgressHUD dismiss];
                     });
                 }];
            }];
        } else {
            [SVProgressHUD dismiss];
            [JGStyles removeUserDefaults];
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        }
    }];
}

- (void)loadTopTracks
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result,
                                                        NSError *error)
     {
         if (result) {
             [JGSpotify getTopTracksCompletionHandler:^(NSDictionary *tracks,
                                                        NSError *error)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      for (NSDictionary *track in tracks[@"items"]) {
                          [self.tableView beginUpdates];
                          [self.tracks addObject:track];
                          NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tracks.count - 1
                                                                      inSection:0];
                          
                          [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                                withRowAnimation:UITableViewRowAnimationFade];
                          
                          [self.tableView endUpdates];
                      }
                  });
                  [SVProgressHUD dismiss];
              }];
         } else {
             [SVProgressHUD dismiss];
             [JGStyles removeUserDefaults];
             [self dismissViewControllerAnimated:YES
                                      completion:nil];
         }
     }];
}

- (void)loadTracks
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isLoadingRecommendations ? [self loadRecommendations] : [self loadTopTracks];
    });
}

- (void)restoreMedia:(NSIndexPath *)indexPath
{
    Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell IndexPath:indexPath];
}


#pragma mark - Selectors

- (void)openInSpotify:(UIButton *)sender
{
    NSURL *spotifyUrl = [NSURL URLWithString:self.tracks[sender.tag][@"external_urls"][@"spotify"]];
    NSString *title = @"What do you want to do?";
    NSString *message = [NSString stringWithFormat:@"The track %@ will open in Spotify.",
                                                   self.tracks[sender.tag][@"name"]];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:message];
    
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeDestructive
                          handler:nil];
    
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[UIApplication sharedApplication] openURL:spotifyUrl];
                          }];
    
    
    if ([[UIApplication sharedApplication] canOpenURL:spotifyUrl]) {
        [alertView show];
    } else {
        NSString *noSpotifyTitle = @"No Spotify";
        NSString *noSpotifyMessage = @"Your iPhone doesn't have the Spotify app installed.";
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:noSpotifyTitle
                                                         andMessage:noSpotifyMessage];
        
        [alertView addButtonWithTitle:@"Ok"
                                 type:SIAlertViewButtonTypeCancel
                              handler:nil];
        [alertView show];
    }
}

- (void)playPreview:(UIButton *)sender
{
    if (self.isPlaying) {
        [self.player pause];
        self.player = nil;
    }
    
    
    if (self.tagPlaying != -1) {
         NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.tagPlaying inSection:0];
        self.tagPlaying = sender.tag;
        [self restoreMedia:currentIndexPath];
    }
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag
                                                inSection:0];
    
    self.tagPlaying = sender.tag;
    [self restoreMedia:indexPath];
    
    NSURL *url = [NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][@"preview_url"]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:indexPath];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0f;
    [self.player play];
}

- (void)saveTrack:(UIButton *)sender
{
    NSString *title = @"Do you want to save this track?";
    NSString *message = [NSString stringWithFormat:@"The track %@ will be save in 'Your Music' library in Spotify.",
                                                   self.tracks[sender.tag][@"name"]];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:message];
    
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeDestructive
                          handler:nil];
    
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView)
    {
        [SVProgressHUD show];
        [JGSpotify saveTrack:self.tracks[sender.tag][@"id"]
       WithCompletionHandler:^(id artist,
                               NSError *error)
         {
             [SVProgressHUD dismiss];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error) {
                     NSDictionary *artistInfo = (NSDictionary *)artist;
                     if ([artistInfo objectForKey:@"error"]) {
                         NSString *successTitle = @"Error";
                         NSString *successMessage =
                         [NSString stringWithFormat:@"The track %@ couldn't been saved in 'Your Music' library in Spotify.",
                                                    self.tracks[sender.tag][@"name"]];
                         
                         SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                          andMessage:successMessage];
                         
                         [alertView addButtonWithTitle:@"Ok"
                                                  type:SIAlertViewButtonTypeCancel
                                               handler:nil];
                         [alertView show];
                     } else {
                         NSString *successTitle = @"Success";
                         NSString *successMessage =
                         [NSString stringWithFormat:@"The track %@ has been saved in 'Your Music' library in Spotify.",
                                                    self.tracks[sender.tag][@"name"]];
                         
                         SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                          andMessage:successMessage];
                         
                         [alertView addButtonWithTitle:@"Ok"
                                                  type:SIAlertViewButtonTypeCancel
                                               handler:nil];
                         [alertView show];
                     }
                 } else {
                     NSString *successTitle = @"Error";
                     NSString *successMessage =
                     [NSString stringWithFormat:@"The track %@ couldn't been saved in 'Your Music' library in Spotify.",
                                                self.tracks[sender.tag][@"name"]];
                     
                     SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                      andMessage:successMessage];
                     
                     [alertView addButtonWithTitle:@"Ok"
                                              type:SIAlertViewButtonTypeCancel
                                           handler:nil];
                     [alertView show];
                 }
             });
         }];
    }];
    
    [alertView show];
}

- (void)stopPreview:(UIButton *)sender
{
    self.tagPlaying = -1;
    [self.player pause];
    self.player = nil;
    self.isPlaying = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag
                                                inSection:0];
    
    [self restoreMedia:indexPath];
}

-(void)trackDidFinishPlaying:(NSNotification *) notification
{
    [self.player pause];
    self.player = nil;
    self.isPlaying = NO;
    self.tagPlaying = -1;
    
    NSIndexPath *indexPath = (NSIndexPath *)[notification object];
    [self restoreMedia:indexPath];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section { return self.tracks.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track_TVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                         forIndexPath:indexPath];
    
    [self configureCell:cell
              IndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    
    Tracks_TVC *newTracksTVC = [storyboard instantiateViewControllerWithIdentifier:@"TracksViewController"];
    newTracksTVC.isLoadingRecommendations = YES;
    newTracksTVC.recommendationsParameters = [self.tracks objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:newTracksTVC
                                         animated:YES];
}

@end
