//
//  MSComment.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-11.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSComment : NSObject

@property (nonatomic) long long objectId;
@property (nonatomic, copy) NSString *commentUser;
@property (nonatomic, copy) NSString *commentText;
@property (nonatomic) long long statusID;

@end
