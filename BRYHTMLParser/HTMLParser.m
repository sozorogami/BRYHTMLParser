//
//  HTMLParser.m
//  StackOverflow
//
//  Created by Ben Reeves on 09/03/2010.
//  Copyright 2010 Ben Reeves. All rights reserved.
//

#import "LibXMLHTMLNode.h"
#import "HTMLParser.h"
#import <libxml/HTMLparser.h>

@implementation HTMLParser {
    htmlDocPtr _doc;
}

-(LibXMLHTMLNode*)doc
{
	if (_doc == NULL)
		return NULL;
	
	return [[LibXMLHTMLNode alloc] initWithXMLNode:(xmlNode*)_doc];
}

-(LibXMLHTMLNode*)html
{
	if (_doc == NULL)
		return NULL;
	
	return [[self doc] findChildTag:@"html"];
}

-(LibXMLHTMLNode*)head
{
	if (_doc == NULL)
		return NULL;

	return [[self doc] findChildTag:@"head"];
}

-(LibXMLHTMLNode*)body
{
	if (_doc == NULL)
		return NULL;
	
	return [[self doc] findChildTag:@"body"];
}

-(instancetype)initWithString:(NSString*)string error:(NSError**)error
{ 
	if (self = [super init])
	{
		_doc = NULL;
		
		if ([string length] > 0)
		{
			CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
			const char *enc = CFStringGetCStringPtr(cfencstr, 0);
			// _doc = htmlParseDoc((xmlChar*)[string UTF8String], enc);
			int optionsHtml = HTML_PARSE_RECOVER;
			optionsHtml = optionsHtml | HTML_PARSE_NOERROR; //Uncomment this to see HTML errors
			optionsHtml = optionsHtml | HTML_PARSE_NOWARNING;
			_doc = htmlReadDoc ((xmlChar*)[string UTF8String], NULL, enc, optionsHtml);
		}
		else 
		{
			if (error) {
				*error = [NSError errorWithDomain:@"HTMLParserdomain" code:1 userInfo:nil];
			}
		}
	}
	
	return self;
}

#ifdef NS_UNAVAILABLE
- (instancetype)init NS_UNAVAILABLE {
    return nil;
}
#endif

-(instancetype)initWithData:(NSData*)data error:(NSError**)error
{
	if (self = [super init])
	{
		_doc = NULL;

		if (data)
		{
			CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
			const char *enc = CFStringGetCStringPtr(cfencstr, 0);
			//_doc = htmlParseDoc((xmlChar*)[data bytes], enc);
			
			_doc = htmlReadDoc((xmlChar*)[data bytes],
							 "",
							enc,
							XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		}
		else
		{
			if (error) 
			{
				*error = [NSError errorWithDomain:@"HTMLParserdomain" code:1 userInfo:nil];
			}

		}
	}
	
	return self;
}

-(instancetype)initWithContentsOfURL:(NSURL*)url error:(NSError**)error
{
	
	NSData * _data = [[NSData alloc] initWithContentsOfURL:url options:0 error:error];

	if (_data == nil || *error)
	{
		return nil;
	}
	
	self = [self initWithData:_data error:error];
	
	
	return self;
}


-(void)dealloc
{
	if (_doc)
	{
		xmlFreeDoc(_doc);
	}
	
}

@end
