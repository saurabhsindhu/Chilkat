//
//  MailTypes.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoImap.h"

@interface MailReceiver:NSObject {
    NSMutableArray *ccNames;
    NSMutableArray *ccAddresses;
    NSMutableArray *recipientNames;
    NSMutableArray *recipientAddresses;
}
@property (retain) NSMutableArray *ccNames;
@property (retain) NSMutableArray *ccAddresses;
@property (retain) NSMutableArray *recipientNames;
@property (retain) NSMutableArray *recipientAddresses;
@end

@interface MailAttachment : NSObject{
    NSString *fileName;
    NSInteger fileSize;
}
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, assign) NSInteger fileSize;
@end

@interface Mail : NSObject{
    int     rowid;
    int uid;
   
    int sender;
    NSString *fromAddr;
    NSString *fromName;
    
    NSString *subject;
    NSNumber * dateSent;
    int read;
    NSString *snippet;
    int mailboxIDX;
    
    int numOfAttachment;
    MailReceiver *receiver;
    BOOL isSnippetEmpty;
    BOOL hasAttachment;
    CkoEmail *_ckoEmail;
    BOOL isPlain;
    int size; //legacy code. do not use.
    
    NSArray *attachments;
}
- (id)initWithCkoEmail:(CkoEmail*)ckoEmail mailboxIDX:(int)mailboxIDX mailBoxReference:(NSString*)reference;
- (void)requestUpdateSnippetFromServer;
- (void)updateReadToDB;
- (NSUInteger)attatchmentTotalSize;

@property (assign) int size;
@property (retain, nonatomic) MailReceiver *receiver;
@property (copy, nonatomic) NSString* fromAddr;
@property (copy, nonatomic) NSString* fromName;
@property (retain, nonatomic) NSArray* attachments;
@property (assign, nonatomic) BOOL isSnippetEmpty;
@property (assign, nonatomic) int     rowid;
@property (assign, nonatomic) int uid;
@property (assign, nonatomic) int sender;
@property (assign, nonatomic) BOOL hasAttachment;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSNumber * dateSent;
@property (assign, nonatomic) int read;
@property (copy, nonatomic) NSString *snippet;
@property (assign, nonatomic) int mailboxIDX;
@property (assign, nonatomic) int numOfAttachment;
@property (retain, nonatomic) NSString *mailBoxReference;
@property (retain, nonatomic) CkoEmail *_ckoEmail;
@property (assign, nonatomic) BOOL isPlain;

@end

typedef enum _MailSyncStatus{
    MailSyncStatusReady,
    MailSyncStatusSync,
    MailSyncStatusEnd,
    
}MailSyncStatus;

@interface MailBox : NSObject <NSCopying>{
    BOOL            isLoadMore;
    NSString       *reference;
    NSMutableArray *inferiors;
    NSMutableArray *mailUIDs;
    NSMutableArray *mailArray;
    
    CkoMessageSet *allCkoMessageSet;
    CkoMessageSet *updateCkoMessageSet;
    
    int numOfUnSeen;
    int numOfIgnored;
    int rowid;
    BOOL isDeleted;
    int lastSyncMailIndex;
    int numOfSavedTotal;
    BOOL numOfSavedTotalGotten;
    
    NSDate *syncDate; // 프로그램 내에서 싱크가 된 시간 기록
    MailSyncStatus syncStatus; 
}
- (BOOL) addMail:(Mail*) mail;
- (void)recalNumOfUnseen;
- (int) lastUID;
@property (nonatomic, assign) BOOL isLoadMore;
@property (retain) NSDate *syncDate;
@property (nonatomic, retain) NSString *reference;
@property (assign) int lastSyncMailIndex;
@property (assign) BOOL isDeleted;
@property (assign) int numOfUnSeen;
@property (assign) int rowid;
@property (assign) int numOfSavedTotal;
@property (assign) int numOfIgnored;
@property (retain) NSMutableArray *mailArray;
@property (retain) NSMutableArray *mailUIDs;
@property (retain) CkoMessageSet   *allCkoMessageSet;
@property (retain) CkoMessageSet   *updateCkoMessageSet;
@property (assign) MailSyncStatus syncStatus;
-(NSUInteger)level;
-(BOOL) hasUID:(NSNumber*)uid;
-(NSString*)name;

@end