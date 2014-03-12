//
//  MSStatusDetailViewController.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSStatusDetailViewController.h"
#import "MSDBManager.h"
#import "MSAddCommentViewController.h"
#import "MSComment.h"
#import "MSStatus.h"


static NSString *CellIdentifier = @"CommentCellIdentifier";

@interface MSStatusDetailViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIButton *rightItemButton;

@property (nonatomic, strong) NSArray *comments;

@end

@implementation MSStatusDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //Custom Navigation Bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //Set Navigation Bar Title
    [self.navigationItem setTitle:@"Status Detail"];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeueLTCom-Cn" size:17.0], NSFontAttributeName, nil]];
    
    //Set Add Status Bar Button Item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addComment:)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=backButton;
    
    
    // Set background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74, 300, 300)];
    [self.view addSubview:_statusImageView];
    
    _statusUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_statusImageView.frame), CGRectGetWidth(self.view.frame), 18)];
    [_statusUserNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_statusUserNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_statusUserNameLabel setTextColor:[UIColor blackColor]];
    [_statusUserNameLabel setText:@"You say:"];
    [self.view addSubview:_statusUserNameLabel];
    
    _statusTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_statusUserNameLabel.frame), CGRectGetWidth(self.view.frame)-25, 60)];
    [_statusTextView setContentInset:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_statusTextView setFont:[UIFont systemFontOfSize:12]];
    [_statusTextView setTextColor:[UIColor blackColor]];
    [_statusTextView setBackgroundColor:[UIColor clearColor]];
    [_statusTextView setTextAlignment:NSTextAlignmentLeft];
    [_statusTextView setEditable:NO];
    [_statusTextView setUserInteractionEnabled:NO];
    [_statusTextView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view addSubview:_statusTextView];
    
    //Set comments table view
    _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(_statusTextView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(_statusTextView.frame)) style:UITableViewStylePlain];
    [_commentsTableView setBackgroundColor:[UIColor whiteColor]];
    [_commentsTableView setDataSource:self];
    [_commentsTableView setDelegate:self];
    [_commentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_commentsTableView setScrollEnabled:YES];
    [_commentsTableView setClipsToBounds:YES];
    [_commentsTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
    [_commentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [self.view addSubview:_commentsTableView];
    
    //UIRefreshControl to add pull table view to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_commentsTableView addSubview:_refreshControl];
    
    _commentsTableView.allowsSelection = YES;
    
    _comments = [[NSArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_statusImageView setImage:([_selectedStatus.statusImageURL length] > 0) ? [UIImage imageWithData:_selectedStatus.statusImageURL] : [UIImage imageNamed:[NSString stringWithFormat:@"NoImage"]]];
    [_statusTextView setText:_selectedStatus.statusText];
    
    [self refresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Comments";
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 30;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MSComment *comment = [_comments objectAtIndex:indexPath.row];
    
    //TODO custom cell
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.textLabel setTextAlignment:NSTextAlignmentJustified];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", comment.commentUser, comment.commentText]];
    
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
        if(![[MSDBManager getSharedInstance] deleteComment:[_comments objectAtIndex:indexPath.row]])
            [[[UIAlertView alloc] initWithTitle:@"Data deleted failed"
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        else
            [self refresh:nil];
    }
}

- (void)refresh:(id)sender
{
    _comments = [[MSDBManager getSharedInstance] fetchAllCommentsForStatusID:_selectedStatus.objectId];
    [_refreshControl endRefreshing];
    [_commentsTableView reloadData];
    
}


- (void)addComment:(id)sender
{
    
    //create profile
    MSAddCommentViewController *addCommentViewController= [[MSAddCommentViewController alloc] init];
    addCommentViewController.status = _selectedStatus;
    
    [self.navigationController pushViewController:addCommentViewController animated:YES];
   
}


@end
