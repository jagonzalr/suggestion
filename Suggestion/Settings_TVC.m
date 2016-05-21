//
//  Settings_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 19/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

// Classes
#import "Settings_TVC.h"
#import "AppDelegate.h"

// Helpers
#import "JGStyles.h"

// Libraries
#import "SIAlertView.h"

// Constants
static NSString *CellIdentifier = @"settingCell";

@interface Settings_TVC ()

@property (nonatomic, strong) NSMutableArray *settings;

@end

@implementation Settings_TVC

#pragma mark - Initialize Variables

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
    [JGStyles configureTabBar:self.tabBarController.tabBar];
}


#pragma mark - Functions

- (void)configureCell:(UITableViewCell *)cell
            IndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = self.settings[indexPath.row];
    cell.textLabel.textColor = [JGStyles textColor];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyLightColor];
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
}

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
    self.tableView.separatorColor = [JGStyles greyDarkColor];
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


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self configureTableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section { return self.settings.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
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
    
    if ([self.settings[indexPath.row] isEqualToString:@"Libraries"]) {
        [self performSegueWithIdentifier:@"showLibraries"
                                  sender:nil];
    }
    
    if ([self.settings[indexPath.row] isEqualToString:@"Logout"]) {
        NSString *title = @"Closing session";
        NSString *message = @"Are you sure you want to close your current session?";
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                         andMessage:message];
        
        [alertView addButtonWithTitle:@"No"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        
        [alertView addButtonWithTitle:@"Yes"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [JGStyles removeUserDefaults];
                                  UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main"
                                                                                  bundle:nil];
                                  
                                  UIViewController* rootController = [main instantiateViewControllerWithIdentifier:@"LoginViewController"];
                                  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                  appDelegate.window.rootViewController = rootController;
                              }];
        
        [alertView show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 100.0f; }

@end
