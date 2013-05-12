//
//  MailSender.m
//  DzMail
//
//  Created by KIM TAE HO on 11. 11. 18..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailSender.h"
#import "MailSubscriber.h"              // <--------------
#import "OrgaSelect.h"                  // <--------------
#import "CkoMailMan.h"
#import "MailSOUtil.h"
#import "CkoEmail.h"
#import "MailSenderAttachmentV.h"
#import "MailSODateTimeUtil.h"
#import "NSString+RegularExp.h"
#import "TKAlertCenter.h"
#import "MailManager.h"
#import "MailConfig.h"


@implementation MailAttachmentImage
@synthesize name;
@synthesize image;
@synthesize selected;
@synthesize size;
@end



@implementation MailSender
@synthesize tfTo;
@synthesize tfCc;
@synthesize textV;
@synthesize senderDelegate;

/* 포워드 되는지 테스트하기 위한 코드. 삭제되어도 무방하다.
- (void)forwardTest:(CkoEmail*)_email{
    CkoEmail *email=[_email CreateForward];
    CkoMailMan *mailman = [[[CkoMailMan alloc] init] autorelease];
    BOOL success;
    success = [mailman UnlockComponent: @"JOODONIMAPMAILQ_rNZneBNT3J4w"];
    if (success != YES) {
        [MailSOUtil alert:@"서버가 응답하지 않습니다 (Error 1)"];
        [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
        return;
    }
    
    //  Set the SMTP server.
    NSString *serverstr= [[NSUserDefaults standardUserDefaults] objectForKey:@"MailSSvr"];
    mailman.SmtpHost=serverstr;
    if (serverstr==nil) {
        [MailSOUtil alert:@"SMTP 서버 설정을 해주세요"];
        return;
    }
    
    NSString *imapid=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyEmail"];
    NSString *imapPassword=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyPassword"];
    if (imapid==nil) {
        [MailSOUtil alert:@"SMTP 유져 설정을 해주세요"];
        return;
    }
    
    //  Set the SMTP login/password (if required)
    mailman.SmtpUsername = imapid;
    mailman.SmtpPassword = imapPassword;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SmtpIsSSL"] isEqualToString:@"1"]) {
        mailman.SmtpSsl=YES;
    }
    else{
        mailman.SmtpSsl=NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MailSPort"]==nil) {
        mailman.SmtpPort=[NSNumber numberWithInt:465];
    }
    else{
        mailman.SmtpPort=[NSNumber numberWithInt: [[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSPort"] intValue]];
    }
    
    email.From = imapid;
    [email setFromAddress:imapid];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MyName"]!=nil) {
        [email setFromName:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyName"]];
    }
    
    
    [email AddMultipleTo:@"jd.yang@shiftone.co.kr"];
//    [email AddMultipleCC:tfCc.text];
    
    [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) withObject:@"메일 보내기를 시도합니다" waitUntilDone:NO]; 

    [self performSelectorOnMainThread:@selector(sentMessageStart) withObject:nil waitUntilDone:NO];
    
    NSLog(@"MailSending : Attachment : %d ",[[email NumAttachments] intValue]);
    success = [mailman SendEmail: email];
    if (success != YES) {
        [MailSOUtil alert:@"서버가 응답하지 않습니다 (Error 2)"];
        NSLog([mailman LastErrorText],nil);
        //            [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
        return;
    }
    NSLog(@"MailSending END");
    
    //  Some SMTP servers do not actually send the email until
    //  the connection is closed.  In these cases, it is necessary to
    //  call CloseSmtpConnection for the mail to be  sent.
    //  Most SMTP servers send the email immediately, and it is
    //  not required to close the connection.  We'll close it here
    //  for the example:
    [mailman CloseSmtpConnection];

}
 */

-(void)setSubject:(NSString*)subject{
    preSubject=[subject retain];
}
-(void)setTo:(NSString*)to{
    preTo=[to retain];
}

- (void)reset{
    if (forwardCkoEmail) {
        [forwardCkoEmail release];
        forwardCkoEmail=nil;
    }
    forwardFileExist = NO;
    preSnippet=nil;
    preTo=nil;
    preSnippet=nil;
    [attachmentPics removeAllObjects];
    [addDocs removeAllObjects];
    if (dispatch_get_main_queue() == dispatch_get_current_queue() ){
        [fileExistL setText:nil];
        [self.tfCc setText:nil];
        [self.tfTo setText:nil];
        NSLog(@"TfTO6: %@",self.tfTo.text);
        [self.textV setText:nil];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [fileExistL setText:nil];
            [self.tfCc setText:nil];
            [self.tfTo setText:nil];
            NSLog(@"TfTO6: %@",self.tfTo.text);
            [self.textV setText:nil];
        });
    }
}

-(void)setSnippet:(NSString *)snippet{
    preSnippet = [snippet retain];
}

-(void)setFileExistLText{
    int selectedImgs=0;
    for (MailAttachmentImage *imgObj in attachmentPics) {
        if (imgObj.selected==YES){
            selectedImgs++;
        }
    }
    if ([addDocs count] == 0 && selectedImgs == 0 ) {
        fileExistL.text=@"There is no attachment";
    }
    else{
        fileExistL.text=[NSString stringWithFormat:@"Photo of% d,% d documents",selectedImgs, [addDocs count]];
    }
}

-(void)setDocs:(NSArray*)docs{
    if (addDocs) {
        [addDocs release];
    }
    addDocs=[[NSMutableArray array] retain];
    for (NSString *fileName in docs) {
        NSString *modifiedFileName=[MailSOUtil stringTrim:fileName];
        [addDocs addObject:modifiedFileName];
        NSLog(modifiedFileName,nil);
    }
    [self setFileExistLText];
}



-(void)pressLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)sentMessageStart{
//     blackCoverV.hidden=YES;f
     [[self navigationController] popViewControllerAnimated:YES]; 
}

-(void)sentMessageFinished{
    /*
    blackCoverV.hidden=YES;
    [[self navigationController] popViewControllerAnimated:YES]; 
     */
}

-(void)sentMessageFinishedNoPop{
//    blackCoverV.hidden=YES;
}

- (IBAction)pressSendB:(id)sender{
    NSString *subject=[[subjectV.text copy] autorelease];
    if (subject==nil || [subject isEqualToString:@""]) {
        [MailSOUtil alert:@"No title."];
        [senderDelegate performSelector:@selector(sendFail) withObject:nil];
        return;
    }
    
    if (tfTo.text==nil || [tfTo.text isEqualToString:@""]) {
        [MailSOUtil alert:@"Recipient"];
        [senderDelegate performSelector:@selector(sendFail) withObject:nil];
        return;
    }
    
    //    blackCoverV.hidden=NO;
    [tfTo resignFirstResponder];
    [tfCc resignFirstResponder];
    [subjectV resignFirstResponder];
    [textV resignFirstResponder];
    
    dispatch_async(dispatch_queue_create("smtp", DISPATCH_QUEUE_SERIAL), ^(void){
        NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
        
        //  The mailman object is used for sending and receiving email.
        CkoMailMan *mailman = [[[CkoMailMan alloc] init] autorelease];
        
        //  Any string argument automatically begins the 30-day trial.
        BOOL success;
        success = [mailman UnlockComponent: @"JOODONIMAPMAILQ_rNZneBNT3J4w"];
        if (success != YES) {
            [MailSOUtil alert:@"Failed for an unknown reason.(Error 2)"];
            [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
                    [senderDelegate performSelector:@selector(sendFail) withObject:nil];
            return;
        }
        
        //  Set the SMTP server.
        NSString *serverstr= [[NSUserDefaults standardUserDefaults] objectForKey:@"MailSSvr"];
        mailman.SmtpHost=serverstr;
        if (serverstr==nil) {
            [MailSOUtil alert:@"SMTP Server settings, please"];
            [senderDelegate performSelector:@selector(sendFail) withObject:nil];
            return;
        }
        
        NSString *imapid=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyEmail"];
        NSString *imapPassword=[[NSUserDefaults standardUserDefaults] objectForKey:@"MyPassword"];
        if (imapid==nil) {
            imapid=@"imaptest@shiftone.co.kr";
            imapPassword=@"imaptest";
        }

        
        //  Set the SMTP login/password (if required)
        mailman.SmtpUsername = imapid;
        mailman.SmtpPassword = imapPassword;
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SmtpIsSSL"] isEqualToString:@"1"]) {
            mailman.SmtpSsl=YES;
        }
        else{
            mailman.SmtpSsl=NO;
        }
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MailSPort"]==nil) {
            mailman.SmtpPort=[NSNumber numberWithInt:465];
        }
        else{
            mailman.SmtpPort=[NSNumber numberWithInt: [[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSPort"] intValue]];
        }
        
        
        //  Create a new email object
        CkoEmail *email;
        if (forwardCkoEmail==nil) {
            email=[[[CkoEmail alloc] init] autorelease];
        }
        else{
            email=forwardCkoEmail;
        }
        
        email.Subject = subject;
        
        NSMutableString *modifiedTxt=[NSMutableString  stringWithString: [textV.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"]];
        if (preSnippet != nil) {
            [modifiedTxt appendString:preSnippet];
        }
        email.Body = modifiedTxt;
        [email AddHtmlAlternativeBody:modifiedTxt];
        email.From = imapid;
        [email setFromAddress:imapid];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MyName"]!=nil) {
            [email setFromName:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyName"]];
        }
        
#ifdef MAIL_WRITE_REMOVE_NAME
        NSArray *arr = [tfTo.text rgxMatchAllStringsWithPatten:@"[_A-Za-z0-9-_\\.]*@[A-Za-z0-9.]*"];
        NSMutableString *tmpStr=[NSMutableString string];
        for (NSString *email in arr) {
            [tmpStr appendFormat:@";%@",email];
        }
        [email AddMultipleTo:tmpStr];
#else
        [email AddMultipleTo:tfTo.text];
#endif
        
        [email AddMultipleCC:tfCc.text];
        
        int totalSize=0;
        //attachment
        for (MailAttachmentImage *imgObj in attachmentPics) {
            if (imgObj.selected==NO) {
                continue;
            }
            NSData *data=UIImagePNGRepresentation(imgObj.image);
            [email AddDataAttachment:imgObj.name data:data dataLen:[NSNumber numberWithInt:[data length]]];
            totalSize+=[data length];
            if (totalSize>1024*1024*10) {
                [MailSOUtil alert:@"The file size is greater than 10M"];
                //               [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
                        [senderDelegate performSelector:@selector(sendFail) withObject:nil];
                return;
            }
            //파일 저장//
            NSString *filePath=[MailSOUtil filePathWithName:imgObj.name];
            [data writeToFile:[MailSOUtil filePathWithName:filePath] atomically:YES];
        }
        for (NSString *fileName in addDocs){
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath= [documentsDirectory stringByAppendingFormat:[NSString stringWithFormat:@"/%@",fileName],nil];
            NSData *data=[NSData dataWithContentsOfFile:filePath];
            [email AddDataAttachment:fileName data:data dataLen:[NSNumber numberWithInt:[data length]]];
            totalSize+=[data length];
            if (totalSize>1024*1024*10) {
                [MailSOUtil alert:@"The file size is greater than 10M"];
                //                [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
                        [senderDelegate performSelector:@selector(sendFail) withObject:nil];
                return;
            }
        }
        [senderDelegate performSelector:@selector(sendSuccess) withObject:nil];

        [[MailManager manager] addNumOfNetworkThreadWithLog:@"SMTP"];
        
        //  To add more recipients, call AddTo, AddCC, or AddBcc once per recipient.
        //  Call SendEmail to connect to the SMTP server and send.
        //  The connection (i.e. session) to the SMTP server remains
        //  open so that subsequent SendEmail calls may use the
        //  same connection.
        [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) withObject:@"Sending mail." waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(sentMessageStart) withObject:nil waitUntilDone:NO];
        
        NSLog(@"MailSending : Attachment : %d ",[[email NumAttachments] intValue]);
        success = [mailman SendEmail: email];
        if (success != YES) {
            [MailSOUtil alert:@"Please reset the account"];
            NSLog([mailman LastErrorText],nil);
            //            [self performSelectorOnMainThread:@selector(sentMessageFinishedNoPop) withObject:nil waitUntilDone:NO];
            [[MailManager manager] removeNumOfNetworkThreadWithLog:@"SMTP"];
            return;
        }
        NSLog(@"MailSending END");
        
        //  Some SMTP servers do not actually send the email until
        //  the connection is closed.  In these cases, it is necessary to
        //  call CloseSmtpConnection for the mail to be  sent.
        //  Most SMTP servers send the email immediately, and it is
        //  not required to close the connection.  We'll close it here
        //  for the example:
        success = [mailman CloseSmtpConnection];
        if (success != YES) {
            [strOutput appendString: @"Connection to SMTP server not closed cleanly."];
            [strOutput appendString: @"\n"];
        }

        [strOutput appendFormat: @"Success sending mail\n[%@]",subject];
        [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) withObject:strOutput waitUntilDone:NO]; 
        [[MailManager manager] removeNumOfNetworkThreadWithLog:@"SMTP"];
        preSnippet=nil;
    });
}


-(void)pressRightBtn{
    [self pressSendB:nil];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    bgStatus=0;
    bgV.image=[UIImage imageNamed:@"m_write_bg@2x.png"];
    addBtn.hidden=NO;
    addCCBTN.hidden=NO;
    addPicBtn.hidden=NO;
    fileExistL.hidden=NO;
    tfTo.hidden=NO;
    tfCc.hidden=NO;

    textV.frame=CGRectMake(7, 196+4, 303, 200-4);
    subjectV.frame=CGRectMake(73, 159, 233, 31);
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    bgStatus=1;
    //제목 부분만 보이게
    textV.frame=CGRectMake(5, 44+44+4, 303, 198-44-4);
    subjectV.frame=CGRectMake(73, 44+4, 233, 31);
    bgV.image=[UIImage imageNamed:@"m_write02_bg@2x.png"];
    addBtn.hidden=YES;
    addCCBTN.hidden=YES;
    addPicBtn.hidden=YES;
    fileExistL.hidden=YES;
    tfTo.hidden=YES;
    tfCc.hidden=YES;
    return YES;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dayTimeStr=[[MailSODateTimeUtil stringForDate:[NSDate date] option:SODateStringFilenameType] retain];
        fileidx=1;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)drawSelf{
    [tfTo setText:preTo];

    NSLog(@"TfTO7: %@",self.tfTo.text);
    if (preTo==nil) {
        [tfTo setText:@""];
                NSLog(@"TfTO2: %@",self.tfTo.text);
    }
    [subjectV setText:preSubject];
//    [textV setText:preSnippet];
    
    [subjectV becomeFirstResponder];
    [textV setSelectedRange:NSMakeRange(0, 0)];
    [g_mailSubscriber clearList];       // <--------------
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [naviBar setTitle:@"Write e-mail" leftBtnType:MailLeftBtnTypeCancel rightBtnType:MailRightBtnTypeSend];
    [self drawSelf];
}


- (void)viewDidUnload
{
    [self setTfTo:nil];
    [self setTfCc:nil];
    [textV release];
    textV = nil;
    [subjectV release];
    subjectV = nil;
    [naviBar release];
    naviBar = nil;
    [portraitVs release];
    portraitVs = nil;
    [bgV release];
    bgV = nil;
    [fileExistL release];
    fileExistL = nil;
    [blackCoverV release];
    blackCoverV = nil;
    [addBtn release];
    addBtn = nil;
    [addCCBTN release];
    addCCBTN = nil;
    [addPicBtn release];
    addPicBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        for (UIView *view in portraitVs) {
            view.alpha=1;
        }
        bgV.alpha=1;
//        textV.frame=CGRectMake(7, 200, 303, 40);
        if (bgStatus) {
            [self textViewShouldBeginEditing:nil];
        }
        else{
            [self textFieldShouldBeginEditing:nil];
        }
    }
    else{
        for (UIView *view in portraitVs) {
            view.alpha=0;
        }
        bgV.alpha=0;
        textV.frame=CGRectMake(0, 0, 480, 138);
        [textV becomeFirstResponder]; // The horizontal screen to move the focus
    }
    return YES;
}

- (void)dealloc {
    [dayTimeStr release];
    [attachmentPics release];
    [tfTo release];
    [tfCc release];
    [textV release];
    [subjectV release];
    [naviBar release];
    [portraitVs release];
    [bgV release];

    [preSnippet release];
    [preTo release];
    [preSubject release];
    [fileExistL release];
    [blackCoverV release];
    [addBtn release];
    [addCCBTN release];
    [addPicBtn release];
    [super dealloc];
}

- (void)setG_MailSubscriber{
    [g_mailSubscriber clearList];

    if (tfTo.text!=nil && [tfTo.text isEqualToString:@""]==NO) {
        NSArray *senders=[tfTo.text componentsSeparatedByString:@";"];

        for (NSString *senderString in senders) {
            //Regular expression to extract only the email address
            if ([senderString length]==0) {
                continue;
            }
            NSString *name=nil;
            NSString *email=nil;

            if ([senderString hasSubString:@"<"]) {
                name=[senderString rgxMatchFirstStringWithPatten:@"^[^<]*"];
                NSString *tempemail=[senderString rgxMatchFirstStringWithPatten:@"<.*>$"];
                email=[tempemail substringWithRange:NSMakeRange(1, [tempemail length]-2)];

            }
            else{
                email=senderString;
            }

            if ([g_mailSubscriber findAdrs:email] == 0){
                if (name==nil || [name isEqualToString:@""] == YES) {
                    [g_mailSubscriber addTo:@"" :email];
                }
                else{
                    [g_mailSubscriber addTo:name :email];
                }
            }
        }
    }

    if (tfCc.text!=nil && [tfCc.text isEqualToString:@""] == NO) {
        NSArray *senders=[tfCc.text componentsSeparatedByString:@";"];
        for (NSString *senderString in senders) {
            //Regular expression to extract only the email address
            if ([senderString length]==0) {
                continue;
            }
            NSString *name=nil;
            NSString *email=nil;
            
            if ([senderString hasSubString:@"<"]) {
                name=[senderString rgxMatchFirstStringWithPatten:@"^[^<]*"];
                NSString *tempemail=[senderString rgxMatchFirstStringWithPatten:@"<.*>$"];
                email=[tempemail substringWithRange:NSMakeRange(1, [tempemail length]-2)];
                
            }
            else{
                email=senderString;
            }
            
            if ([g_mailSubscriber findAdrs:email] == 0){
                if (name==nil || [name isEqualToString:@""] == YES) {
                    [g_mailSubscriber addCc:@"" :email];
                }
                else{
                    [g_mailSubscriber addCc:name :email];
                }
            }
        }
    }
}

- (IBAction)onAddTo:(id)sender {
    [self setG_MailSubscriber];

    OrgaSelect *osv = [[OrgaSelect alloc] init];
    osv.curMode = 1;
    addState = 1;
    [self.navigationController pushViewController:osv animated:YES];
    [osv release];
}

- (IBAction)onAddCc:(id)sender {
    [self setG_MailSubscriber];

    OrgaSelect *osv = [[OrgaSelect alloc] init];
    osv.curMode = 2;
    addState = 2;
    [self.navigationController pushViewController:osv animated:YES];
    [osv release];
}


// on Picture Add 용 Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            break;
        }
        case 1:{
            MailSenderAttachmentV *dVC=[[MailSenderAttachmentV alloc] initWithNibName:@"MailSenderAttachmentV" bundle:nil];
            [self.navigationController pushViewController:dVC animated:YES];
            dVC.mailSender=self;
            [dVC release];
        }
            break;
        case 2:{
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType = 
            UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentModalViewController:imagePicker 
                                    animated:YES];
            [imagePicker release];

        }
            break;
        case 3:{
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType = 
            UIImagePickerControllerSourceTypeCamera;
            
            [self presentModalViewController:imagePicker 
                                    animated:YES];
            [imagePicker release];

        }
            break;
        default:{
        }
    }
}


- (IBAction)onPictureAdd:(id)sender {
    // Attachments, including those in the Document.
    addState = 4;
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"Source selection attachments" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Download File ", @" Camera Roll", @"Shooting", nil];
    [sheet showInView:self.view];
    [sheet release];
}

-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    if (attachmentPics==nil) {
        attachmentPics = [[NSMutableArray array] retain];
    }
    MailAttachmentImage *imageObj=[[[MailAttachmentImage alloc] init] autorelease];
    [attachmentPics addObject:imageObj];
    
    [imageObj setImage:[info objectForKey: UIImagePickerControllerOriginalImage]];
    [imageObj setName: [NSString stringWithFormat:@"picture%@%d.PNG",dayTimeStr,fileidx++]];
    imageObj.selected=YES;
    NSData *data=UIImagePNGRepresentation(imageObj.image);
    imageObj.size=[data length];

    [self dismissModalViewControllerAnimated:YES];
    [self setFileExistLText];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    switch (addState) {
        case 1:{
            tfTo.text=@"";
            int cnt = [g_mailSubscriber.nameTo count];
            for(int i=0;i<cnt;i++){
                NSMutableString *strTemp = [NSMutableString stringWithString:@""];
                if ([[[g_mailSubscriber nameTo] objectAtIndex:i] length]==0) {
                    [strTemp appendFormat:@"%@", [g_mailSubscriber.adrsTo objectAtIndex:i]];
                }
                else{
                    [strTemp appendFormat:@"%@<%@>", [g_mailSubscriber.nameTo objectAtIndex:i], [g_mailSubscriber.adrsTo  objectAtIndex:i]];
                }
                    if (tfTo.text==nil || [tfTo.text length]==0) {
                        tfTo.text = [NSString stringWithFormat:@"%@",strTemp];
                                NSLog(@"TfTO4: %@",self.tfTo.text);
                    }
                    else{
                        tfTo.text = [NSString stringWithFormat:@"%@;%@",tfTo.text,strTemp];
                                NSLog(@"TfTO5: %@",self.tfTo.text);
                }
            }
        }
            break;
        case 2:{
            tfCc.text=@"";
            int cnt = [g_mailSubscriber.nameCc count];
            
            for(int i=0;i<cnt;i++){
                NSMutableString *strTemp = [NSMutableString stringWithString:@""];
                if ([[[g_mailSubscriber nameCc] objectAtIndex:i] length]==0) {
                    [strTemp appendFormat:@"%@", [g_mailSubscriber.adrsCc objectAtIndex:i]];
                }
                else{
                    [strTemp appendFormat:@"%@<%@>", [g_mailSubscriber.nameCc objectAtIndex:i], [g_mailSubscriber.adrsCc  objectAtIndex:i]];
                }
                if (tfCc.text==nil || [tfCc.text length]==0) {
                    tfCc.text = [NSString stringWithFormat:@"%@",strTemp];
                }
                else{
                    tfCc.text = [NSString stringWithFormat:@"%@;%@",tfCc.text,strTemp];
                }
            }
        }
            
        default:
            break;
        }
}

@end
