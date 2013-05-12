//
//  MailSOSingleton.m
//  SOIDX2
//
//  Created by jdyang on 10. 9. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailSOSingleton.h"


@implementation MailSOSingleton

#pragma mark Singleton
/* Add following function to each child class */
/*
static Singleton *instance;

+ (Singleton *)shared  {
	
	@synchronized(self) {
		if(!instance) {
			instance = [[Singleton alloc] init];
		}
	}
	
	return instance;
}
 */


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be retaind
}

- (oneway void)release{
    //do nothing
}

- (id)autoretain {
    return self;
}
@end
