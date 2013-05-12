//  util.m
//  DietBook23
//
//  Created by jdyang on 10. 4. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailSOUtil.h"
#import "MailSODateTimeUtil.h"

static MailSOUtil *sharedSoUtil=nil;

@implementation MailSOUtil
@synthesize dic;

/*
+(void)setVersion:(NSInteger)aVersion{
	[[NSUserDefaults standardUserDefaults] setInteger:aVersion forKey:@"__SO__VERSION__"];
}
 */

+(BOOL) string:(NSString*)string existInArray:(NSArray*)array{
    for (NSString *str in array) {
        if ([string isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

+(NSString*)version{
	NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    return [plistData objectForKey:@"CFBundleVersion"];
;
}

+(NSArray*)dictToSortArray:(NSDictionary*)dict sortKey:(NSString*)indexKey{
	NSMutableArray *array=[[[dict allValues] mutableCopy] autorelease];
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:indexKey ascending:YES ] autorelease];
	[array sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
	return array;
}

+(NSDictionary*) dictInArrayToArrayInDict:(NSArray*)array keyPath:(NSString*)keyPath{
    
    NSMutableDictionary *retDict=[NSMutableDictionary dictionary];
    for (NSDictionary *dict in array){
        id key=[dict objectForKey:keyPath];
        NSMutableArray *insideArray=[retDict objectForKey:key];
        if (insideArray==nil) {
            insideArray=[NSMutableArray array];
            [retDict setObject:insideArray forKey:key];
        }
        [insideArray addObject:dict];
    }
    return retDict;
}
#pragma mark StatusBar
-(void)setNetworkActivityIndicatorVisibleNo{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
-(void)setNetworkActivityIndicatorVisibleYES{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark Thread
-(void)addOperation:(NSOperation*)operation{
    if (operationQueue==nil) {
        operationQueue=[[NSOperationQueue alloc] init];
    }
    [operationQueue addOperation:operation];
}

-(void)addOperationWithBlock:(void (^)(void))block{
    if (operationQueue==nil) {
        operationQueue=[[NSOperationQueue alloc] init];
    }
    [operationQueue addOperationWithBlock:block];
}



#pragma mark FILE UTIL
#define kAppDataFileName @"/MailSOUtil_data.plist"
+(NSString *)appDataFilePath{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingFormat:kAppDataFileName];
}
#undef kAppDataFileName

+(NSString *)filePathWithName: (NSString *)filename{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingFormat:[NSString stringWithFormat:@"/%@",filename],nil];	
}

+(NSArray*)filenamesInDirectory:(NSSearchPathDirectory) directory{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:nil];
    return fileList;
}


#pragma mark MACRO-Alert
//알럿을 현재 무조건 보여주기 --> 하나씩 보여주기로 교체
static BOOL MailSOUtilIsShowingAlert;

+(void) alert:(NSString*)msg{
    [[MailSOUtil shared] alert:msg title:nil];
}

-(void) alert:(NSString*)msg title:(NSString *)title{
    @synchronized(self){
        if (title==nil) {
            title=@"알림";
        }
        if (MailSOUtilIsShowingAlert==NO) {
            MailSOUtilIsShowingAlert=YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];            
            [alert release];
            
        }
        else{
            // add to queue
            [alertMsgQueue addObject:msg];
            [alertTitleQueue addObject:title];
        }
    }
}


//alert view deleagte. queue 가 남아있으면 하나씩 꺼냄
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    @synchronized(self){
        if ([alertMsgQueue count]) {
            NSString *msg=[alertMsgQueue objectAtIndex:0];
            NSString *title=[alertTitleQueue objectAtIndex:0];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [alertMsgQueue removeObjectAtIndex:0];
            [alertTitleQueue removeObjectAtIndex:0];
        }
        else{
            MailSOUtilIsShowingAlert=NO;
        }
    }
}




+(void) alert:(NSString*)msg title:(NSString*) title{
	UIAlertView *exitAlert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
	[exitAlert show];
	[exitAlert release];
}

+ (unsigned long long int) documentsFolderSize {
    NSFileManager *_manager = [NSFileManager defaultManager];
    NSArray *_documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *_documentsDirectory = [_documentPaths objectAtIndex:0];   
    NSArray *_documentsFileList;
    NSEnumerator *_documentsEnumerator;
    NSString *_documentFilePath;
    unsigned long long int _documentsFolderSize = 0;
	
    _documentsFileList = [_manager subpathsAtPath:_documentsDirectory];
    _documentsEnumerator = [_documentsFileList objectEnumerator];
    while (_documentFilePath = [_documentsEnumerator nextObject]) {
        NSDictionary *_documentFileAttributes = [_manager attributesOfItemAtPath:[_documentsDirectory stringByAppendingPathComponent:_documentFilePath] error:nil];
        _documentsFolderSize += [_documentFileAttributes fileSize];
    }
	
    return _documentsFolderSize;
}


#pragma mark LOG
+(void) log:(NSString *)msg value:(float)value{
#if DEBUG
	NSLog([NSString stringWithFormat:@"MailSOUtilLog: %@ : %f",msg,value],nil);
#endif
}
+(void) log:(NSString *)msg{
#if DEBUG
	NSLog([NSString stringWithFormat:@"MailSOUtilLog: %@",msg],nil);
#endif
}

+(void) log:(NSString *)msg obj:(NSObject*)obj{
#if DEBUG
	NSLog([NSString stringWithFormat:@"MailSOUtilLog: %@ obj:%@",msg,[obj description]],nil);
#endif
}

+(void)cacheLog:(NSString *)msg{
#if	SOUTIL_DEBUGCache
	NSLog([NSString stringWithFormat:@"*** Cache *** MailSOUtilCacheLog: %@ ",msg],nil);
#endif
}


+(void)errorLog:(NSString *)msg{
	NSLog([NSString stringWithFormat:@"*** ERROR *** MailSOUtilErrorLog: %@ ",msg],nil);
}
+(void) errorLog:(NSString*)msg error:(NSError*)error{
    if ([error respondsToSelector:@selector(localizedRecoverySuggestion)]) {
        NSLog([NSString stringWithFormat:@"*** ERROR *** MailSOUtilErrorLog: %@ \n\
               *** ERROR ***  - Description: %@ \n\
               *** ERROR ***  - Reason: %@ \n\
               *** ERROR ***  - Suggestion: %@", msg, [error description], 
               [error localizedFailureReason], [error localizedRecoverySuggestion]],nil);

    }
    else{
        NSLog([NSString stringWithFormat:@"*** ERROR *** MailSOUtilErrorLog: %@ \n\
               *** ERROR ***  - Description: %@",msg,[error description]],nil);
    }
#ifdef DEBUG
    assert(0);
#endif
}

+(void) frameLog:(UIView*)view{
	NSLog([NSString stringWithFormat:@"*MailSOUtilFrameLog: viewTag:%d: x:%f y:%f width:%f height:%f",
		   view.tag, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height
		   ],nil);
}

+(void) timeLogStart:(NSString*)identifier{
	[[MailSOUtil shared] setObject:[NSDate date] forKey:identifier];
}
+(void) timeLogEnd:(NSString*)identifier{
	NSDate *dt=[[MailSOUtil shared] objectForKey:identifier];
	NSDate *now=[NSDate date];
	NSTimeInterval interval=[now timeIntervalSinceDate:dt];
	NSLog([NSString stringWithFormat:@"%@ executeTime: %lf",identifier,interval],nil);
}


+(NSString *) lastExecutedDay{
	return [[NSUserDefaults standardUserDefaults] objectForKey:__SOUTIL_LASTEXECUTEDDAY__];
}

+(void) setTodayAsExecutedDay{
	NSString *str=[[MailSODateTimeUtil stringForToday] retain];
	[[NSUserDefaults standardUserDefaults] setObject:str forKey:__SOUTIL_LASTEXECUTEDDAY__];
	[str release];
}

+(void) logForDate:(NSDate *)date{
	NSString *str=[[MailSODateTimeUtil stringForDate:date] retain];
	[MailSOUtil log:str];
	[str release];
}

#pragma mark String

////////////////////////////////////////
// +(BOOL) string:(NSString*)aString containsCharacterInSet:(NSCharacterSet*)aSet{
// aString에 aSet에 해당하는 문자가 포함되었는지 검사 (문자가 포함되었으면 YES, 문자가 하나도 포함되지 않았다면 NO)
//
+(BOOL) string:(NSString*)aString containsCharacterInSet:(NSCharacterSet*)aSet{
	//캐릭터셋
	if (aString==nil || [aString isEqualToString:@""] ) {
		return YES;
	}
	NSRange range=[aString rangeOfCharacterFromSet:aSet];
	if (range.location==NSNotFound) {
		return NO;
	}
	return YES;
}
+(NSString*) stringTrim:(NSString*)string{
    if (string==nil) {
        return nil;
    }
    int len=[string length];
    if (len==0 || (len == 1 && [string isEqualToString:@" "])){
        return string;
    }
	int start=0;
	int end=len-1;
	while ([string characterAtIndex:start]==' ' || [string characterAtIndex:start]=='\n' ) {
		start++;
	}
	while ([string characterAtIndex:end]==' ' || [string characterAtIndex:end]=='\n' ) {
		end--;
	}
	NSRange range;
	range.location=start;
	range.length=end-start+1;
	return [string substringWithRange:range];
}

////
// +(BOOL) string:(NSString*)aString containsCharacterInSetOnly:(NSCharacterSet*)aSet{
// aString이 aSet의 문자로만 구성되었는지 검사 
+(BOOL) string:(NSString*)aString containsCharacterInSetOnly:(NSCharacterSet*)aSet{
	//캐릭터셋
	if (aString==nil || [aString isEqualToString:@""] ) {
		return YES;
	}
	NSMutableCharacterSet * characterSet=[(NSMutableCharacterSet*) aSet copy];
	
	if (characterSet==nil) {
		characterSet=[[NSMutableCharacterSet punctuationCharacterSet] retain];
		[characterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
		NSRange spaceR;
		spaceR.location=(unsigned int)' ';
		spaceR.length=1;
		[characterSet addCharactersInRange:spaceR];		
	}
	NSCharacterSet* invertedSet=[characterSet invertedSet];
	
	NSRange range=[aString rangeOfCharacterFromSet:invertedSet];
	[characterSet release];
	if (range.location==NSNotFound ) {
		return YES;
	}
	return NO;	
}


////////////////////////////////////////
// stringHasOnlyCharacterSet  // deprecated!!!!!
// aString에 aSet에 해당하는 문자만 포함하는지 검사 (다른 문자가 포함되었다면 NO, aSet내부의 문자로 구성되었다면 YES)
// aSet이 nil일 경우, 특수문자가 포함되어있는지 검사 (특수 문자가 포함되었다면 NO 이외에는 YES)
//

+(BOOL) stringHasOnlyCharacterSet:(NSString*)aString characterSet:(NSCharacterSet*)aSet{
	return [self string:aString containsCharacterInSetOnly:aSet];
}



#pragma mark SINGLETON
+(MailSOUtil*) shared{
	@synchronized(self)
	{
		if (sharedSoUtil==nil) {
			sharedSoUtil=[[MailSOUtil alloc]init];
		}
	}
	return sharedSoUtil;
}

- (id) init{
    self=[super init];
    if (self) {
        dic=[[NSMutableDictionary alloc]init];
        alertMsgQueue=[[NSMutableArray alloc]init];
        alertTitleQueue=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)key{
	[sharedSoUtil.dic setObject:anObject forKey:key];	
}
- (id)objectForKey:(id)key{
	return [sharedSoUtil.dic objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key{
	[sharedSoUtil.dic setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key{
	return [sharedSoUtil.dic  valueForKey:key];
}

- (void)setInt:(NSInteger)value forKey:(NSString *)key{
	[sharedSoUtil.dic setValue:[NSString stringWithFormat:@"%d",value] forKey:key];
}

- (NSInteger)intForKey:(NSString *)key{
	return [[sharedSoUtil.dic  valueForKey:key] intValue];
}


- (BOOL)boolForKey:(NSString *)key{
	if ([[sharedSoUtil.dic objectForKey:key] isEqualToString:@"Y"]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName{
	if (value) {
		[sharedSoUtil.dic setObject:@"Y" forKey:defaultName];
	}
	else {
		[sharedSoUtil.dic setObject:@"N" forKey:defaultName];
	}
}



#pragma mark ANSI C FUNCTION

-(NSString*) itos: (NSInteger) integer{
	return [NSString stringWithFormat:@"%d",integer];
}
-(NSInteger) stoi: (NSString*) string{
	return [string intValue];
}

#pragma mark Graphic Layout
-(CGRect)makeNextLabelFrame:(UITextView*) txtView{
	return CGRectMake(20, txtView.frame.size.height+txtView.frame.origin.y+10 , 290, 21);
}

-(CGRect)makeNextLabelFrameL:(UILabel*) label{
	return CGRectMake(25, label.frame.size.height+label.frame.origin.y-5, 290, 21);
}

-(CGRect)makeNextViewFrame:(UILabel*) label with:(UITextView*)original{
	float height=original.frame.size.height;
	return CGRectMake(20, label.frame.size.height+label.frame.origin.y-5, 290, height);
}



+(NSArray*)recursiveSubviews:(UIView*)view includeSelf:(BOOL)includeSelf{
	if (includeSelf==NO) {
		[MailSOUtil errorLog:@"not coded : recursiveSubView"];
		return nil;
	}

	NSMutableArray* ret=[NSMutableArray arrayWithObject:view];
	NSArray* subView=[view subviews];
	if (subView!=nil) {
		for (UIView* view in subView) {
			[ret addObjectsFromArray:[self recursiveSubviews:view includeSelf:YES] ];
		}
	}
	return ret;
}

+(UIView*)subViewOf:(UIView*)view tag:(int)tag{
	NSArray* subView=[view subviews];
    for (UIView *view in subView){
        if (view.tag==tag) {
            return view;
        }
    }
    return nil;
}


+(void) view:(UIView*)view changeHeight:(float)aNewHeight{
	view.frame=CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, aNewHeight);
}

+(void) view:(UIView*)view changeWidth:(float)aNewWidth{
	view.frame=CGRectMake(view.frame.origin.x, view.frame.origin.y, aNewWidth, view.frame.size.height);
}

+(void) view:(UIView*)view changeWidth:(float)aNewWidth changeHeight:(float)aNewHeight{
	view.frame=CGRectMake(view.frame.origin.x, view.frame.origin.y, aNewWidth, aNewHeight);    
}

+(void) view:(UIView*)view changeWidth:(float)aNewWidth height:(float)aNewHeight{
	view.frame=CGRectMake(view.frame.origin.x, view.frame.origin.y, aNewWidth, aNewHeight);
}


+(void) view:(UIView*)view changeX:(float)x{
	[self view:view changeX:x changeY:view.frame.origin.y];
}
+(void) view:(UIView*)view changeY:(float)y{
	[self view:view changeX:view.frame.origin.x changeY:y];
}

+(void) view:(UIView*)view changeX:(float)x changeY:(float)y{
	view.frame=CGRectMake(x,y, view.frame.size.width, view.frame.size.height);
}


+(BOOL) areContainNilOrEmptyStrWithCount:(NSUInteger)count,	... {
	va_list args;
    va_start(args, count);
    for (int i=0; i<count; i++)
    {
		NSString* object=va_arg(args,id);
		if (object==nil  || [object isEqualToString:@""]) {
			return YES;
		}
	}
    va_end(args);
	return NO;
}

+(BOOL) findAndResignFirstResponder:(UIView	*)view{
	if (view.isFirstResponder) {
        [view resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in view.subviews) {
        if ([MailSOUtil findAndResignFirstResponder:subView])
            return YES;
    }
    return NO;	
}


+(NSDictionary*) dictionaryWithNullObjectsAndKeysWithCount:(NSUInteger)count, ... {
	NSMutableDictionary* dict=[NSMutableDictionary	dictionary];
	va_list args;
    va_start(args, count);
    for (int i=0; i<count; i++)
    {
		id object=va_arg(args,id);
		id key=va_arg(args,id);
		if (object!=nil) {
			[dict setObject:object forKey:key];
		}
    }
    va_end(args);
	return dict;
}



-(void)dealloc {
	[dic release];
	[super dealloc];
}

@end

@implementation SODateData
@synthesize date;
@synthesize data;
@synthesize dataID;
@end
