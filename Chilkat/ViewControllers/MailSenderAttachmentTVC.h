//
//  MailSenderAttachmentTVC.h
//  DzMail
//
//  Created by JD YANG on 12. 1. 12..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MailSenderAttachmentV;

@interface MailSenderAttachmentTVC : UITableViewCell{
    MailSenderAttachmentV *delegate;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIButton *selectBtn;
    BOOL selectedBtn;
}

@property (nonatomic, retain) MailSenderAttachmentV *delegate;
@property (nonatomic, readonly) BOOL selectedBtn;
@property (nonatomic, readonly) UILabel *nameLabel;
- (IBAction)selectAttachment:(id)sender;

@end
