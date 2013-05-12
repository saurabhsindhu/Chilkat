//
//  MailBoxTVC.m
//  DzGW
//
//  Created by JD YANG on 11. 12. 5..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailBoxTVC.h"
#import "MailSOUtil.h"
#import "MailImageUtil.h"
#import "MailConfig.h"

@implementation MailBoxTVC
@synthesize mailBox;
@synthesize upperWhiteLine;
@synthesize iconY;

-(void)drawThread{
    if (mailBox.numOfUnSeen==0 || isEffect==NO) {
//        [numOfUnSeenLabel setText:nil];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [self setSelected:[self isSelected] animated:NO];
        }
        return;
    }
    else{
        [numOfUnSeenLabel setText:[NSString stringWithFormat:@"%d",mailBox.numOfUnSeen]];
        [nameLabel setTextColor:[UIColor colorWithRed:255/255.0f green:104/255.0f blue:0/255.0f alpha:1]];
        [numOfUnSeenLabel setTextColor:[UIColor colorWithRed:255/255.0f green:104/255.0f blue:0/255.0f alpha:1]];
    }
    [self setSelected:[self isSelected] animated:NO];
    [self setNeedsDisplay];
}

-(void)setSendMailMode{
    [MailSOUtil view:nameLabel changeX:nameLabel.frame.origin.x+MailOneIndentWidth*1];
    iconImageV=[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"m_icon_mail01_none@2x"]];
    [self addSubview:iconImageV];
    [iconImageV release];
    [iconImageV autoHalfFrame];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
    if (iconY==0) {
        [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 34)];
    }
    else{
        [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, iconY)];
    }
    }else {
        [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
    }
    isSendMailMode=YES;
    nameLabel.text=@"메일 쓰기";
}
-(void)setMailBox:(MailBox *)_mailBox withEffect:(BOOL)effect{
    isEffect=effect;
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (iconY==0) {
            [iconImageV setCenter:CGPointMake(7+nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 34)];
        }
        else {
            [iconImageV setCenter:CGPointMake(7+nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, iconY)];
        }
        }
        else {
            [iconImageV setCenter:CGPointMake(7+nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
        }
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (iconY==0) {
            [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 34)];
        }
        else{
            [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, iconY)];
        }
        }
        else {
            [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
        }
    }
    [mailBox addObserver:self forKeyPath:@"numOfUnSeen" options:0 context:nil];
    [self performSelectorOnMainThread:@selector(drawThread) withObject:nil waitUntilDone:NO];
}

-(void)setMailBox:(MailBox *)_mailBox{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
    self.upperWhiteLine.hidden=YES;
    }

    [self setMailBox:_mailBox withEffect:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *view=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 51)] autorelease];
        view.backgroundColor=MailOrangeColor;
        [self setSelectedBackgroundView:view];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        iconImageV.image=[UIImage imageNamed:@"m_img_sub_none@2x"];
    }
    return self;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self performSelectorOnMainThread:@selector(drawThread) withObject:nil waitUntilDone:NO];

}

-(MailBox*)mailBox{
    return mailBox;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        [super setSelected:selected animated:animated];
        self.backgroundColor=MailOrangeColor;
        nameLabel.textColor=[UIColor whiteColor];
        numOfUnSeenLabel.textColor=[UIColor whiteColor];
        if (isSendMailMode) {
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail01_sele@2x.png"];
            return;
        }
        
        int level=[mailBox level];
        if (level>1) {
            iconImageV.image=[UIImage imageNamed:@"m_img_sub_sele@2x"];
        }
        else if (level==1){ //level ==0 , ///////'''''''''''''
            NSString *boxName=mailBox.name;
            if ([boxName isEqualToString:Mail__SentMessageBoxName__]) {
                iconImageV.image=[UIImage imageNamed:@"m_icon_mail03_sele@2x.png"];
            }
            else if ([boxName isEqualToString:Mail__DeletedMessagesBoxName__]) {
                iconImageV.image=[UIImage imageNamed:@"m_icon_mail04_sele@2x.png"];
            }
            else if ([boxName isEqualToString:[MailManager manager].inboxReference]) {
                UIImage *img=[UIImage imageNamed:@"m_icon_mail02_sele@2x.png"];
                iconImageV.image=img;
            }
            else if ([boxName isEqualToString:Mail__DeletedMessagesBoxName__]) {
                iconImageV.image=[UIImage imageNamed:@"m_icon_mail04_sele@2x.png"];
            }
            else if ([boxName isEqualToString:Mail__SpamMessageBoxName__]) {
                iconImageV.image=[UIImage imageNamed:@"m_icon_mail05_sele@2x.png"];
            }
            else {
                iconImageV.image=[UIImage imageNamed:@"m_icon_mail06_sele@2x.png"];
            }
            [iconImageV autoHalfFrame];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            if (iconY==0) {
                [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 34)];
            }
            else{
                [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, iconY)];
            }
            }
            else {
                [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
            }
        }        
    }
    else{
        int level=[mailBox level];
        self.backgroundColor=[UIColor clearColor];
        nameLabel.textColor=MailGrayColor;
        if (mailBox.numOfUnSeen!=0) {
            [numOfUnSeenLabel setTextColor:MailOrangeColor];
            [nameLabel setTextColor:MailOrangeColor];
        }
        else{
            [numOfUnSeenLabel setTextColor:MailGrayColor];
            [nameLabel setTextColor:MailGrayColor];
        }

        if (isSendMailMode) {
            [self drawThread];
            iconImageV.image=[UIImage imageNamed:@"m_icon_mail01_none@2x.png"];
            return;
        }

        if (level>1) {
            iconImageV.image=[UIImage imageNamed:@"m_img_sub_none@2x"];
        }

         if (level==1){ //level ==0 , ///////'''''''''''''
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
             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
             if (iconY==0) {
                 [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 34)];
             }
             else{
                 [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, iconY)];
             }
             }
             else {
                 [iconImageV setCenter:CGPointMake(nameLabel.frame.origin.x-DISTANCE_MAIL_IMAGE, 25)];
             }
        }
    }
}

- (void)dealloc{
    [mailBox removeObserver:self forKeyPath:@"numOfUnSeen"];
    [mailBox release];
    [nameLabel release];
    [numOfUnSeenLabel release];
    [upperWhiteLine release];
    [super dealloc];
}

@end
