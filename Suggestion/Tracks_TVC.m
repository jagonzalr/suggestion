//
//  Tracks_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 10/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "Tracks_TVC.h"
#import "Track_TVCell.h"
#import "JGSpotify.h"
#import "JGStyles.h"

#import "SIAlertView.h"
#import "SVProgressHUD.h"

@interface Tracks_TVC ()

@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) NSMutableArray *tracks;

@end

@implementation Tracks_TVC

#pragma mark - Getters && Setters

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [JGStyles configureTabBar:self.tabBarController.tabBar];
}


#pragma mark - Functions

- (void)configureAVSession
{
    NSError *error;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
}

- (void)configureCell:(Track_TVCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    cell.song.text = [self.tracks objectAtIndex:indexPath.row][@"name"];
    cell.artist.text = [self.tracks objectAtIndex:indexPath.row][@"artists"][0][@"name"];
    cell.artist.text = cell.artist.text.uppercaseString;
    cell.album.text = [self.tracks objectAtIndex:indexPath.row][@"album"][@"name"];
    cell.album.text = cell.album.text.uppercaseString;

    cell.song.textColor = [JGStyles textColor];
    cell.artist.textColor = [JGStyles textColor];
    cell.album.textColor = [JGStyles textColor];
    
    cell.saveTrackBtn.tag = indexPath.row;
    cell.mediaBtn.tag = indexPath.row;
    cell.openInSpotifyBtn.tag = indexPath.row;
    
    [cell.saveTrackBtn addTarget:self
                          action:@selector(saveTrack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell.mediaBtn addTarget:self
                      action:@selector(playPreview:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [cell.openInSpotifyBtn addTarget:self
                              action:@selector(openInSpotify:)
                    forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)loadTopTracks
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result, NSError *error) {
        if (result) {
            [JGSpotify getTopTracksCompletionHandler:^(NSDictionary *tracks, NSError *error)
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
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"spotifyAccessToken"];
            [userDefaults removeObjectForKey:@"spotifyAccessTokenExpires"];
            [userDefaults removeObjectForKey:@"spotifyRefreshToken"];
            [userDefaults synchronize];
            
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)loadRecommendations
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result, NSError *error) {
        if (result) {
            __block NSString *seedArtistID = @"";
            __block NSString *seedTrackID = @"";
            __block NSString *seedGenreID = @"";
            __block BOOL isArtist = [self.recommendationsParameters objectForKey:@"genres"] ? YES : NO;
            
            if ([self.recommendationsParameters objectForKey:@"artists"]) {
                seedArtistID = [self.recommendationsParameters objectForKey:@"artists"][0][@"id"];
            } else {
                seedArtistID = [self.recommendationsParameters objectForKey:@"id"];
            }
            
            [JGSpotify getArtistTopTracks:seedArtistID WithCompletionHandler:^(NSDictionary *tracks, NSError *error) {
                NSMutableArray *trackIDs = [[NSMutableArray alloc] init];
                int tracksMaxCount = 2;
                if (!isArtist) {
                    if (self.isAlbum) {
                        [trackIDs addObject:self.recommendationsParameters[@"tracks"][@"items"][0][@"id"]];
                    } else {
                        [trackIDs addObject:[self.recommendationsParameters objectForKey:@"id"]];
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
                                       AndCompletionHandler:^(NSDictionary *recommendations, NSError *error)
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
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"spotifyAccessToken"];
            [userDefaults removeObjectForKey:@"spotifyAccessTokenExpires"];
            [userDefaults removeObjectForKey:@"spotifyRefreshToken"];
            [userDefaults synchronize];
            
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)loadTracks
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isLoadingRecommendations ? [self loadRecommendations] : [self loadTopTracks];
    });
}


#pragma mark - Selectors

- (void)openInSpotify:(UIButton *)sender
{
    NSString *title = @"What do you want to do?";
    NSString *message = [NSString stringWithFormat:@"The track %@ will open in Spotify.", [self.tracks objectAtIndex:sender.tag][@"name"]];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:message];
    
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Cancel Clicked");
                          }];
    
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][@"external_urls"][@"spotify"]]];
                          }];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][@"external_urls"][@"spotify"]]]) {
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
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"]
                       forState:UIControlStateNormal];
        
        [cell.mediaBtn removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventTouchUpInside];
        
        [cell.mediaBtn addTarget:self
                          action:@selector(playPreview:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.isPlaying) {
        [self.player pause];
        self.player = nil;
    }
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag
                                                inSection:0];
    
    Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.mediaBtn setImage:[UIImage imageNamed:@"Stop"]
                   forState:UIControlStateNormal];
    
    [cell.mediaBtn removeTarget:nil
                         action:NULL
               forControlEvents:UIControlEventTouchUpInside];
    
    [cell.mediaBtn addTarget:self
                      action:@selector(stopPreview:)
            forControlEvents:UIControlEventTouchUpInside];
    
    NSURL *url = [NSURL URLWithString:[self.tracks objectAtIndex:sender.tag][@"preview_url"]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0f;
    [self.player play];
}


- (void)saveTrack:(UIButton *)sender
{
    NSString *title = @"Do you want to save this track?";
    NSString *message = [NSString stringWithFormat:@"The track %@ will be save in 'Your Music' library in Spotify.", [self.tracks objectAtIndex:sender.tag][@"name"]];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:message];
    
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeDestructive
                          handler:nil];
    
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              [SVProgressHUD show];
                              [JGSpotify saveTrack:[self.tracks objectAtIndex:sender.tag][@"id"] WithCompletionHandler:^(id artist, NSError *error) {
                                  [SVProgressHUD dismiss];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (!error) {
                                          NSDictionary *artistInfo = (NSDictionary *)artist;
                                          if ([artistInfo objectForKey:@"error"]) {
                                              NSString *successTitle = @"Error";
                                              NSString *successMessage = [NSString stringWithFormat:@"The track %@ couldn't been saved in 'Your Music' library in Spotify.", [self.tracks objectAtIndex:sender.tag][@"name"]];
                                              
                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                                               andMessage:successMessage];
                                              
                                              [alertView addButtonWithTitle:@"Ok"
                                                                       type:SIAlertViewButtonTypeDestructive
                                                                    handler:nil];
                                              [alertView show];
                                          } else {
                                              NSString *successTitle = @"Success";
                                              NSString *successMessage = [NSString stringWithFormat:@"The track %@ has been saved in 'Your Music' library in Spotify.", [self.tracks objectAtIndex:sender.tag][@"name"]];
                                              
                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                                               andMessage:successMessage];
                                              
                                              [alertView addButtonWithTitle:@"Ok"
                                                                       type:SIAlertViewButtonTypeCancel
                                                                    handler:nil];
                                              [alertView show];
                                          }
                                          
                                          
                                      } else {
                                          NSString *successTitle = @"Error";
                                          NSString *successMessage = [NSString stringWithFormat:@"The track %@ couldn't been saved in 'Your Music' library in Spotify.", [self.tracks objectAtIndex:sender.tag][@"name"]];
                                          
                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:successTitle
                                                                                           andMessage:successMessage];
                                          
                                          [alertView addButtonWithTitle:@"Ok"
                                                                   type:SIAlertViewButtonTypeDestructive
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
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventTouchUpInside];
        
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"]
                       forState:UIControlStateNormal];
    }
    
    [self.player pause];
    self.player = nil;
    self.isPlaying = !self.isPlaying;
    
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn addTarget:self
                          action:@selector(playPreview:)
                forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)trackDidFinishPlaying:(NSNotification *) notification
{
    for (int i = 0; i < self.tracks.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i
                                                    inSection:0];
        
        Track_TVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.mediaBtn setImage:[UIImage imageNamed:@"Play"]
                       forState:UIControlStateNormal];
        
        [cell.mediaBtn removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventTouchUpInside];
        
        [cell.mediaBtn addTarget:self
                          action:@selector(playPreview:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.isPlaying = NO;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track_TVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
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


#pragma mark - UITabBar

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"%lu", (unsigned long)tabBarController.selectedIndex);
    if (tabBarController.selectedIndex == 0) {
        NSLog(@"showTopSongs");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTopSongs" object:nil];
    }
    
    if (tabBarController.selectedIndex == 2) {
        NSLog(@"showNewReleases");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNewReleases" object:nil];
    }
}

@end
