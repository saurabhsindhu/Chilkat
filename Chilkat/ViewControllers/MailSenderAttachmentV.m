//
//  MailSenderAttachmentV.m
//  DzMail
//
//  Created by JD YANG on 12. 1. 11..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import "MailSenderAttachmentV.h"
#import "MailSOUtil.h"

@implementation MailSenderAttachmentV
@synthesize mailSender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        addDocSet=[[NSMutableSet set] retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)attachmentCellIsSelected:(MailSenderAttachmentTVC*)cell{
    if (cell.selectedBtn){
        [addDocSet addObject:cell];

    }
    else{
        [addDocSet removeObject:cell];

    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [naviBar setTitle:@"첨부 파일 선택" leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeDone];
    documentDocs=[[MailSOUtil filenamesInDirectory:NSDocumentDirectory] retain];
}

- (void)pressLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressRightBtn{
    NSMutableArray *docs=[NSMutableArray array];
    for (MailSenderAttachmentTVC *cell in addDocSet) {
        [docs addObject:cell.nameLabel.text];
    }
    [mailSender setDocs:docs];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [documentDocs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    

    static NSString *CellIdentifier = @"MailBoxAttachTVC";
    
    MailSenderAttachmentTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MailSenderAttachmentTVC" owner:self options:nil];
        cell = (MailSenderAttachmentTVC *)[nib objectAtIndex:0];
        cell.delegate=self;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.nameLabel.text=[documentDocs objectAtIndex:indexPath.row];
    
    return (UITableViewCell *)cell;
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}



- (void)viewDidUnload
{
    [naviBar release];
    naviBar = nil;
    [tableV release];
    tableV = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [addDocSet release];
    [documentDocs release];
    [naviBar release];
    [tableV release];
    [super dealloc];
}
@end
