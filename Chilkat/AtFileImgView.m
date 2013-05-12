//
//  AtFileImgView.m
//  mgw
//
//  Created by KIM TAE HO on 11. 12. 15..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "AtFileImgView.h"
#import "GlobalVal.h"

@implementation AtFileImgView
@synthesize wView;

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
    [wView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:g_val.tmpStr]]];
}

- (void)viewDidUnload
{
    [self setWView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if(toInterfaceOrientation>2){
        [wView setFrame:CGRectMake(0, 0, 480, 300)];
    }
    else{
        [wView setFrame:CGRectMake(0, 45, 320, 415)];
    }
}

- (void)dealloc {
//    [wView release];
    [super dealloc];
}
- (IBAction)onBack {
    [g_val.tmpStr setString:@""];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onHome {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    NSURL *fUrl = [NSURL fileURLWithPath:g_val.tmpStr];
    UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:fUrl];
    
    [g_val.tmpStr setString:@""];
    
    [doc retain];
    [doc presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
//    if(ret==NO)
//        [g_val showMsg:nil :@"현재 파일을 볼 수 있는 프로그램이 없습니다. 이 파일을 폰에서 열람하기 위해서는, 이 파일을 지원하는 앱을 설치해야 합니다."];
}
@end
