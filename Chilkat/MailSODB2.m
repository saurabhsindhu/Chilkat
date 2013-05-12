//
//  MailSODB2.m
//  Nelson
//
//  Created by jdyang on 11. 2. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailSODB2.h"
#import "MailSOUtil.h"

@interface MailSODB2()
-(BOOL)createDBIfNeeded:(NSString*)fileName;
-(BOOL)checkError:(int)resultCode;
@end


@implementation MailSODB2

-(void)closeDB{
    @synchronized(self){
        int r=sqlite3_close(db);
        
        if (r== SQLITE_DONE || r == SQLITE_OK) {
            NSLog(@"DB CLOSE OK");
        }
        else {
            [MailSOUtil errorLog:[NSString stringWithUTF8String:sqlite3_errmsg(db)]];
        }
    }
}

-(BOOL)createDBIfNeeded:(NSString*)fileName{

    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *toFileName=[NSString stringWithFormat:@"%@.sqlite",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyEmail"]];

    NSString *filePath=[documentsDirectory stringByAppendingFormat:[[NSString stringWithFormat:@"/%@",toFileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],nil];

	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL exist=[fileManager fileExistsAtPath:filePath];
	if (exist) {
		[MailSOUtil log:@"createEditable : default db exist"];
		return TRUE;
	}
	[MailSOUtil log:@"createEditable : default db not exist"];

	NSString *resourceDBPath=[[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@",fileName];
	NSError *error;
	BOOL retVal=[fileManager copyItemAtPath:resourceDBPath toPath:filePath error:&error];
	if (retVal!=YES) {
		[MailSOUtil errorLog:@"copyFile" error:error];
		return NO;
	}
	return YES;
}

//open file
-(id)initWithDBFileName:(NSString*)fileName createEditableIfNeeded:(BOOL)editable{
	if ((self=[super init])) {
		NSString *filePath=nil;
		if (editable) {
			if ([self createDBIfNeeded:fileName]==NO) {
				return nil;
			}
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

            NSString *toFileName=[NSString stringWithFormat:@"%@.sqlite",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyEmail"]];

            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            filePath=[documentsDirectory stringByAppendingFormat:[[NSString stringWithFormat:@"/%@",toFileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],nil];	
		}
		else {
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *filePath=[documentsDirectory stringByAppendingFormat:[[NSString stringWithFormat:@"/%@",fileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],nil];	

			if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]!=YES) {
				[MailSOUtil errorLog:@"warning : db not exist at resourcePath. now check bundle path"];
				filePath=[[[MailSOUtil filePathWithName:fileName] retain] autorelease];
				if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]!=YES) {
					[MailSOUtil errorLog:@"db not exist at bundlePath"];
					return nil;
				}
			}
		}
		if (sqlite3_open([filePath UTF8String], &db) != SQLITE_OK){
			[MailSOUtil errorLog:[NSString stringWithUTF8String:sqlite3_errmsg(db)]];
			sqlite3_close(db);
			return nil;
		}
        [MailSOUtil log:[NSString stringWithFormat:@"DB Loaded: %@",filePath]];
	}
	return self;
}

-(BOOL) checkError:(int)resultCode{
	if (resultCode!=SQLITE_ROW && resultCode!=SQLITE_OK && resultCode!= SQLITE_DONE) {
		[MailSOUtil errorLog:[NSString stringWithUTF8String: sqlite3_errmsg(db)]];
		return NO;
	}
	return YES;
}

#define SO_SQLITE_IMAGE 400
#define SO_SQLITE_SKIP  401

-(BOOL)executeSQL:(NSString*)sql{
    char *errmsg;
    @synchronized(self){
        int r=sqlite3_exec(db, [sql UTF8String], NULL, 0, &errmsg);
        
        if (r== SQLITE_DONE || r == SQLITE_OK) {
 //           NSLog(@"[DB]%@ executed OK",sql);
            return YES;
        }
        else {
   //         NSLog(@"[DB]%@ executed Error",sql);
            [MailSOUtil errorLog:[NSString stringWithUTF8String:sqlite3_errmsg(db)]];
            return NO;
        }
    }
}
/*
-(void)insertObjects:(NSArray*)objects toTable:(NSString*)table{
    //detect table column name
    [MailSOUtil log:@"insert obj"];
    @synchronized(self){
        sqlite3_stmt *stmt;
        //get db
        NSString *qry=[NSString stringWithFormat:@"select * from messages limit 1",table];
        int r=sqlite3_prepare_v2(db, [qry UTF8String], -1, &stmt, NULL);
        if (r!=SQLITE_OK) {
            [MailSOUtil errorLog:[NSString stringWithUTF8String:sqlite3_errmsg(db)]];
            return;
        }
        r=sqlite3_step(stmt);
        if ([self checkError:r] == NO){
            return;
        }
        
        int cnt=sqlite3_column_count(stmt);
        
        ///////////////////////////////////
        //detect column name
        NSMutableArray *nameA=[NSMutableArray arrayWithCapacity:cnt];
        for (int i=0; i<cnt; i++) {
            [nameA addObject:[NSString stringWithUTF8String: sqlite3_column_name(stmt, i)]];
        }
        id object=[objects objectAtIndex:0]; // sample object
        int *typeA=(int*)malloc(sizeof(int)*cnt);

        //detect column type
        for (int i=0; i<cnt;i++) {
            NSString *name=[nameA objectAtIndex:i];
            id value=[object valueForKey:name];
            if ([value isKindOfClass:[NSString class]]) {
                typeA[i]=SQLITE_TEXT;
            }
            else if ([value isKindOfClass:[NSData class]]){
                typeA[i]=SQLITE_BLOB;
            }
            else if ([value isKindOfClass:[NSNumber class]]){
                typeA[i]=SQLITE_FLOAT;
            }
            else {
                typeA[i]=SQLITE_INTEGER;
            }
        }
        free(typeA);
    }
}

*/
-(NSArray*)selectWithQry:(NSString*)qry{
	return [self selectWithQry:qry entryObject:nil];
}

-(NSArray*)selectWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj {
	return [self selectWithQry:qry entryObject:anEntryObj isOneColumn:NO];
}

-(NSArray*)selectOneColumnWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj{
	return [self selectWithQry:qry entryObject:anEntryObj isOneColumn:YES];
}

-(NSArray*)selectWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj isOneColumn:(BOOL)oneColumn{
//    NSLog(qry,nil);
    @synchronized(self){
        NSMutableArray *retArray=[NSMutableArray array] ;
        sqlite3_stmt *stmt;
        int r=sqlite3_prepare_v2(db, [qry UTF8String], -1, &stmt, NULL);
        if (r!=SQLITE_OK) {
            [MailSOUtil errorLog:[NSString stringWithUTF8String:sqlite3_errmsg(db)]];
            return nil;
        }
        r=sqlite3_step(stmt);
        if ([self checkError:r] == NO){
            return nil;
        }
        
        int cnt=sqlite3_column_count(stmt);
        
        ///////////////////////////////////
        //detect column type
        int *typeA=(int*)malloc(sizeof(int)*cnt);
        NSMutableArray *nameA=[NSMutableArray arrayWithCapacity:cnt];
        for (int i=0; i<cnt; i++) {
            [nameA addObject:[NSString stringWithUTF8String: sqlite3_column_name(stmt, i)]];
        }
        for (int i=0; i<cnt; i++) {
            if (anEntryObj==nil) {
                typeA[i]=sqlite3_column_type(stmt, i);
            }
            else {
                id member;
                
                if (oneColumn) {
                    member=anEntryObj;
                }
                else {
                    member=[anEntryObj valueForKey:[nameA objectAtIndex:i]];
                }
                
                if ([member isKindOfClass:[NSNumber class]]){
                    typeA[i]=SQLITE_FLOAT;
                }
                else if ([member isKindOfClass:[NSString class]]) {
                    typeA[i]=SQLITE_TEXT;
                }
                else if ([member isKindOfClass:[UIImage class]]) {
                    typeA[i]=SO_SQLITE_IMAGE;
                }
                else if ([member isKindOfClass:[NSData class]]){
                    typeA[i]=SQLITE_BLOB;
                }
                else {
                    //cannot figure : NODATA
                    typeA[i]=SO_SQLITE_SKIP;
                }
            }
            
        }
        //end detect column type
        
        
        int row=0;
        while (r==SQLITE_ROW) {
            row++;
            if (anEntryObj==nil) {
                NSMutableDictionary* rowDic=[[[NSMutableDictionary alloc]init]autorelease];
                for (int i=0; i<cnt; i++) {
                    switch (typeA[i]) {
                        case SO_SQLITE_SKIP:
                            break;
                        case SQLITE_INTEGER:
                            [rowDic setObject:[NSNumber numberWithInt:sqlite3_column_int64(stmt, i)] forKey:[nameA objectAtIndex:i]];
                            break;
                        case SQLITE_FLOAT:
                            [rowDic setObject:[NSNumber numberWithDouble:sqlite3_column_double(stmt, i)] forKey:[nameA objectAtIndex:i]];
                            break;
                        case SQLITE_TEXT:
                        {
                            char *strChar=(char*)sqlite3_column_text(stmt, i);
                            if (strChar!=nil) {
                                NSString *str=[NSString stringWithUTF8String:strChar];
                                if (str!=nil) {
                                    [rowDic setObject:str forKey:[nameA objectAtIndex:i]];
                                }
                                else {
                                    [rowDic setObject:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)] forKey:[nameA objectAtIndex:i]];
                                }
                            }
                            break;
                        }
                        case SQLITE_BLOB:
                            [rowDic setObject:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)] forKey:[nameA objectAtIndex:i]];
                            break;
                        case SO_SQLITE_IMAGE:
                            [rowDic setObject:[UIImage imageWithData:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)]] forKey:[nameA objectAtIndex:i]];
                        case SQLITE_NULL:
                        default:
                            [MailSOUtil errorLog:[NSString stringWithFormat: @"selectWithQry : %@",qry]];
                            [MailSOUtil errorLog:[NSString stringWithFormat:@"error in selectAsArray : type not defined : %@ - %d",[nameA objectAtIndex:i],typeA[i]]];
                            break;
                    }
                }
                if (oneColumn) {
                    [retArray addObject:[rowDic objectForKey:[nameA objectAtIndex:0]]];
                }
                else {
                    [retArray addObject:rowDic];
                }
                r=sqlite3_step(stmt);			
            }
            else {
                if (oneColumn) {
                    switch (typeA[0]) {
                        case SO_SQLITE_SKIP:
                            break;
                        case SQLITE_INTEGER:
                            [retArray addObject:[NSNumber numberWithInt:sqlite3_column_int64(stmt, 0)]];
                            break;
                        case SQLITE_FLOAT:
                            [retArray addObject:[NSNumber numberWithDouble:sqlite3_column_double(stmt, 0)] ];
                            break;
                        case SQLITE_TEXT:
                            [retArray addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 0)]];
                            break;
                        case SQLITE_BLOB:
                            [retArray addObject:[NSData dataWithBytes:sqlite3_column_blob(stmt, 0) length:sqlite3_column_bytes(stmt, 0)] ];
                            break;
                        case SO_SQLITE_IMAGE:
                            [retArray addObject:[UIImage imageWithData:[NSData dataWithBytes:sqlite3_column_blob(stmt, 0) length:sqlite3_column_bytes(stmt, 0)]] ];
                            break;
                        case SQLITE_NULL:
                        default:
                            [MailSOUtil errorLog:[NSString stringWithFormat: @"selectWithQry : %@",qry]];
                            [MailSOUtil errorLog:@"error in selectAsArray : type not defined"];
                            break;						
                    }
                }
                else {
                    id	copiedObj=[anEntryObj copy];
                    [retArray addObject:copiedObj];
                    [copiedObj release];
                    for (int i=0; i<cnt; i++) {
                        switch (typeA[i]) {
                            case SO_SQLITE_SKIP:
                                break;
                            case SQLITE_INTEGER:
                                [copiedObj setValue:[NSNumber numberWithInt:sqlite3_column_int64(stmt, i)] forKey:[nameA objectAtIndex:i]];
                                break;
                            case SQLITE_FLOAT:
                                if ([[nameA objectAtIndex:i] isEqualToString:@"mailboxIDX"]) {
                                    int v=sqlite3_column_int(stmt, i);
                                    [copiedObj setMailboxIDX:v];
                                }
                                else{
                                    [copiedObj setValue:[NSNumber numberWithDouble:sqlite3_column_double(stmt, i)] forKey:[nameA objectAtIndex:i]];
                                }
                                break;
                            case SQLITE_TEXT:{
                                char * text=(char*)sqlite3_column_text(stmt, i);
                                if (text!=NULL) {
                                    [copiedObj setValue:[NSString stringWithUTF8String:text] forKey:[nameA objectAtIndex:i]];
                                }
                            }
                                break;
                            case SQLITE_BLOB:
                                [copiedObj setValue:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)] forKey:[nameA objectAtIndex:i]];
                                break;
                            case SO_SQLITE_IMAGE:
                                [copiedObj setValue:[UIImage imageWithData:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)]] forKey:[nameA objectAtIndex:i]];
                                break;
                            case SQLITE_NULL:
                            default:
                                [MailSOUtil errorLog:[NSString stringWithFormat: @"selectWithQry : %@",qry]];
                                [MailSOUtil errorLog:[NSString stringWithFormat:@"error in selectAsArray : type not defined : %@ - %d",[nameA objectAtIndex:i],typeA[i]]];
                                break;
                        }
                    }
                    
                }
                
                r=sqlite3_step(stmt);
            }
            
        }
        free(typeA);
        /* do nothing
        if ([retArray count]==0) {
            int i=0;
        }
         */
        return retArray;
    }
}


-(int) selectIntwithQry:(NSString*)aQuery{
    @synchronized(self){
        sqlite3_stmt *stmt;
        int r=sqlite3_prepare_v2(db,[aQuery UTF8String], -1, &stmt, nil);
        NSLog(aQuery,nil);
        if (r!=SQLITE_OK) {
            [MailSOUtil errorLog:[NSString stringWithFormat: @"selectWithQry : %@",aQuery]];
            [NSException raise:@"SQLITE3_NOCOLUMN" format:nil];
            return 0;
        }
        int i=sqlite3_step(stmt);
        if (i==SQLITE_ROW) {
            int retVal= sqlite3_column_int(stmt,0);
            sqlite3_finalize(stmt);
            return retVal;
        }
        else {
            [MailSOUtil errorLog:[NSString stringWithFormat: @"selectWithQry : %@",aQuery]];
            [NSException raise:@"SQLITE3_NOCOLUMN" format:nil];
            return 0;
        }
    }
}

-(void)beginTransaction{
    @synchronized(self){
        while (onTransaction) {
            [NSThread sleepForTimeInterval:1];
        }
        onTransaction=YES;
    }
    NSString *execution=@"BEGIN EXCLUSIVE TRANSACTION";
    [self executeSQL:execution];
}

-(void)rollbackTransaction{
    NSString *execution=@"ROLLBACK TRANSACTION";
    [self executeSQL:execution];
    @synchronized(self){
        onTransaction=NO;
    }
}


-(void)commitTransaction{
    NSString *execution=@"COMMIT TRANSACTION";
    [self executeSQL:execution];
    @synchronized(self){
        onTransaction=NO;
    }
}

@end
