//
//  MailSOWebUtil.h
//  SOIDX2
//
//  Created by jdyang on 10. 9. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
		
#import <Foundation/Foundation.h>
#import "MailSOSingleton.h"

@protocol MailSOWebUtilAsyncProtocol <NSObject>
@required
-(void)completeAsync:(NSString*)identifier data:(NSData*)data;
@optional
-(void)ongoingAsync:(NSString*)identifier percentage:(int)percent;
@end

@interface SOAsyncDataCollection : NSObject{
    NSMutableData *data;
    long long    dataLength;
    NSObject<MailSOWebUtilAsyncProtocol>    *delegate;
    NSString    *identifier;
    int progressPercentage;
}

@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, assign) long long  dataLength;
@property (nonatomic, retain) NSObject  *delegate;
@property (nonatomic, retain) NSString  *identifier;
@property (nonatomic, assign) int progressPercentage;
@end

#define MailSOWebUtilImageResizeDefault CGSizeMake(320,367)

@interface MailSOWebUtil : MailSOSingleton {
	NSString *baseURL;
	NSString *pgURL;//deprecated
	NSStringEncoding encoding;
    NSMutableDictionary *asyncDataDic;
}

@property (nonatomic, retain) NSString* baseURL;

-(void)touchURLString:(NSString*)aURL;

+(MailSOWebUtil*) shared;
-(void)loadWithBaseURL:(NSString*)urlStr;


-(NSURL*)urlWithURLString:(NSString*)urlStr;
-(NSURL*)urlWithURLString:(NSString*)urlStr parameters:(NSDictionary*)parameters;
-(NSString*)strWithURLString:(NSString*)urlStr parameters:(NSDictionary*)parameters;
+(NSString*)parameters2Str:(NSDictionary*)parameters;

-(BOOL)boolWithURLString:(NSString*)aURL;
-(BOOL)boolWithURLString:(NSString *)aURL postData:(NSData *)postData;


-(int)intWithURLString:(NSString*)aURL;
-(float)floatWithURLString:(NSString*)aURL;
-(BOOL)boolWithURLString:(NSString *)aURL postData:(NSData *)postData;
-(NSString*)stringWithURLString:(NSString *)aURL;
-(NSString*)stringWithURLString:(NSString *)urlString postData:(NSData *)postData;

-(UIImage*)imageWithURLString:(NSString*)aURL;


- (id)postDataWithURLString:(NSString*)aURL dataStr:(NSString*)dataStr returnType:(NSString*)type; //deprecated use stringWithURLString instead

//async http request controller
-(void)asyncHttpRequest:(NSURL*)aURL delegate:(id)aDelegate identifier:(NSString*)identifier param:(NSDictionary*)aParam method:(BOOL)isGet;
-(void)asyncHttpRequest:(NSURL*)aURL delegate:(id)aDelegate identifier:(NSString*)identifier;


@end
