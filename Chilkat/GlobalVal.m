//
//  GlobalVal.m
//  SmartCeo
//
//  Created by DUZON on 11. 6. 1..
//  Copyright 2011 DUZON C&T. All rights reserved.
//

#import "GlobalVal.h"


@implementation GlobalVal
@synthesize tmpStr;
@synthesize chPortrait;


- (id)init{
    self = [super init];
    if(self!=nil){
        tmpStr = [[NSMutableString alloc] init];
        
    }
    return self;
}

- (void)dealloc{
    [tmpStr release];
    
    [super dealloc];
}
@end

GlobalVal *g_val;
