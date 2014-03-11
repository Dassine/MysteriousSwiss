//
//  MSStatusCell.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSStatusCell.h"

@implementation MSStatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Init cell component
        
        _statusImage = [[UIImageView alloc] init];
        [_statusImage setFrame:CGRectMake(0, 0, 90, 90)];
        [self.contentView addSubview:_statusImage];
        
        _userLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, CGRectGetWidth(self.frame)-95, 18)];
        [_userLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_userLabel setTextAlignment:NSTextAlignmentLeft];
        [_userLabel setTextColor:[UIColor blackColor]];
        [_userLabel setText:@"You say:"];
        [self.contentView addSubview:_userLabel];
        
        _statusText = [[UITextView alloc] initWithFrame:CGRectMake(95, CGRectGetMaxY(_userLabel.frame), CGRectGetWidth(self.frame)-95, 60)];
        [_statusText setContentInset:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_statusText setFont:[UIFont systemFontOfSize:12]];
        [_statusText setTextColor:[UIColor blackColor]];
        [_statusText setBackgroundColor:[UIColor clearColor]];
        [_statusText setTextAlignment:NSTextAlignmentLeft];
        [_statusText setEditable:NO];
        [_statusText setScrollEnabled:NO];
        [_statusText setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.contentView addSubview:_statusText];
        
        _nbOfCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, CGRectGetMaxY(_statusText.frame), CGRectGetWidth(self.frame)-95, 12)];
        [_nbOfCommentsLabel setFont:[UIFont systemFontOfSize:10]];
        [_nbOfCommentsLabel setTextAlignment:NSTextAlignmentLeft];
        [_nbOfCommentsLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_nbOfCommentsLabel setNumberOfLines:0];
        [_nbOfCommentsLabel setTextColor:[UIColor grayColor]];
        [_nbOfCommentsLabel setText:[NSString stringWithFormat:@"number of comments %i",_nbOfComment]];
        [self.contentView addSubview:_nbOfCommentsLabel];
    }
    return self;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
