//
//  MailSODB2.h
//  Nelson
//
//  Created by jdyang on 11. 2. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MailSODictArray.h"

/*
 Important: This is not Thread-Safe Class!!!!!
 */
/*!
    @class MailSODB2
    @abstract    sqlite3 DB와 연결
    @discussion  
*/

@interface MailSODB2 : NSObject {
	@private
	sqlite3* db;
    BOOL onTransaction;
}

//open file
-(id)initWithDBFileName:(NSString*)fileName createEditableIfNeeded:(BOOL)editable;

//insert
//-(void)insertObjects:(NSArray*)objects toTable:(NSString*)table;

/*!
    @method     selectWithQry
    @abstract   qry를 실행시킨 후 NSArray로 리턴함
    @discussion 각 column는 NSDictionary 상태로 저장됨.
*/
-(NSArray*)selectWithQry:(NSString*)qry;

/*!
    @method     selectWithQry
    @abstract   qry를 실행시킨 후 NSArray로 리턴함, 각 row는 anEntryObj의 class로 저장됨.
    @discussion db에서 저장될 anEntryObj의 각 member들은 미리 initialized된 상태여야 함
*/
-(NSArray*)selectWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj;

-(NSArray*)selectOneColumnWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj;

-(NSArray*)selectWithQry:(NSString*)qry entryObject:(NSObject *)anEntryObj isOneColumn:(BOOL)oneColumn;

-(int) selectIntwithQry:(NSString*)aQuery;

-(BOOL)executeSQL:(NSString*)sql;

-(void)beginTransaction;

-(void)commitTransaction;

-(void)rollbackTransaction;

-(void)closeDB;
@end