//
//  NewReleases_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "NewReleases_TVC.h"
#import "NewReleases_TVCell.h"
#import "Tracks_TVC.h"
#import "JGSpotify.h"
#import "JGStyles.h"

#import "SVProgressHUD.h"

static NSString *CellIdentifier = @"newReleaseCell";

@interface NewReleases_TVC ()

@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation NewReleases_TVC

#pragma mark - Getters && Setters

- (NSMutableArray *)albums
{
    if (!_albums) _albums = [[NSMutableArray alloc] init];
    return _albums;
}


#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeUI];
    [self loadNewReleases];
}

- (void)viewWillAppear:(BOOL)animated
{
    [JGStyles configureTabBar:self.tabBarController.tabBar];
}

#pragma mark - Functions

- (void)configureTableView
{
    if (self.albums.count > 0) {
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
    
    self.title = @"New Releases".uppercaseString;
}

- (void)loadNewReleases
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result, NSError *error) {
        if (result) {
            [JGSpotify getNewReleasesCompletionHandler:^(NSDictionary *albums, NSError *error)
             {
                 for (NSDictionary *album in albums[@"albums"][@"items"]) {
                     [JGSpotify getAlbum:album[@"id"] WithCompletionHandler:^(NSDictionary *albumData, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.tableView beginUpdates];
                             [self.albums addObject:albumData];
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.albums.count - 1
                                                                         inSection:0];
                             
                             [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                                   withRowAnimation:UITableViewRowAnimationFade];
                             
                             [self.tableView endUpdates];
                         });
                     }];
                     
                 }
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

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewReleases_TVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newReleaseCell" forIndexPath:indexPath];
    
    NSDictionary *album = [self.albums objectAtIndex:indexPath.row];
    cell.albumName.text = album[@"name"];
    cell.albumArtist.text = album[@"artists"][0][@"name"];
    cell.albumArtist.text = cell.albumArtist.text.uppercaseString;
    cell.albumName.textColor = [JGStyles textColor];
    cell.albumArtist.textColor = [JGStyles textColor];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyLightColor];
    
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    
    Tracks_TVC *newTracksTVC = [storyboard instantiateViewControllerWithIdentifier:@"TracksViewController"];
    newTracksTVC.isLoadingRecommendations = YES;
    newTracksTVC.recommendationsParameters = [self.albums objectAtIndex:indexPath.row];
    newTracksTVC.isAlbum = YES;
    [self.navigationController pushViewController:newTracksTVC
                                         animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

@end
