//
//  MailDBManager.h
//  DzGW
//
//  Created by JD YANG on 11. 12. 6..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MailManager.h"
#import "CkoEmail.h"
#import "MailSODB2.h"


@interface MailDBManager : NSObject{
    BOOL OnTransaction;
    NSArray *searchResult;
    NSOperationQueue *ckoEmailSaveQueue;
    int dispatch_save_checker;
    MailSODB2 *sodb2;
}

+(MailDBManager*)manager;
-(void)changeDB;
-(void)resetDB;
-(void)closeDB;
-(NSArray*)searchMail:(NSString*)searchString from:(int)mailboxIDX reference:(NSString*)mailBoxReference;
-(MailBox*)makeNewMailBoxWithReference:(NSString*)reference;
-(MailBox*)mailBoxWithReference:(NSString*)reference;
-(NSArray*)mailBoxReferenceList;
//-(Mail*) mail:(CkoEmail*)mail inMailBox:(int)mailboxIdx;
-(void)saveRead:(Mail*)mail read:(int)read;
-(MailReceiver *)receiverOfMailRowID:(int)mailID mailBoxID:(int)mailboxIDX;
-(void)saveCkoMail:(CkoEmail*)mail toMailBox:(int)mailboxIdx mail:(Mail*)convertedMail;
-(NSArray*)mailsInMailBox:(int)mailboxIDX reference:(NSString*)mailBoxReference;
-(BOOL) resetMailBox:(NSUInteger)mailboxIDX;
-(NSArray*) uidsInMailBox:(int)mailboxIDX;
-(void)saveMailBody:(Mail*)mail;
-(BOOL)deleteMail:(Mail*)mail;
- (void) saveMailAttachment:(Mail*)mail;
-(BOOL)moveMail:(Mail*)mail to:(int)mailboxIDX;
-(NSArray*)attachmentFileNames:(Mail*)mail;
-(NSArray*)attachmentFileSizes:(Mail*)mail;
//-(void) mailBox:(MailBox*)mailBox updateTotalMailIdx:(int)numOfSavedTotal;
-(int) getUnseenOfMailBox:(MailBox *)mailBox;
-(int) getNumOfSavedTotalOfMailBox:(MailBox *)mailBox;
-(void) mailBox:(MailBox*)mailBox setNumOfIgnored:(int)numIgnoredMessage;
-(NSArray*)confirmedAttach:(Mail*)mail;
-(void)deleteMailBox:(NSString*)mailBoxReferenceList;

//-(int) setMailBox:(NSString*)mailBoxReference numOfUnseen:(NSUInteger)numOfUnseen numOfSavedTotal:(NSUInteger)numOfSavedTotal;

@end