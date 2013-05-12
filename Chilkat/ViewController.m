//
//  ViewController.m
//  Chilkat
//
//  Created by saurabh sindhu on 11/05/13.
//  Copyright (c) 2013 saurabh sindhu. All rights reserved.
//

#import "ViewController.h"
#import "MailRoot.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tfMailSvr;
@synthesize tfMailPort;
@synthesize tfMailAdrs;
@synthesize tfMailPw;
@synthesize tfName;
@synthesize tfDelMonth;
@synthesize lbNotReadCnt;
@synthesize resetBtn;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *dflt = [NSUserDefaults standardUserDefaults];
    
	tfMailSvr.text = [dflt objectForKey:@"MailSvr"];
    tfMailPort.text = [dflt objectForKey:@"MailPort"];
    tfMailAdrs.text = [dflt objectForKey:@"MyEmail"];
    tfMailPw.text = [dflt objectForKey:@"MyPassword"];
    tfName.text = [dflt objectForKey:@"MyNmae"];
    tfDelMonth.text = [NSString stringWithFormat:@"%d",[dflt integerForKey:@"MailDeleteMonth"]];
    
}

- (void)viewDidUnload
{
    [self setTfMailSvr:nil];
    [self setTfMailPort:nil];
    [self setTfMailAdrs:nil];
    [self setTfMailPw:nil];
    [self setTfName:nil];
    [self setTfDelMonth:nil];
    [self setLbNotReadCnt:nil];
    [self setResetBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    lbNotReadCnt.text = [NSString stringWithFormat:@"Unread Mail : %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"MailCount"]];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MailReset"] == 1) {
        [resetBtn setTitle:@"Initialization" forState:UIControlStateNormal];
    }
    else{
        [resetBtn setTitle:@"DontIn" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtnPressed:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MailReset"] == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MailReset"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"MailReset"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MailReset"] == 1) {
        [resetBtn setTitle:@"Init" forState:UIControlStateNormal];
    }
    else{
        [resetBtn setTitle:@"DontIn" forState:UIControlStateNormal];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [tfMailSvr release];
    [tfMailPort release];
    [tfMailAdrs release];
    [tfMailPw release];
    [tfName release];
    [tfDelMonth release];
    [lbNotReadCnt release];
    [super dealloc];
}
- (IBAction)onSave {
    NSUserDefaults *dflt = [NSUserDefaults standardUserDefaults];
    
	[dflt setObject:tfMailSvr.text forKey:@"MailSvr"];
    [dflt setObject:tfMailPort.text forKey:@"MailPort"];
    [dflt setObject:tfMailAdrs.text forKey:@"MyEmail"];
    [dflt setObject:tfMailPw.text forKey:@"MyPassword"];
    [dflt setObject:tfName.text forKey:@"MyName"];
    
    NSInteger dm = [tfDelMonth.text intValue];
    [dflt setInteger:dm forKey:@"MailDeleteMonth"];
    
    if ([tfMailSvr.text isEqualToString:@"imap.gmail.com"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"smtp.gmail.com" forKey:@"MailSSvr"];
        [[NSUserDefaults standardUserDefaults] setObject:@"465" forKey:@"MailSPort"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"UseInbox"];
    }
    if ([tfMailSvr.text isEqualToString:@"mail.duzon.com"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"mail.duzon.com" forKey:@"MailSSvr"];
        [[NSUserDefaults standardUserDefaults] setObject:@"25" forKey:@"MailSPort"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"UseInbox"];
    }
    if ([tfMailSvr.text isEqualToString:@"imap.naver.com"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"smtp.naver.com" forKey:@"MailSSvr"];
        [[NSUserDefaults standardUserDefaults] setObject:@"465" forKey:@"MailSPort"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"SmtpIsSSL"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"UseInbox"];
    }
    if ([tfMailSvr.text isEqualToString:@"imap.daum.net"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"993" forKey:@"MailPort"];
        [[NSUserDefaults standardUserDefaults] setObject:@"smtp.daum.net" forKey:@"MailSSvr"];
        [[NSUserDefaults standardUserDefaults] setObject:@"465" forKey:@"MailSPort"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"SmtpIsSSL"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"UseInbox"];
    }
    
    
    
    [dflt synchronize];
}

- (IBAction)onMail {
    // MailRootOnly same name... Mail,Use all of the contents in the folder create a new one..
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MailSvr"] isEqualToString:@"imap.gmail.com"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ImapIsSSL"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"SmtpIsSSL"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ImapIsSSL"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"SmtpIsSSL"];
    }
    MailRoot *mr = [[MailRoot alloc] init];
    [self.navigationController pushViewController:mr animated:YES];
    [mr release];
}

@end
