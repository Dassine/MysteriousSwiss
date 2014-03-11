//
//  MSWallViewController.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSWallViewController.h"
#import "MSDBManager.h"
#import "MSStatusCell.h"
#import "MSAddStatusViewController.h"
#import "MSStatus.h"


static NSString *CellIdentifier = @"StatusCellIdentifier";

@interface MSWallViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIButton *rightItemButton;

@property (nonatomic, strong) NSArray *status;

@end

@implementation MSWallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //set navigation bar background color, title view and right bar button item
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeueLTCom-Cn" size:17.0], NSFontAttributeName, nil]];
    
    //right bar button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStatus:)];
    
    
    //Set table view
    _statusTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    [_statusTableView setBackgroundColor:[UIColor whiteColor]];
    [_statusTableView setDataSource:self];
    [_statusTableView setDelegate:self];
    [_statusTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_statusTableView setScrollEnabled:YES];
    [_statusTableView setClipsToBounds:YES];
    
    [_statusTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
    
    [self.view addSubview:_statusTableView];
    
    //UIRefreshControl to add pull table view to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_statusTableView addSubview:_refreshControl];
    
    _statusTableView.allowsSelection = YES;
    
    _status = [[NSArray alloc] init];
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set Navigation Bar Title
    [[self.navigationController.navigationBar topItem] setTitle:@"Swiss Wall"];
    [self.navigationItem setTitle:@"Swiss Wall"];
    
    
    [self refresh:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_status count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MSStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[MSStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MSStatus *status = [_status objectAtIndex:indexPath.row];
    
    // Set Image Status
    [cell.statusImage setImage:[UIImage imageWithData:status.statusImageURL]];
    
    // Set Text Status
    [cell.statusText setText:status.statusText];
    
    // Set number of comments
    [cell setNbOfComment:status.statusNbOfComments];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [[MSDBManager getSharedInstance] fetchAllStatus];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //TODO Delete swiped status
        if(![[MSDBManager getSharedInstance] deleteStatus:[_status objectAtIndex:indexPath.row]])
            [[[UIAlertView alloc] initWithTitle:@"Data deleted failed"
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        else
            [self refresh:nil];
    }
}

- (void)addStatus:(id)sender
{
    //create profile
    MSAddStatusViewController *addStatusViewController= [[MSAddStatusViewController alloc] init];
    
    [self.navigationController pushViewController:addStatusViewController animated:YES];
}


- (void)refresh:(id)sender
{
    _status = [[MSDBManager getSharedInstance] fetchAllStatus];
    [_refreshControl endRefreshing];
    [_statusTableView reloadData];
    
}


@end
