//
//  MailVC.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 13..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailTypes.h"
#import "MailNaviBarV.h"
@class MailAttachmentV;


@interface MailVC : UIViewController <MailNaviBarVDelegate>{
    Mail *mail;
    IBOutlet UIView *detailV;
    IBOutlet UIActivityIndicatorView *indiV;
    IBOutlet MailNaviBarV *naviBar;
    IBOutlet UIWebView *snippetV;
    IBOutlet UILabel *sentAddr;
    NSMutableArray *mailAttachmentBtns;
    IBOutlet UIView *recipientV;
    IBOutlet UIView *ccV;
    IBOutlet UIView *sentDateV;
    IBOutlet UIView *subjectV;
    IBOutlet UILabel *subjectLabel;
    IBOutlet UILabel *sentDateLabel;
    
    IBOutlet UIImageView *dotLineImageV;
    
    IBOutlet UIView *attachmentV;
    IBOutlet UILabel *attachmentFileSizeL;
    IBOutlet UILabel *attachmentNameL;
    IBOutlet UIImageView *attachmentImgV;
    BOOL showDetail;
    float snippetVDefaultHeight;
    BOOL snippetRequested;
}
@property (retain) Mail *mail;
@property (nonatomic, readonly) UILabel *attachmentNameL;
//-(BOOL)mailAttachmentDownload:(MailAttachmentV*)attachmentV;
-(BOOL)deleteMail;
- (IBAction)pressDelete:(id)sender;
- (IBAction)pressReply:(id)sender;
- (IBAction)pressForward:(id)sender;
- (IBAction)pressMailMoveB:(id)sender;
- (void)detailVSetup;
- (void)drawMail;
@end