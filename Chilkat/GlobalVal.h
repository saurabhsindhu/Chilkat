//
//  GlobalVal.h
//  SmartCeo
//
//  Created by DUZON on 11. 6. 1..
//  Copyright 2011 DUZON C&T. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVal : NSObject {

    NSMutableString *tmpStr;                    // 임시 변수

}
@property (nonatomic,retain) NSMutableString *tmpStr;
@property (nonatomic, assign) BOOL chPortrait;
@end

extern GlobalVal *g_val;









