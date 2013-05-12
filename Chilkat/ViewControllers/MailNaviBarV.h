//
//  MailNaviBarVC.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum _MailLeftBtnType {
    MailLeftBtnTypeBack,
    MailLeftBtnTypeCancel,
    MailLeftBtnTypeClose,
}MailLeftBtnType;

typedef enum _MailRightBtnType {
    MailRightBtnTypeHome,
    MailRightBtnTypeDone,
    MailRightBtnTypeSave,
    MailRightBtnTypeSend,
}MailRightBtnType;

@protocol MailNaviBarVDelegate <NSObject>
@required
-(void)pressLeftBtn;
-(void)pressRightBtn;
@end

@interface MailNaviBarV : UIView{
    MailRightBtnType rightBtnType;
    MailLeftBtnType  leftBtnType;
    IBOutlet UIButton *rightBtn;
    IBOutlet UIButton *leftBtn;
    IBOutlet id  <MailNaviBarVDelegate> delegate;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

-(void)setTitle:(NSString*)title leftBtnType:(MailLeftBtnType)leftBtnType rightBtnType:(MailRightBtnType) rightBtnType;

@end
