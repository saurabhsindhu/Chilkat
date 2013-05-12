//
//  MailAttachmentListV.h
//  DzMail
//
//  Created by JD YANG on 12. 1. 5..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailManager.h"
#import "MailNaviBarV.h"

@interface MailAttachmentListV : UIViewController <MailNaviBarVDelegate,UIDocumentInteractionControllerDelegate>{
    NSArray *filesizes;
    NSArray *filenames;
    IBOutlet MailNaviBarV *naviBar;
    UIAlertView *alertV;
    IBOutlet UIView *coverV;
}
@property (nonatomic, retain) Mail *mail;
@end
