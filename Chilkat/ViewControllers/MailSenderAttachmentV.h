//
//  MailSenderAttachmentV.h
//  DzMail
//
//  Created by JD YANG on 12. 1. 11..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailNaviBarV.h"
#import "MailSender.h"
#import "MailSenderAttachmentTVC.h"
@interface MailSenderAttachmentV : UIViewController<MailNaviBarVDelegate>{
    IBOutlet UITableView *tableV;
    IBOutlet MailNaviBarV *naviBar;
    NSMutableSet *addDocSet;
    NSArray *documentDocs;
}
@property (nonatomic, retain)     MailSender *mailSender;
-(void)attachmentCellIsSelected:(MailSenderAttachmentTVC*)cell;
@end
