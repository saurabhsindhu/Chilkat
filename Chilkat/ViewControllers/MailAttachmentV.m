//
//  MailAttachmentV.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 15..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#if 0
#import "MailAttachmentV.h"
@implementation MailAttachmentV
@synthesize delegate;
@synthesize size=_size;
@synthesize name=_name;

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"MailAttachmentV" owner:self options:nil] objectAtIndex:0]];

    }
    return self;
}

-(void)setName:(NSString *)name{
    [nameBtn setTitle:name forState:UIControlStateNormal];
}

-(NSString*)name{
    return nameBtn.titleLabel.text;
}

-(void)setSize:(NSString *)size{
    [sizeBtn setTitle:size forState:UIControlStateNormal];
}

-(NSString*)size{
    return sizeBtn.titleLabel.text;
}

- (void)dealloc {
    [nameBtn release];
    [sizeBtn release];
    [iconImageV release];
    [super dealloc];
}

- (IBAction)touchDown:(id)sender {
    [iconImageV setImage:[UIImage imageNamed:@"m_img_clip_on_s"]];
    self.backgroundColor=[UIColor colorWithRed:255/255.0f green:255/104.0f blue:0 alpha:1];
}

- (IBAction)touchUp:(id)sender {
    if ([self.delegate mailAttachmentDownload:self]){
        //start download
        [iconImageV setImage:[UIImage imageNamed:@"m_img_clip_sele"]];
    }
    else{
        [iconImageV setImage:[UIImage imageNamed:@"m_img_clip_none"]];
    }
    self.backgroundColor=[UIColor whiteColor];
}
@end

#endif
