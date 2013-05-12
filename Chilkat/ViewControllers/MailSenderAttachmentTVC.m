//
//  MailSenderAttachmentTVC.m
//  DzMail
//
//  Created by JD YANG on 12. 1. 12..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import "MailSenderAttachmentTVC.h"
#import "MailSenderAttachmentV.h"
@implementation MailSenderAttachmentTVC
@synthesize nameLabel;
@synthesize selectedBtn;
@synthesize delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [nameLabel release];
    [selectBtn release];
    [super dealloc];
}
- (IBAction)selectAttachment:(id)sender {
    selectedBtn=!selectedBtn;
    if (selectedBtn) {
        [selectBtn setImage:[UIImage imageNamed:@"m_img_checkbox_sele.png"] forState:UIControlStateNormal];
    }
    else {
        [selectBtn setImage:[UIImage imageNamed:@"m_img_checkbox_none.png"] forState:UIControlStateNormal];
    }
    [delegate attachmentCellIsSelected:self];
}
@end
