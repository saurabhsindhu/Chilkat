//
//  util.h
//  DietBook23
//
//  Created by jdyang on 10. 4. 26..
//  Copyright 2010 SO__MyCompanyName__. All rights reserved.
//
//	Last updated 2010/9/5
//	developed for
//			UCB
//			DH4

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MailSOSingleton.h"
//#import "Setting.h"

#define __SOUTIL_LASTEXECUTEDDAY__ @"_MailSOUtil_lastExecutedDay"

#define MailGrayColor [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1]

#define MailOrangeColor [UIColor colorWithRed:255/255.0f green:104/255.0f blue:0/255.0f alpha:1]


typedef enum _SODataType {
	SODataTypeArray,
	SODataTypeDict,
	SODataTypeMailSODictArray
} SODataType;


@class MailSOUtil;
@interface MailSOUtil : MailSOSingleton{
	NSMutableDictionary *dic;
    NSMutableArray *alertMsgQueue;
    NSMutableArray *alertTitleQueue;
    NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) NSMutableDictionary *dic;
+(NSString*)version;
+(MailSOUtil*) shared;

+(BOOL) string:(NSString*)string existInArray:(NSArray*)array;

+(NSString *)lastExecutedDay;
+(void) setTodayAsExecutedDay;
#pragma mark StatusBar
//thread safe 하지 않은 함수들에 대한 wrapper
-(void)setNetworkActivityIndicatorVisibleNo;
-(void)setNetworkActivityIndicatorVisibleYES;

#pragma mark Thread
-(void)addOperation:(NSOperation*)operation;
-(void)addOperationWithBlock:(void (^)(void))block;

#pragma mark FILE UTIL
+(NSString *)appDataFilePath;
+(NSString *)filePathWithName: (NSString *)filename;
+(NSArray*)filenamesInDirectory:(NSSearchPathDirectory) directory;
+ (unsigned long long int) documentsFolderSize;

#pragma mark MACRO-Alert
+(void) alert:(NSString*)msg; //deprecated
-(void) alert:(NSString*)msg title:(NSString*)title;
+(void) alert:(NSString*)msg title:(NSString*) title; // deprecated

#pragma mark Sigleton
- (void)setObject:(id)anObject forKey:(id)key;
- (id)objectForKey:(id)key;	
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setInt:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;

#pragma mark LOG Util
#if 1
#define functionLog() NSLog(@"%s Executing\n", __func__)
#define functionLogStart() NSLog(@"%s Start\n", __func__)
#define functionLogEnd() NSLog(@"%s Ended\n", __func__)
#else
#define functionLog() 0
#define functionLogStart() 0
#define functionLogEnd() 0
#endif

+(void) log:(NSString *)msg value:(float)value; 
+(void) log:(NSString *)msg obj:(NSObject*)obj;
+(void) log:(NSString *)msg;
+(void) logForDate:(NSDate *)date; 
+(void) errorLog:(NSString*)msg;
+(void) errorLog:(NSString*)msg error:(NSError*)error;
#define errorLogFunc() [MailSOUtil errorLog:[NSString stringWithCString:__func__ encoding:NSUTF8StringEncoding]]
+(void) cacheLog:(NSString*)msg;
+(void) timeLogStart:(NSString*)identifier;
+(void) timeLogEnd:(NSString*)identifier;

#ifdef DEBUG_Method
#define methodLogStart (NSLog(@"Method Start : %@ %s\n%@", NSStringFromSelector(_cmd), __FILE__, self))
#define methodLogEnd   (NSLog(@"Method End : %@ %s\n%@", NSStringFromSelector(_cmd), __FILE__, self))
#else
#define methodLogStart
#define methodLogEnd
#endif


+(void) frameLog:(UIView*)view;

#pragma mark Dictionary
/*
 dictionaryWithObjectsAndCount와 동일함. 대신, null object를 컨트롤 가능
 */
+(NSDictionary*) dictionaryWithNullObjectsAndKeysWithCount:(NSUInteger)count, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark Data Structure Util
+(NSArray*)dictToSortArray:(NSDictionary*)dict sortKey:(NSString*)indexKey;

+(NSDictionary*) dictInArrayToArrayInDict:(NSArray*)array keyPath:(NSString*)key;

#pragma mark string checker

+(BOOL) areContainNilOrEmptyStrWithCount:(NSUInteger)count,	... NS_REQUIRES_NIL_TERMINATION;

/*!
    @function   string:(NSString*)string containsCharacterInSetOnly:(NSCharacterSet*)set
    @abstract   string에 set내부의 문자로만 포함되어있는지 검사
    @discussion string:(NSString*)string containsCharacterInSet:(NSCharacterSet*)set 참조
    @param      string 검사될 string
	@param      set 검사할 set
    @result     해당 문자로만 string이 구성되어있으면 YES, 해당 문자 외에 다른 문자가 섞여있으면 NO
*/
+(BOOL) string:(NSString*)string containsCharacterInSetOnly:(NSCharacterSet*)set;
/*!
    @function   string:(NSString*)string containsCharacterInSet:(NSCharacterSet*)set
    @abstract   string에 set의 문자가 포함되었는지 검사
    @discussion string에 set의 문자가 포함되었는지 검사
    @param      string 검사될 string
	@param		set 검사할 set
    @result     string에 해당문자 중 하나라도 포함되어있으면 YES, 어떤 문자도 포함되어있지 않으면 NO
*/

+(BOOL) string:(NSString*)string containsCharacterInSet:(NSCharacterSet*)set;
+(NSString*) stringTrim:(NSString*)string;
/*!
	@deprecated 
 */
+(BOOL) stringHasOnlyCharacterSet: (NSString *)aString characterSet:(NSCharacterSet*)aSet; //deprecated

#pragma mark UI-Related
+(NSArray*)recursiveSubviews:(UIView*)view includeSelf:(BOOL)includeSelf;
+(UIView*)subViewOf:(UIView*)view tag:(int)tag;

+(void) view:(UIView*)view changeHeight:(float)aNewHeight;
+(void) view:(UIView*)view changeWidth:(float)aNewWidth;
+(void) view:(UIView*)view changeWidth:(float)aNewWidth height:(float)aNewHeight DEPRECATED_ATTRIBUTE;
+(void) view:(UIView*)view changeX:(float)x;
+(void) view:(UIView*)view changeY:(float)y;
+(void) view:(UIView*)view changeX:(float)x changeY:(float)y;
+(void) view:(UIView*)view changeWidth:(float)aNewWidth changeHeight:(float)aNewHeight;


+(BOOL) areContainNilOrEmptyStrWithCount:(NSUInteger)count,	... NS_REQUIRES_NIL_TERMINATION;
#define aquaColor [UIColor colorWithRed:0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0f]
+(BOOL) findAndResignFirstResponder:(UIView	*)view;

#define midpointBetweenPoints(a, b) (CGPointMake(  (a.x+b.y) /2.0  , (a.y+b.y)/2.0  ))



#pragma mark NUMBER feature
#define int2Str(num)  ([NSString stringWithFormat:@"%d",(num)])
#define double2Str(num)	([NSString stringWithFormat:@"%ld",(num)])
#define numInt2Str(num) ([NSString stringWithFormat:@"%d",[(num) intValue]])
#define str2NumInt(str) ([NSNumber numberWithInt:[str intValue]])


#pragma mark View gfeature
#define soNumOfPages(numOfItem, numOfItemInOneView) (numOfItem/numOfItemInOneView+((numOfItem%numOfItemInOneView==0)?0:1))

#pragma mark Extra
#ifdef DEBUG
	#define Log(str)	(NSLog([NSString stringWithFormat:@"MailSOUtilLog: %@",str],nil))
#else
	#define Log(str)
#endif

@end


@interface SODateData : NSObject
{
	NSDate* date;
	id dataID;
	id data;
}

@property (retain) NSDate* date;
@property (retain) id data;
@property (retain) id dataID;

@end
