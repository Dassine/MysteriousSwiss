//
//  MSDBManager.h
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class MSStatus;
@class MSComment;

@interface MSDBManager : NSObject
{
    NSString *databasePath;
}

+ (MSDBManager*)getSharedInstance;

- (BOOL)createDB;
- (BOOL)saveStatusData:(NSString*)userName
            statusText:(NSString*)text
           statusImage:(NSData*)imageData;
- (NSMutableArray*)fetchAllStatus;
- (BOOL)deleteStatus:(MSStatus*)status;

- (BOOL) saveCommentOfStatusID:(long long)statusID
                   commentUser:(NSString*)userName
                   commentText:(NSString*)comment;
- (NSMutableArray*)fetchAllCommentsForStatusID:(long long)statusID;
- (BOOL)deleteComment:(MSComment*)comment;


- (NSArray*)findByObjectID:(long long)objectID;
- (int)getCommentsCountForStatusID:(long long)statusID;


@end