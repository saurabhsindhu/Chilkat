//
//  MailSender.h
//  DzMail
//
//  Created by KIM TAE HO on 11. 11. 18..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailNaviBarV.h"
#import "CkoEmail.h"


@class CkoEmail;
@class Mail;

@interface MailAttachmentImage : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) int size;
@end


@interface MailSender : UIViewController <UIImagePickerControllerDelegate, MailNaviBarVDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    int fileidx;

    IBOutletCollection(UIView) NSArray *portraitVs;
    IBOutlet MailNaviBarV *naviBar;
    IBOutlet UITextField *subjectV;
    IBOutlet UITextView *textV;
    IBOutlet UIImageView *bgV;
    NSString *dayTimeStr;
    NSObject* senderDelegate;
    NSMutableArray* attachmentPics;

    NSString*   preSubject;
    NSString*   preTo;
    NSString*   preSnippet;
    
    int addState;
    IBOutlet UILabel *fileExistL;
    IBOutlet UIView *blackCoverV;
    NSMutableArray *addDocs;
    
    
    IBOutlet UIButton *addBtn;
    IBOutlet UIButton *addCCBTN;
    IBOutlet UIButton *addPicBtn;
    
    BOOL bgStatus;
    CkoEmail *forwardCkoEmail;
    BOOL forwardFileExist;
}
//- (void) setFowardMail:(Mail*)mail;
//- (void)forwardTest:(CkoEmail*)email;
- (void)reset;
- (void)setG_MailSubscriber;
- (IBAction)pressSendB:(id)sender;
-(void)setDocs:(NSArray*)docs;
-(void)setSubject:(NSString*)subject;
-(void)setTo:(NSString*)to;
-(void)setSnippet:(NSString*)snippet;
- (void)drawSelf;

@property (nonatomic, assign) NSObject* senderDelegate;
@property (retain, nonatomic) IBOutlet UITextField *tfTo;
@property (retain, nonatomic) IBOutlet UITextField *tfCc;
@property (retain, nonatomic) IBOutlet UITextView *textV;

- (IBAction)onAddTo:(UIButton*)sender;
- (IBAction)onAddCc:(UIButton*)sender;
- (IBAction)onPictureAdd:(id)sender;

@end
 