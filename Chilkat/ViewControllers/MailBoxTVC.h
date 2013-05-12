//
//  MailBoxTVC.h
//  DzGW
//
//  Created by JD YANG on 11. 12. 5..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailManager.h"

@interface MailBoxTVC : UITableViewCell{
    MailBox *mailBox;
    UIImageView *iconImageV;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *numOfUnSeenLabel;
    
    BOOL isSendMailMode;
    BOOL isEffect;
    float iconY;
}
-(void)drawThread;
-(void)setSendMailMode;
-(void)setMailBox:(MailBox *)_mailBox withEffect:(BOOL)effect;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property (retain, nonatomic) IBOutlet UIView *upperWhiteLine;
@property (nonatomic, assign) float iconY;
@property (nonatomic, retain) MailBox *mailBox;
@end
