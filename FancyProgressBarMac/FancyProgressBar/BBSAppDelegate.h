//
//  BBSAppDelegate.h
//  FancyProgressBar
//
//  Created by Byron Wright on 5/10/12.
//  Copyright (c) 2012 Blue Bear Studio LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBSAppDelegate : NSObject <NSApplicationDelegate> {
  NSProgressIndicator * progressIndicator_;
}

@property (assign) IBOutlet NSWindow *            window;
@property (retain) IBOutlet NSProgressIndicator * progressIndicator;
@end
