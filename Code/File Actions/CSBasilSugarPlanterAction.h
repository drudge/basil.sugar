//
//  CSBasilSugarPlanterAction.h
//  Basil.sugar
//
//  Created by Nicholas Penree on 4/10/09.
//  Copyright 2009 Conceited Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CSBasilSugarPlanterAction : NSObject {
	IBOutlet id planterSheet;
}

- (IBAction)cancelPlanting:(id)sender;
- (IBAction)doPlanting:(id)sender;

@end
