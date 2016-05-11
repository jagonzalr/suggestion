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

#import <ChameleonFramework/Chameleon.h>

@interface Tracks_TVC ()

@property (nonatomic, strong) NSMutableArray *tracks;

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
    [JGSpotify getTopTracksCompletionHandler:^(NSDictionary *tracks, NSError *error) {
        for (NSDictionary *trackInfo in tracks[@"items"]) {
            NSLog(@"%@", trackInfo);
            [self.tracks addObject:@[trackInfo[@"name"], trackInfo[@"preview_url"], trackInfo[@"artists"][0][@"name"]]];
        }
        [self.tableView reloadData];
    }];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"CDCDCD"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Songs".uppercaseString;
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
    
    cell.song.textColor = [UIColor colorWithHexString:@"414141"];
    cell.artist.textColor = [UIColor colorWithHexString:@"414141"];
    cell.backgroundColor = [UIColor clearColor];
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [UIColor colorWithHexString:@"EDEDED"];
    cell.selectedBackgroundView = cellBackgroundView;
    
    return cell;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100.0f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
