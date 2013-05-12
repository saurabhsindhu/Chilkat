//
//  MailManager.h
//  DzGW
//
//  Created by JD YANG on 11. 12. 2..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoImap.h"
#import "CkoMailboxes.h"
#import "MailTypes.h"


@interface MailManager : NSObject <UIDocumentInteractionControllerDelegate> {
    NSMutableDictionary     *mailBoxDic;
    NSMutableArray          *mailBoxArray;
    NSMutableArray          *tempMailBoxArray;
    NSMutableArray          *arrangedMailBoxArray;
    
    BOOL isInboxValid;


    NSMutableArray *mailBoxReferenceList;
    NSMutableArray *deletedMailBoxReferenceListArray;

    NSArray *mailBoxReferenceListInDB;

    CkoImap *imap;
    CkoImap *imap_sub;
    BOOL    logined;
    NSString *idString;
    NSString *password;
    NSString *inboxReference;
    NSString *deletedReference;
    BOOL usingSSL;
    int port;
    BOOL loginThreadStop;

    NSString *lastSelectedMailBox;
    int numOfNetworkThread;
//    NSString *statusLog;
    NSString *mailBoxStatusLog;
    NSMutableSet *reloadMailBoxes;
    
    BOOL downloading;
    BOOL logining;
    BOOL logouted;
    BOOL setupAllFinished;
    BOOL loginAndGetMailBoxListThreadExecuting;
    BOOL mailboxLoaded;
    
    UIViewController *mailRoot;
    NSNumber *observerAssigned;
}
@property (assign) BOOL mailboxLoaded;
@property (assign) UIViewController *mailRoot;
@property (readonly) CkoImap *imap;
@property (nonatomic, readonly) NSString* inboxReference;
@property (nonatomic, readonly) NSString* deletedReference;
//@property (nonatomic) BOOL setupAllFinished;
@property (nonatomic, readonly) NSMutableArray *mailBoxReferenceList;
@property (readonly) BOOL downloading;
@property (readonly) BOOL logouted;
@property (nonatomic, assign) int numOfNetworkThread;
@property (retain) NSMutableArray *mailBoxArray;
@property (retain) NSMutableDictionary *mailBoxDic;
@property (nonatomic, assign) BOOL logined;
//@property (retain) NSString *statusLog;
@property (retain) NSString *mailBoxStatusLog;

+(MailManager*) manager;

//login
+(void) assignNewManager;
-(void)assignMailRoot:(UIViewController*)mailRootVC;
-(void)resignMailRoot;
-(BOOL) login;
-(BOOL)loginWithID:(NSString*)idString password:(NSString*)password port:(NSUInteger)port usingSSL:(BOOL)usingSSL;
-(void) logout;

//mailbox loading
-(void)loadMailboxesFromServer;
-(void)loadMailboxFromServer:(MailBox *)mailBox;
-(void)loadMailboxFromServer:(MailBox *)mailBox CkoMessageSet:(CkoMessageSet*)mSet;
-(void)loadMoreMailFromServer:(MailBox*)mailBox;
-(void)loadMailboxesFromCache;
-(void)updateMailBodyAndAttachment:(Mail*)mail;
-(NSMutableArray*)arrangedMailBoxes;


//mail loading + save
-(BOOL)isMailBoxReloaded:(MailBox *)mailBox;
-(NSArray*)mailsInMailBox:(NSString*)reference mailBoxRowID:(int)rowid searchString:(NSString*)searchStr;
-(void) setReceiverWithMail:(Mail*)mail;

-(CkoEmail*) getCkoEmail:(NSInteger)mailUID mailBox:(NSString*)mailBoxReference;
-(CkoEmailBundle*)fetchBundle:(CkoMessageSet*)messageSet boxReference:(NSString*)reference;

//attachment handling
-(BOOL)downloadAttachment:(Mail*)mail fileName:(NSString*)filename;
-(NSArray*) attachmentFileSizesOfMail:(Mail*)email ;
-(NSArray*) attachmentFileNamesOfMail:(Mail*)email ;
-(int) numberOfAttachment:(CkoEmail*)email;
-(int) attachmentFileSize:(CkoEmail*)email ofIndex:(int)index;
-(NSString*) attachmentFileName:(CkoEmail*)email ofIndex:(int)index;

//log handling
-(void)addNumOfNetworkThreadWithLog:(NSString*)log;
-(void)removeNumOfNetworkThreadWithLog:(NSString*)log;


-(BOOL)getMailSeen:(CkoEmail*)email;
-(BOOL)moveMail:(Mail*)mail toMailBox:(MailBox*)mailBox;
-(BOOL)deleteMail:(Mail*)mail;
@end