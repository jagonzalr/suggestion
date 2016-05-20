//
//  Settings_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

#import "Settings_TVC.h"
#import "JGStyles.h"

@interface Settings_TVC ()

@property (nonatomic, strong) NSMutableArray *settings;

@end

@implementation Settings_TVC

#pragma mark - Getters && Setters

- (NSMutableArray *)settings
{
    if (!_settings) _settings = [NSMutableArray arrayWithObjects:@"Libraries", @"Logout", nil];
    return _settings;
}


#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Songs"];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Artists"];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:@"New Releases"];
    [[self.tabBarController.tabBar.items objectAtIndex:3] setTitle:@"Settings"];
}

#pragma mark - Functions

- (void)configureTableView
{
    if (self.settings.count > 0) {
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
    self.tableView.separatorColor = [JGStyles greyLightColor];
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.view.backgroundColor = [JGStyles whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.title = @"Settings".uppercaseString;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyDarkColor];
    
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = [self.settings objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [JGStyles textColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.settings[indexPath.row] isEqualToString:@"Logout"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"spotifyAccessToken"];
        [userDefaults removeObjectForKey:@"spotifyAccessTokenExpires"];
        [userDefaults removeObjectForKey:@"spotifyRefreshToken"];
        [userDefaults synchronize];
        
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

@end
