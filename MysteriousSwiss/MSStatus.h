//
//  MSStatus.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSStatus : NSObject

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *statusUserName;
@property (nonatomic, copy) NSData *statusImageURL;
@property (nonatomic, copy) NSString *statusText;
@property (nonatomic) NSInteger statusNbOfComments;

@end
