///Users/jdyang/dev/DzMail/DzMail/Mail/ViewControllers/MailBoxCopyTVC.m
//  MailBoxCopyTVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 17..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailBoxCopyTVC.h"
#import "MailManager.h"
#import "MailSOUtil.h"
#import "MailImageUtil.h"
#import "MailConfig.h"


@implementation MailBoxCopyTVC
@synthesize mailBox;
@synthesize mail;
@synthesize delegate;

-(void)setMailBox:(MailBox *)_mailBox{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    mailBox=[_mailBox retain];
    nameLabel.text=mailBox.name;
    //set indentation level
    int level=[mailBox level];
    [MailSOUtil view:nameLabel changeX:nameLabel.frame.origin.x+MailOneIndentWidth*level];
    if (level>1) {
        if (iconImageV==nil) {
            iconImageV=[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"m_img_sub_none@2x"]];
            [self addSubview:iconImageV];
            [iconImageV release];
        }
        iconImageV.image=[UIImage imageNamed:@"m_img_sub_none@2x"];
        [iconImageV autoHalfFrame];
        float newX=nameLabel.frame.origin.x-7;
        [MailSOUtil view:nameLabel changeX:newX];
        [iconImageV setCenter:CGPointMake(7+nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
    }
    else if (level==1){ //level ==0 , ///////'''''''''''''
        if (iconImageV==nil) {
            iconImageV=[[UIImageView alloc] init];
            [self addSubview:iconImageV];
            [iconImageV release];
        }
        NSString *boxName=mailBox.name;
        if ([boxName isEqualToString:Mail__SentMessageBoxName__]) {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail03_none@2x.png"];
        }
        else if ([boxName isEqualToString:Mail__DeletedMessagesBoxName__]) {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail04_none@2x.png"];
        }
        else if ([boxName isEqualToString:[MailManager manager].inboxReference]) {
            UIImage *img=[UIImage imageNamed:@"m_icon_mail02_none@2x.png"];
            iconImageV.image=img;
        }
        else if ([boxName isEqualToString:Mail__DeletedMessagesBoxName__]) {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail04_none@2x.png"];
        }
        else if ([boxName isEqualToString:Mail__SpamMessageBoxName__]) {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail05_none@2x.png"];
        }
        else {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail06_none@2x.png"];
        }
        [iconImageV autoHalfFrame];
        [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
    }
    [nameLabel setTextColor:MailGrayColor];
}

-(MailBox*)mailBox{
    return mailBox;
}

-(void)pop{
    [delegate pressLeftBtn];
    [delegate.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mailBoxSelect:(id)sender {
    MailBox *oldMailBox = [[MailManager manager].mailBoxDic objectForKey:mail.mailBoxReference];
    [[oldMailBox mutableArrayValueForKey:@"mailArray"] removeObject:mail];

    [[MailManager manager] moveMail:mail toMailBox:mailBox];
    [self pop];
}
/*
- (IBAction)mailBoxSelect:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"메일"
                                                    message:@"메일 이동 중입니다"
                                                   delegate:nil 
                                          cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *indiV=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [alert addSubview:indiV];
    indiV.frame=CGRectMake(135, 80, indiV.frame.size.width, indiV.frame.size.height);
    [indiV startAnimating];

    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];            

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        if (mail==nil || mail.uid == 0) {
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert release];
            [MailSOUtil alert:@"메일이 없습니다"];
            [self performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
            return;
        }
        if (mailBox==nil) {
            [alert removeFromSuperview];
            [alert release];
            [MailSOUtil alert:@"메일박스가 없습니다"];

            [self performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
            return;
        }
        if ([[MailManager manager] moveMail:mail toMailBox:mailBox]){
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert release];
            [MailSOUtil alert:@"메일 이동 성공"];
            [self performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
        }
        else{
            [alert removeFromSuperview];
            [alert release];
            [MailSOUtil alert:@"메일 이동 실패"];
            [self performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
        }
    });
}
*/
-(void)dealloc{
    [mailBox release];
    [mail release];
    [super dealloc];
}



@end