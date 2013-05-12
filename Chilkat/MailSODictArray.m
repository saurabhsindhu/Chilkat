//
//  MailSODictArray.m
//  SDepartment
//
//  Created by jdyang on 11. 1. 4..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailSODictArray.h"


@implementation MailSODictArray
@synthesize dict;
@synthesize array;

- (id)init{
	if (self=[super init]) {
		dict=[[NSMutableDictionary alloc]init];
		array=[[NSMutableArray	alloc]init];
	}
	return self;
}


//NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:dict forKey:@"dict"];
	[aCoder encodeObject:array forKey:@"array"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self=[super init]) {
		self.dict=[aDecoder decodeObjectForKey:@"dict"];
		self.array=[aDecoder decodeObjectForKey:@"array"];
	}
	return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (id)objectAtIndex:(NSUInteger)index{
	return [array objectAtIndex:index];
}

- (id)objectForKey:(id)aKey{
	return [dict objectForKey:aKey];
}

#if 0 //deprecated
- (id)circularObjectAtIndex:(NSInteger*)indexWillBeModified{
	int index=*indexWillBeModified;
	int cycle=(index)/[array count];
	int newIdx=index+[array count]*cycle;
	*indexWillBeModified=newIdx;
	return [array objectAtIndex:newIdx];
}

- (id)circularObjectAtIndexAndNextIndex:(NSInteger*)indexWillBeModified{
	int index=*indexWillBeModified;
	for (; index<0; index+=[array count]);
	for (; index>=[array count]; index-=[array count]);
	
	
	id retVal=[array objectAtIndex:index];
	index++;
	if (index==[array count]) {
		index=0;
	}
	*indexWillBeModified=index;
	return retVal;
}

#endif


- (void)setObject:(id)obj forKey:(id)key{
	[dict setObject:obj forKey:key];
	[array addObject:obj];
}

- (NSUInteger)indexOfObject:(id)anObject{
	return [array indexOfObject:anObject];
}

- (NSUInteger)count{
	return [array count];
}

@end
