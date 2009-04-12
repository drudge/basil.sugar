//
//  CSBasilSugarLogViewAction.m
//  Basil.sugar
//
//  Created by Nicholas Penree on 4/10/09.
//  Copyright 2009 Conceited Software. All rights reserved.
//

#import "CSBasilSugarLogViewAction.h"
#import <EspressoFileActions.h>
#import <NSString+MRFoundation.h>

#import <Growl/Growl.h>

@implementation CSBasilSugarLogViewAction
@synthesize paused;

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
	_fileName = [[dictionary objectForKey:@"filename"] retain];
	[NSBundle loadNibNamed:@"CSBasilSugarLogViewer" owner:self];
	[GrowlApplicationBridge setGrowlDelegate:self];
	[panel setDelegate:self];
	[self clearLogView:self];
	self.paused = YES;

	return self;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification object] == panel) {
		NSLog(@"terminating log tailer...");
		[_task terminate];
		[self clearLogView:self];

	}
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib
{	
	[self clearLogView:self];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc
{	
	[_fileName autorelease];
	[_task release];
	[_fileHandle release];
	[super dealloc];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canPerformActionWithContext:(id)context
{
	return [[NSFileManager defaultManager] fileExistsAtPath:_fileName];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	[panel setTitle:[_fileName lastPathComponent]];
	[self clearLogView:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(readPipe:)
												 name:NSFileHandleReadCompletionNotification 
											   object:nil];
	
	NSPipe *pipe = [NSPipe pipe];
	
	_fileHandle = [pipe fileHandleForReading];
	[_fileHandle readInBackgroundAndNotify];
	
	_task = [[NSTask alloc] init];
	[_task setLaunchPath:@"/usr/bin/tail"];
	[_task setArguments: [NSArray arrayWithObjects:@"-f", _fileName, nil]];
	[_task setStandardOutput: pipe];
	[_task setStandardError: pipe];
	[_task launch];
	self.paused = NO;
	[panel makeKeyAndOrderFront:nil];

	return YES;
}


//------------------------------------------------------------------------------------------------------------------------------------------
#pragma mark Controller actions
//------------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)clearLogView:(id)sender
{
	if (logTextView) {
		[logTextView setFont:[NSFont fontWithName:@"Monaco" size:9.0]];
		[logTextView setTextColor:[NSColor whiteColor]];
		[logTextView setString:@""];
	}
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)addMarkerToLogView:(id)sender
{
	if (logTextView) {
		
		NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], @"NSForegroundColorAttributeName",
								 [NSFont fontWithName:@"Monaco" size:9.0], @"NSFontAttributeName",
								 [NSColor whiteColor], @"NSBackgroundColorAttributeName", nil];
		
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼\n" 
																	 attributes:attribs];
		//[[[logText textStorage] mutableString] appendString:@"________________________________________________________________________________________________________\n"];
		                                                        
		//[logText setFont:[NSFont fontWithName:@"Monaco" size:9.0]];
		//[logText setTextColor:[NSColor whiteColor]];
		[logTextView setEditable:YES];
		[logTextView insertText:string];
		[logTextView setEditable:NO];
	}
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray *growlNotifications = [NSArray arrayWithObjects: @"Generic", @"Log Updated", nil];
	
	return [NSDictionary dictionaryWithObjectsAndKeys: growlNotifications, GROWL_NOTIFICATIONS_ALL,
			growlNotifications, GROWL_NOTIFICATIONS_DEFAULT,
			nil];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)readPipe:(NSNotification *)notification
{
	NSData *data;
	NSString *text;
	
	if([notification object] != _fileHandle)
		return;
	
	data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	@try {
		[logTextView setFont:[NSFont fontWithName:@"Monaco" size:9.0]];
		[logTextView setTextColor:[NSColor whiteColor]];
	}
	@catch (NSException * e) {
		
	}
	
	if (![[[logTextView textStorage] mutableString] isEqualToString:@""]) {
		//TODO: Add growl notifications
		[GrowlApplicationBridge 
		 notifyWithTitle:[NSString stringWithFormat:@"%@ Updated", [_fileName lastPathComponent]]
		 description:(([text length] > 20)? [NSString stringWithFormat:@"%@...", [text substringToIndex:19]] : text)
		 notificationName:@"Log Updated" 
		 iconData:nil
		 priority:0
		 isSticky:NO 
		 clickContext:nil];
	}
	
	float scrollPos = [[scroller verticalScroller] floatValue]; 
	
	[[[logTextView textStorage] mutableString] appendString:text];
	
	if( scrollPos == 1.0 || scrollPos == 0.0) {
		NSRange range;
		range = NSMakeRange ([[[logTextView textStorage] mutableString] length], 0);
		[logTextView scrollRangeToVisible: range];
	}
	
	[text release];
	
	if(data != 0)
		[_fileHandle readInBackgroundAndNotify];
}

@end
