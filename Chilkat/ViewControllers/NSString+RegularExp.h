//
//  NSString+RegularExp.h
//  shopScrapper
//
//  Created by JD YANG on 12. 1. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RGXMatchOption{
    SORGXMatchOptionExtractToEnd=1,
} SORGXMatchOption;

@interface NSString (RegularExp)
- (BOOL)hasSubString:(NSString*)subString;

- (NSArray*) rgxMatchAllStringsWithPatten:(NSString*)patten;
- (NSArray*) rgxMatchAllStringsWithPatten:(NSString*)patten option:(SORGXMatchOption)option;

- (NSString*) rgxMatchFirstStringWithPatten:(NSString*)patten;
- (NSString*) rgxMatchFirstStringWithPatten:(NSString*)patten option:(SORGXMatchOption)option;

- (NSNumber *) rgxMatchFirstNumberWithPatten:(NSString*)patten option:(SORGXMatchOption)option;

- (NSDictionary *) rgxDictSeparatedByPatten:(NSString*)patten;
@end