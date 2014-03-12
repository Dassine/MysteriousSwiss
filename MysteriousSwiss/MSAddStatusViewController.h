//
//  MSAddStatusViewController.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSAddStatusViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *statusAddImageButton;
@property (nonatomic, strong) UILabel *statusUserNameLabel;
@property (nonatomic, strong) UITextView *statusTextView;

@end
