//
//  MSAddCommentViewController.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-11.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSAddCommentViewController.h"
#import "MSDBManager.h"
#import "MSComment.h"
#import "MSStatus.h"

@interface MSAddCommentViewController () {
    CGSize keyboardSize;
}

@end

@implementation MSAddCommentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //Custom Navigation Bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //Set Navigation Bar Title
    [self.navigationItem setTitle:@"New Comment"];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeueLTCom-Cn" size:17.0], NSFontAttributeName, nil]];
    
    //Set Add Status Bar Button Item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addComment:)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=backButton;
    
    
    // Set background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _commentUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 74, CGRectGetWidth(self.view.frame), 18)];
    [_commentUserNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_commentUserNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_commentUserNameLabel setTextColor:[UIColor blackColor]];
    [_commentUserNameLabel setText:@"Michael say:"];
    [self.view addSubview:_commentUserNameLabel];
    
    _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_commentUserNameLabel.frame), CGRectGetWidth(self.view.frame)-25, 60)];
    [_commentTextView setContentInset:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_commentTextView setFont:[UIFont systemFontOfSize:12]];
    [_commentTextView setTextColor:[UIColor blackColor]];
    [_commentTextView setBackgroundColor:[UIColor clearColor]];
    [_commentTextView setTextAlignment:NSTextAlignmentLeft];
    [_commentTextView setText:@"Add your comment here"];
    [_commentTextView setEditable:YES];
    [_commentTextView setUserInteractionEnabled:YES];
    [_commentTextView setDelegate:self];
    [_commentTextView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view addSubview:_commentTextView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addComment:(id)sender
{
    //save in DB and dismiss
    
    if (![[MSDBManager getSharedInstance] saveCommentOfStatusID:_status.objectId commentUser:_commentUserNameLabel.text commentText:_commentTextView.text]) {
        [[[UIAlertView alloc]initWithTitle:@"Data Insertion failed"
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) keyboardWillShow:(NSNotification *) notification
{
    
    keyboardSize  = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Add your comment here"]) {
        [textView setText:@""];
    }
}


@end
