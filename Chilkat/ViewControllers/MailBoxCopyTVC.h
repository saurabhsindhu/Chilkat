//
//  MailBoxCopyTVC.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 17..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailBoxTVC.h"
#import "MailManager.h"
#import "MailBoxListCopyVC.h"
@interface MailBoxCopyTVC : UITableViewCell{
    MailBox *mailBox;
    Mail* mail;
    UIImageView *iconImageV;
    IBOutlet UILabel *nameLabel;
    MailBoxListCopyVC *delegate;
}
- (IBAction)mailBoxSelect:(id)sender;

@property (nonatomic, retain) Mail* mail;
@property (nonatomic, retain) MailBox *mailBox;
@property (nonatomic, assign) MailBoxListCopyVC *delegate;;
@end