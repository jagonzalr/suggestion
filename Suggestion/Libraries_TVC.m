//
//  Libraries_TVC.m
//  Suggestion
//
//  Created by José Antonio González on 20/05/16.
//  Copyright © 2016 Jose Antonio Gonzalez. All rights reserved.
//

// Classes
#import "Libraries_TVC.h"
#import <SafariServices/SafariServices.h>

// Helpers
#import "JGStyles.h"

// Constants
static NSString *CellIdentifier = @"libraryCell";

@interface Libraries_TVC () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *libraries;

@end

@implementation Libraries_TVC

#pragma mark - Initialize Variables

- (NSMutableArray *)libraries
{
    if (!_libraries) {
        _libraries = [NSMutableArray arrayWithObjects:@[@"ChameleonFramework",
                                                        @"https://github.com/ViccAlexander/Chameleon"],
                                                      @[@"SIAlertView",
                                                        @"https://github.com/Sumi-Interactive/SIAlertView"],
                                                      @[@"SVProgressHUD",
                                                        @"https://github.com/SVProgressHUD/SVProgressHUD"], nil];
    }
    
    return _libraries;
}


#pragma mark - Initial Configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeUI];
}


#pragma mark - Functions

- (void)configureCell:(UITableViewCell *)cell
            IndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = self.libraries[indexPath.row][0];
    cell.textLabel.textColor = [JGStyles textColor];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    cellBackgroundView.backgroundColor = [JGStyles greyDarkColor];
    cell.selectedBackgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
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
    
    self.title = @"Libraries".uppercaseString;
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section { return self.libraries.count; }

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
    
    NSURL *url = [NSURL URLWithString:self.libraries[indexPath.row][1]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:url];
    svc.delegate = self;
    [self presentViewController:svc
                       animated:YES
                     completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 100.0f; }

@end
