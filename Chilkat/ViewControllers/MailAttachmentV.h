//
//  MailAttachmentV.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 15..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#if 0

#import <UIKit/UIKit.h>
#import "MailVC.h"

@interface MailAttachmentV : UIView{
    int currentState;
    IBOutlet UIImageView *iconImageV;
    IBOutlet UIButton *nameBtn;
    IBOutlet UIButton *sizeBtn;
}

@property (retain) MailVC *delegate;
@property (copy)  NSString *name;
@property (copy)  NSString *size;

- (IBAction)touchDown:(id)sender;
- (IBAction)touchUp:(id)sender;

@end
#endif
