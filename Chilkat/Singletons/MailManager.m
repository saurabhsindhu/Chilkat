//
//  MailManager.m
//  DzGW
//
//  Created by JD YANG on 11. 12. 2..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//
#ifndef UNLOCKKEY
#define UNLOCKKEY @"JOODONIMAPMAILQ_rNZneBNT3J4w"
#endif

#import "MailManager.h"
#import "CkoImap.h"
#import "CkoMessageSet.h"
#import "MailDBManager.h"
#import "MailSOUtil.h"
#import "MailSODateTimeUtil.h"
#import "CkoEmailBundle.h"
#import "MailConfig.h"
#import "TKAlertCenter.h"


static MailManager *sharedMailManager;

@interface  MailManager()
-(CkoMailboxes*)ckoMailBoxOfReference:(NSString*)reference;
-(void)noopThread;
-(BOOL)selectMailBox:(NSString*)mailBoxReference;
@end


@implementation MailManager
////@synthesize setupAllFinished;
@synthesize mailRoot;
@synthesize imap;
@synthesize mailBoxReferenceList;
@synthesize logined;
@synthesize mailBoxArray;
@synthesize inboxReference;
@synthesize deletedReference;
@synthesize mailBoxDic;
@synthesize numOfNetworkThread;
//@synthesize statusLog;
@synthesize mailBoxStatusLog;
@synthesize logouted;
@synthesize downloading;
@synthesize mailboxLoaded;

NSCountedSet *mailThreadWorkingFunctionSet;

-(id)init{
    self=[super init];
    if (self) {
        mailBoxArray = [[NSMutableArray array] retain];
        mailBoxDic =[[NSMutableDictionary dictionary] retain];
        mailThreadWorkingFunctionSet=[[NSCountedSet set] retain];
        mailBoxReferenceList = [[NSMutableArray array] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNSApplicationWillBecomeActiveNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNSApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
//        isInboxValid=1;
        inboxReference=[[[NSUserDefaults standardUserDefaults] objectForKey:@"MailInboxName"] retain];
        deletedReference=[[[NSUserDefaults standardUserDefaults] objectForKey:@"MailDeletedBoxName"] retain];
        reloadMailBoxes=[[NSMutableArray array] retain];
    }
    return self;
}

+(void)assignNewManager{
    UIViewController *root=sharedMailManager.mailRoot;
    [sharedMailManager resignMailRoot]; 
    sharedMailManager = [[MailManager alloc] init];
    [sharedMailManager assignMailRoot:root];
    NSLog(@"Assign New Manager : %@",[sharedMailManager description]);
}

-(CkoEmail*) getCkoEmail:(NSInteger)mailUID mailBox:(NSString*)mailBoxReference{
    @synchronized(self){
        [self selectMailBox:mailBoxReference];
        CkoEmail *email=[imap FetchSingle: [NSNumber numberWithInt: mailUID] bUid: YES];
        return email;
    }
}


-(BOOL)login{
    NSString *imapid=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyEmail"];
    NSString *imapPassword=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyPassword"];
    port=[[[NSUserDefaults standardUserDefaults] objectForKey:@"MailPort"] intValue];
    usingSSL=NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ImapIsSSL"] isEqualToString:@"1"]) {
        usingSSL=YES;
    }
    return [[MailManager manager] loginWithID:imapid password:imapPassword port:port usingSSL:usingSSL];
}

-(BOOL) selectMailBox:(NSString*)mailBoxReference{
    @synchronized(self){

    if ([imap IsConnected] == YES && imap.IsLoggedIn == YES && [[imap SelectedMailbox] isEqualToString:mailBoxReference]) {
        return YES;
    }
        BOOL success;
        
        if (mailBoxReference==nil) {
            success=[imap SelectMailbox:lastSelectedMailBox];
        }
        else{
            if (lastSelectedMailBox) {
                [lastSelectedMailBox release];
            }
            lastSelectedMailBox=[mailBoxReference retain];
            success=[imap SelectMailbox:mailBoxReference];
        }
        
        if (success){
            return YES;
        }
        else{
            NSLog(@"SELECT failed mailbox!!");
            NSLog([imap LastErrorText],nil);
            success=[imap Login:idString password:password];
            if (success!=YES) {
//                [imap release];
                imap = [[CkoImap alloc] init]; // do not release it.
//                success = [imap UnlockComponent:UNLOCKKEY];
                imap.Ssl = usingSSL;
                imap.Port = [NSNumber numberWithInt:port];
                
                //  Connect to an IMAP server.
                if (imap.IsConnected==NO) {
                    {
                        NSLog(@"Not connected mailbox!!");
                        NSString *server=[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSvr"];
                        if (server==nil || [server isEqualToString:@"imap.gmail.com"]) {
                            server=@"imap.gmail.com";
                            imap.Ssl=YES;
                        }
                        success = [imap Connect: server];
                        if (success != YES) {
                            NSLog(@"[IMAP] Login Failed");
                            logined=NO;
                            logining=NO;
                            return NO;
                        }
                    }
                }
                NSLog(@"IMAP LOGIN: %@ / %@ ",idString,password);
                NSLog(@"          : SSL %d / Port %d ",usingSSL,port);
                
                success = [imap Login:idString password:password];
            }
            if (success!=YES) {
                return NO;
            }
            success=[imap SelectMailbox:mailBoxReference];
            return success;
        }
    }
}


-(NSArray*)mailBoxesUnderMailBoxReference:(NSString*)reference{
    NSMutableArray *retArray=[NSMutableArray array];
    NSCharacterSet *componentSet=[NSCharacterSet characterSetWithCharactersInString:@".//"];
    
    int level=[[reference componentsSeparatedByCharactersInSet:componentSet] count];
    int refLength=[reference length];
    for (MailBox *box in tempMailBoxArray) {
        if ([box.reference length]<=refLength) {
            continue;
        }
        if ([[box.reference substringToIndex:refLength] isEqualToString:reference]) {
            int newLevel=[[box.reference componentsSeparatedByCharactersInSet:componentSet] count];
            if (newLevel==level+1) {
                [retArray addObject:box];
                [retArray addObjectsFromArray:[self mailBoxesUnderMailBoxReference:box.reference]];
            }
        }
    }
    return retArray;
}

-(void)logout{
    logouted=YES;
    [mailBoxArray removeAllObjects];
    [mailBoxDic removeAllObjects];
    [mailThreadWorkingFunctionSet removeAllObjects];

    NSLog(@"\n------LOGOUT HERE---------");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){

        @synchronized(self){
            if (imap.IsLoggedIn) {
                [imap Logout];
            }
            logined=NO;
            logining=NO;
        }
    }
                   );
    [[MailDBManager manager] closeDB];
}

-(void)moveMailBox:(NSMutableArray*)teampMailBoxArray retArray:(NSMutableArray*)retArray ref:(NSString*)mailBoxReference withDelete:(BOOL)delete{
    if ([mailBoxDic objectForKey:mailBoxReference]!=nil) {
        if ([mailBoxDic objectForKey:mailBoxReference]==nil) {
            return;
        }
        
        [retArray addObject:[mailBoxDic objectForKey:mailBoxReference]];
        NSArray *addArray=[self mailBoxesUnderMailBoxReference:mailBoxReference];
        [retArray addObjectsFromArray:addArray];
        
        if (delete) {
            [tempMailBoxArray removeObject:[mailBoxDic objectForKey:mailBoxReference]];
            for (id object in addArray) {
                [tempMailBoxArray removeObject:object];
            }
        }
    }

}
//For speed, but the original synchronized.
-(NSMutableArray*)arrangedMailBoxes{
    /*
    if (isInboxValid==NO) {
        return mailBoxArray;
    }
    */
    if (tempMailBoxArray) [tempMailBoxArray release];
    tempMailBoxArray=[[NSMutableArray array] retain];
    [tempMailBoxArray addObjectsFromArray:mailBoxArray];
    
    //If the deleted mailbox, and gives it out in the Arrange.
    for (int i=0; i<deletedMailBoxReferenceListArray.count; i++) {
        NSString *deletedBoxReference=[deletedMailBoxReferenceListArray objectAtIndex:i];
        for (int i=0; i<[tempMailBoxArray count]; i++) {
            MailBox *box = [tempMailBoxArray objectAtIndex:i];
            if ([box.reference isEqualToString:deletedBoxReference]) {
                [tempMailBoxArray removeObjectAtIndex:i];
                break;
            }
        }
    }

    
    NSMutableArray *retArray=[[NSMutableArray array] retain];
    
    
    if (inboxReference != nil) {
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:inboxReference withDelete:YES];
    }
    else {
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:@"Inbox"  withDelete:YES];
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:@"Inbox"  withDelete:YES];
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:@"INBOX"  withDelete:YES];
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:@"Inbox"  withDelete:YES];
    }
    [self moveMailBox:tempMailBoxArray retArray:retArray ref:Mail__DraftMessageBoxName__  withDelete:YES];
    [self moveMailBox:tempMailBoxArray retArray:retArray ref:Mail__SentMessageBoxName__  withDelete:YES];
    [self moveMailBox:tempMailBoxArray retArray:retArray ref:Mail__SpamMessageBoxName__  withDelete:YES];
    [self moveMailBox:tempMailBoxArray retArray:retArray ref:Mail__DeletedMessagesBoxName__  withDelete:YES];
    
    for (MailBox* object in tempMailBoxArray) {
        if (object.level == 1) {
            [self moveMailBox:tempMailBoxArray retArray:retArray ref:object.reference  withDelete:NO];
        }
    }
    for (MailBox* object in retArray) {
        int cnt = [tempMailBoxArray count];
        for (int i=0; i<cnt; i++) {
            MailBox *tempObj=[tempMailBoxArray objectAtIndex:i];
            if (tempObj == object) {
                [tempMailBoxArray removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    for (MailBox* object in tempMailBoxArray) {
        [self moveMailBox:tempMailBoxArray retArray:retArray ref:object.reference  withDelete:NO];
    }
    

    NSLog(@"-------Clean Mail------");
    for (MailBox *object in retArray){
        NSLog(@"|    %@",object.reference);
    }
    NSLog(@"------------------------");

    
    return retArray;
}


-(BOOL)getMailSeen:(CkoEmail*)email{
    @synchronized(imap_sub){
        return [[imap_sub GetMailFlag:email flagName:@"Seen"] boolValue];
    }
}

-(CkoEmailBundle*)fetchBundle:(CkoMessageSet*)messageSet boxReference:(NSString*)reference{
    @synchronized(self){
        [self addNumOfNetworkThreadWithLog:@"Get Mssg Header"];
        [self selectMailBox:reference];
        CkoEmailBundle *ret= [imap FetchHeaders:messageSet];
        [self removeNumOfNetworkThreadWithLog:@"Get Mssg Header"];
        return ret;
    }
}

-(int) numberOfAttachment:(CkoEmail*)email{
    @synchronized(imap_sub){
        return [[imap_sub GetMailNumAttach:email] intValue];
    }
}

-(NSString*) attachmentFileName:(CkoEmail*)email ofIndex:(int)index{
    @synchronized(imap_sub){
        return [imap_sub GetMailAttachFilename:email attachIndex:[NSNumber numberWithInt:index]];
    }
}


-(int) attachmentFileSize:(CkoEmail*)email ofIndex:(int)index{
    @synchronized(imap_sub){
        return [[imap_sub GetMailAttachSize:email attachIndex:[NSNumber numberWithInt:index]] intValue];
    }
}



-(NSArray*) attachmentFileNamesOfMail:(Mail*)email {
    if (email._ckoEmail) {
        //DB because the state has not been saved yet
        NSMutableArray *retArrray=[NSMutableArray array];
        for (int i=0; i<email.numOfAttachment; i++) {
            [retArrray addObject:[self attachmentFileName:email._ckoEmail ofIndex:i]];
        }
        return retArrray;
    }
    
    return [[MailDBManager manager] attachmentFileNames:email];
}

-(NSArray*) attachmentFileSizesOfMail:(Mail*)email {
    if (email._ckoEmail) {
        //DB because the state has not been saved yet
        NSMutableArray *retArrray=[NSMutableArray array];
        for (int i=0; i<email.numOfAttachment; i++) {
            [retArrray addObject:[NSNumber numberWithInt: [self attachmentFileSize:email._ckoEmail ofIndex:i]]];
        }
        return retArrray;
    }
    return [[MailDBManager manager] attachmentFileSizes:email];
}

-(void)updateMailBodyAndAttachment:(Mail*)mail{
    //get ckomail
    if (logining ) {
        while (1) {
            [NSThread sleepForTimeInterval:0.5];
            if (logining == NO) {
                break;
            }
        }
    }
    @synchronized(self){
        if (logouted) {
            return;
        }
        
        [self addNumOfNetworkThreadWithLog:@"Receive an Email mssg of"];
        //update mail
        BOOL success;
        //select mailbox
        [imap ClearSessionLog];
        NSLog(@"SELECT MAIL BOX : %@",mail.mailBoxReference);
        success=[self selectMailBox:mail.mailBoxReference];

        if (success!=YES) {
#if DEBUG
            [MailSOUtil alert:imap.LastErrorText];
#else
            [MailSOUtil alert:@"Unknown Error"];
#endif
            return;
        }
        mail._ckoEmail = [imap FetchSingle: [NSNumber numberWithInt: mail.uid] bUid: YES];
        if ([mail._ckoEmail HasHtmlBody]) {
            mail.snippet=mail._ckoEmail.Body;
        }
        else{
            NSString *changedBody=[mail._ckoEmail.Body stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>"];
            mail.snippet=[NSString stringWithFormat:@"%@%@%@",MAIL__PlainToHtmlPre,changedBody,MAIL__PlainToHtmlPost];
        }
        //NSLog([imap SessionLog],nil);
        [self removeNumOfNetworkThreadWithLog:@"Receive an e-mail message of"];

        //And re-test the mail Attachment
        if (mail._ckoEmail == NULL) {
            return;
        }
        int numAttach=[[imap_sub GetMailNumAttach:mail._ckoEmail] intValue];
        NSLog(@"Num Attach : %d" , numAttach);
        
        
        NSMutableArray *attachmentArray=[NSMutableArray array];
        for (int i=0; i<numAttach; i++) {
            NSString *attachedFileName=[self attachmentFileName:mail._ckoEmail ofIndex:i];
            int attachedFileSize=[self attachmentFileSize:mail._ckoEmail ofIndex:i];

            MailAttachment *attach=[[[MailAttachment alloc] init] autorelease];
            attach.fileName=attachedFileName;
            attach.fileSize=attachedFileSize;
            
            [attachmentArray addObject:attach];
        }
        mail.attachments=attachmentArray;
    }
}

-(void) setReceiverWithMail:(Mail*)mail{
    MailReceiver *receiver=[[MailDBManager manager] receiverOfMailRowID:mail.uid mailBoxID:mail.mailboxIDX];
    if ([receiver.recipientNames count]==0) {
        return;
    }
    mail.receiver=receiver;
}

+(MailManager* )manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedMailManager==nil) {
            sharedMailManager=[[MailManager alloc] init];
        }
    });
    return sharedMailManager;
}



-(void)loginAndGetMailBoxListThread{
    loginAndGetMailBoxListThreadExecuting=YES;
    NSLog(@"loginAndGetMailBoxListThread - Entry");
    
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    BOOL success;

retryLogin:
    if (logouted==YES) {
        loginAndGetMailBoxListThreadExecuting=NO;
        NSLog(@"loginAndGetMailBoxListThread - logout Exit");
        return;
    }
    if (imap) {
        [imap Disconnect];
    }

    if (imap!=nil) {
//        [imap release];
        imap=nil;
    }
    NSLog(@"IMAP ALLOC 시도");
    imap = [[CkoImap alloc] init]; // do not release it.
    imap_sub = [[CkoImap alloc] init]; // for Thread-safe
#if DEBUG
    [imap setKeepSessionLog:YES];
#endif
    success = [imap UnlockComponent:UNLOCKKEY];
    if (success != YES) {
        NSLog(@"[IMAP] Unlock Failed %s",__func__);
        loginAndGetMailBoxListThreadExecuting=NO;
        return;
    }
    
    imap.Ssl = usingSSL;
    imap.Port = [NSNumber numberWithInt:port];
    
    //  Connect to an IMAP server.
    if (imap.IsConnected==NO) {
        {
            NSString *server=[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSvr"];
            if (server==nil || [server isEqualToString:@"imap.gmail.com"]) {
                server=@"imap.gmail.com";
                imap.Ssl=YES;
            }
            success = [imap Connect: server];
            if (success != YES) {
                NSLog(@"CONNECT FAIL : %@",server);
                NSLog(@"[IMAP] Login Failed");
                logined=NO;
                loginAndGetMailBoxListThreadExecuting=NO;
                NSLog(@"loginAndGetMailBoxListThread - 커넥션 종료");
                return;
            }
        }
    }
    NSLog(@"IMAP LOGIN: %@ / %@ ",idString,password);
    NSLog(@"          : SSL %d / Port %d ",usingSSL,port);
    
    success = [imap Login:idString password:password];
    if (success != YES) {
        NSLog([imap LastErrorText],nil);
        NSLog(@"loginAndGetMailBoxListThread - 아이디/로긴 종료");
        loginAndGetMailBoxListThreadExecuting=NO;
        return;
    }

    CkoMailboxes *mboxes;
    mboxes = [imap ListMailboxes:@"" wildcardedMailbox: @"*"];
    NSLog([imap LastCommand],nil);
    if (mboxes == nil ) {
        NSLog(@"The mailbox list is empty.");
        goto retryLogin;
    }

    NSString *server=[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSvr"];

    if ([mboxes.Count intValue] == 0) {
        NSLog(@"The mail box. Login considered a failure.");
        goto retryLogin;
    }
    NSLog(@"Total% d e-mail box",[mboxes.Count intValue]);
    NSLog(@"-------Server mailboxes list-------------");
    for (int i = 0; i <= [mboxes.Count intValue] - 1; i++) {
        NSString *mailBoxName = [mboxes GetName: [NSNumber numberWithInt: i]];
        NSLog(@"     %@",mailBoxName);
        NSString *trimMailBoxName=[MailSOUtil stringTrim:mailBoxName];
        if ([trimMailBoxName isEqualToString:@""]) {
            NSLog(@"-------Mailboxes list on the server end, error detection------");
            goto retryLogin;
        }
    }
    NSLog(@"-------The end of the list server mailbox----------");


    if (MAIL__UNICODECHECK_MAILSERVER != NULL) {
        if ([server isEqualToString:MAIL__UNICODECHECK_MAILSERVER]) {
            for (int i = 0; i <= [mboxes.Count intValue] - 1; i++) {
                NSString *mailBoxName = [mboxes GetName: [NSNumber numberWithInt: i]];
                if ([mailBoxName isEqualToString:MAIL__UNICODECHECK_REQUIREDMAILBOX]) {
                    break;
                }
                if (logouted==YES) {
                    loginAndGetMailBoxListThreadExecuting=NO;
                    NSLog(@"loginAndGetMailBoxListThread - End of log out (2)");
                    return;
                }
                NSLog(@"The Zone Testing server: mail box list Unicode error");
                goto retryLogin;
            }
        }
    }
    if ([server isEqualToString:@"imap.gmail.com"]) {
        for (int i = 0; i <= [mboxes.Count intValue] - 1; i++) {
            NSString *mailBoxName = [mboxes GetName: [NSNumber numberWithInt: i]];
            if ([mailBoxName characterAtIndex:[mailBoxName length]-1]=='/'){
                NSLog(@"We test server: mail box list Unicode error");
                goto retryLogin;
            }
        }
    }
    
LoginSuccess:

    for (int i = 0; i <= [mboxes.Count intValue] - 1; i++) {
        NSString *boxName= [mboxes GetName: [NSNumber numberWithInt: i]];
        if (isInboxValid==NO){
            if ([boxName isEqualToString:@"INBOX"]) {
                continue;
            }
            if ([boxName length]>6 && [[boxName substringToIndex:6] isEqualToString:@"INBOX/"]) {
                continue;
            }
        }
        BOOL alreadyExistedFlag=NO;
        for (NSString *mailBoxReference in mailBoxReferenceList) {
            if ([mailBoxReference isEqualToString:boxName]) {
                alreadyExistedFlag = YES;
                break;
            }
        }
        if (alreadyExistedFlag == NO) {
            [MailSOUtil log:@"Found that a new message" obj:boxName];
            [[self mutableArrayValueForKeyPath:@"mailBoxReferenceList"]  addObject:boxName];
        }
        NSLog(@"%@ (%d) %@",[self description],__LINE__, boxName,nil);
    }
    
    
    for (NSString *mailBoxReference in mailBoxReferenceList) {
        BOOL findFlag=NO;
        for (int i = 0; i <= [mboxes.Count intValue] - 1; i++) {
            NSString *boxName= [mboxes GetName: [NSNumber numberWithInt: i]];
            if ([boxName isEqualToString:mailBoxReference]) {
                findFlag=YES;
                break;
            }
        }
        if (findFlag==NO) {
            if (deletedMailBoxReferenceListArray == nil) {
                deletedMailBoxReferenceListArray = [[NSMutableArray array] retain];
            }
            [deletedMailBoxReferenceListArray addObject:mailBoxReference];
        }
    }

    

#if DEBUG
    //NSLog([imap SessionLog],nil);
    [imap ClearSessionLog];
#endif
    if (inboxReference==nil || [inboxReference isEqualToString:@""]) {
        if ([MailSOUtil string:@"Inbox" existInArray:mailBoxReferenceList]) {
            inboxReference=@"Inbox";
        }
        else if ([MailSOUtil string:@"INBOX" existInArray:mailBoxReferenceList]) {
            inboxReference=@"INBOX";
        }
        else if ([MailSOUtil string:@"Inbox" existInArray:mailBoxReferenceList]) {
            inboxReference=@"Inbox";
        }
        else {
            inboxReference=[mailBoxReferenceList objectAtIndex:0];
        }
        [inboxReference retain];
    }
    if (deletedReference==nil || [deletedReference isEqualToString:@""]) {
        if ([MailSOUtil string:@"Deleted Item" existInArray:mailBoxReferenceList]) {
            deletedReference=@"Deleted Items";
        }
        else if ([MailSOUtil string:@"Deleted Messages" existInArray:mailBoxReferenceList]) {
            deletedReference=@"Deleted Messages";
        }
        else {
            deletedReference=nil;
        }
        [deletedReference retain];
    }
    NSLog(@"---------------------");
    [MailSOUtil log:@"INBOX Reference" obj:inboxReference];
    [MailSOUtil log:@"DELETED Reference" obj:deletedReference];
    NSLog(@"---------------------");

    if (logouted) {
        NSLog(@"Login FAILED (LOGOUTED) with ID: %@!!!",idString);
        loginAndGetMailBoxListThreadExecuting=NO;
        [pool release];
        NSLog(@"loginAndGetMailBoxListThread - End logout (3)");
        return;
    }
    NSLog(@"Login SUCCESS with ID: %@!!!",idString);
    if (loginThreadStop) {
        NSLog(@"loginAndGetMailBoxListThreadExecuting - loginThreadStop End");
        loginAndGetMailBoxListThreadExecuting=NO;
        return;
    }
    [self performSelectorInBackground:@selector(noopThread) withObject:nil];
    logined=YES;
    loginAndGetMailBoxListThreadExecuting=NO;
    NSLog(@"loginAndGetMailBoxListThread - Normal Termination");
    [pool release];

}
-(void)loadDBData{
    
}
-(BOOL)loginWithID:(NSString*)_idString password:(NSString*)_password port:(NSUInteger)_port usingSSL:(BOOL)_usingSSL{
    [mailBoxArray removeAllObjects];
    [mailBoxDic removeAllObjects];
    [mailThreadWorkingFunctionSet removeAllObjects];
    [[MailDBManager manager] changeDB];

    if (logining==YES) {
        return NO;
    }
    logouted = NO;
    inboxReference=[[[NSUserDefaults standardUserDefaults] stringForKey:@"MailInboxName"] retain];
    deletedReference=[[[NSUserDefaults standardUserDefaults] stringForKey:@"MailInboxName"] retain];

    if (loginAndGetMailBoxListThreadExecuting==YES) {
        NSLog(@"loginAndGetMailBoxListThreadExecuting Is alive...Waiting");
        [MailSOUtil alert:@"Plz login Shortly"];
        [inboxReference release];
        [deletedReference release];
        return NO;
    }
    NSLog(@"Login, GetMailThread Death. Login attempts");
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UseInbox"] isEqualToString:@"1"]){
        isInboxValid=YES;
    }
    else{
        isInboxValid=NO;
    }
    
    NSString *versionKey=[NSString stringWithFormat:@"MailVersion%@",MailVersion];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MailReset"] == 1 ||
        [[NSUserDefaults standardUserDefaults] floatForKey:versionKey] != [MailVersion floatValue]) {
        [[MailDBManager manager] resetDB];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MailReset"];
        [[NSUserDefaults standardUserDefaults] setFloat:[MailVersion floatValue] forKey:versionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    logining=YES;

    [mailBoxReferenceList removeAllObjects];
    NSArray *tempArr = [[MailDBManager manager] mailBoxReferenceList];
    
    for ( NSString *boxName in tempArr) {
        NSString *trimedBoxName = [MailSOUtil stringTrim:boxName];
        if (isInboxValid==NO){
            if ([trimedBoxName isEqualToString:@"INBOX"]) {
                continue;
            }
            if ([trimedBoxName length]>6 && [[boxName substringToIndex:6] isEqualToString:@"INBOX/"]) {
                continue;
            }
        }
        if ([trimedBoxName isEqualToString:@""]) {
            continue;
        }
        if ([trimedBoxName characterAtIndex:[trimedBoxName length]-1] == '/') {
            continue;
        }
        [[self mutableArrayValueForKey:@"mailBoxReferenceList"] addObject:boxName];
        NSLog(boxName,nil);
    }
    
    [self loadMailboxesFromCache];
    
    if (idString)
        [idString release];
    if (password)
        [password release];
    usingSSL=_usingSSL;
    idString=[_idString copy];
    password=[_password copy];
    logouted=NO;
    port=_port;


    @synchronized(self){


        self.mailBoxStatusLog=@"Login";
        [self addNumOfNetworkThreadWithLog:@"Log in operation"];
        if ([imap IsLoggedIn]==YES) {
            [imap Logout];
        }
        
        
        if (port==0) {
            port=993;
        }

        loginThreadStop=NO;
               
        [MailSOUtil timeLogStart:@"Login threads"];
        loginAndGetMailBoxListThreadExecuting = YES;
        /*
        NSLog(@"Box list ---");
        if (mailBoxReferenceList==nil) {
            mailBoxReferenceList=[[NSMutableArray array] retain];
        }
        else{
            [mailBoxReferenceList removeAllObjects];
        }
         */
        [self performSelectorInBackground:@selector(loginAndGetMailBoxListThread) withObject:nil];
        
        int i=0;
        while (loginAndGetMailBoxListThreadExecuting==YES) {
            i++;
            [NSThread sleepForTimeInterval:0.5];
            if (logouted==YES) {
                NSLog(@"TYPE1");
                [self removeNumOfNetworkThreadWithLog:@"Log in operation"];
                logining=NO;
                return NO;
            }

            if (i==40) {
                loginThreadStop=YES;
                break;
            }
        }
        
        
        [MailSOUtil timeLogEnd:@"Login threads"];
    } // end of synchronized
        if (logined==YES) {
            //print thread 실행
            //[self performSelectorInBackground:@selector(printNumOfNetworkThread) withObject:nil];
            [self loadMailboxesFromCache];

            if (deletedMailBoxReferenceListArray != nil) {
                for (NSString *deletedReferenceStr in deletedMailBoxReferenceListArray) {
                    for (NSString *ref in mailBoxReferenceList) {
                        if ([ref isEqualToString:deletedReferenceStr]) {
                            [mailBoxReferenceList removeObject:ref];
                            break;
                        }
                    }
                    [[MailDBManager manager] deleteMailBox:deletedReferenceStr];
                }
            }
            
            
            if (logouted) {
                NSLog(@"TYPE2");
                [self removeNumOfNetworkThreadWithLog:@"Log in operation"];
                logining=NO;
                return NO;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                [self loadMailboxesFromServer];
            });

            if (logouted) {
                NSLog(@"TYPE3 (%@)", [self description]);
                logining=NO;
                [self removeNumOfNetworkThreadWithLog:@"Log in operation"];
                return NO;
            }
        }
        NSLog(@"TYPE4 (%@)",[self description]);
        [self removeNumOfNetworkThreadWithLog:@"Log in operation"];
        if (logined == NO) {
            //printThreadDoes not run, check the indicator.
            NSLog(@"TIMEOUT");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            logining=NO;
            return NO;
        }
    
    logining=NO;
//    self.setupAllFinished=YES;
    return YES;
}

-(void)loadMoreMailFromServer:(MailBox*)mailBox{
    //30 e-mail additional load
    //find last uid

    mailBox.isLoadMore = YES;
    CkoMessageSet *newMessageSet = [[CkoMessageSet alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        @synchronized(self){
            [imap SelectMailbox:mailBox.reference];
            CkoMessageSet *allMessageSet = [imap GetAllUids];
            NSLog([allMessageSet ToString],nil);

            for (Mail *mail in mailBox.mailArray){
                [allMessageSet RemoveId:[NSNumber numberWithInt: mail.uid]];
            }
            int i = [[allMessageSet Count] intValue];
            int j = 0;
            while ( i > 0) {
                [newMessageSet InsertId:[allMessageSet GetId:[NSNumber numberWithInt:i-1]]];
                i--;
                j++;
                if (j > Mail__CACHENUM__) {
                    break;
                }
            }
            NSLog([newMessageSet ToString],nil);
            
        }
        //request more mail
        [self loadMailboxFromServer:mailBox CkoMessageSet:newMessageSet];
        mailBox.isLoadMore=NO;
        [newMessageSet release];
    });
}

-(void)loadMailboxesFromCache{
    self.mailBoxStatusLog=@"Synchronize the mailboxes list.";
    @try {
        if ([MailSOUtil string:@"Inbox" existInArray:mailBoxReferenceList]) {
            inboxReference=@"Inbox";
        }
        else if ([MailSOUtil string:@"INBOX" existInArray:mailBoxReferenceList]) {
            inboxReference=@"INBOX";
        }
        else if ([MailSOUtil string:@"Inbox" existInArray:mailBoxReferenceList]) {
            inboxReference=@"Inbox";
        }
        else {
            inboxReference=[mailBoxReferenceList objectAtIndex:0];
        }

        for (NSString *reference in mailBoxReferenceList) {
            if (logouted) {
                return;
            }
            BOOL mailBoxInited=NO;
            MailBox *mailBox=[mailBoxDic objectForKey:reference];
                        
            if (mailBox == nil) {
                mailBoxInited = YES;
                mailBox = [[MailDBManager manager]mailBoxWithReference:reference];
                if (mailBox == nil) {
                    mailBox=[[MailDBManager manager] makeNewMailBoxWithReference:reference];
                }
            }
            [mailBoxDic setObject:mailBox forKey:reference];
            
            NSArray *newMailArray=[[MailDBManager manager] mailsInMailBox:mailBox.rowid reference:mailBox.reference];
            mailBox.numOfUnSeen=[[MailDBManager manager] getUnseenOfMailBox:mailBox];
            for (Mail *newMail in newMailArray) {
                [mailBox addMail:newMail];
            }
            if (mailBoxInited) {
                [[self mutableArrayValueForKey:@"mailBoxArray"] addObject:mailBox];
            }

    }
    }
    @catch (NSException *exception) {
        [MailSOUtil errorLog:[exception description]];
    }
    @finally {
        self.mailboxLoaded = YES;
        NSLog(@"------- Fetched from the DB-mail. -------");
        for (MailBox *box in mailBoxArray) {
            NSLog(@"|   from db:   %@", box.name);
        }
        self.mailboxLoaded=YES;

        NSLog(@"------- ------------------ -------");
    }
}

-(void)loadMailboxesFromServerHandleCkoEmail:(CkoEmail*)email mailBox:(MailBox*)mailBox{
    NSLog(@"Start processing: %@, UID: %d",[email Subject],[[email GetImapUid] intValue],nil);

    if (email==NULL || [[email GetImapUid] intValue]==0 || [[email GetImapUid] intValue] < 0) {
#ifdef DEBUG
        NSLog(@"     ---------ERROR -------------------    ");
        NSLog(@"     ---------loadMailboxesFromServerHandleCkoEmail  -------------------    ");
        NSLog(@"     ---------ERROR -------------------    ");
//        NSLog([imap SessionLog],nil);
#endif
    }
    
    Mail *mail=[[Mail alloc] initWithCkoEmail:email mailboxIDX:mailBox.rowid mailBoxReference:mailBox.reference];

    if (mail.subject == nil || [mail.subject isEqualToString:@""]) {
        [mail release];
        CkoEmail *newEmail = [imap FetchSingle: [NSNumber numberWithInt: mail.uid] bUid: YES];
        mail=[[Mail alloc] initWithCkoEmail:newEmail mailboxIDX:mailBox.rowid mailBoxReference:mailBox.reference];
        NSLog([imap LastCommand],nil);

        NSLog(@"     ---------ERROR -------------------    ");
        NSLog(@"     ---------loadMailboxesFromServerHandleCkoEmail  -------------------    ");
        NSLog(@"     ---------ERROR -------------------    ");
//        NSLog([imap SessionLog],nil);
//        NSLog([imap LastErrorText],nil);
    }

    BOOL result=[mailBox addMail:mail];
    if (result) {
        NSLog(@"Insert email %@",mail.subject);
    }
    else{
        NSLog(@"Insert email %@",mail.subject);
    }
    if (result) {
        [[MailDBManager manager] saveCkoMail:mail._ckoEmail toMailBox:mailBox.rowid mail:mail];

        if( [self getMailSeen:email] == NO){
                mailBox.numOfUnSeen++;                
        }
    }
    [mail release];
}

-(void)loadMailboxFromServer:(MailBox *)mailBox{
    [reloadMailBoxes addObject:mailBox];
    [self loadMailboxFromServer:mailBox CkoMessageSet:NULL];
}

-(BOOL)isMailBoxReloaded:(MailBox *)mailBox{
    if ([reloadMailBoxes containsObject:mailBox]) {
        return YES;
    }
    else {
        return NO;
    }
}


-(void)loadMailboxFromServer:(MailBox *)mailBox CkoMessageSet:(CkoMessageSet*)mSet{
    @synchronized(self){
        if (logined==NO) {
            return;
        }
        if (mailBox.syncDate!=nil) {
            NSTimeInterval timeInterval=[mailBox.syncDate timeIntervalSinceNow];
            if ( timeInterval*(-1) < Mail__SYNC_Interval){
               
                mailBox.syncStatus=MailSyncStatusEnd;
                return;
            }
        }
        if (logouted) {
            return;
        }
        NSLog(@"loadMailboxFromServer :  %@",mailBox.name);
        mailBox.syncDate=[NSDate date];
        mailBox.syncStatus=MailSyncStatusSync;
        
        if (imap.IsConnected == NO || imap.IsLoggedIn == NO) {
            //relogin
            BOOL success=[imap Login:idString password:password];
            if (success==NO) {
                NSLog([imap LastErrorText],nil);
//                [MailSOUtil alert:@""];
                //            [NSException raise:@"Logouted" format:nil];
                mailBox.syncStatus=MailSyncStatusEnd;
                return;
            }
        }

    }
    int totalMail;
    int startMailSeq ;
    
    @synchronized(self){
        CkoEmailBundle *emailBundle;
        BOOL success;
        [self addNumOfNetworkThreadWithLog:[NSString stringWithFormat:@"[동기화] %@",mailBox.name]];
     //   self.mailBoxStatusLog=[NSString stringWithFormat:@" %@",mailBox.name];
        success=[self selectMailBox:mailBox.reference];
        
        if (success!=YES) {
            mailBox.syncStatus=MailSyncStatusEnd;
            NSLog(@"----------------------");
            NSLog([imap LastCommand],nil);
            NSLog([imap LastResponse],nil);
            NSLog([imap LastErrorText],nil);
            NSLog(@"----------------------");
            NSLog(@"Failure to Synchronize  SelectMailbox Mailbox command failed: %@  syncStatus %d",mailBox.name,mailBox.syncStatus);
            [self removeNumOfNetworkThreadWithLog:[NSString stringWithFormat:@"Sync %@",mailBox.name]];
            return;
        }
        
        totalMail=[[imap NumMessages] intValue];
        startMailSeq=totalMail-Mail__CACHENUM__;
        if (startMailSeq<1) {
            startMailSeq=1;
        }
        int endMailSeq=totalMail - startMailSeq + 1;

        if (mailBox.numOfSavedTotal==0 ) { // The first Connection 
            [[MailDBManager manager] mailBox:mailBox setNumOfIgnored:startMailSeq-1];
        }
        
        if (mSet == NULL) {
            emailBundle=[imap FetchSequenceHeaders:[NSNumber numberWithInt:startMailSeq] numMessages:[NSNumber numberWithInt: endMailSeq]];
        }
        else {
            emailBundle=[imap FetchHeaders:mSet];
        }
    
        NSString *lastResponse=[imap LastResponse];
        NSString *trimedLastResponse=[lastResponse substringFromIndex:5];
#if DEBUG
        //NSLog([imap SessionLog],nil);
//        [imap ClearSessionLog];
#endif
        NSLog([imap LastCommand],nil);

        if ([trimedLastResponse isEqualToString:@"OK FETCH completed\r\n"] || [trimedLastResponse isEqualToString:@"OK Success\r\n"]) {
            mailBox.syncStatus=MailSyncStatusEnd;
            NSLog(@"----------------------");
            NSLog([imap LastCommand],nil);
            NSLog([imap LastResponse],nil);
            NSLog(@"----------------------");
            NSLog(@"Mailbox synchronization failure (no new e-mail): %@  syncStatus %d",mailBox.name,mailBox.syncStatus);
            [self removeNumOfNetworkThreadWithLog:[NSString stringWithFormat:@"[Synchronization] %@",mailBox.name]];
            return;
        }

        
        NSNumber *numCount=[emailBundle MessageCount];
        for (int i=0; i<[numCount intValue]; i++) {

            CkoEmail *email=[emailBundle GetEmail:[NSNumber numberWithInt:[numCount intValue]-i-1]];
            NSLog([imap LastCommand],nil);

            if (email==NULL) {
                NSLog(@"\n\n--------- ERROR  emailBundle ------------");
                NSLog([imap LastCommand],nil);
                NSLog([imap LastResponse],nil);
                NSLog(@"----------------------------\n\n");                    
            }
            else{
                [self loadMailboxesFromServerHandleCkoEmail:email mailBox:mailBox];
            }
        }
        mailBox.numOfSavedTotal+=[numCount intValue];
        mailBox.syncStatus=MailSyncStatusEnd;
        NSLog(@"Mailbox sync shutdown: %@  syncStatus %d",mailBox.name,mailBox.syncStatus);
        [self removeNumOfNetworkThreadWithLog:[NSString stringWithFormat:@"[Synchronization] %@",mailBox.name]];
    }
}


-(void)loadMailboxesFromServer{
    /*
    for (MailBox *mailBox in mailBoxArray) {
        mailBox.syncStatus=MailSyncStatusReady;
    }

    @try {
        
        for (MailBox *mailBox in mailBoxArray) {
            if (logouted) {
                return;
            }
            [self loadMailboxFromServer:mailBox];
        }
    }
    @catch (NSException *exception) {
        NSLog([exception description],nil);
    }
     */
    // Replace that modify the synchronization, only INBOX
    MailBox *inbox = [mailBoxDic objectForKey:inboxReference];
    if (inbox == nil) {
        return;
    }
    inbox.syncStatus = MailSyncStatusReady;
    [self loadMailboxFromServer:inbox];
}

#if 0
-(NSArray*)inferiorReferencesOfMailBox:(CkoMailboxes*)box{
    int count=[[box Count] intValue];
    NSMutableArray *tempArray=[NSMutableArray array];

    for (int i=0; i<count; i++){
        NSString *inferiorReference=[box GetName:[NSNumber numberWithInt:i]];
        if ([inferiorReference characterAtIndex:[inferiorReference length]-1]=='/') {
            NSException *exception=[NSException exceptionWithName:@"hangul" reason:nil userInfo:nil];
            [exception raise];
        }

        if (isInboxValid==NO && [inferiorReference length] > 4) {
            NSString *subStr=[[inferiorReference substringToIndex:5] uppercaseString];
            if ( [subStr isEqualToString:@"INBOX"]) {
                NSLog(@"Skip mailbox server : %@",inferiorReference);
                continue;
            }
            else{
                NSLog(@"Check the mailbox server: %@",inferiorReference);
            }
        }
        [tempArray addObject:inferiorReference];
    }
    return tempArray;
}
#endif

-(CkoMailboxes*)ckoMailBoxOfReference:(NSString*)reference{
    if (imap==nil) {
        NSException *exception=[[[NSException alloc] initWithName:@"NotConnected" reason:nil userInfo:nil] autorelease];
        [exception raise];
    }
    
    if (imap.IsLoggedIn==NO) {
        NSLog(@"ckoMailBoxOfReference : not logined with ref %@",reference);
        NSException *exception=[[[NSException alloc] initWithName:@"NotLogined" reason:nil userInfo:nil] autorelease];
        [exception raise];
    }
    return [imap ListMailboxes:reference wildcardedMailbox:@"*"];
}


-(MailBox*)mailBoxOfReference:(NSString*)reference{
    return [mailBoxDic objectForKey:reference];
}


-(void)setMailBox:(MailBox*)mailBox withReference:(NSString*)name{
    [mailBoxDic setObject:mailBox forKey:name];
}

-(void)noopThread{
#if 1
    //send noop for every x second
        while(1){
            for (int i=0; i<15; i++) {
                [NSThread sleepForTimeInterval:0.5];
                if (logined==NO) {
                    NSLog(@"Login == NO. NOOP End of threaded");
                    return;
                }
            }
            @synchronized(self){
                NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
                NSLog(@"NOOP");
                if (logined==NO) {
                    NSLog(@"Login == NO. NOOP End of thread");
                    [pool release];
                    return;
                }
#if NOOP_IS_SELECTED_MAILBOX
                [self selectMailBox:nil];
#else
                if ([imap Noop]==NO) {
                    //reconnect
                    [self loginWithID:idString password:password port:port usingSSL:usingSSL];
                };
#endif
                [pool release];
            }
        }
#endif
}

- (void)getNSApplicationWillResignActiveNotification{
    NSLog(@"-------- ResignActive ------------");
    logined=NO;
    logouted=YES;
    [MailManager assignNewManager];
}

-(void)getNSApplicationWillBecomeActiveNotification{
//    @synchronized(self){
    NSLog(@"-------- BecomeActive : %@ ------------",[self description]);

    if ([MailManager manager] != self) {
        //And not wake, leaves the memory Leak.
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^(void){
            [[MailManager manager ] login];
        });

}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    [MailSOUtil log:@"valid"];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    [MailSOUtil log:@"end"];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    [MailSOUtil log:@"dismiss"];
}

-(void)addNumOfNetworkThreadWithLog:(NSString*)log{
    self.numOfNetworkThread++;
    [mailThreadWorkingFunctionSet addObject:log];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Thread 추가 : %@",log);
    self.mailBoxStatusLog=log;
}
-(void)removeNumOfNetworkThreadWithLog:(NSString*)log{
    self.numOfNetworkThread--;
    [mailThreadWorkingFunctionSet removeObject:log];
    NSLog(@"Thread 완료 : %@",log);
    if (numOfNetworkThread==0) {
        self.mailBoxStatusLog=nil;
    }
    if (self.numOfNetworkThread==-1) {
        int i=0;i++;
    }
}


-(BOOL)downloadAttachment:(Mail*)mail fileName:(NSString*)filename{

    @synchronized(self){
        downloading=YES;
        [imap ClearSessionLog];
        [self addNumOfNetworkThreadWithLog:@"downloadAndExecuteAttachment"];
        
        if (mail._ckoEmail == nil) {
            BOOL success;
            success=[self selectMailBox:mail.mailBoxReference];
            if (success!=YES) {
#if DEBUG
                
                downloading=NO;
                [MailSOUtil alert:imap.LastErrorText];
#else
                [MailSOUtil alert:@"Unknown error."];
#endif
                [self removeNumOfNetworkThreadWithLog:@"downloadAndExecuteAttachment"];
                return NO;
            }

            mail._ckoEmail = [imap FetchSingle:[NSNumber numberWithInt: mail.uid] bUid: YES];
#if DEBUG
            NSLog(@"FETCH-----");
            NSLog(mail.subject,nil);
            NSLog(@"Num Attach : %d" , [[imap_sub GetMailNumAttach:mail._ckoEmail] intValue]);
            
#endif
        }
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        for (int i=0; i<mail.numOfAttachment; i++) {
            NSString *matchiedFileName=[imap_sub GetMailAttachFilename:mail._ckoEmail attachIndex:[NSNumber numberWithInt:i]];
            if ([matchiedFileName isEqualToString:filename]) {
                if ([mail._ckoEmail SaveAttachedFile:[NSNumber numberWithInt:i] directory:documentsDirectory] == NO) {
                    [MailSOUtil errorLog:@"Failed to save"];
                    [MailSOUtil errorLog:[mail._ckoEmail LastErrorText]];
                };
                break;
            }
        }
        [self removeNumOfNetworkThreadWithLog:@"downloadAndExecuteAttachment"];
#if DEBUG
        //NSLog([imap SessionLog],nil);
#endif
        if ([[NSFileManager defaultManager] fileExistsAtPath:[MailSOUtil filePathWithName:filename]] == YES){

            downloading=NO;
            return YES;
        }
                    downloading=NO;
        return NO;
    }
}

-(void)printNumOfNetworkThread{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init ];
    static bool isExecuting;
    if (isExecuting) {
        [pool release];
        return;
    }
    while (1) {
        for (int i=0; i < 10 ; i++){
            [NSThread sleepForTimeInterval:0.5];
            if (self.numOfNetworkThread==0) {
                if (self.mailBoxStatusLog!=nil) {
                    self.mailBoxStatusLog=nil;
                }
            }
            if (logined==NO) {
                NSLog(@"Login == NO. End of monitoring the network thread");
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                isExecuting=NO;
                [pool release];
                return;
            }
            isExecuting=YES;
            if (self.numOfNetworkThread==0) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            else{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }
#ifdef DEBUG
        NSMutableString *log=[NSMutableString string];
        NSDate *date=[NSDate date];
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        
        [log appendFormat:@"\n---------------------- %@ ---------------------\n",[formatter stringFromDate:date]];
        [formatter release];
        
        for (NSString *string in mailThreadWorkingFunctionSet) {
            [log appendFormat:@"| %@ : %d \n",string,[mailThreadWorkingFunctionSet countForObject:string]];
        }
        [log appendString:@"----------------------------------------------------\n"];
        NSLog(@"%@",log);
        NSLog(@"Number Of Network Thread: %d",numOfNetworkThread);
#endif
    }
    [pool release];
}

-(NSArray*)mailsInMailBox:(NSString*)reference mailBoxRowID:(int)rowid searchString:(NSString*)searchStr
{
    @synchronized(self){
        NSString *qryStr=MAIL__SearchCommand(searchStr);
//        NSString *qryStr=[NSString stringWithFormat:@"OR (SUBJECT %@)  (BODY %@) ", searchStr,searchStr, searchStr, searchStr];
        
        //  Fetch the email headers into a bundle object:
        BOOL success;
        success = [self selectMailBox:reference];
        if (success != YES) {
#if DEBUG
            [MailSOUtil alert:imap.LastErrorText];
#else
            [MailSOUtil alert:@"Unknown error."];
#endif
            [NSException exceptionWithName:@"imapError" reason:nil userInfo:nil];
        }
        CkoMessageSet *messageSet;
        messageSet = [imap Search: qryStr bUid: YES];
        if (messageSet == nil ) {
            return nil;
        }
        
        
        CkoEmailBundle* bundle = [self fetchBundle:messageSet boxReference:reference];
        int cnt=[bundle.MessageCount intValue];
        if (cnt==0) {
            NSLog([imap LastCommand],nil);
            NSLog([imap LastResponse],nil);
        }
        NSMutableArray *retArray=[NSMutableArray array];
        for (int i=cnt-1 ; i>=0 ; i--) {
            if (cnt - i > 500) {
                break;
            }
            CkoEmail* email=[bundle GetEmail:[NSNumber numberWithInt:i]];
            // Retrieved from the server, do not put it in the DB! Important!
            Mail* mail=[[Mail alloc] initWithCkoEmail:email mailboxIDX:rowid mailBoxReference:reference];
            [retArray addObject:mail];
            [mail release];
        }
        return retArray;
    }
}

-(BOOL)deleteMail:(Mail*)mail{
    if (deletedReference==nil || [deletedReference isEqualToString:@""] || [MailSOUtil string:deletedReference existInArray:mailBoxReferenceList]==NO) {
        [MailSOUtil alert:@"Please delete the e-mail"];
        return NO;
    }
    if ([mail.mailBoxReference isEqualToString:deletedReference]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^(void){
            @synchronized(self){
                BOOL success=[self selectMailBox:mail.mailBoxReference];
                if (success!=YES) {
#if DEBUG
                    [MailSOUtil alert:[imap LastErrorText]];
#else
                    [MailSOUtil alert:@"Have failed to remove."];
#endif
                    return ;
                }
                success=[imap SetFlag:[NSNumber numberWithInt:mail.uid] bUid:YES flagName:@"Deleted" value:[NSNumber numberWithInt:1]];
                if (success!=YES) {
#if DEBUG
                    [MailSOUtil alert:[imap LastErrorText]];
#else
                    [MailSOUtil alert:@"Have failed to remove."];
#endif
                    return ;
                }
#if MAIL__DELETE_IS_EXPURGE
                success=[imap Expunge];
#endif
                if (success!=YES) {
#if DEBUG
                    [MailSOUtil alert:[imap LastErrorText]];
#else
                    [MailSOUtil alert:@"Have failed to remove."];
#endif
                    return ;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                    // Original new mail server should sync.
                    //Sync at the following e-mail server is stored in the DB.
                    [[MailDBManager manager] deleteMail:mail];
                });
                
            }
            return ;
        });
        return YES;
    }
    else{
        MailBox *mailBox=[self mailBoxOfReference:deletedReference];    
        return [self moveMail:mail toMailBox:mailBox];
    }
}


-(BOOL)moveMail:(Mail*)mail toMailBox:(MailBox*)mailBox{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
        @synchronized(self){
        [self addNumOfNetworkThreadWithLog:@"Moving e-mail"];
        BOOL success=[self selectMailBox:mail.mailBoxReference];
        if (success!=YES) {
        }
        success=[imap Copy:[NSNumber numberWithInt: mail.uid] bUid:YES copyToMailbox:mailBox.reference];
          
        NSLog(@"MAILMOVE : %@ --> %@",mail.subject, mailBox.reference);
        if (success!=YES) {
            [self removeNumOfNetworkThreadWithLog:@"Moving e-mail"];
            return;
        }
        
        success=[imap SetFlag:[NSNumber numberWithInt:mail.uid] bUid:YES flagName:@"Deleted" value:[NSNumber numberWithInt:1]];
        if (success!=YES) {
            [self removeNumOfNetworkThreadWithLog:@"Moving e-mail"];
            return;
        }
        
        success=[imap Expunge];
        if (success!=YES) {
            [self removeNumOfNetworkThreadWithLog:@"Moving e-mail"];
            return;
        }
            // The original must be sync to the new mail server.
           // The following e-mail server is stored in the DB SYNC.
            [self removeNumOfNetworkThreadWithLog:@"Moving e-mail"];
            [[MailDBManager manager] deleteMail:mail];
        }
    });
        ///////I charge from MailBoxCopyTVC annotated below, now
    //MailManager Only responsible for the communication server
    
        //In current mailBoxArray deleting them from the list.
        //The move mailBoxArray insert the mail.
    /*
        MailBox *oldBox=[mailBoxDic objectForKey: mail.mailBoxReference];
        [[mailBox mutableArrayValueForKey:@"mailArray"] addObject:mail];
        [[oldBox mutableArrayValueForKey:@"mailArray"] removeObject:mail];
        NSLog(@"Move Mail : %@",[mail description]);
        mail.mailBoxReference=mailBox.reference;
        mail.mailboxIDX=mailBox.rowid;
        [self removeNumOfNetworkThreadWithLog:@"메일 이동"];
     */

        return YES;
}

-(void)assignMailRoot:(UIViewController*)mailRootVC{
    if (self.mailRoot == mailRootVC) {
        return;
    }
    @synchronized(observerAssigned){
            self.mailRoot = mailRootVC;
            [self addObserver:mailRootVC forKeyPath:@"mailboxLoaded" options:NSKeyValueObservingOptionInitial context:nil];
            [self addObserver:mailRootVC forKeyPath:@"mailBoxStatusLog" options:NSKeyValueObservingOptionInitial context:nil];
            [self addObserver:mailRootVC forKeyPath:@"mailBoxArray" options:NSKeyValueObservingOptionInitial context:nil];
//            [self addObserver:mailRootVC forKeyPath:@"setupAllFinished" options:NSKeyValueObservingOptionInitial context:nil];
            observerAssigned = [NSNumber numberWithBool:YES];
    }
}

-(void)resignMailRoot{
    @synchronized(observerAssigned){
        if ([observerAssigned boolValue] == YES) {
            [self removeObserver:mailRoot forKeyPath:@"mailBoxStatusLog"];
            [self removeObserver:mailRoot forKeyPath:@"mailBoxArray"];
            [self removeObserver:mailRoot forKeyPath:@"mailboxLoaded"];
  //          [self removeObserver:mailRoot forKeyPath:@"setupAllFinished"];
            observerAssigned = [NSNumber numberWithBool:NO];
            self.mailRoot = nil;
        }
    }
}

@end

