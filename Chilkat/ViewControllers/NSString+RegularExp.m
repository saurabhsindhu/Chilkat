//
//  NSString+RegularExp.m
//  shopScrapper
//
//  Created by JD YANG on 12. 1. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "NSString+RegularExp.h"

@implementation NSString (RegularExp)

- (BOOL)hasSubString:(NSString*)subString{
    NSRange range=[self rangeOfString:subString];
    if (range.location==NSNotFound) {
        return NO;
    }
    return YES;
}

- (NSArray*) rgxMatchAllStringsWithPatten:(NSString*)patten option:(SORGXMatchOption)option{
    NSRegularExpression *rgx=[NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSArray *matches= [rgx matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    NSMutableArray *retArray= [NSMutableArray array];
    
    int modifier;
    
    if (option==SORGXMatchOptionExtractToEnd){
        for (modifier=0; modifier<[patten length]; modifier++) {
            char characterAtIndex=[patten characterAtIndex:modifier];
            char characterBeforeIndex='\0';
            if (modifier>0) {
                characterBeforeIndex=[patten characterAtIndex:modifier-1];
            }
            if ( ( characterAtIndex=='[' || characterAtIndex == '.' || characterAtIndex == '(' ) && characterBeforeIndex != '\\'  ) {
                //found
                break;
            }
        }
    }

        
    for (NSTextCheckingResult *match in matches) {
        if (option==SORGXMatchOptionExtractToEnd) {
            NSString *subStr=[self substringWithRange:match.range];
            [retArray addObject:[subStr substringFromIndex:modifier]];
        }
        else{
            [retArray addObject:[self substringWithRange:match.range]];
        }
    }
    return [NSArray arrayWithArray:retArray];
}


- (NSArray*) rgxMatchAllStringsWithPatten:(NSString*)patten{
    return [self rgxMatchAllStringsWithPatten:patten option:0];
}

- (NSString*) rgxMatchFirstStringWithPatten:(NSString*)patten{
    return [self rgxMatchFirstStringWithPatten:patten option:0];
}

- (NSNumber *) rgxMatchFirstNumberWithPatten:(NSString*)patten option:(SORGXMatchOption)option{
    NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [f numberFromString:[self rgxMatchFirstStringWithPatten:patten option:option]];
}

- (NSDictionary *) rgxDictSeparatedByPatten:(NSString*)patten{
    NSRegularExpression *rgx=[NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *matches=[rgx matchesInString:self options:NSRegularExpressionDotMatchesLineSeparators range:NSMakeRange(0, [self length])];
    NSMutableArray *strings=[NSMutableArray array];
    NSMutableArray *indexes=[NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        [indexes addObject:[NSNumber numberWithUnsignedLong:match.range.location]];
    }
    [indexes addObject:[NSNumber numberWithUnsignedInteger:[self length]]];

    
    for (int i=0; i<[indexes count]-1 ; i++) {
        [strings addObject:[self substringWithRange:NSMakeRange([[indexes objectAtIndex:i] intValue], [[indexes objectAtIndex:i+1] intValue] - [[indexes objectAtIndex:i] intValue]) ]];
    }

    NSMutableDictionary *returnDict=[NSMutableDictionary dictionary];
    for (int i=0; i<[strings count]; i++) {
        NSString *string=[strings objectAtIndex:i];
        [returnDict setObject:string forKey:[string rgxMatchFirstStringWithPatten:patten]];
    }
    return returnDict;
}

- (NSString*) rgxMatchFirstStringWithPatten:(NSString*)patten option:(SORGXMatchOption)option{
    NSRegularExpression *rgx=[NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSTextCheckingResult *match= [rgx firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if (match.range.location==NSNotFound) {
        return nil;
    }
    NSString *resultStr=[self substringWithRange:match.range];

    if (option==0) {
        return resultStr;
    }
    else if (option==SORGXMatchOptionExtractToEnd){
        int modifier;
        for (modifier=0; modifier<[resultStr length]; modifier++) {
            char characterAtIndex=[patten characterAtIndex:modifier];
            char characterBeforeIndex='\0';
            if (modifier>0) {
                characterBeforeIndex=[patten characterAtIndex:modifier-1];
            }
            if ( ( characterAtIndex=='[' || characterAtIndex == '.' ) && characterBeforeIndex != '\\'  ) {
                //found
                break;
            }
        }
        return [resultStr substringFromIndex:modifier];
    }
    return nil;
}


@end
