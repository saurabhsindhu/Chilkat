//
//  MailVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 13..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailVC.h"
#import "MailSOUtil.h"
#import "MailAttachmentV.h"
#import "MailManager.h"
#import "MailBoxListCopyVC.h"
#import "MailSender.h"
#import "MailAttachmentListV.h"
#import "MailConfig.h"
#import "TKAlertCenter.h"

@implementation MailVC
@synthesize mail;
@synthesize attachmentNameL;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)pressMailMoveB:(id)sender {
    MailBoxListCopyVC *copyVC;
    copyVC=[[MailBoxListCopyVC   alloc] initWithNibName:@"MailRoot" bundle:nil];
    copyVC.mailToCopy=mail;
    [self.navigationController pushViewController:copyVC animated:YES];
    [copyVC release];
}



-(void)drawLoad{
    if (mail.isSnippetEmpty) {
        [indiV stopAnimating];
        NSLog(@"indicator Stop (drawLoad)");
    }

    if (mail.snippet!=nil && [mail.snippet isEqualToString:@""]==NO) {
        [snippetV loadHTMLString:mail.snippet baseURL:nil];
    }
    
    if ([mail.attachments count]==0) {
        [attachmentV setHidden:YES];
        [dotLineImageV setHidden:YES];
    }
 ///MailPhone
    
    else {
        [attachmentV setHidden:NO];
        [dotLineImageV setHidden:NO];
        
        UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressAttachmentV)];
        [attachmentV addGestureRecognizer:recognizer];
        [recognizer release];
        
                
        if ([mail.attachments count]==1) {
            MailAttachment *attachment=[mail.attachments objectAtIndex:0];
            attachmentNameL.text=attachment.fileName;
            attachmentFileSizeL.text=[NSString stringWithFormat:@"%dKB",attachment.fileSize/1024];
        }
        else if ([mail.attachments count] > 1) {
            MailAttachment *attachment=[mail.attachments objectAtIndex:0];
            attachmentNameL.text=[NSString stringWithFormat:@"%@ 외 %d개",attachment.fileName, [[mail attachments] count]-1 ];
            attachmentFileSizeL.text=nil;
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (mail.snippet!=nil && [mail.snippet isEqualToString:@""]==NO) {
        [indiV stopAnimating];
    }
    NSLog(@"indicator Stop (webViewDidFinishLoad)");
}

- (float)drawReceiver_SentDate:(float)height{
    [MailSOUtil view:sentDateV changeY:height];
    height+=sentDateV.frame.size.height;
    return height;
}

-(void)drawReceiver{
    int numOfRecipient=[mail.receiver.recipientAddresses count];
    int numOfCC=[mail.receiver.ccNames count];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [MailSOUtil view:recipientV changeHeight:recipientV.frame.size.height + (numOfRecipient - 1) * 18];
        [MailSOUtil view:ccV changeHeight:ccV.frame.size.height + (numOfCC - 1) * 18];
    }
    else {
        [MailSOUtil view:recipientV changeHeight:35 + (numOfRecipient - 1) * 18];
        [MailSOUtil view:ccV changeHeight:35 + (numOfCC - 1) * 18];
    }
    if (numOfCC==0) {
        [MailSOUtil view:ccV changeHeight:0];
    }
    if (numOfRecipient==0) {
        [MailSOUtil view:recipientV changeHeight:0];
    }
    
    
    for (int i=0; i<numOfRecipient; i++) {
        UILabel *addrString=[[[UILabel alloc] initWithFrame:CGRectMake(68, 10+18*i, 200, 16)] autorelease];
        addrString.textColor=MailGrayColor;
        if ([[mail.receiver.recipientNames objectAtIndex:i] isEqualToString:@""]) {
            addrString.text=[NSString stringWithFormat:@"%@", [ mail.receiver.recipientAddresses objectAtIndex:i]];
        }
        else{
            addrString.text=[NSString stringWithFormat:@"%@ <%@>", [ mail.receiver.recipientNames objectAtIndex:i],
                             [ mail.receiver.recipientAddresses objectAtIndex:i]];
        }

        [recipientV addSubview:addrString];
        [addrString setBackgroundColor:[UIColor clearColor]];
        [addrString setFont:[UIFont systemFontOfSize:13]];
    }
    for ( int i=0 ; i<numOfCC ; i++ ){
        UILabel *addrString=[[[UILabel alloc] initWithFrame:CGRectMake(68, 10+18*i, 200, 16)] autorelease];
        if ([[mail.receiver.ccNames objectAtIndex:i] isEqualToString:@""]) {
            addrString.text=[NSString stringWithFormat:@"%@", [ mail.receiver.ccAddresses objectAtIndex:i]];
        }
        else{
            addrString.text=[NSString stringWithFormat:@"%@ <%@>", [ mail.receiver.ccNames objectAtIndex:i],
                             [ mail.receiver.ccAddresses objectAtIndex:i]];
        }
        [ccV addSubview:addrString];
        [addrString setBackgroundColor:[UIColor clearColor]];
        [addrString setFont:[UIFont systemFontOfSize:13]];
        addrString.textColor=MailGrayColor;
    }
    float height=0;
    [MailSOUtil view:recipientV changeY:height];
    height+=recipientV.frame.size.height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        height=[self drawReceiver_SentDate:height];
    }
    else {
        [MailSOUtil view:ccV changeY:height];
        height+=ccV.frame.size.height;
        [MailSOUtil view:sentDateV changeY:height];
        height+=sentDateV.frame.size.height;
    }
    [MailSOUtil view:subjectV changeY:height];
}

- (IBAction)pressShowDetail:(id)sender {
    showDetail= !showDetail;
    [self setSnippetDefaultHeight];
    if (showDetail) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            detailV.hidden=NO;
        }

        float height=0;
        height+=recipientV.frame.size.height;
        height+=ccV.frame.size.height;
        height+=sentDateV.frame.size.height;
        height+=subjectV.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^(void){
            detailV.alpha=1;
            [MailSOUtil view:detailV changeHeight:height];
            [MailSOUtil view:snippetV changeY:110+height];
        }completion:^(BOOL finished){
        }];
    }
    else {
        [MailSOUtil view:snippetV changeHeight:snippetVDefaultHeight];
        [UIView animateWithDuration:0.3 animations:^(void){
        [MailSOUtil view:snippetV changeY:110];
            detailV.alpha=0;
        }];
    }
}

/*
-(BOOL)mailAttachmentDownload:(MailAttachmentV*)attachmentV{
    if ([[MailManager manager] downloadAndExecuteAttachment:mail Index:attachmentV.tag InView:self.view]) {
        return YES;
    }
    else{
        [MailSOUtil alert:@"첨부 파일을 연결할 프로그램이 없습니다"];
        return NO;
    }
}
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"snippet"]) {
        [self performSelectorOnMainThread:@selector(drawLoad) withObject:nil waitUntilDone:NO];
    }
    else if ([keyPath isEqualToString:@"attachments"]) {
        [self performSelectorOnMainThread:@selector(drawLoad) withObject:nil waitUntilDone:NO];
    }
    else if ([keyPath isEqualToString:@"receiver"]){
        [self performSelectorOnMainThread:@selector(drawReceiver) withObject:nil waitUntilDone:NO];
    }
/*    if ([keyPath isEqualToString:@"isSnippetEmpty"]) {
        [self performSelectorOnMainThread:@selector(drawLoad) withObject:nil waitUntilDone:NO];
    }
 */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)pressAttachmentV{
    MailAttachmentListV *listV=[[MailAttachmentListV alloc] initWithNibName:@"MailAttachmentListV" bundle:nil];
    [attachmentV setBackgroundColor:MailOrangeColor];
    
    attachmentFileSizeL.textColor=[UIColor whiteColor];
    attachmentNameL.textColor=[UIColor whiteColor];
    attachmentImgV.image=[UIImage imageNamed:@"m_img_clip_sele_s"];
    listV.mail=mail;
    [self.navigationController pushViewController:listV animated:YES];
    [listV release];
}

- (void)releaseAttachmentV{
}


-(Mail*)mail{
    return mail;
}

- (void)setSnippetDefaultHeight{
    if (mail.numOfAttachment==0) {
        snippetVDefaultHeight=348;
    }
    else{
        snippetVDefaultHeight=309;
    }
}

- (void)drawMail{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        detailV.hidden=YES;
    }
    else {
        detailV.hidden=NO;
        detailV.alpha = 0;
    }

    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date=[NSDate dateWithTimeIntervalSinceReferenceDate:[mail.dateSent longValue]];
    [sentDateLabel setText:[NSString stringWithString:[dateFormat stringFromDate:date]]];
    
    [subjectLabel setText:mail.subject];
    if (mail.fromName==nil || [mail.fromName isEqualToString:@""]) {
        if (mail.fromAddr==nil) {
            [sentAddr setText:@""];
        }
        else{
            [sentAddr setText:[NSString stringWithFormat:@"%@", mail.fromAddr]];
        }
    }
    else{
        [sentAddr setText:[NSString stringWithFormat:@"%@ <%@>",  mail.fromName, mail.fromAddr]];
    }
    [snippetV setBackgroundColor:[UIColor clearColor]];
    [snippetV setOpaque:NO];
    
    [self setSnippetDefaultHeight];
    [MailSOUtil view:snippetV changeHeight:snippetVDefaultHeight];
    if (mail.snippet!=nil && [mail.snippet isEqualToString:@""]==NO) {
        [indiV stopAnimating];
        NSLog(@"indicator Stop (drawMail)");

        //   [snippetV loadHTMLString:[snippetV stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 5.0;"] baseURL:nil];
        
    }
    [self releaseAttachmentV];
}

-(void)setMail:(Mail *)_mail{
    snippetRequested=NO;
    [snippetV stopLoading];
    @synchronized(self){
        if (mail!=nil) {
            [mail removeObserver:self forKeyPath:@"snippet"];
            [mail removeObserver:self forKeyPath:@"isSnippetEmpty"];
            [mail removeObserver:self forKeyPath:@"receiver"];
            [mail removeObserver:self forKeyPath:@"attachments"];

            [mail release];
            mail=nil;
        }
        
        if (_mail==nil) {
            [sentAddr setText:@""];
            [sentDateLabel setText:@""];
            [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                [indiV stopAnimating];
                NSLog(@"indicator Stop (setMail-OpQueue)");
                [snippetV loadHTMLString:@"" baseURL:nil];
                [attachmentFileSizeL setText:@""];
                [attachmentNameL setText:@""];
            }]];
            return;
        }
        mail=[_mail retain];
        [snippetV loadHTMLString:nil baseURL:nil];
        [indiV startAnimating];

/*        if (mail.snippet==nil || [mail.snippet isEqualToString:@""]) {
            NSLog(@"indicator Start");
        }
 */
        [self performSelectorOnMainThread:@selector(drawReceiver) withObject:nil waitUntilDone:NO];
        
        if (mail.snippet==nil || [mail.snippet isEqualToString:@""] || [mail.snippet isEqualToString:[NSString stringWithFormat:@"%@%@",MAIL__PlainToHtmlPre, MAIL__PlainToHtmlPost]]) {
            if (snippetRequested==NO) {
                snippetRequested=YES;
                [mail requestUpdateSnippetFromServer];
            }
        }
        [mail addObserver:self forKeyPath:@"snippet" options:NSKeyValueObservingOptionInitial context:nil];
        [mail addObserver:self forKeyPath:@"attachments" options:NSKeyValueObservingOptionInitial context:nil];
        [mail addObserver:self forKeyPath:@"isSnippetEmpty" options:NSKeyValueObservingOptionInitial context:nil];
        [mail addObserver:self forKeyPath:@"receiver" options:0 context:nil];
        
        [[MailManager manager] setReceiverWithMail:mail];
        
        [self performSelectorOnMainThread:@selector(drawMail) withObject:nil waitUntilDone:NO];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue]>5.0) {
        indiV.color=[UIColor brownColor];
    }
//    [snippetV setScalesPageToFit:SnippetV_ScaleToFit];
    if (mail.snippet==nil || [mail.snippet isEqualToString:@""] || [mail.snippet isEqualToString:[NSString stringWithFormat:@"%@%@",MAIL__PlainToHtmlPre, MAIL__PlainToHtmlPost]]) {
        if (snippetRequested==NO) {
            snippetRequested=YES;
            [mail requestUpdateSnippetFromServer];
        }
    }
    
    [naviBar setTitle:@"메일 읽기" leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeHome];
    
    //화면 재설정
    [self detailVSetup];
    if (mail!=nil) {
        [self setMail:mail];
    }
}

- (void)detailVSetup{
    
    [detailV addSubview:sentDateV];
    [detailV addSubview:recipientV];
    [detailV addSubview:ccV];
    [detailV addSubview:subjectV];
     
    detailV.clipsToBounds=YES;
}

-(BOOL)deleteMail{
    if ([[MailManager manager] deleteMail:mail]) {
        MailBox *mailBox=[[MailManager manager].mailBoxDic objectForKey:mail.mailBoxReference];
        [[mailBox mutableArrayValueForKey:@"mailArray"] removeObject:mail];
        //    [MailSOUtil alert:@"메일이 삭제되었습니다"];
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

-(IBAction)pressDelete:(id)sender{
    [self deleteMail];
}



- (IBAction)pressReply:(id)sender {
    MailSender *dVC=[[MailSender alloc] initWithNibName:@"MailSender" bundle:nil];
    [dVC setSubject:[NSString stringWithFormat:@"Re: %@",mail.subject]];
    [dVC setTo:mail.fromAddr];
    [self.navigationController pushViewController:dVC animated:YES];
    [dVC release];
}

- (IBAction)pressForward:(id)sender {
    MailSender *dVC=[[MailSender alloc] initWithNibName:@"MailSender" bundle:nil];
    [dVC setSubject:[NSString stringWithFormat:@"Fw: %@",mail.subject]];
    [dVC setSnippet:mail.snippet];
    if (!(mail.attachments == nil || [mail.attachments count]==0 ) ) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"아이폰에서는 포워딩시 첨부파일을 포합하지 않습니다"];
    }
    [self.navigationController pushViewController:dVC animated:YES];
    [dVC release];
}


- (void)viewDidUnload
{
    [snippetV release];
    snippetV = nil;
    [sentAddr release];
    sentAddr = nil;
    [recipientV release];
    recipientV = nil;
    [ccV release];
    ccV = nil;
    [subjectV release];
    subjectV = nil;
    [sentDateV release];
    sentDateV = nil;
    [subjectLabel release];
    subjectLabel = nil;
    [naviBar release];
    naviBar = nil;
    [dotLineImageV release];
    dotLineImageV = nil;
    [indiV release];
    indiV = nil;
    [attachmentNameL release];
    attachmentNameL = nil;
    [attachmentFileSizeL release];
    attachmentFileSizeL = nil;
    [attachmentV release];
    attachmentV = nil;
    [attachmentImgV release];
    attachmentImgV = nil;
    [detailV release];
    detailV = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)pressLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressRightBtn{
        [[MailManager manager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    if ([snippetV isLoading]) {
        [snippetV stopLoading];
    }
    [mail removeObserver:self forKeyPath:@"snippet"];
    [mail removeObserver:self forKeyPath:@"receiver"];
    [mail removeObserver:self forKeyPath:@"attachments"];
    [mail removeObserver:self forKeyPath:@"isSnippetEmpty"];
    [mail release];
    mail=nil;
    [snippetV setDelegate:nil];

    [snippetV release];
    [sentAddr release];
    [recipientV release];
    [ccV release];
    [subjectV release];
    [sentDateV release];
    [subjectLabel release];
    [naviBar release];
    [dotLineImageV release];
    [indiV release];
    [attachmentNameL release];
    [attachmentFileSizeL release];
    [attachmentV release];
    [attachmentImgV release];
    [detailV release];
    [super dealloc];
}
@end
