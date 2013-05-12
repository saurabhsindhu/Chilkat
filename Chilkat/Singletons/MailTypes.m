//
//  MailTypes.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailTypes.h"
#import "MailManager.h"
#import "MailDBManager.h"
#import "CkoImap.h"
#import "CkoMessageSet.h"
#import "CkoEmailBundle.h"
#import "CkoEmail.h"
#import "MailSOUtil.h"
#import "MailSODateTimeUtil.h"

@implementation MailReceiver
@synthesize ccNames;
@synthesize ccAddresses;
@synthesize recipientNames;
@synthesize recipientAddresses;

-(id)initWithCkoEmail:(CkoEmail*)email{
    self=[super init];
    if (self) {
        self.ccNames=[NSMutableArray array];
        self.ccAddresses=[NSMutableArray array];
        self.recipientNames=[NSMutableArray array];
        self.recipientAddresses=[NSMutableArray array];
        int numCC=[[email NumCC] intValue];
        for (int i=0; i<numCC; i++) {
            [ccNames addObject:[email GetCC:[NSNumber numberWithInt:i]]];
            [ccAddresses addObject:[email GetCC:[NSNumber numberWithInt:i]]];
        }
        
        int numRecipient=[[email NumTo] intValue];
        for (int i=0; i<numRecipient; i++) {
            [recipientNames addObject:[email GetToName:[NSNumber numberWithInt:i]]];
            [recipientAddresses addObject:[email GetToAddr:[NSNumber numberWithInt:i]]];
        }

    }
    
    return self;
}
-(id)init{
    self=[super init];
    if (self) {
        self.ccNames=[NSMutableArray array];
        self.ccAddresses=[NSMutableArray array];
        self.recipientNames=[NSMutableArray array];
        self.recipientAddresses=[NSMutableArray array];
    }
    return self;
}
-(void)dealloc{
    [ccNames release];
    [ccAddresses release];
    [recipientNames release];
    [recipientAddresses release];
    [super dealloc];
}
@end

@implementation MailAttachment
@synthesize fileName;
@synthesize fileSize;
@end

@implementation Mail
@synthesize uid;
@synthesize isSnippetEmpty;
@synthesize rowid;
@synthesize sender;
@synthesize dateSent;
@synthesize subject;
@synthesize read;
@synthesize mailboxIDX;
@synthesize snippet;
@synthesize numOfAttachment;
@synthesize mailBoxReference;
@synthesize fromAddr;
@synthesize fromName;
@synthesize receiver;
@synthesize _ckoEmail;
@synthesize hasAttachment;
@synthesize size;
@synthesize isPlain;
@synthesize attachments;


- (id)valueForUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"deleted"]) {
        return nil;
    }
    else {
        NSLog(@"--- ERROR : ValueForUndefined For Mail");
        return nil;
    }
}


- (void)setAttachments:(NSArray *)_attachments{
    //MailDB 에 업데이트
    attachments=[_attachments retain];
}

- (void)setRead:(int)_read{
    if (read!=_read) {
        read=_read;
        MailBox *box=[[MailManager manager].mailBoxDic objectForKey:mailBoxReference];
        [box recalNumOfUnseen];
    }
}

- (id)initWithCkoEmail:(CkoEmail*)ckoEmail mailboxIDX:(int)_mailboxIDX mailBoxReference:(NSString*)reference{
    self=[super init];
    if (self) {
        self.uid=[[ckoEmail GetImapUid] intValue];
        self.subject=[ckoEmail Subject];
        self.fromAddr=[ckoEmail FromAddress];

        self.fromName=[ckoEmail FromName];
        self.numOfAttachment=[[MailManager manager] numberOfAttachment:ckoEmail];
        self.mailBoxReference=reference;
        self.mailboxIDX=_mailboxIDX;
        self.dateSent=[NSNumber numberWithDouble: [[ckoEmail EmailDate] timeIntervalSinceReferenceDate]];
        self.receiver=[[[MailReceiver alloc] initWithCkoEmail:ckoEmail] autorelease];
        self.read= [[MailManager manager] getMailSeen:ckoEmail];
        self._ckoEmail=ckoEmail;
        /*
        NSString *txt=[ckoEmail Header];
        NSLog(txt,nil);
        int numHeader=[[ckoEmail NumHeaderFields] intValue];
        for (int i=0; i<numHeader; i++) {
            NSLog([ckoEmail GetHeaderFieldName:[NSNumber numberWithInt:i]],nil);
            NSLog([ckoEmail GetHeaderFieldValue:[NSNumber numberWithInt:i]],nil);
        }
         */
    }
    return self;
}

- (NSUInteger)attatchmentTotalSize{
    NSUInteger ret=0;
    for (MailAttachment *attach in attachments) {
        ret+=attach.fileSize;
    }
    return ret;
}


- (void)updateReadToDB{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[MailDBManager manager] saveRead:self read:read];
    });
}
-(id)init{
    self=[super init];
    if (self) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    Mail *clone = [[Mail allocWithZone:zone] init];
    return clone;
}

-(void)dealloc{
    [_ckoEmail release];
    [fromAddr release];
    [fromName release];
    [dateSent release];
    [subject release];
    [snippet release];
    [super dealloc];
}

-(void)requestUpdateSnippetFromServer{
        //  ppet
    if (mailBoxReference==nil) {
        NSLog(@"ERROR : requestUpdateSnippet NIL !!!!");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (uid == 0) {
            MailBox *mBox = [[[MailManager manager] mailBoxDic] objectForKey:self.mailBoxReference];
            [mBox.mailArray removeObject:self];
            [[MailDBManager manager] deleteMail:self];
            return;
        }
        [[MailManager manager]updateMailBodyAndAttachment:self];
        self.isSnippetEmpty=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[MailDBManager manager] saveMailBody:self];
            [[MailDBManager manager] saveMailAttachment:self];
        });
    });
}



@end

@implementation MailBox
@synthesize reference;
@synthesize numOfUnSeen;
@synthesize isDeleted;
@synthesize numOfIgnored;
@synthesize mailArray;
@synthesize numOfSavedTotal;
@synthesize mailUIDs;
@synthesize allCkoMessageSet;
@synthesize updateCkoMessageSet;
@synthesize lastSyncMailIndex;
@synthesize rowid;
@synthesize syncDate;
@synthesize syncStatus;
@synthesize isLoadMore;

-(NSString*) description{
    NSString *superDescription=[super description];
    return [NSString stringWithFormat:@"%@ ,%@, %d mails",superDescription, reference, [mailArray count]];
}

-(BOOL) hasUID:(NSNumber*)uid{
    for (Mail *mail in mailArray) {
        int uidInt=[uid intValue];
        if (mail.uid==uidInt) {
            return YES;
        }
    }
    return NO;
}

-(int) lastUID{
    int currentUID = 0;
    for (Mail *mail in mailArray) {
        if ( mail.uid > currentUID ){
            currentUID = mail.uid;
        }
    }
    return currentUID;
}


- (void)recalNumOfUnseen{
    int newNumOfUnseen=0;
    for (Mail *mail in mailArray) {
        if (mail.read==NO) {
            newNumOfUnseen++;
        }
    }
    self.numOfUnSeen=newNumOfUnseen;
}

- (BOOL) addMail:(Mail*) mail{
    @synchronized(mailArray){
        
        for (Mail *oldMail in mailArray) {
            if (mail.uid == oldMail.uid) {
                return NO;
            }
        }
         
        int k;
        for (k=0; k<[mailArray count] ; k++) {
            Mail *currentMail=[mailArray objectAtIndex:k];
            long long currentMailDateSent=[[currentMail dateSent] longLongValue];
            long long mailDateSent=[[mail dateSent] longLongValue];
            
            if (currentMailDateSent < mailDateSent){
                break;
            }
        }
        

        [[self mutableArrayValueForKey:@"mailArray"] insertObject:mail atIndex:k];                
        return YES;
    }
}

- (MailBox *)init{
    self=[super init];
    if (self) {
        mailArray=[[NSMutableArray array] retain];
        mailUIDs=[[NSMutableArray array] retain];
    }
    return self;
}

- (int)numOfSavedTotal{
    if (numOfSavedTotalGotten==NO){
        numOfSavedTotal=[[MailDBManager manager] getNumOfSavedTotalOfMailBox:self];
        numOfSavedTotalGotten=YES;
    }
    return numOfSavedTotal;
}

- (void)setNumOfSavedTotal:(int)_numOfSavedTotal{
    numOfSavedTotal=_numOfSavedTotal;
}

- (id)copyWithZone:(NSZone *)zone{
    MailBox *clone = [[MailBox allocWithZone:zone] init];
    return clone;
}

- (NSUInteger)level{
    NSCharacterSet *componentSet=[NSCharacterSet characterSetWithCharactersInString:@"//."];
    NSUInteger _level=[[reference componentsSeparatedByCharactersInSet:componentSet] count];
    return _level;
}

- (void)setReference:(NSString *)_reference  {
        reference=[_reference retain];
}

-(NSString*)name{
    int level=[self level];
    NSCharacterSet *componentSet=[NSCharacterSet characterSetWithCharactersInString:@"//."];
        return [[reference componentsSeparatedByCharactersInSet:componentSet] objectAtIndex:level-1];
}


- (void)dealloc{
    [mailArray release];
    [reference release];
    [inferiors release];
    [super dealloc];
}


@end
