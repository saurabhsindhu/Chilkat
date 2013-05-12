//
//  MailSODateTimeUtil.m
//  WonDiet
//
//  Created by jdyang on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailSODateTimeUtil.h"
#import "MailSOUtil.h"

@implementation MailSODateTimeUtil

#pragma mark TIME UTIL
+(SODateDay) weekDay : (NSDate*) date{
	if (date==nil) {
		date=[NSDate date];
	}
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the date
	NSDate* now = (date==nil) ? [NSDate date]: date;		
	// Get the hours, minutes, seconds
	NSDateComponents* nowWeek = [cal components:NSWeekdayCalendarUnit fromDate:now];
	[cal release];
	return [nowWeek weekday];
}

+(NSDate *) getDateOfRefWeek:(SODateDay)day referenceWeek:(NSDate*)date{
	SODateDay weekday=[MailSODateTimeUtil weekDay:date];
	//if today is wed, I want monday:
	// day = mon (2), weekday = wed (4)
	// today(wed, 4) - mon (2) = 2
	// today - today_day(4)+wantday(2) = today - 2 = return value!
	return [self datePlusDay:day-weekday originDate:date];
}

+(NSDate *) getDateOfThisWeek:(SODateDay)day{
	return [self getDateOfRefWeek:(SODateDay)day referenceWeek:[NSDate date]];
}

+(NSString*) weekDayStr:(NSDate *)date{
	if (date==nil) {
		date=[NSDate date];
	}	
	int day=[self weekDay:date];
	switch (day) {
		case 2:
			return NSLocalizedString(@"월",@"");
		case 3:
			return NSLocalizedString(@"화",@"");
		case 4:
			return NSLocalizedString(@"수",@"");
		case 5:
			return NSLocalizedString(@"목",@"");
		case 6:
			return NSLocalizedString(@"금",@"");
		case 7:
			return NSLocalizedString(@"토",@"");
		case 1:
		default:
			return NSLocalizedString(@"일",@"");
	}
}

+(int) month{
	return [self month:nil];
}
+(int) day{
	return [self day:nil];
}
+(int) year{
	return [self year:nil];
}


+(NSDate *) setYear:(int)year setMonth:(int)month setDay:(int)day{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps]  ;
	[MailSOUtil log:@"dt count" value:[date retainCount]];
	[comps release];
	[gregorian release];
	return date ;	
}

+(int)hour:(NSDate*) date{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the hours, minutes, seconds
	NSDateComponents* nowHour = [cal components:NSHourCalendarUnit fromDate:date];
	[cal release];
	return nowHour.hour;
}

+(int)hour{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the date
	NSDate* now = [NSDate date];	
	// Get the hours, minutes, seconds
	NSDateComponents* nowHour = [cal components:NSHourCalendarUnit fromDate:now];
	[cal release];
	return nowHour.hour;
}

+(int)month : (NSDate*) date{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the date
	NSDate* now = (date==nil) ? [NSDate date]: date;		
	// Get the hours, minutes, seconds
	NSDateComponents* nowMonth = [cal components:NSMonthCalendarUnit fromDate:now];
	[cal release];
	return nowMonth.month;
}

+(int)day: (NSDate*) date{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the date
	NSDate* now = (date==nil) ? [NSDate date]: date;	
	// Get the hours, minutes, seconds
	NSDateComponents* nowDay = [cal components:NSDayCalendarUnit fromDate:now];
	[cal release];
	return nowDay.day;
}

+(int)year: (NSDate*) date{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	// Get the date
	NSDate* now = (date==nil) ? [NSDate date]: date;	
	// Get the hours, minutes, seconds
	NSDateComponents* nowYear = [cal components:NSYearCalendarUnit fromDate:now];
	[cal release];
	return nowYear.year;
}

+(NSDate *) datePlusDay :(int) day  originDate:(NSDate*) date{
	//NSDate *returnDt=[NSDate alloc
	if (date==nil) {
		return [NSDate dateWithTimeIntervalSinceNow:24*60*60*day];
	}
	else {
		return [NSDate dateWithTimeInterval: 24*60*60*day sinceDate:date] ;
	}
}

+(int) dayDiffFrom:(NSDate*)from  to:(NSDate*) to{
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps2 = [gregorian components:NSDayCalendarUnit fromDate:from  toDate:to  options:0];
	[gregorian release];
	return [comps2 day]; // 날짜 차이
	
}

+(NSDate *) dateForString : (NSString*)dateString option:(SODateStringType) option {
	//timestampstr : 2011-01-03 13:23:25
	NSDateFormatter *dateFormat=[[[NSDateFormatter alloc]init] autorelease];
	switch (option) {
		case SODateStringTimestampType:
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			return [dateFormat dateFromString:dateString];
		default:
			[MailSOUtil errorLog:@"dateForString not yet coded"];
			break;
	}
	return nil;
}

//default : return as 2010/05/21
//option 1 : return as 2010년 5월 21일

+(NSString *) stringForDate: (NSDate *)date{
	return [self stringForDate:date option:SODateStringDefaultType];
}
+(NSString *) stringForDate: (NSDate *)date option:(int) option{
	if (date==nil) {
		[MailSOUtil log:@"SOUtil : stringForDate : date is nil"];
		return nil;
	}
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	switch (option) {
		case SODateStringDefaultType:
			[dateFormat setDateFormat:@"YYYY/MM/dd"];
			break;
		case SODateStringBasicType:
			[dateFormat setDateFormat:@"YYYYMMdd"];
			break;			
		case SODateStringKorType:
			[dateFormat setDateFormat:@"YYYY년 M월 d일"];
			break;
		case SODateStringKorType2:
			[dateFormat setDateFormat:@"YYYY.M.d "];
			break;
		case SODateStringKorType3:
			[dateFormat setDateFormat:@"M월 d일 "];
			break;
        case SODateStringFilenameType:
            [dateFormat setDateFormat:@"YYYYMMddHHmmss"];
            break;
        case SODateStringIMAPType:
            [dateFormat setDateFormat:@"dd-MMM-YYYY"];
            break;
        case SODateStringTimeType:
            [dateFormat setDateFormat:@"HH:mm:ss"];
            break;
        case SODateStringTimeAMPMType:
            [dateFormat setDateFormat:@"HH:mm:ss"];
        default:{
            
        }
	}
	NSMutableString *dateString =[NSMutableString stringWithString: [dateFormat stringFromDate:date]];  
	if (option==SODateStringKorType2 || option==SODateStringKorType3) {
		[dateString appendString:[NSString stringWithFormat:@"(%@)", [self weekDayStr:date]]];
	}
    if (option == SODateStringTimeAMPMType) {
        if ([MailSODateTimeUtil hour:date] > 11) {
            [dateString insertString:@"오후 " atIndex:0];
            if ([MailSODateTimeUtil hour:date] > 13) {
                [dateString replaceCharactersInRange:NSMakeRange(3, 2) withString:[NSString stringWithFormat:@"%02d",[MailSODateTimeUtil hour:date]-12]];
            }
        }
        else{
            [dateString insertString:@"오전 " atIndex:0];
        }
    }
	[dateFormat release];
	return dateString;
}
+(NSString *) stringForToday{
	return [self stringForDate:[NSDate date]];
}

//return as PM 3:24:59
+(NSString *) stringForTime: (NSDate *)date{
	if (date==nil) {
		[MailSOUtil log:@"SOUtil : stringForDate : date is nil"];
		return nil;
	}
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"a hh:mm:ss"];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return dateString;
}
+(NSString *) stringForNow{
	return [self stringForTime:[NSDate date]];
}

+(NSDate*) getZeroDate:(NSDate *)date{
	int year=[self year:date];
	int month=[self month:date];
	int day=[self day:date];
	NSDate *a=[self setYear:year setMonth:month setDay:day];
	return a;
}

@end
