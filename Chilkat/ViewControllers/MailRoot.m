//
//  MailRoot.m
//  DzGW
//
//  Created by KIM TAE HO on 11. 9. 16..
//  Copyright 2011년 DUZON C&T. All rights reserved.
//

#import "MailRoot.h"
#import "MailSubscriber.h"
#import "MailManager.h"
#import "MailBoxTVC.h"
#import "MailListVC.h"
#import "MailNaviBarV.h"
#import "MailSender.h"
#import "MailSOUtil.h"
#import "MailConfig.h"
#import "MailImageUtil.h"
@implementation MailRoot

@synthesize mailBoxTVCNibName;
@synthesize mailListVCNibName;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // [MailManager manager]; // initialize
        isRootManager=YES;
        mailBoxTVCNibName = [@"MailBoxTVC" retain];
        mailListVCNibName = [@"MailListVC" retain];
        [MailManager assignNewManager];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil assignNewManager:(BOOL)assignNewManager
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // [MailManager manager]; // initialize
        isRootManager=YES;
        mailBoxTVCNibName = [@"MailBoxTVC" retain];
        mailListVCNibName = [@"MailListVC" retain];
        if (assignNewManager) {
            [MailManager assignNewManager];
        }
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)viewFinishLoading{
    [activityIndiV stopAnimating];
    [tableV setHidden:NO];
    if (mailboxes) {
        [mailboxes release];
    }
    mailboxes=[[[MailManager manager] arrangedMailBoxes] retain];
    [tableV reloadData];
}

-(void)viewFinishLoadingFailed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    /*Local Exchange server
     :   mail.duzon.com
     : imap :143
     smtp: 25
     engine002@duzon.com
     / wogh$$60
      ssl 
     */
    if (isRootManager) {
        g_mailSubscriber = [[MailSubscriber alloc] init];   // Recipients Information Manager
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @try {
                if ([[MailManager manager] login] == NO){
                    if ([MailManager manager].logouted==NO) {
                        NSLog(@"Login Fail");
                        [MailSOUtil alert:@"LogIn Failed"];
                        [self performSelectorOnMainThread:@selector(viewFinishLoadingFailed) withObject:nil waitUntilDone:NO];
                        return;
                    }
                }
                
                [self performSelectorOnMainThread:@selector(viewFinishLoading) withObject:nil waitUntilDone:NO];
            }
            @catch (NSException *exception) {
                NSLog(exception.name,nil);
            }
        });
        
        //add KVO 
        [tableV setBackgroundColor:[UIColor clearColor]];
        [[MailManager manager] assignMailRoot:self];

        [MailSOUtil log:@"---AddObserver---"];
        
        
        //UI
        naviBar.titleLabel.text=@"Mail";
        [naviBar setTitle:@"메일" leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeHome];
    }
    
    NSLog(@"View Did Load End");
}

- (void)setStatusLogView{
    NSString *statusLog = [MailManager manager].mailBoxStatusLog;
    if (statusLog==nil) {
        [MailSOUtil view:tableV changeHeight:412];
        [logIndiV stopAnimating];
        statusL.hidden=YES;
        return;
    }
    [MailSOUtil view:tableV changeHeight:387];
    statusL.hidden=NO;
    [logIndiV startAnimating];
    [statusL performSelectorOnMainThread:@selector(setText:) withObject:statusLog waitUntilDone:NO];    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"mailBoxStatusLog"]) {
        functionLog();
        NSLog(@"Mail Root STATUS LOG: %@",[MailManager manager].mailBoxStatusLog);
        [self performSelectorOnMainThread:@selector(setStatusLogView) withObject:nil waitUntilDone:NO];
    }
    else if([keyPath isEqualToString:@"mailBoxArray"] || [keyPath isEqualToString:@"mailboxLoaded"]){
        if ([MailManager manager].mailboxLoaded == NO) {
            return;
        }
        //MailBox Copy Use.
        if (mailboxes) {
            [mailboxes release];
        }
        mailboxes=[[[MailManager manager] arrangedMailBoxes] retain];
        [tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    

    else {
        if ([MailManager manager].mailboxLoaded == NO) {
            return;
        }

        mailboxes=[[[MailManager manager] arrangedMailBoxes] retain];
        [tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

    }
}


- (void)dealloc{
    [mailboxes release];
    [g_mailSubscriber release];
    [activityIndiV release];
    [naviBar release];
    [mailWriteTVC release];
    [statusL release];
    [logIndiV release];
    [mailWriteTVCLabel release];
    [mailBoxTVCNibName release];
    [mailListVCNibName release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [activityIndiV release];
    activityIndiV = nil;
    [naviBar release];
    naviBar = nil;
    [mailWriteTVC release];
    mailWriteTVC = nil;
    [statusL release];
    statusL = nil;
    [logIndiV release];
    logIndiV = nil;
    [mailWriteTVCLabel release];
    mailWriteTVCLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onWriteMail {
    MailSender *sender=[[[MailSender alloc] initWithNibName:@"MailSender" bundle:nil] autorelease];
    [self.navigationController pushViewController:sender animated:YES];
    
    /*
    [g_mailSubscriber clearList];
    MailWriter *nv = [[MailWriter alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
    [nv release];
     */
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count=[mailboxes count]+1;
    if (count==1) {
        return 0;
    }
    NSLog(@"MailRootVC : Refreshes the MailBox. ( MAILBOX : A total of %d)",count-1);
    return count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MailBoxTVC *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:mailBoxTVCNibName owner:self options:nil];
    cell = (MailBoxTVC *)[nib objectAtIndex:0];
    if (indexPath.row==0) {
        [cell setSendMailMode];
        return cell;
    }
    
    if ([mailboxes count]<=indexPath.row-1) {
        return cell; // difference in speed;
    }
    [cell setMailBox:[mailboxes objectAtIndex:indexPath.row-1] ];

    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        [self onWriteMail];
        return;
    }
     MailListVC *detailViewController = [[MailListVC alloc] initWithNibName:mailListVCNibName bundle:nil mailBox:[mailboxes objectAtIndex:indexPath.row-1]];
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
}

-(void)pressLeftBtn{
    [[MailManager manager] logout];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)pressRightBtn{
    [[MailManager manager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)listViewPop:(MailListVC*)listV withCell:(MailBoxTVC*)cell{
    [cell retain];
    lastSelectedCell = cell;
}


@end
