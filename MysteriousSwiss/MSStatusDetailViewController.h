//
//  MSStatusDetailViewController.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSStatusDetailViewController : UIViewController


@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *statusUserNameLabel;
@property (nonatomic, strong) UITextView *statusTextView;
@property (nonatomic, strong) UITableView *commentsTableView;

@end
