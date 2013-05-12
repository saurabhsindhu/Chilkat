//
//  MailSODictArray.h
//  SDepartment
//
//  Created by jdyang on 11. 1. 4..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MailSODictArray : NSObject <NSCoding>{
	NSMutableDictionary* dict;
	NSMutableArray* array;
}
@property (nonatomic, retain) NSDictionary* dict;
@property (nonatomic, retain) NSArray* array;


- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(id)aKey;
- (void)setObject:(id)obj forKey:(id)key;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)count;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
#if 0
- (id)circularObjectAtIndex:(NSInteger*)indexWillBeModified; // deprecated
- (id)circularObjectAtIndexAndNextIndex:(NSInteger*)indexWillBeModified; // deprecated
#endif

@end
