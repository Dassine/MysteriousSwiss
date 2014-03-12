//
//  MSAddCommentViewController.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-11.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSStatus;

@interface MSAddCommentViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) MSStatus *status;
@property (nonatomic, strong) UILabel *commentUserNameLabel;
@property (nonatomic, strong) UITextView *commentTextView;

@end
