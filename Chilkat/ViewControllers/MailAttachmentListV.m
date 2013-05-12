//
//  MailAttachmentListV.m
//  DzMail
//
//  Created by JD YANG on 12. 1. 5..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#import "MailAttachmentListV.h"
#import "MailSOUtil.h"
#import "GlobalVal.h"
#import "AtFileImgView.h"

@implementation MailAttachmentListV
@synthesize mail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [naviBar setTitle:@"첨부 파일" leftBtnType:MailLeftBtnTypeBack rightBtnType:MailRightBtnTypeHome];
    filenames=[[[MailManager manager] attachmentFileNamesOfMail:mail] retain];
    filesizes=[[[MailManager manager] attachmentFileSizesOfMail:mail] retain];
}

-(void)pressLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pressRightBtn{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [naviBar release];
    naviBar = nil;
    [coverV release];
    coverV = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mail.attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    MailAttachment *attach=[mail.attachments objectAtIndex:indexPath.row];
    cell.textLabel.text=attach.fileName;
    return cell;
}




- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [controller autorelease];
}

#pragma mark - Table view delegate

- (void)watchDownload:(NSString*)fileName{
    [coverV setHidden:YES];
    if (fileName==nil) {
        return;
    }
    NSURL *filePathURL=[NSURL fileURLWithPath:[MailSOUtil filePathWithName:fileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[MailSOUtil filePathWithName:fileName]] == NO ){
        [MailSOUtil alert:@"파일이 없습니다"];
        return;
    }
    
    NSString *expension=[[filePathURL pathExtension] uppercaseString];
    if ([expension isEqualToString:@"JPG"]||[expension isEqualToString:@"PNG"] || [expension isEqualToString:@"PDF"] || [expension isEqualToString:@"JPEG"] || [expension isEqualToString:@"BMP"]) {
        NSString *filePath=[MailSOUtil filePathWithName:fileName];
        [g_val.tmpStr setString:filePath];
        [MailSOUtil log:@"file saved With URL" obj:filePath];
        AtFileImgView *nv = [[AtFileImgView alloc] init];
        [self.navigationController pushViewController:nv animated:YES];
        [nv release];
        return;
    }
    UIDocumentInteractionController* docController = [[UIDocumentInteractionController 
                                                       interactionControllerWithURL:filePathURL] retain];
    
    
    BOOL canOpen;
    if (docController!=nil ){
        docController.delegate = self;
        canOpen = [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:NO];                   
    }
    if (canOpen==NO) {
        [MailSOUtil alert:@"파일을 연결한 프로그램이 없습니다"];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MailAttachment *attachment=[mail.attachments objectAtIndex:indexPath.row];
    
    if (attachment.fileSize>1024*1024*10) {
        [MailSOUtil alert:@"파일 용량이 너무 큽니다"];
        return;
    }
    /*
    alertV=[[UIAlertView alloc] initWithTitle:@"알림" message:@"파일을 다운로드 하는 중입니다." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *indiV=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [alertV addSubview:indiV];
    indiV.frame=CGRectMake(135, 80, indiV.frame.size.width, indiV.frame.size.height);
    [indiV startAnimating];

    [alertV show];
    [indiV release];*/
    [coverV setHidden:NO];
     

    dispatch_async(dispatch_queue_create("DownloadQueue", 0), ^(void){
        if ([[MailManager manager] downloadAttachment:mail fileName:attachment.fileName] == NO){
            [MailSOUtil errorLog:@"파일 다운로드 실패!"];
            [MailSOUtil alert:@"다운로드 할 수 없는 파일입니다"];
            [self performSelectorOnMainThread:@selector(watchDownload:) withObject:nil waitUntilDone:NO];
            return;
        }
        
        [self performSelectorOnMainThread:@selector(watchDownload:) withObject:[filenames objectAtIndex:indexPath.row] waitUntilDone:NO];

    }
     
                   );    
}

-(void)dealloc{
    [filenames release];
    [filesizes release];
    [naviBar release];
    [coverV release];
    [super dealloc];
}

@end