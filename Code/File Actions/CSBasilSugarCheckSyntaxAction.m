//
//  CSBasilSugarCheckSyntaxAction.m
//  Basil.sugar
//
//  Created by Nicholas Penree on 4/14/09.
//  Copyright 2009 Conceited Software. All rights reserved.
//

#import "CSBasilSugarCheckSyntaxAction.h"
#import <EspressoSDK.h>

@implementation CSBasilSugarCheckSyntaxAction

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
	phpPath = [[dictionary objectForKey:@"php-path"] retain];
	
	return self;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc
{	
	[phpPath release];
	[super dealloc];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canPerformActionWithContext:(id)context
{
	return ([[NSFileManager defaultManager] fileExistsAtPath:phpPath] && 
			[[NSFileManager defaultManager] fileExistsAtPath:[[[context documentContext] fileURL] path]]);
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	NSString *string;
	NSAlert *sheet;
	NSDictionary *lintResults;
	
    [task setLaunchPath:phpPath];
    [task setArguments:[NSArray arrayWithObjects: @"-l", [[[context documentContext] fileURL] path], nil]];
    [task setStandardOutput:pipe];
    [task launch];
		
    string = [[NSString alloc] initWithData:[[pipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	lintResults = [self parseLintResult:string];
	[string release];
	[task release];

	sheet = [NSAlert alertWithMessageText:[lintResults objectForKey:@"CSTitle"] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[lintResults objectForKey:@"CSMessage"]];   
	[sheet beginSheetModalForWindow:[context windowForSheet] modalDelegate:nil didEndSelector:nil contextInfo:nil];
		
	return YES;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (NSDictionary *)parseLintResult:(NSString *)result
{
	NSString *title;
	NSString *message;
	
	// only english support atm, otherwise it will just toss the output into a sheet
	
	if ([result hasPrefix:@"No syntax errors detected in"]) {
		title = result;
		message = @"Please note that we are referring to the last saved version of the file when checking the syntax. Please make sure to save before checking syntax.";
	} else if ([result containsString:@"Errors parsing"]) {
		NSRange r = [result rangeOfString:@"Errors parsing"];
		
		if (r.location != NSNotFound) {
			title = [[result substringFromIndex:r.location] stringByRemovingLeadingWhitespace];
			message = [[result substringToIndex:r.location] stringByRemovingLeadingWhitespace];
		} else {
			title = @"PHP Syntax Check";
			message = result;
		}
	} else {
		title = @"PHP Syntax Check";
		message = result;
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:title, @"CSTitle", message, @"CSMessage", nil];
}
@end
