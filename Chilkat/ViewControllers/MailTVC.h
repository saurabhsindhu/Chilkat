//
//  MailTVC.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 20..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailManager.h"

@interface MailTVC : UITableViewCell{
    Mail *mail;
}
@property (nonatomic, retain) IBOutlet UIImageView *clipIconV;
@property (nonatomic, retain) IBOutlet UIImageView *arrIcon;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *addrLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) UIView *cell;
@property (nonatomic, retain) Mail *mail;
-(void)setMail:(Mail *)_mail;
- (id)initDefaultWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end