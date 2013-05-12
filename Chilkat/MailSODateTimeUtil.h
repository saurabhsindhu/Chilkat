//
//  MailSODateTimeUtil.h
//  WonDiet
//
//  Created by jdyang on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _SODateDay {
	SODateDaySunday=1,
	SODateDayMonday=2,
	SODateDayTuesday=3,
	SODateDayWednesday=4,
	SODateDayThursday=5,
	SODateDayFriday=6,
	SODateDaySaterday=7,
} SODateDay;


typedef enum _SODateStringType {
  SODateStringDefaultType, //2010/05/21
  SODateStringKorType,  //2010년 5월 21일
  SODateStringKorType2, //YYYY.M.d (수)
  SODateStringKorType3, //10월 3일 (목)
  SODateStringBasicType, //20100521
  SODateStringTimestampType,	//2011-01-03 13:23:25
  SODateStringFilenameType,	//YYYYMMDDHHmmss
  SODateStringIMAPType, // 1-AUG-2004
  SODateStringTimeType, // 12:44:23
  SODateStringTimeAMPMType // 오전 12:44:23

} SODateStringType;

@interface MailSODateTimeUtil : NSObject {

}
+(int) hour;
+(int) hour :  (NSDate*) date;
+(int) month :  (NSDate*) date;
+(int) day : (NSDate*) date;
+(int) year :  (NSDate*) date;
+(int) month;
+(int) day;
+(int) year;

+(SODateDay) weekDay : (NSDate*) date;
+(NSString*) weekDayStr:(NSDate *)date;

+(NSDate *) dateForString : (NSString*)dateString option:(SODateStringType) option;
+(NSDate *) datePlusDay :(int) day  originDate:(NSDate*) date;
+(NSDate *) setYear:(int)year setMonth:(int)month setDay:(int)day;
+(NSDate *) getZeroDate : (NSDate *)date;
+(int) dayDiffFrom:(NSDate*)from  to:(NSDate*) to;
+(NSDate *) getDateOfThisWeek:(SODateDay)day;
+(NSDate *) getDateOfRefWeek:(SODateDay)day referenceWeek:(NSDate*)date;

+(NSString *) stringForDate: (NSDate *)date;
+(NSString *) stringForDate: (NSDate *)date option:(int) option;

+(NSString *) stringForToday;
+(NSString *) stringForTime: (NSDate *)date;
+(NSString *) stringForNow;

@end
