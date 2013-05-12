//
//  MailBoxListCopyVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 17..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailBoxListCopyVC.h"
#import "MailManager.h"
#import "MailBoxCopyTVC.h"
#import "MailSOUtil.h"
@implementation MailBoxListCopyVC
@synthesize mailToCopy;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil assignNewManager:NO];
    if (self) {
        isRootManager=NO;
    }
    return self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //UI 설정
    naviBar.titleLabel.text=@"메일 이동";
    [naviBar setTitle:@"메일 이동" leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeHome];
    tableV.hidden=NO;
    [logIndiV stopAnimating];
    logIndiV.hidden=YES;
    [activityIndiV stopAnimating];
    [tableV setBackgroundColor:[UIColor clearColor]];
    [statusL setText:nil];
    mailboxes=[[[MailManager manager] arrangedMailBoxes] copy];

    [MailSOUtil view:tableV changeHeight:412];
    NSLog(@"View Did Load End");
    [tableV setRowHeight:50];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MailBoxTVC";
    
    MailBoxCopyTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MailBoxCopyTVC" owner:self options:nil];
        cell = (MailBoxCopyTVC *)[nib objectAtIndex:0];
    }
    cell.delegate = self;
    cell.mail=mailToCopy;
    [cell setMailBox:[mailboxes objectAtIndex:indexPath.row]];

    // Configure the cell...
    
    return (UITableViewCell*)cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count=[mailboxes count];
    NSLog(@"MailRootVC : 메일박스를 새로 고칩니다. ( MAILBOX : 총 %d 개)",count-1);
    return count;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

-(void)pressLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)pressRightBtn{
    [[MailManager manager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
