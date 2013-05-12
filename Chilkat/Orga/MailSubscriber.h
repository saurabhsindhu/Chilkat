//
//  MailSubscriber.h
//  DzGW
//
//  Created by KIM TAE HO on 11. 9. 16..
//  Copyright 2011년 DUZON C&T. All rights reserved.
//

/** * @file MailSubscriber.h 8 @brief   메일 수신자 관리 */
/**
 test doxy
 */
#import <Foundation/Foundation.h>

@interface MailSubscriber : NSObject{
    NSMutableArray *nameTo;         /**< 수신자 이름*/
    NSMutableArray *adrsTo;         // 수신자 이메일주소
    NSMutableArray *nameCc;         // 참조 이름
    NSMutableArray *adrsCc;
    NSMutableArray *nameBcc;        // 숨은 참조 이름
    NSMutableArray *adrsBcc;
}

/** 
 name
 */
@property (nonatomic, retain) NSMutableArray *nameTo; 
@property (nonatomic, retain) NSMutableArray *adrsTo; 
@property (nonatomic, retain) NSMutableArray *nameCc; 
@property (nonatomic, retain) NSMutableArray *adrsCc;
@property (nonatomic, retain) NSMutableArray *nameBcc;
@property (nonatomic, retain) NSMutableArray *adrsBcc;


- (void)clearList;                                  // 수신자 정보 클리어. 신규,회신,전달 전에 실시
- (NSInteger)findAdrs:(NSString*)adrs;              // 수신자 목록 검색. 0=없음,1=수신자에있음,2=참조에있음,3=숨은참조에있음
- (void)addTo:(NSString*)name :(NSString*)adrs;     // 수신자 추가
- (void)addCc:(NSString*)name :(NSString*)adrs;     // 참조 추가
- (void)addBcc:(NSString*)name :(NSString*)adrs;    // 숨은 참조 추가
- (void)delTo:(NSString*)adrs;                      // 수신자 삭제
- (void)delCc:(NSString*)adrs;                      // 참조 삭제
- (void)delBcc:(NSString*)adrs;                     // 숨은 참조 삭제

@end

extern MailSubscriber *g_mailSubscriber; 

