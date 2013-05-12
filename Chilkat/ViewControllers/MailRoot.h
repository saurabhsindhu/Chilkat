//
//  MailRoot.h
//  DzGW
//
//  Created by KIM TAE HO on 11. 9. 16..
//  Copyright 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailNaviBarV.h"

@class MailBoxTVC;
@class MailListVC;

@interface MailRoot : UIViewController <UITableViewDelegate, UITableViewDataSource, MailNaviBarVDelegate>{
    NSMutableArray *mailboxes;
    
    IBOutlet MailNaviBarV *naviBar;
    IBOutlet UIActivityIndicatorView *activityIndiV;
    
    IBOutlet UITableView *tableV;
    IBOutlet UITableViewCell *mailWriteTVC;
    IBOutlet UILabel *mailWriteTVCLabel;
    IBOutlet UILabel *statusL;
    IBOutlet UIActivityIndicatorView *logIndiV;
    
    BOOL isRootManager; // if NO, use for inherited classView
    
    NSString *mailBoxTVCNibName;
    NSString *mailListVCNibName;
    MailBoxTVC *lastSelectedCell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil assignNewManager:(BOOL)assignNewManager;

-(void)listViewPop:(MailListVC*)listV withCell:(MailBoxTVC*)cell;

@property (nonatomic, retain) NSString *mailBoxTVCNibName;
@property (nonatomic, retain) NSString *mailListVCNibName;

@end