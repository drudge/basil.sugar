//
//  CSBasilSugarLogViewAction.h
//  Basil.sugar
//
//  Created by Nicholas Penree on 4/10/09.
//  Copyright 2009 Conceited Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface CSBasilSugarLogViewAction : NSObject <GrowlApplicationBridgeDelegate> {
	IBOutlet id logTextView;
	IBOutlet id panel;
	IBOutlet id scroller;
	
	NSTask *_task;
	NSFileHandle *_fileHandle;
	NSString *_fileName;
	
	BOOL paused;
}

- (IBAction)clearLogView:(id)sender;
- (IBAction)addMarkerToLogView:(id)sender;

- (NSDictionary *)registrationDictionaryForGrowl;

@property BOOL paused;

@end
