//
//  OrgaSelect.m
//  testOgSelect
//
//  Created by TAE HO KIM on 12. 9. 13..
//  Copyright (c) 2012년 DUZON Next. All rights reserved.
//

#import "OrgaSelect.h"
#import "MailSubscriber.h"

@implementation OrgaSelect
@synthesize delegate;
@synthesize tblView;
@synthesize curMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancel:)];
    [self.navigationItem setLeftBarButtonItem:lbtn];
    [lbtn release];

    UIBarButtonItem *rbtn = [[UIBarButtonItem alloc] initWithTitle:@"완료" style:UIBarButtonItemStyleBordered target:self action:@selector(onDone:)];
    [self.navigationItem setRightBarButtonItem:rbtn];
    [rbtn release];
    
    listName = [[NSArray alloc] initWithObjects:@"김태희",@"이효리",@"한지민",@"성유리",@"써니",@"서현",@"유리",@"구하라",@"빅토리아",@"전지현",@"태연",@"티파니",@"이민정",@"김규리",@"한예슬",@"한가인",@"최강희",@"설리",@"강성연", nil];
    listAdrs = [[NSArray alloc] initWithObjects:@"kth@test.com",@"lhl@test.com",@"hjm@test.com",@"sul@test.com",@"sn@test.com",@"sh@test.com",@"gl@test.com",@"ghl@test.com",@"bt@test.com",@"jjh@test.com",@"ty@test.com",@"tpn@test.com",@"lmj@test.com",@"kkl@test.com",@"hys@test.com",@"hki@test.com",@"kkh@test.com",@"sly@test.com",@"ksy@test.com", nil];
    
    if(curMode==1) [self.navigationController setTitle:@"수신자 선택"];
    else if(curMode==2) [self.navigationController setTitle:@"참조 선택"];
    else if(curMode==3) [self.navigationController setTitle:@"숨은 참조 선택"];
}

- (void)viewDidUnload
{
    [self setTblView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)onCancel:(id)sender {
    [delegate onOrgaSelect:YES];
}

- (void)onDone:(id)sender {
    [delegate onOrgaSelect:NO];
}

- (void)dealloc {
    [titLabel release];
    [tblView release];
    [listName release];
    [listAdrs release];
    [super dealloc];
}

#pragma mark - tblview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listName count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = [listName objectAtIndex:row];
    
    NSString *tmp = [listAdrs objectAtIndex:row];
    NSInteger sel = [g_mailSubscriber findAdrs:tmp];
    
    if(sel==curMode) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *adrs = [listAdrs objectAtIndex:row];
    NSInteger sel = [g_mailSubscriber findAdrs:adrs];
    
    
    if(sel==0){
        NSString *name = [listName objectAtIndex:row];
        if(curMode==1) [g_mailSubscriber addTo:name :adrs];
        else if(curMode==2) [g_mailSubscriber addCc:name :adrs];
        else if(curMode==3) [g_mailSubscriber addBcc:name :adrs];
    }
    else if(sel==curMode){
        if(curMode==1) [g_mailSubscriber delTo:adrs];
        else if(curMode==2) [g_mailSubscriber delCc:adrs];
        else if(curMode==3) [g_mailSubscriber delBcc:adrs];
    }
    else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"중복선택" message:@"다른 수신자 목록에서 이미 선택한 사람입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    [tblView reloadData];
}

@end
