//
//  MailImageUtil.m
//  DzMail
//
//  Created by JD YANG on 11. 12. 19..
//  Copyright (c) 2011년 DUZON C&T. All rights reserved.
//

#import "MailImageUtil.h"
#import "MailSOUtil.h"
@implementation UIImageView (AutoSize)
- (void)autoFrameWithFrameX:(float)x Y:(float)y{
    UIImage *image=[self image];
    CGRect imageFrame=CGRectMake(x, y, image.size.width, image.size.height);
    self.frame=imageFrame;
    [self setContentMode:UIViewContentModeScaleToFill];
}

- (void)autoFrame{
    UIImage *image=[self image];
    [MailSOUtil view:self changeWidth:image.size.width height:image.size.height];
    [self setContentMode:UIViewContentModeScaleToFill];
}

- (void)autoHalfFrame{
    UIImage *image=[self image];
    [MailSOUtil view:self changeWidth:image.size.width/2 height:image.size.height/2];
    [self setContentMode:UIViewContentModeScaleToFill];
}

@end
