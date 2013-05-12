//
//  MailTVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 20..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailTVC.h"
#import "MailSOUtil.h"
#import "MailDBManager.h"

@implementation MailTVC
@synthesize clipIconV;
@synthesize arrIcon;
@synthesize dateLabel;
@synthesize addrLabel;
@synthesize titleLabel;
@synthesize mail;
@synthesize cell;

- (id)initDefaultWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MailTVC" owner:self options:nil];
        cell = [(UIView*) [nib objectAtIndex:0] retain];
        [self addSubview:cell];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)setMail:(Mail *)_mail{
    if (_mail==nil) {
        [dateLabel setText:nil];
        [addrLabel setText:nil];
        [titleLabel setText:nil];
        [clipIconV setHidden:YES];
        [mail release];
        mail=nil;
        return;
    }
    [mail release];
    mail=[_mail retain];

    NSDate *date=[NSDate dateWithTimeIntervalSinceReferenceDate:[mail.dateSent doubleValue]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateLabel setText:[NSString stringWithString:[dateFormat stringFromDate:date]]];
    [titleLabel setText:mail.subject];
    if (mail.fromName!=nil && [mail.fromName isEqualToString:@""]==NO) {
        [addrLabel setText:[NSString stringWithFormat:@"from %@ <%@>",mail.fromName, mail.fromAddr]];
    }
    else{
        [addrLabel setText:[NSString stringWithFormat:@"from %@",mail.fromAddr]];
    }
    if (mail.numOfAttachment==0) {
        [clipIconV setHidden:YES];
    }
    else{
        [clipIconV setHidden:NO];
    }
    
    if (mail.read==0) {
        [titleLabel setTextColor:MailOrangeColor];
    }
    [dateFormat release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [mail setRead:YES];
        [mail updateReadToDB];
        cell.backgroundColor=MailOrangeColor;
        [dateLabel setTextColor:[UIColor whiteColor]];
        [addrLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [clipIconV setImage:[UIImage imageNamed:@"m_img_clip_sele"]];
        [arrIcon setImage:[UIImage imageNamed:@"m_img_arr_sele"]];
    }
    else{
        cell.backgroundColor=[UIColor clearColor];
        if (mail.read==0) {
            [dateLabel setTextColor:MailGrayColor];
            [addrLabel setTextColor:MailGrayColor];
            [titleLabel setTextColor:MailOrangeColor];
            [clipIconV setImage:[UIImage imageNamed:@"m_img_clip_on"]];
            
        }
        else{
            [dateLabel setTextColor:MailGrayColor];
            [addrLabel setTextColor:MailGrayColor];
            [titleLabel setTextColor:MailGrayColor];
            [clipIconV setImage:[UIImage imageNamed:@"m_img_clip_none"]];
        }
        [arrIcon setImage:[UIImage imageNamed:@"m_img_arr_none"]];
    }
}

- (void)dealloc {
    [mail   release];
    [cell release];
    [dateLabel release];
    [titleLabel release];
    [addrLabel release];
    [clipIconV release];
    [arrIcon release];
    [super dealloc];
}
@end
