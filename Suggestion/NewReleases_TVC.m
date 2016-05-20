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

#import <ChameleonFramework/Chameleon.h>
#import "SIAlertView.h"
#import "SVProgressHUD.h"

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
    self.tableView.separatorColor = [UIColor colorWithHexString:@"CDCDCD"];
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.title = @"New Releases".uppercaseString;
}

- (void)loadNewReleases
{
    [SVProgressHUD show];
    [self verifyAccessTokenWithCompletionHandler:^(BOOL result, NSError *error) {
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
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *initialNavController = [main instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:initialNavController animated:YES completion:nil];
        }
    }];
}

- (void)verifyAccessTokenWithCompletionHandler:(void(^)(BOOL result, NSError *error))completionHandler
{
    JGSpotify *spotify = [JGSpotify sharedInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *accessTokenExpires = [userDefaults objectForKey:@"spotifyAccessTokenExpires"];
    
    NSDate *now = [NSDate date];
    NSTimeInterval distanceBetweenDates = [accessTokenExpires timeIntervalSinceDate:now];
    if (distanceBetweenDates < 60) {
        [spotify refreshTokenWithCompletionHandler:^(BOOL result, NSError *error) {
            completionHandler(result, nil);
        }];
    } else {
        completionHandler(YES, nil);
    }
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
    cell.albumName.textColor = [UIColor colorWithHexString:@"414141"];
    cell.albumArtist.textColor = [UIColor colorWithHexString:@"414141"];
    
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
