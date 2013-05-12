//
//  MailSOWebUtil.m
//  SOIDX2
//
//  Created by jdyang on 10. 9. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailSOWebUtil2.h"
#import "MailSOUtil.h"

//#import "UIImage+Resize.h"

#ifndef SOWEBUtilLog
#define SOWEBUtilLog 1
#endif

@implementation SOAsyncDataCollection
@synthesize data;
@synthesize dataLength;
@synthesize delegate;
@synthesize identifier;
@synthesize progressPercentage;

-(SOAsyncDataCollection*)init{
    self=[super init];
    if (self) {
        data=[[NSMutableData alloc] init];
    }
    return self;
}
-(void)dealloc{
    [data release];
    [super dealloc];
}

@end



static MailSOWebUtil *sharedMailSOWebUtil=nil;


@implementation MailSOWebUtil
@synthesize baseURL;

+(MailSOWebUtil*) shared{
	@synchronized(self)
	{
		if (sharedMailSOWebUtil==nil) {
			sharedMailSOWebUtil=[[MailSOWebUtil alloc]init];
		}
	}
	return sharedMailSOWebUtil;
}

-(id)init{
    self=[super init];
    if (self) {
        asyncDataDic=[[NSMutableDictionary alloc] init];
        encoding=NSUTF8StringEncoding;
    }
    return self;
}


-(void)loadWithBaseURL:(NSString*)urlStr {
    [MailSOUtil log:[NSString stringWithFormat:@"베이스 URL 설정 [%@]",urlStr]];
	self.baseURL=[urlStr stringByAppendingString:@"/"];
}


-(NSURL*)urlWithURLString:(NSString*)urlStr{
	if (urlStr==nil) {
		[MailSOUtil errorLog:@"urlWithURLStr error"];
		return nil;
	}
	NSString*	finalURLStr=baseURL?[baseURL stringByAppendingString:urlStr]:urlStr;
	return [NSURL URLWithString:[finalURLStr stringByAddingPercentEscapesUsingEncoding:encoding]]; 
}

-(NSString*)strWithURLString:(NSString*)urlStr parameters:(NSDictionary*)parameters{
	return [NSString stringWithContentsOfURL:[self urlWithURLString:urlStr parameters:parameters] encoding:NSUTF8StringEncoding error:nil];
}

/*
 urlWithURLString :parameter
	pass parameter (php-style) by nsdict type, nil can be accepted
 */
-(NSURL*)urlWithURLString:(NSString*)urlStr parameters:(NSDictionary*)parameters{
	NSMutableString*	finalURLStr=[NSMutableString stringWithString:[baseURL stringByAppendingString:urlStr]];
	if ([MailSOUtil string:finalURLStr containsCharacterInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]]) {
		[finalURLStr appendFormat:@"&%@",[MailSOWebUtil parameters2Str:parameters]];		
	}
	else {
		[finalURLStr appendFormat:@"?%@",[MailSOWebUtil parameters2Str:parameters]];		
	}
#if SOWEBUtilLog
    NSLog([NSString stringWithFormat:@"[MailSOWebUtil] makeURL: %@",finalURLStr],nil);
#endif
	return [NSURL URLWithString:[finalURLStr stringByAddingPercentEscapesUsingEncoding:encoding]]; 	
}


-(NSString*)stringWithURLString:(NSString*)aURL{
	NSString* finalURLStr=[baseURL stringByAppendingString:aURL];
	NSURL *finalUrl=[NSURL URLWithString:[finalURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
#if SOWEBUtilLog
    NSLog([NSString stringWithFormat:@"[MailSOWebUtil] stringWithURLString: %@",finalURLStr],nil);
#endif
	NSString *sourceStr = [NSString stringWithContentsOfURL:finalUrl encoding:encoding error:nil];
	return sourceStr;
}

+(NSString*)parameters2Str:(NSDictionary*)parameters{
	NSMutableString *paramStr=[NSMutableString string];
	if (parameters==nil) {
		return @"";
	}
	
	NSString *key;
	for (key in parameters) {
		id obj=[parameters objectForKey:key];
		if (obj==nil) {
			continue;
		}
		if ( [obj isKindOfClass: [NSString class] ] == YES) {
			NSString *text=[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (text!=nil && [text isEqualToString:@""]==NO) {
				[paramStr appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
			}
		} 
		else if ([obj respondsToSelector:@selector(text)]==YES ) {
			NSString *text=[[obj text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (text!=nil && [text isEqualToString:@""]==NO) {
				[paramStr appendString:[NSString stringWithFormat:@"%@=%@&",key,[obj text]]];
			}			
		}
		
		else if ([obj isKindOfClass: [NSNumber class] ] == YES) {
			const char *objType=[obj objCType];
			if (*objType=='i') {
				[paramStr appendString:[NSString stringWithFormat:@"%@=%d&",key,[obj intValue]]];
			}
			else if (*objType=='d') {
				[paramStr appendString:[NSString stringWithFormat:@"%@=%f&",key,[obj doubleValue]]];
			}
			else {
				[MailSOUtil errorLog:@" parameter wrong!!!!"];
			}
		}
		else {
			[MailSOUtil errorLog:@" parameter wrong!!!!"];
			return nil;
		}
	}
	return paramStr;
}

-(BOOL)boolWithURLString:(NSString*)aURL{
    return [[self stringWithURLString:aURL] boolValue];
}

-(void)touchURLString:(NSString*)aURL{
    NSString* finalURLStr=[baseURL stringByAppendingString:aURL];
	NSURL *finalUrl=[NSURL URLWithString:[finalURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
    NSURLConnection *connection=[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:finalUrl] delegate:nil];
    [connection start];
}


-(int)intWithURLString:(NSString*)aURL{
	[MailSOUtil log:aURL];
	NSString* str=[self stringWithURLString:aURL];
	return [str intValue];
}
-(float)floatWithURLString:(NSString*)aURL{
	NSURL *url=[self urlWithURLString:aURL];
    NSString *str=[NSString stringWithContentsOfURL:url encoding:encoding error:nil];
    return [str floatValue];
}

-(UIImage*)imageWithURLString:(NSString*)aURL{
	NSURL *url=[self urlWithURLString:aURL];
	NSData *data=[NSData dataWithContentsOfURL:url];
	UIImage *img=[UIImage imageWithData:data];
	return img;
}

- (id)postDataWithURLString:(NSString*)aURL dataStr:(NSString*)dataStr returnType:(NSString*)type{
	NSData *data=[dataStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [data length]];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[self urlWithURLString:aURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:data];
	NSURLResponse *response;
	NSError *error;
	NSData *responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error!=nil) {
		//[MailSOUtil errorLog:@"postData" error:error];
        NSLog(@"%s error", __func__);
	}
	if ([type isEqualToString:@"string"]) {
		return [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	}
	return responseData;
}

-(void)asyncHttpRequest:(NSURL*)aURL delegate:(id)aDelegate identifier:(NSString*)identifier param:(NSDictionary*)aParam method:(BOOL)isGet {
    if (aParam==nil) {
        NSURLConnection *connection=[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:aURL] delegate:self];
        SOAsyncDataCollection *asyncData=[[SOAsyncDataCollection  alloc] init];
        asyncData.delegate=aDelegate;
        asyncData.identifier=identifier;
        [asyncDataDic setObject:asyncData  forKey:connection];
        [asyncData release];
        [connection start];

    }
    else{
        [MailSOUtil errorLog:@"not coded : MailSOWebUtil"];
        exit(1);
    }
}

-(void)asyncHttpRequest:(NSURL*)aURL delegate:(id)aDelegate identifier:(NSString*)identifier{
    [self asyncHttpRequest:aURL delegate:aDelegate identifier:identifier  param:nil method:NO];
}

-(NSString*) stringWithURLString:(NSString *)urlString postData:(NSData *)postData
{
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSURL *url = [self urlWithURLString:urlString] ;
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    NSLog(@"%s : trying %@ with %@", __func__, url, postData);
    [req setHTTPMethod:@"POST"];
    [req setValue:postLength forHTTPHeaderField:@"Content-length"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:postData];
    
    NSData *ret = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    [req release];
    
    if (error) {
        NSLog(@"error: %@", error);
        return NO;
    }
    
    return [NSString stringWithCharacters:[ret bytes] length:[ret length]];
}

-(BOOL) boolWithURLString:(NSString *)aURL postData:(NSData *)postData
{
    return [[self stringWithURLString:aURL postData:postData] boolValue];
}

#define USERFILE    @"userfile"
/*
-(NSData*) uploadImage:(UIImage*)image toURLString:(NSString*)urlString filename:(NSString*)fileName resize:(CGSize)resize{
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[self urlWithURLString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    //resize image
    UIImage *resizedImage=nil;
    if ( resize.width!=0 || resize.height!=0) {
        if (image.size.width > resize.width || image.size.height > resize.height) {
            resizedImage=[image resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                            bounds:resize
                                              interpolationQuality:kCGInterpolationMedium];        
        }
    }
    else{
        resizedImage=image;
    }
    
    
    //Set Header and content type of your request.
    
    NSString *boundary = [NSString stringWithString:@"---------------------------Boundary Line---------------------------"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    // now lets create the body of the request.
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",USERFILE, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:UIImageJPEGRepresentation(resizedImage, 90)]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[[NSString stringWithFormat:@"geotag=%@&", [self _currentLocationMetadata]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set body with request.
    [request setHTTPBody:body];
    [request addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    // now lets make the connection to the web
    NSData *ret = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
        return nil;
    }
    return ret;
}

*/

/// URL Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    SOAsyncDataCollection *dataCollection=[asyncDataDic objectForKey:connection];
    dataCollection.dataLength=response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    SOAsyncDataCollection *dataCollection=[asyncDataDic objectForKey:connection];
    [dataCollection.data appendData:data];
}

@end
