//
//  MailListVC.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailListVC.h"
#import "MailVC.h"
#import "MailTVC.h"
#import "MailDBManager.h"
#import "MailSODateTimeUtil.h"
#import "MailConfig.h"
#import "MailSOUtil.h"

@implementation MailListVC

@synthesize mailBox;
@synthesize loadMoreV;
@synthesize isSearch;
@synthesize mailRoot;
@synthesize mailRootViewCellForListVC;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailBox:(MailBox* ) _mailBox;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailBox=[_mailBox retain];
        //add kvo
        [mailBox addObserver:self forKeyPath:@"mailArray" options:0 context:nil];
        [mailBox addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionInitial context:nil];
        [mailBox addObserver:self forKeyPath:@"isLoadMore" options:0 context:nil];
        loadMoreV.hidden=YES;
        rowHeight=88;
    }
    return self;
}

-(void)setMailBox:(MailBox *)_mailBox{
    [mailBox removeObserver:self forKeyPath:@"mailArray"];
    [mailBox removeObserver:self forKeyPath:@"syncStatus"];
    [mailBox removeObserver:self forKeyPath:@"isLoadMore"];
    [mailBox release];
    mailBox=[_mailBox retain];
    [mailBox addObserver:self forKeyPath:@"mailArray" options:0 context:nil];
    [mailBox addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionInitial context:nil];
    [mailBox addObserver:self forKeyPath:@"isLoadMore" options:NSKeyValueObservingOptionInitial context:nil];

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            [[MailManager manager] loadMailboxFromServer:mailBox];
        });
    }

    switch (mailBox.syncStatus) {
        case MailSyncStatusReady:
            [tableV setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                [tableV setContentOffset:CGPointMake(0, 0)];
            loadMoreCellLabel.text=@"새로고침 중입니다";
            [loadMoreCellActivity startAnimating];
            break;
        case MailSyncStatusEnd:
            [tableV setContentInset:UIEdgeInsetsMake(rowHeight*(-1), 0, 0, 0)];
                [tableV setContentOffset:CGPointMake(0, rowHeight)];
            loadMoreCellLabel.text=[NSString stringWithFormat:@"최종 업데이트: %@\n새로 고침하려면 끌어 내리세요", [MailSODateTimeUtil stringForDate:mailBox.syncDate option:SODateStringTimeType] ];
            [loadMoreCellActivity stopAnimating];
            break;
        case MailSyncStatusSync:
            [tableV setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                [tableV setContentOffset:CGPointMake(0, 0)];
            loadMoreCellLabel.text=[NSString stringWithFormat:@"새로고침 중입니다", [MailSODateTimeUtil stringForDate:mailBox.syncDate] ];
            [loadMoreCellActivity startAnimating];
            break;
    }

    [tableV reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (ignoreScrollViewDidScroll) {
        ignoreScrollViewDidScroll = NO;
        return;
    }
    if (isSearch) {
        return;
    }
    if (mailBox.syncStatus==MailSyncStatusEnd) {
        if (scrollView.contentOffset.y < -30) {
            mailBox.syncStatus=MailSyncStatusReady;
            syncStateReadyTime=[[NSDate date] retain];
        }
        if (scrollView.contentOffset.y + tableV.frame.size.height + 50 > tableV.contentSize.height 
            && [mailBox.mailArray count] > Mail__CACHENUM__ ) {
            if (mailBox.isLoadMore == NO) {
                [[MailManager manager] loadMoreMailFromServer:mailBox];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        mailBox.syncStatus=MailSyncStatusEnd;
    }
    else {
        mailBox.mailArray=[NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[MailDBManager manager] resetMailBox:mailBox.rowid];
            mailBox.numOfSavedTotal=0;
            [[MailManager manager] loadMailboxFromServer:mailBox];
        });
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (mailBox.syncStatus==MailSyncStatusReady && scrollView.contentOffset.y < -30) {
        //5초 이상 잡고 있을 때
        if ([[NSDate date] timeIntervalSinceDate:syncStateReadyTime] > 2 ) {
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"알림" message:@"메일박스를 초기화 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];            
            [alertView show];
            [alertView release];
        }
        else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[MailManager manager] loadMailboxFromServer:mailBox];
            });
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapped)];
//    [tableV addGestureRecognizer:recognizer];
    [mailNaviBarV setTitle:mailBox.name leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeHome];
    NSLog(@"현재 메일박스 sync Status: %d",mailBox.syncStatus);
    if ([[MailManager manager] isMailBoxReloaded:mailBox]) {
        return; // 동기화 하지 않음
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                return ;
            }
            [[MailManager manager] loadMailboxFromServer:mailBox];
        });
    }
}

- (void)viewDidUnload
{
    [mailNaviBarV release];
    mailNaviBarV = nil;
    [tableV release];
    tableV = nil;
    [searchTF release];
    searchTF = nil;
    [loadMoreCell release];
    loadMoreCell = nil;
    [loadMoreCellLabel release];
    loadMoreCellLabel = nil;
    [self setLoadMoreV:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// 검색버튼이 눌렸을 때. 디비의 데이타가 많을 수 있으므로 엔터를 쳤을때 실행되도록 한다.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self performSelector:@selector(search:) withObject:textField.text afterDelay:0];
    return YES;
}

-(void)search:(NSString*)text{
    NSLog(@"검색어 : %@",text);
    isSearchedInServer=NO;
    if (searchedMailArray) {
        [searchedMailArray release];
    }
    searchedMailArray=[[[MailDBManager manager] searchMail:text from:mailBox.rowid reference:mailBox.reference] retain];
    isSearch=YES;
    [tableV setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [tableV setContentOffset:CGPointMake(0, 0)];
    [searchTF resignFirstResponder];
    [tableV reloadData];
}


-(void)updateTableData{
#if 0 // lazy loading
    if (isUpdating) {
        return;
    }
    while (1) {
        if (setNeedUpdate) {
            isUpdating=YES;
            [tableV reloadData];
        }
        else{
            return;
        }
        [NSThread sleepForTimeInterval:1];
    }
#else
    switch (mailBox.syncStatus) {
        case MailSyncStatusReady:
            [UIView animateWithDuration:0.2 animations:^(void){
            [tableV setContentInset:UIEdgeInsetsMake(rowHeight*(-1), 0, 0, 0)];
            }];

            [loadMoreCellActivity startAnimating];
            loadMoreCellLabel.text=@"새로고침 중입니다";
            break;
        case MailSyncStatusEnd:
            [UIView animateWithDuration:0.2 animations:^(void){
                ignoreScrollViewDidScroll = YES;
            [tableV setContentInset:UIEdgeInsetsMake(rowHeight*(-1), 0, 0, 0)];
            }];
            loadMoreCellLabel.text=[NSString stringWithFormat:@"최종 업데이트: %@\n새로 고침하려면 끌어 내리세요", [MailSODateTimeUtil stringForDate:mailBox.syncDate option:SODateStringTimeType] ];
            [loadMoreCellActivity stopAnimating];
            break;
        case MailSyncStatusSync:
            [UIView animateWithDuration:0.2 animations:^(void){
            [tableV setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }];
            [loadMoreCellActivity startAnimating];
            loadMoreCellLabel.text=@"새로고침 중입니다";
            break;
        default:
            break;
    }
    [tableV reloadData];
#endif
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (mailBox.isLoadMore) {
        loadMoreV.hidden=NO;
    }
    else {
        loadMoreV.hidden=YES;
    }
    
    if (isSearch==NO) {
        [self performSelectorOnMainThread:@selector(updateTableData) withObject:nil waitUntilDone:NO];
    }
}


- (void)dealloc {
    [syncStateReadyTime release];
    [mailBox removeObserver:self forKeyPath:@"mailArray"];
    [mailBox removeObserver:self forKeyPath:@"syncStatus"];

    [mailNaviBarV release];
    [searchedMailArray release];
    [tableV release];
    [searchTF release];
    [loadMoreCell release];
    [loadMoreCellActivity release];
    [loadMoreCellLabel release];
    [loadMoreV release];
    [super dealloc];
}

- (void)pressLeftBtn{
    [mailRoot listViewPop:self withCell:(MailBoxTVC*)mailRootViewCellForListVC];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pressRightBtn{
    [[MailManager manager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)cancelSearch:(id)sender {
    isSearch=NO;
    isSearchedInServer=NO;
    [searchTF resignFirstResponder];
    [searchTF setText:nil];
    [tableV setContentInset:UIEdgeInsetsMake(rowHeight*(-1), 0, 0, 0)];
    [tableV reloadData];
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return rowHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count=[mailBox.mailArray count];
    NSLog(@"박스 %@ 메일 개수 :  %d" , mailBox.reference, count);

    if (isSearch){
        return [searchedMailArray count]+1;
    }
    return count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MailBoxTVC";

    if (isSearch==NO && indexPath.row==0) {
        return loadMoreCell;
    }
    
    MailTVC *cell = (MailTVC*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[[MailTVC alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    if (isSearch) {
        if (indexPath.row==[searchedMailArray count]) {
            [cell setMail:nil];
            cell.titleLabel.text=@"서버에서 계속 검색";
            return cell;
        }
        Mail *mail=[searchedMailArray objectAtIndex:indexPath.row ];
        [cell setMail:mail];
        return cell;
    }
    else{
        Mail *mail=[mailBox.mailArray objectAtIndex:indexPath.row-1 ];
        [cell setMail:mail];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearch) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        // 서버에서 삭제
        // Load More 셀이 있으므로 row -1 을 해준다. 
        if ([[MailManager manager] deleteMail:[mailBox.mailArray objectAtIndex:indexPath.row-1]]){
            [mailBox.mailArray removeObjectAtIndex:indexPath.row-1];
            [tableV reloadData];
        }
    }   
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MailVC  *detailViewController = [[[MailVC alloc] initWithNibName:@"MailVC" bundle:nil] autorelease];
    if (isSearch) {
        if (indexPath.row==[searchedMailArray count]) { // 서버에서 계속 검색
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                    searchedMailArray=[[[MailManager manager] mailsInMailBox:mailBox.reference mailBoxRowID:mailBox.rowid searchString:searchTF.text] retain];
                    isSearchedInServer=YES;
                    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                });
            }
            return;
        }
        else{
            detailViewController.mail=[searchedMailArray objectAtIndex:indexPath.row];
            if (detailViewController.mail.read==0) {
                detailViewController.mail.read=1;
                [detailViewController.mail updateReadToDB];
                if (isSearchedInServer == NO) {
                    if (mailBox.numOfUnSeen!=0) { // 혹시나 할 에러상황 대비
                        mailBox.numOfUnSeen--;
                    }
                }
            }
        }
    }
    else{
        if (indexPath.row == 0) {
            return;
        }
        detailViewController.mail=[mailBox.mailArray objectAtIndex:indexPath.row-1];
        if (detailViewController.mail.read==0) {
            detailViewController.mail.read=1;
            [detailViewController.mail updateReadToDB];
            if (mailBox.numOfUnSeen!=0) { // 혹시나 할 에러상황 대비
                mailBox.numOfUnSeen--;
            }
        }
    }

    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
