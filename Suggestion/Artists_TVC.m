//
//  Artists_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

// Classes
#import "Artists_TVC.h"
#import "Artists_TVCell.h"
#import "Tracks_TVC.h"

// Helpers
#import "JGSpotify.h"
#import "JGStyles.h"

// Libraries
#import "SVProgressHUD.h"

// Constants
static NSString *CellIdentifier = @"artistCell";

@interface Artists_TVC ()

@property (nonatomic, strong) NSMutableArray *artists;

@end

@implementation Artists_TVC

#pragma mark - Initialize Variables

- (NSMutableArray *)artists
{
    if (!_artists) _artists = [[NSMutableArray alloc] init];
    return _artists;
}


#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeUI];
    [self loadArtists];
}

- (void)viewWillAppear:(BOOL)animated
{
    [JGStyles configureTabBar:self.tabBarController.tabBar];
}


#pragma mark - Functions

- (void)configureCell:(Artists_TVCell *)cell
            IndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *artist = [self.artists objectAtIndex:indexPath.row];
    cell.artistName.text = artist[@"name"];
    cell.artistName.textColor = [JGStyles textColor];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyLightColor];
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
}

- (void)configureTableView
{
    if (self.artists.count > 0) {
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
    self.tableView.tableFooterView = [UIView new];
    
    self.view.backgroundColor = [JGStyles whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.title = @"Artists".uppercaseString;
}

- (void)loadArtists
{
    [SVProgressHUD show];
    [JGSpotify verifyAccessTokenWithCompletionHandler:^(BOOL result,
                                                        NSError *error)
    {
        if (result) {
            [JGSpotify getTopArtistsCompletionHandler:^(NSDictionary *artists,
                                                        NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (NSDictionary *artist in artists[@"items"]) {
                        [self.tableView beginUpdates];
                        [self.artists addObject:artist];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.artists count] - 1
                                                                    inSection:0];
                        
                        [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                              withRowAnimation:UITableViewRowAnimationFade];
                        
                        [self.tableView endUpdates];
                    }
                    
                    [SVProgressHUD dismiss];
                });
            }];
        } else {
            [SVProgressHUD dismiss];
            [JGStyles removeUserDefaults];
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.artists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Artists_TVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
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
    newTracksTVC.recommendationsParameters = [self.artists objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:newTracksTVC
                                         animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 100.0f; }

@end
