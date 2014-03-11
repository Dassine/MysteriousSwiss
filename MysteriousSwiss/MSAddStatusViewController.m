//
//  MSAddStatusViewController.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSAddStatusViewController.h"
#import "MSDBManager.h"

@interface MSAddStatusViewController () {
    CGSize keyboardSize;
    UIImage *selectedImage;
}

@end

@implementation MSAddStatusViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //Custom Navigation Bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //Set Navigation Bar Title
    [self.navigationItem setTitle:@"New Status"];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeueLTCom-Cn" size:17.0], NSFontAttributeName, nil]];
    
    //Set Add Status Bar Button Item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addStatus:)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=backButton;

    
    // Set background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _statusAddImageButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 74, 300, 300)];
    [_statusAddImageButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"AddImage"]] forState:UIControlStateNormal];
    [_statusAddImageButton addTarget:self action:@selector(addStatusImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_statusAddImageButton];
    
    _statusUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_statusAddImageButton.frame), CGRectGetWidth(self.view.frame), 18)];
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
    [_statusTextView setText:@"Add your status here"];
//    [_statusTextView.layer setBorderWidth:1.0f];
//    [_statusTextView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_statusTextView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_statusTextView setDelegate:self];
    [self.view addSubview:_statusTextView];
    
   
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

- (void)addStatus:(id)sender
{
    //save in DB and dismiss

    if (![[MSDBManager getSharedInstance] saveStatusData:_statusUserNameLabel.text statusText:_statusTextView.text statusImage:UIImagePNGRepresentation(selectedImage) statusNbOfComment:@"0"]) {
        [[[UIAlertView alloc]initWithTitle:@"Data Insertion failed"
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addStatusImage:(id)sender
{
    // add image from galery or take picture
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
    @"take picture",
    @"Add from Gallery",
    nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


- (void) keyboardWillShow:(NSNotification *) notification
{
    
   keyboardSize  = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Add your status here"]) {
        [textView setText:@""];
    }
    CGRect newFrame = self.view.frame;
    newFrame.origin.y -= keyboardSize.height;
    self.view.frame = newFrame;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    //Set initial position of _labelCharsRemaing
    
    CGRect newFrame = self.view.frame;
    newFrame.origin.y += keyboardSize.height;
    self.view.frame = newFrame;
}


#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{}];
        }
            break;
        case 1:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:^{}];
        }
        default:
            break;
    }
}

#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Picking Image from Camera/ Library
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Adjusting Image Orientation
    NSData *data = UIImagePNGRepresentation(selectedImage);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:selectedImage.scale
                                   orientation:selectedImage.imageOrientation];
    selectedImage = fixed;
    
    [_statusAddImageButton setImage:selectedImage forState:UIControlStateNormal];
}


@end
