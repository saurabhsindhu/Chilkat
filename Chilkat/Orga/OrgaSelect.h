//
//  OrgaSelect.h
//  testOgSelect
//
//  Created by TAE HO KIM on 12. 9. 13..
//  Copyright (c) 2012년 DUZON Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrgaSelectDelegate <NSObject>
- (void)onOrgaSelect:(BOOL)isCancel;
@end

@interface OrgaSelect : UIViewController{
    NSInteger curMode;
    UILabel *titLabel;
    UITableView *tblView;
    
    NSArray *listName;
    NSArray *listAdrs;
}
@property (nonatomic, assign) NSInteger curMode;
@property (assign, nonatomic) id<OrgaSelectDelegate>delegate;
@property (retain, nonatomic) IBOutlet UITableView *tblView;
- (void)onCancel:(id)sender;
- (void)onDone:(id)sender;



@end
