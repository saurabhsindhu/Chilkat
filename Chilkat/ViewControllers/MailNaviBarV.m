//
//  MailNaviBarVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailNaviBarV.h"

@implementation MailNaviBarV
@synthesize titleLabel;

-(id)initWithCoder:(NSCoder *)aDecoder{
    //load from nib
    self=[super initWithCoder:aDecoder];
    if (self) {
        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"MailNaviBarV" owner:self options:nil]; 
        [self addSubview:[xib objectAtIndex:0]];
    }
    return self;
}


-(void)setTitle:(NSString*)title leftBtnType:(MailLeftBtnType)_leftBtnType rightBtnType:(MailRightBtnType)_rightBtnType{
        rightBtnType = _rightBtnType;
        leftBtnType = _leftBtnType;
    self.titleLabel.text=title;
        
        switch (rightBtnType) {
            case MailRightBtnTypeDone:
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_done_none"] forState:UIControlStateNormal];
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_done_sele"] forState:UIControlStateHighlighted];
                break;
            case MailRightBtnTypeHome:
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_home_none"] forState:UIControlStateNormal];
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_home_sele"] forState:UIControlStateHighlighted];
                break;
            case MailRightBtnTypeSave:
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_save_none"] forState:UIControlStateNormal];
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_save_sele"] forState:UIControlStateHighlighted];
                break;
            case MailRightBtnTypeSend:
            default:
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_send_none"] forState:UIControlStateNormal];
                [rightBtn setImage:[UIImage imageNamed:@"m_btn_send_sele"] forState:UIControlStateHighlighted];
                break;
        }
        switch (leftBtnType) {
            case MailLeftBtnTypeBack:
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_back_none"] forState:UIControlStateNormal];
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_back_sele"] forState:UIControlStateHighlighted];
                break;
            case MailLeftBtnTypeCancel:
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_cancel_none"] forState:UIControlStateNormal];
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_cancel_sele"] forState:UIControlStateHighlighted];
                break;
            case MailLeftBtnTypeClose:
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_close_none"] forState:UIControlStateNormal];
                [leftBtn setImage:[UIImage imageNamed:@"m_btn_close_sele"] forState:UIControlStateHighlighted];
                break;
        }
}


- (IBAction)pressRightB:(id)sender {
    [delegate pressRightBtn];
}

- (IBAction)pressLeftB:(id)sender {
    [delegate pressLeftBtn];
}



- (void)dealloc {
    [titleLabel release];
    [super dealloc];
}
@end
