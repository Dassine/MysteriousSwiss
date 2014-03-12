//
//  MSStatusCell.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSStatusCell : UITableViewCell

@property (nonatomic, strong) UIImageView *statusImage;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UITextView *statusText;

@property (nonatomic, strong) UILabel *nbOfCommentsLabel;

@end
