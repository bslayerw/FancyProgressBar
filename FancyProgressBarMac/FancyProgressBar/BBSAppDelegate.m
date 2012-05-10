//
//  BBSAppDelegate.m
//  FancyProgressBar
//
//  Created by Byron Wright on 5/10/12.
//  Copyright (c) 2012 Blue Bear Studio LLC. All rights reserved.
//

#import "BBSAppDelegate.h"

@implementation BBSAppDelegate

@synthesize window = _window;
@synthesize progressIndicator = progressIndicator_;

- (void)dealloc {
  [progressIndicator_ release];
  [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

@end
