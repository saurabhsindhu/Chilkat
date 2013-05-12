//
//  MailDBManager.m
//  DzGW
//
//  Created by JD YANG on 11. 12. 6..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailDBManager.h"
#import "MailManager.h"
#import "MailSOUtil.h"
static MailDBManager *sharedManager;

#define MailDBName @"mailDB.db"

#define MailAddrTypeTo   2
#define MailAddrTypeCC   3


@implementation MailDBManager

-(void) closeDB{

//    [sodb2 closeDB];
}

+(MailDBManager*)manager{
    if (sharedManager==nil) {
        sharedManager=[[MailDBManager    alloc] init];
    }
    return sharedManager;
}


/*
 -(void) mailBox:(MailBox*)mailBox updateTotalMailIdx:(int)numOfSavedTotal{
    [sodb2 executeSQL:[NSString stringWithFormat:@"update  mailbox set numOfSavedTotal=%d WHERE rowid=%d ",numOfSavedTotal, mailBox.rowid]];
}
 */

-(int) getUnseenOfMailBox:(MailBox *)mailBox{
    int cnt;
    NSString *qry=[NSString stringWithFormat:@"SELECT count(*) from messages where read=0 and mailboxIdx=%d and deleted=0",mailBox.rowid];
    cnt=[sodb2 selectIntwithQry:qry];
    return cnt;
}

-(void) mailBox:(MailBox*)mailBox setNumOfIgnored:(int)numIgnoredMessage{
    NSString *qry=[NSString stringWithFormat:@"UPDATE mailbox set numOfIgnored=%d where rowid=%d",numIgnoredMessage, mailBox.rowid];
    [sodb2 executeSQL:qry];
}


-(int) getNumOfSavedTotalOfMailBox:(MailBox *)mailBox{
    int cnt;
    NSString *qry=[NSString stringWithFormat:@"SELECT count(*) from messages where mailboxIdx=%d  and deleted=0",mailBox.rowid];
    cnt=[sodb2 selectIntwithQry:qry];
    return cnt;
}

-(void)resetDB{
    NSLog(@"DB Init -------");
        NSString *qry=@"BEGIN TRANSACTION; \
        DROP TABLE IF EXISTS 'address'; \
        CREATE TABLE 'address' ('uid' integer NOT NULL ,'address' text NOT NULL ,'position' integer NOT NULL ,'type' integer,'mailBox' integer,'name' text); \
        DROP TABLE IF EXISTS 'mailbox';\
        CREATE TABLE \"mailbox\" (\"reference\" text NOT NULL ,\"numOfUnSeen\" integer NOT NULL ,\"numOfIgnored\" integer NOT NULL );\
        DROP TABLE IF EXISTS 'messages';\
        CREATE TABLE 'messages' ('uid' integer NOT NULL ,'subject' text NOT NULL ,'dateSent' integer NOT NULL ,'read' BOOL NOT NULL ,'size' integer NOT NULL ,'snippet' text NOT NULL ,'mailboxIDX' INTEGER NOT NULL  DEFAULT (0) ,'numOfAttachment' integer DEFAULT (0) ,'fromAddr' text,'fromName' text, 'deleted' integer DEFAULT(0));\
        DROP TABLE IF EXISTS 'attachment';\
        CREATE TABLE 'attachment' ('mailbox' integer NOT NULL ,'name' TEXT NOT NULL ,'uid' integer, 'size' integer DEFAULT 0, 'confirm' integer DEFAULT 0);\
        COMMIT;";
        [sodb2 executeSQL:qry];
        return;
}

-(void)getSearchResultThread:(NSString*)qry{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        Mail *mail=[[[Mail alloc] init] autorelease];
        mail.subject=[NSString string];
        mail.fromName=[NSString string];
        mail.fromAddr=[NSString string];
        mail.snippet=[NSString string];
        mail.dateSent=[NSNumber numberWithDouble:0];
        searchResult=[[sodb2 selectWithQry:qry entryObject:mail] retain];
    [pool release];
}

-(NSArray*)searchMail:(NSString*)searchString from:(int)mailboxIDX reference:(NSString*)mailBoxReference 
{
    @synchronized(self){
        NSLog(@" Start search ");
        NSString *searchStr=[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *qry=[NSString stringWithFormat: @"select distinct  messages.* from messages inner join address on messages.uid=address.uid and messages.mailboxIDX=address.mailBox and messages.deleted=0 where (fromname like '%%%@%%' or fromAddr like '%%%@%%' or name like '%%%@%%' or address like '%%%@%%' or subject like '%%%@%%' or snippet like '%%%@%%') and mailboxIDX=%d order by uid desc",searchString, searchString, searchString, searchString, searchStr,searchStr,mailboxIDX];
        NSLog(qry,nil);
        
        if (searchResult) {
            [searchResult release];
            searchResult=nil;
        }

        
        [self performSelectorInBackground:@selector(getSearchResultThread:) withObject:qry ];
        for (int i=0; i<10; i++) {
            [NSThread sleepForTimeInterval:0.5];
            if (searchResult!=nil) {
                for (Mail * mail in searchResult) {
                    mail.subject=[mail.subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    mail.snippet=[mail.snippet stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    mail.mailBoxReference=mailBoxReference;
                    mail.mailboxIDX=mailboxIDX;
                }
                NSLog(@" Search End ");
                return searchResult;
            }
        }
        NSLog(@" Failed To retreive ");
        [MailSOUtil alert:@"Unsupported Query"];
        return searchResult;
    }
}


-(MailReceiver *)receiverOfMailRowID:(int)mailID mailBoxID:(int)mailboxIDX{
    NSString *qry=[NSString stringWithFormat:@"SELECT * from address where mailBox=%d and uid=%d order by position asc",mailboxIDX,mailID];
    NSArray *arr=[sodb2 selectWithQry:qry];
    MailReceiver *receiver=[[MailReceiver alloc] init];
    for (NSDictionary *row in arr) {
        if ([[row objectForKey:@"type"] intValue]==MailAddrTypeTo) {
            [receiver.recipientNames addObject:[row objectForKey:@"name"]];
            [receiver.recipientAddresses addObject:[row objectForKey:@"address"]];
        }
        else if ([[row objectForKey:@"type"] intValue] == MailAddrTypeCC){
            [receiver.ccNames addObject:[row objectForKey:@"name"]];
            [receiver.ccAddresses addObject:[row objectForKey:@"address"]];
        }
        else {
            [MailSOUtil errorLog:@"mail addr type error"];
        }
    }
    return [receiver autorelease];
}

-(NSArray*) uidsInMailBox:(int)mailboxIDX{
    assert(0); // no execution here --
    NSString *qry=[NSString stringWithFormat:@"SELECT uid from message where mailboxIDX=%d and deleted=0",mailboxIDX];
    NSArray *arr=[sodb2 selectWithQry:qry  entryObject:[NSNumber numberWithInt:0] isOneColumn:YES];
    return arr;
}


-(void)saveMailBody:(Mail*)mail{
    //mail.snippet 에 escape.
    NSString *escapedSnippet=[mail.snippet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *escapedSnippet=[mail.snippet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    int x=mail.mailboxIDX;
    NSString *wheremailBox=[NSString stringWithFormat:@"mailboxIDX=%d",x];
    NSString *qry=[NSString stringWithFormat:@"UPDATE messages set snippet=\"%@\" where uid=%d and %@",escapedSnippet,mail.uid,wheremailBox];
    [sodb2 executeSQL:qry];
}

- (void) saveMailAttachment:(Mail*)mail{
    NSMutableString *insertQry=[NSMutableString string];
    [insertQry appendFormat:@"BEGIN TRANSACTION; DELETE FROM `attachment` where mailbox=%d and uid=%d;",mail.mailboxIDX,mail.uid];
    for (MailAttachment *attach in mail.attachments) {
        NSString *name = attach.fileName;
        int size=attach.fileSize;
        [insertQry appendFormat:@"INSERT INTO `attachment` (`mailbox`,`uid`,size,name, confirm) VALUES (%d,%d,%d,\"%@\",1);",mail.mailboxIDX,mail.uid,size,name];
    }
    [insertQry appendFormat:@"COMMIT TRANSACTION"];
    [sodb2 executeSQL:insertQry];
}

-(void)saveRead:(Mail*)mail read:(int)read{
    //mail.snippet 에 escape.
    int x=mail.mailboxIDX;
    NSString *wheremailBox=[NSString stringWithFormat:@"mailboxIDX=%d",x];
    NSString *qry=[NSString stringWithFormat:@"UPDATE messages set read=\"%d\" where uid=%d and %@",read,mail.uid,wheremailBox];
    [sodb2 executeSQL:qry];
}

-(void)deleteMailBox:(NSString*)mailBoxReferenceList{
    NSString *qry=[NSString stringWithFormat: @"DELETE from mailbox where reference=\"%@\"",mailBoxReferenceList];
    [sodb2 executeSQL:qry];
}

-(BOOL)deleteMail:(Mail*)mail{
    // delete flag 로 update to new mssg Racing Condition..This May Happen.
    NSLog(@"Mail %@ Delete at DB: rowid - %d, %@",[mail description], mail.rowid, mail.subject);
    NSString *qry=[NSString stringWithFormat: @"UPDATE  messages set deleted=1 where rowid=%d",mail.rowid];
    return [sodb2 executeSQL:qry];
}

-(BOOL)moveMail:(Mail*)mail to:(int)mailboxIDX{
    if (mail.uid==0) {
        errorLogFunc();
    }
    NSString *qry=[NSString stringWithFormat: @"UPDATE messages set mailboxIDX=%d where rowid=%d",mailboxIDX, mail.rowid];
    return [sodb2 executeSQL:qry];
}


/*
-(int) setMailBox:(NSString*)mailBoxReference numOfUnseen:(NSUInteger)numOfUnseen numOfSavedTotal:(NSUInteger)numOfSavedTotal{
    int rowid;
    @try {
        rowid=[sodb2 selectIntwithQry:[NSString stringWithFormat: @"SELECT rowid from mailbox where reference= \"%@\"",mailBoxReference]];
        NSLog(@"Rowid is assigned to mailbox% @ : %d",mailBoxReference,rowid);
        return rowid;
    }
    @catch (NSException *exception) {
        NSLog(@"Mail box because it does not exist in the DB to create a new DB.");
        if ([sodb2 executeSQL:[NSString stringWithFormat:@"INSERT  INTO mailbox (`reference`,`numOfUnSeen`,`numOfSavedTotal`) VALUES ('%@',%d,%d)",mailBoxReference,numOfUnseen,numOfSavedTotal ]]){
            rowid=[sodb2 selectIntwithQry:[NSString stringWithFormat: @"SELECT rowid from mailbox where reference= \"%@\"",mailBoxReference]];
            NSLog(@"Rowid is assigned to mailbox% @ : %d",mailBoxReference,rowid);
            return rowid;
        }
    }
}
 */

-(NSArray*)mailsInMailBox:(int)_mailboxIDX reference:(NSString*)mailBoxReference{
    //get rowid of reference
    NSString *sql=[NSString stringWithFormat:@"SELECT rowid,* from messages where mailboxIDX=%d and deleted=0 order by dateSent desc",_mailboxIDX];
    Mail *mail=[[Mail alloc] init];
    mail.subject=[NSString string];
    mail.fromName=[NSString string];
    mail.fromAddr=[NSString string];
    mail.snippet=[NSString string];
    mail.dateSent=[NSNumber numberWithDouble:0];
    mail.mailBoxReference=mailBoxReference;
    mail.mailboxIDX=_mailboxIDX;
    NSArray *arr=[sodb2 selectWithQry:sql entryObject:mail];
    for (Mail *mail in arr) {
        mail.mailBoxReference=mailBoxReference;
        //escape 를 푼다
        if (mail.snippet!=nil) {
            mail.snippet=[mail.snippet stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (mail.subject!=nil) {
            mail.subject=[mail.subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        NSArray *attachments=[self confirmedAttach:mail];
        mail.attachments=attachments;
    }
    
    NSLog(@"Mail: %@", mail);
    [mail release];
    return [[arr retain] autorelease];
}
/*
-(Mail*) mail:(CkoEmail*)ckoMail inMailBox:(int)mailboxIdx{
        NSString *sql = [NSString stringWithFormat: @"SELECT rowid,* from messages where mailboxIDX=%d and uid = %d",mailboxIdx, [[ckoMail GetImapUid] intValue ]];
        Mail *mail=[[Mail alloc] init];
        mail.subject=[NSString string];
        mail.snippet=[NSString string];
        mail.fromAddr=[NSString string];
        mail.fromName=[NSString string];
        mail.dateSent=[NSNumber numberWithDouble:0];
    mail.mailboxIDX=mailboxIdx;
    
        
        NSArray *mailBoxArray=[sodb2 selectWithQry:sql entryObject:mail isOneColumn:NO];
        [mail release];
        if ([mailBoxArray count]==0) {
            return nil;
        }
        mail=[mailBoxArray objectAtIndex:0];
        mail.subject=[mail.subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        mail.snippet=[mail.snippet stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return mail;
}
*/
-(void)saveCkoMail:(CkoEmail*)mail toMailBox:(int)mailboxIdx mail:(Mail*)convertedMail{
    //find receipient id from recipient, if not exist, save it and get recipient id
        if ([[mail GetImapUid]intValue]==0) {
            int k=1; k++;
        }
#define USE_OPQUEUE_FOR_DBSAVE 0
#if USE_OPQUEUE_FOR_DBSAVE
        [ckoEmailSaveQueue addOperationWithBlock:^(void){
            if (mailboxIdx==0) {
                [NSException raise:@"mailboxIDX" format:nil];
            }
#else
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
//                @synthesize(dispatch_save_checker){
#endif            
                @synchronized(self){

                    BOOL    seen=convertedMail.read;
            int     uid=convertedMail.uid;
                    long    mailDate=[convertedMail.dateSent longValue];
            int     size=0;
            int     numOfAttachment = convertedMail.numOfAttachment;
            
            @try {
                //If the data already there, return immideately.
                NSString *checkQry=[NSString stringWithFormat:@"SELECT rowid from messages where uid=%d and mailboxIdx=%d",uid, mailboxIdx];
                [sodb2 selectIntwithQry:checkQry]; // no exception
                [MailSOUtil errorLog:@"Message Exist even try to save. Thread error"];
                return;
            }
            @catch (NSException *exception) {
                //If the data does not exist
                if (uid==0) {
                    errorLogFunc();
                }
                [sodb2 beginTransaction];

                NSString *escapedSubject=[[mail Subject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *escapedSnippet=[[mail Body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                NSString *insertQry=[NSString stringWithFormat:@"INSERT INTO `messages` (`uid`,`subject`,`dateSent`,`read`,`size`,`snippet`,`mailboxIDX`,`numOfAttachment`,'fromAddr','fromName') VALUES (%d,\"%@\",%ld,%d,%d,\"%@\",%d,%d,\"%@\",\"%@\")",uid, escapedSubject, mailDate,seen, size ,escapedSnippet,mailboxIdx,numOfAttachment,[mail FromAddress],[mail FromName] ];
                BOOL result=[sodb2 executeSQL:insertQry];
                if (result==NO) {
                    [sodb2 rollbackTransaction];
                    return;
                }
                
                if (numOfAttachment) {
                    for (int i=0; i<numOfAttachment; i++){
                        NSString *name = [[MailManager manager] attachmentFileName:mail ofIndex:i];
                        int size = [[MailManager manager] attachmentFileSize:mail ofIndex:i];
                        insertQry = [NSString stringWithFormat:@"INSERT INTO `attachment` (`mailbox`,`uid`,size,name) VALUES (%d,%d,%d,\"%@\")",mailboxIdx,uid,size,name];
                        BOOL result=[sodb2 executeSQL:insertQry];
                        if (result==NO) {
                            [sodb2 rollbackTransaction];
                            return;
                        }
                    }
                }
                
                int numTo=[[mail NumTo] intValue];
                for (int i=0; i<numTo; i++) {
                    insertQry=[NSString stringWithFormat:@"INSERT INTO `address`(`uid`,`name`,`address`,`position`,`type`,`mailBox`) VALUES  (%d, \"%@\" ,\"%@\" , %d, %d, %d ) ",uid,[mail GetToName:[NSNumber numberWithInt:i]], [mail GetToAddr:[NSNumber numberWithInt:i]], 0, MailAddrTypeTo , mailboxIdx];
                    result=[sodb2 executeSQL:insertQry];
                    if (result==NO) {
                        [sodb2 rollbackTransaction];
                        return;
                    }
                }
                
                
                int numOfCC=[[mail NumCC] intValue];
                for (int i=0; i<numOfCC; i++) {
                    insertQry=[NSString stringWithFormat:@"INSERT INTO `address`(`uid`,`name`,`address`,`position`,`type`,`mailBox`) VALUES  (%d, \"%@\" , \"%@\" , %d, %d, %d ) ",uid,[mail GetCcName:[NSNumber numberWithInt:i]], [mail GetCcAddr:[NSNumber numberWithInt:i]], 0, MailAddrTypeCC , mailboxIdx];
                    result=[sodb2 executeSQL:insertQry];
                    if (result==NO) {
                        [sodb2 rollbackTransaction];
                        return;
                    }
                }
                [sodb2 commitTransaction];
                
                NSString *selectQry = [NSString stringWithFormat:@"SELECT rowid from messages where uid=%d and mailboxIDX=%d", uid, mailboxIdx];
                
                convertedMail.rowid = [sodb2 selectIntwithQry:selectQry];
                
                return;
                
            }
            @finally {
            }
#if USE_OPQUEUE_FOR_DBSAVE
        }];
#else
            }               });
#endif
}


-(BOOL) resetMailBox:(NSUInteger)mailboxIDX{
    NSString *delete=[NSString stringWithFormat:@"DELETE from messages WHERE  mailboxIdx=%d" ,mailboxIDX];
    BOOL result=[sodb2 executeSQL:delete];
    if (result) {
        NSString *delete=[NSString stringWithFormat:@"DELETE from attachment WHERE  mailbox=%d" ,mailboxIDX];
        result=[sodb2 executeSQL:delete];
    }
    return result;
}

-(NSArray*)mailBoxReferenceList{
    NSString *sql = @"SELECT distinct reference from mailbox";
    NSString *entryObj=[NSString string];
    NSMutableArray *retArray=[[sodb2 selectWithQry:sql entryObject:entryObj isOneColumn:YES] mutableCopy];
    return [retArray autorelease];
}

-(MailBox*)mailBoxWithReference:(NSString*)reference{
    NSString *sql = [NSString stringWithFormat:@"SELECT rowid,* from mailbox where reference='%@'" ,reference];
    MailBox *mailBox=[[MailBox alloc] init];
    mailBox.reference=[NSString string];
    NSArray *retArray=[sodb2 selectWithQry:sql entryObject:mailBox];
    [mailBox release];
    if (retArray==nil || [retArray count]==0) {
        return nil;
    }
    return [retArray objectAtIndex:0];
}



-(MailBox*)makeNewMailBoxWithReference:(NSString*)reference{
    NSString *qry =[NSString stringWithFormat:@"INSERT  INTO mailbox (`reference`,`numOfUnSeen`,`numOfIgnored`) VALUES ('%@',0,0)",reference];
    
    [MailSOUtil log:[NSString stringWithFormat:@"makeNewMailBox with Qry : %@",qry]];
    
    [sodb2 executeSQL:qry];
    return [self mailBoxWithReference:reference];
}
         

         -(NSArray*)confirmedAttach:(Mail*)mail{
             @synchronized(self){
                 NSString *sql=[NSString stringWithFormat:@"SELECT name from attachment where mailbox=%d and uid=%d and confirm=1",mail.mailboxIDX,mail.uid];
                 NSArray *fileNameArray=[sodb2 selectWithQry:sql entryObject:nil isOneColumn:YES];
                 sql=[NSString stringWithFormat:@"SELECT size from attachment where mailbox=%d and uid=%d and confirm=1",mail.mailboxIDX,mail.uid];
                 NSArray *fileSizeArray=[sodb2 selectWithQry:sql entryObject:nil isOneColumn:YES];
                 NSMutableArray *array=[NSMutableArray array];
                 for (int i=0; i<[fileNameArray count]; i++) {
                     MailAttachment *attach=[[MailAttachment alloc] init];
                     attach.fileName=[fileNameArray objectAtIndex:i];
                     attach.fileSize=[[fileSizeArray objectAtIndex:i] intValue];
                     [array addObject:attach];
                 }
                 return array;
             }
         }

-(NSArray*)attachmentFileNames:(Mail*)mail{
    @synchronized(self){
        NSString *sql=[NSString stringWithFormat:@"SELECT name from attachment where mailbox=%d and uid=%d",mail.mailboxIDX,mail.uid];
        NSArray *retArray=[sodb2 selectWithQry:sql entryObject:nil isOneColumn:YES];
        return retArray;
    }
}
-(NSArray*)attachmentFileSizes:(Mail*)mail{
    @synchronized(self){
        NSString *sql=[NSString stringWithFormat:@"SELECT size from attachment where mailbox=%d and uid=%d",mail.mailboxIDX,mail.uid];
        NSArray *retArray=[sodb2 selectWithQry:sql entryObject:nil isOneColumn:YES];
        return retArray;
    }
}

         


-(id)init{
    self=[super init];

    if (self) {
        sodb2=[[MailSODB2 alloc] initWithDBFileName:@"imap.sqlite" createEditableIfNeeded:YES];
        if (sodb2==nil) {
            return nil;
        }
        ckoEmailSaveQueue=[[NSOperationQueue alloc] init];
        [ckoEmailSaveQueue setMaxConcurrentOperationCount:1];
    }
    return self;
error:
    printf("error in db---");
    return nil;
}
         
         -(void)changeDB{
             if (sodb2!=nil) {
                 [sodb2 release];
             }
             sodb2=[[MailSODB2 alloc] initWithDBFileName:@"imap.sqlite" createEditableIfNeeded:YES];
         }

@end
