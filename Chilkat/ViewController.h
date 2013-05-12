//
//  ViewController.h
//  Chilkat
//
//  Created by saurabh sindhu on 11/05/13.
//  Copyright (c) 2013 saurabh sindhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *tfMailSvr;
@property (retain, nonatomic) IBOutlet UITextField *tfMailPort;
@property (retain, nonatomic) IBOutlet UITextField *tfMailAdrs;
@property (retain, nonatomic) IBOutlet UITextField *tfMailPw;
@property (retain, nonatomic) IBOutlet UITextField *tfName;
@property (retain, nonatomic) IBOutlet UITextField *tfDelMonth;
@property (retain, nonatomic) IBOutlet UILabel *lbNotReadCnt;
@property (retain, nonatomic) IBOutlet UIButton *resetBtn;

- (IBAction)onSave;
- (IBAction)onMail;


@end
