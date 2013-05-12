//
//  MailSubscriber.m
//  DzGW
//
//  Created by KIM TAE HO on 11. 9. 16..
//  Copyright 2011년 DUZON C&T. All rights reserved.
//

#import "MailSubscriber.h"

@implementation MailSubscriber
@synthesize nameTo,adrsTo,nameCc,adrsCc,nameBcc,adrsBcc;

- (id)init
{
    self = [super init];
    if (self) {
        nameTo = [[NSMutableArray alloc] initWithCapacity:10];
        adrsTo = [[NSMutableArray alloc] initWithCapacity:10];
        nameCc = [[NSMutableArray alloc] initWithCapacity:10];
        adrsCc = [[NSMutableArray alloc] initWithCapacity:10];
        nameBcc = [[NSMutableArray alloc] initWithCapacity:10];
        adrsBcc = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void)dealloc{
    [nameTo release];
    [adrsTo release]; 
    [nameCc release]; 
    [adrsCc release]; 
    [nameBcc release];
    [adrsBcc release];
    [super dealloc];
}

- (void)clearList{          
    // 수신자 정보 클리어
    [nameTo removeAllObjects];
    [adrsTo removeAllObjects]; 
    [nameCc removeAllObjects]; 
    [adrsCc removeAllObjects]; 
    [nameBcc removeAllObjects];
    [adrsBcc removeAllObjects];
}

- (NSInteger)findAdrsInTo:(NSString *)adrs{
    NSInteger ret = -1;
    NSInteger i,j=[adrsTo count];
    for(i=0;i<j;i++){
        NSString *tmp = [adrsTo objectAtIndex:i];
        if([tmp isEqualToString:adrs]){
            ret = i;
            break;
        }
    }
    return ret;
}

- (NSInteger)findAdrsInCc:(NSString *)adrs{
    NSInteger ret = -1;
    NSInteger i,j=[adrsCc count];
    for(i=0;i<j;i++){
        NSString *tmp = [adrsCc objectAtIndex:i];
        if([tmp isEqualToString:adrs]){
            ret = i;
            break;
        }
    }
    return ret;
}

- (NSInteger)findAdrsInBcc:(NSString *)adrs{
    NSInteger ret = -1;
    NSInteger i,j=[adrsBcc count];
    for(i=0;i<j;i++){
        NSString *tmp = [adrsBcc objectAtIndex:i];
        if([tmp isEqualToString:adrs]){
            ret = i;
            break;
        }
    }
    return ret;
}

- (NSInteger)findAdrs:(NSString*)adrs{
    // 수신자 목록 검색. 0=없음,1=수신자에있음,2=참조에있음,3=숨은참조에있음
    if([self findAdrsInTo:adrs]>=0) return 1;
    if([self findAdrsInCc:adrs]>=0) return 2;
    if([self findAdrsInBcc:adrs]>=0) return 3;

    return 0;
}

- (void)addTo:(NSString*)name :(NSString*)adrs{     
    // 수신자 추가
    [nameTo addObject:name];
    [adrsTo addObject:adrs];
}

- (void)addCc:(NSString*)name :(NSString*)adrs{     
    // 참조 추가
    [nameCc addObject:name];
    [adrsCc addObject:adrs];
}

- (void)addBcc:(NSString*)name :(NSString*)adrs{    
    // 숨은 참조 추가
    [nameBcc addObject:name];
    [adrsBcc addObject:adrs];
}

- (void)delTo:(NSString*)adrs{     
    // 수신자 삭제
    NSInteger pos = [self findAdrsInTo:adrs];
    if(pos<0) return;
    [nameTo removeObjectAtIndex:pos];
    [adrsTo removeObjectAtIndex:pos];
}

- (void)delCc:(NSString*)adrs{     
    // 참조 삭제
    NSInteger pos = [self findAdrsInCc:adrs];
    if(pos<0) return;
    [nameCc removeObjectAtIndex:pos];
    [adrsCc removeObjectAtIndex:pos];
}

- (void)delBcc:(NSString*)adrs{    
    // 숨은 참조 삭제
    NSInteger pos = [self findAdrsInBcc:adrs];
    if(pos<0) return;
    [nameBcc removeObjectAtIndex:pos];
    [adrsBcc removeObjectAtIndex:pos];
}

@end

MailSubscriber *g_mailSubscriber;

