//
//  MSDBManager.m
//  MysteriousSwiss
//
//  Created by Lilia Dassine BELAID on 2014-03-09.
//  Copyright (c) 2014 Lilia Dassine BELAID. All rights reserved.
//

#import "MSDBManager.h"
#import "MSStatus.h"

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
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"status.db"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS statusDetail (id TEXT PRIMARY KEY, name TEXT, status TEXT,  imageURL  BLOB, nbComments INTEGER)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                return YES;
            else {
                NSLog(@"Failed to create table");
                return NO;
            }
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
      statusNbOfComment:(NSString*)nbOfComments
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO statusDetail (id, name, status, imageURL, nbComments) VALUES(?, ?, ?, ?, ?)"];
        
        if(sqlite3_prepare_v2(database,[insertSQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
           
            
            sqlite3_bind_text(statement,1, [[self getUUID] UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_text(statement,2,[userName UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_text(statement,3,[text UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_blob(statement, 4, [imageData bytes], [imageData length], NULL);
            
            sqlite3_bind_int(statement,5,[nbOfComments integerValue]);
            
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
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


- (NSArray*) findByRegisterNumber:(NSString*)objectID
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT name, status, imageURL, nbComments from statusDetail where id=\"%@\"",objectID];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
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
                NSString *statusNbOfComments = [[NSString alloc]initWithUTF8String:
                                                (const char *) sqlite3_column_text(statement, 4)];
                [resultArray addObject:statusNbOfComments];
                return resultArray;
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
                              @"DELETE FROM statusDetail WHERE id=\"%@\"",status.objectId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
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

- (int)getStatusCount
{
    int count = 0;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = "SELECT COUNT(*) FROM statusDetail";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
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
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database ,query_stmt , -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                MSStatus *loadedStatus = [[MSStatus alloc] init];
                
                loadedStatus.objectId = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                loadedStatus.statusUserName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                loadedStatus.statusText = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                loadedStatus.statusImageURL =  [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 3) length: sqlite3_column_bytes(statement, 3)];
                
                loadedStatus.statusNbOfComments = sqlite3_column_int(statement, 4);
                
                [statusArray addObject:loadedStatus];
            }
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return statusArray;
}
@end
