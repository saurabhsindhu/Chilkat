//
//  MailListVC.h
//  DzMail
//
//  Created by JD YANG on 11. 12. 9..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailNaviBarV.h"
#import "MailManager.h"
#import "MailRoot.h"

@interface MailListVC : UIViewController < UITableViewDelegate, UITableViewDataSource, MailNaviBarVDelegate,UITextFieldDelegate>{
    
    MailRoot *mailRoot;
    UITableViewCell *mailRootViewCellForListVC;
    
    BOOL    isSearch;
    BOOL    ignoreScrollViewDidScroll;
    IBOutlet UITextField *searchTF;
    NSArray *searchedMailArray;
    IBOutlet MailNaviBarV *mailNaviBarV;
    MailBox *mailBox;
    IBOutlet UITableView *tableV;
    BOOL  setNeedUpdate;
    BOOL  isUpdating;
    IBOutlet UITableViewCell *loadMoreCell;
    IBOutlet UILabel *loadMoreCellLabel;
    IBOutlet UIActivityIndicatorView *loadMoreCellActivity;

    BOOL isSearchedInServer;
    NSDate *syncStateReadyTime;
    @protected
    float   rowHeight;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailBox:(MailBox* ) mailBox;
-(void)search:(NSString*)text;
- (IBAction)cancelSearch:(id)sender;

@property (nonatomic, assign) MailRoot *mailRoot;
@property (nonatomic, assign) UITableViewCell *mailRootViewCellForListVC;
@property (retain, nonatomic) IBOutlet UIView *loadMoreV;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, retain) MailBox *mailBox;

@end