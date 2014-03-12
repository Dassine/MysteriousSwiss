//
//  MSDBManager.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSDBManager.h"
#import "MSStatus.h"
#import "MSComment.h"

static MSDBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation MSDBManager

+(MSDBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

-(BOOL)createDB{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[dirPaths[0] stringByAppendingPathComponent: @"status.db"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: databasePath ] == NO)
    {
        if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            char *errMsg;
            NSString *createSQL  = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS statusDetail (id INTEGER PRIMARY KEY, name TEXT, status TEXT,  imageURL  BLOB)"];
            if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errMsg) == SQLITE_OK) {
                
                createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS commentDetail (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, comment TEXT, statusId INT, FOREIGN KEY(statusId) REFERENCES statusDetail(id))"];
                if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errMsg) == SQLITE_OK)
                    
                    return YES;
                else {
                    NSLog(@"Failed to create table");
                    return NO;
                }
            } else {
                NSLog(@"Failed to create table");
                return NO;
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
        else {
            NSLog(@"Failed to open/create database");
            return NO;
        }
    }
    return NO;
}

- (BOOL) saveStatusData:(NSString*)userName
             statusText:(NSString*)text
            statusImage:(NSData*)imageData
{
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO statusDetail (id, name, status, imageURL) VALUES(?, ?, ?, ?)"];
        
        if(sqlite3_prepare_v2(database,[insertSQL UTF8String], -1, &statement, NULL)==SQLITE_OK){

            sqlite3_bind_text(statement,2,[userName UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_text(statement,3,[text UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_blob(statement, 4, [imageData bytes], [imageData length], NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_bind_int64(statement,1, sqlite3_last_insert_rowid(database)); // Set unique ID
                return YES;
            } else {
                NSLog( @"Error while inserting '%s'", sqlite3_errmsg(database));
                return NO;
            }

        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return NO;
}

- (BOOL) saveCommentOfStatusID:(long long)statusID
             commentUser:(NSString*)userName
            commentText:(NSString*)comment
{
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO commentDetail (username, comment, statusId) VALUES(\"%@\", \"%@\", \"%lld\")", userName, comment, statusID];
        
        if(sqlite3_prepare_v2(database,[insertSQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            
            if ( sqlite3_exec(database, [insertSQL UTF8String], NULL, &statement, NULL) == SQLITE_OK)
                return YES;
            else
            {
                NSLog( @"Error while inserting '%s'", sqlite3_errmsg(database));
                return NO;
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return NO;
}



- (NSArray*) findByObjectID:(long long)objectID
{
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT name, status, imageURL from statusDetail WHERE id = %lld",objectID];
    
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *statusUserName = [[NSString alloc] initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:statusUserName];
                NSString *statusText = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:statusText];
                NSString *statusImageURL = [[NSString alloc]initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 3)];
                [resultArray addObject:statusImageURL];
            }
            else{
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database));
                return nil;
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }
    return nil;
}

- (BOOL)deleteStatus:(MSStatus*)status{
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"DELETE FROM statusDetail WHERE id=\"%lld\"",status.objectId];
        
        if (sqlite3_prepare_v2(database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                return YES;
            }
            else{
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database));
                return NO;
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return NO;

}
- (BOOL)deleteComment:(MSComment*)comment {
    
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM commentDetail WHERE id=\"%lld\"",comment.objectId];
        
        if (sqlite3_prepare_v2(database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                return YES;
            }
            else{
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database));
                return NO;
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return NO;

}

- (int)getCommentsCountForStatusID:(long long)statusID
{
    int count = 0;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM  commentDetail WHERE statusId LIKE %lld", statusID];
        
        if( sqlite3_prepare_v2(database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK )
        {
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database));
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return count;
}

-(NSMutableArray*)fetchAllStatus {
    
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM statusDetail"];
        
        if (sqlite3_prepare_v2(database ,[querySQL UTF8String] , -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                MSStatus *loadedStatus = [[MSStatus alloc] init];
                
                loadedStatus.objectId = sqlite3_column_int64(statement, 0);
                
                loadedStatus.statusUserName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                loadedStatus.statusText = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                loadedStatus.statusImageURL =  [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 3) length: sqlite3_column_bytes(statement, 3)];
                
                [statusArray addObject:loadedStatus];
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return statusArray;
}

- (NSMutableArray*)fetchAllCommentsForStatusID:(long long)statusID {
    
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM commentDetail WHERE statusId = \"%lld\"", statusID];
        
        if (sqlite3_prepare_v2(database ,[querySQL UTF8String] , -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                MSComment *loadedComment = [[MSComment alloc] init];
                loadedComment.objectId = sqlite3_column_int64(statement, 0);
                
                loadedComment.commentUser = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                loadedComment.commentText = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                loadedComment.statusID =  sqlite3_column_int64(statement, 3);
                
                [statusArray addObject:loadedComment];
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return statusArray;
}


@end
