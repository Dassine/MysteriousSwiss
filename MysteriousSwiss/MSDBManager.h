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

@interface MSDBManager : NSObject
{
    NSString *databasePath;
}

+ (MSDBManager*)getSharedInstance;

- (BOOL)createDB;
- (BOOL)saveStatusData:(NSString*)userName
            statusText:(NSString*)text
           statusImage:(NSData*)imageData
     statusNbOfComment:(NSString*)nbOfComments;;
- (NSArray*)findByRegisterNumber:(NSString*)registerNumber;
- (int)getStatusCount;
- (NSMutableArray*)fetchAllStatus;
- (BOOL)deleteStatus:(MSStatus*)status;

@end