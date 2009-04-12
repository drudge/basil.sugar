//
//  CSBasilSugarPlanterAction.m
//  Basil.sugar
//
//  Created by Nicholas Penree on 4/10/09.
//  Copyright 2009 Conceited Software. All rights reserved.
//

#import "CSBasilSugarPlanterAction.h"
#import <EspressoFileActions.h>
#import <NSString+MRFoundation.h>


@implementation CSBasilSugarPlanterAction

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
	//fileName = [[dictionary objectForKey:@"filename"] retain];
	
	return self;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc
{	
	//[fileName autorelease];
	[super dealloc];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canPerformActionWithContext:(id)context
{
	return YES;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	if (!planterSheet)
		[NSBundle loadNibNamed:@"CSBasilSugarPlanter" owner:self];
		
	[NSApp beginSheet:planterSheet modalForWindow:[context windowForSheet]
									modalDelegate:self
									didEndSelector:nil
										contextInfo:nil];
	
	return YES;
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)cancelPlanting:(id)sender
{
	[planterSheet orderOut:sender];
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)doPlanting:(id)sender
{
	[self cancelPlanting:sender];
}

@end
