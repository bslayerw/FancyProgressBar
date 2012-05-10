//
//  BBSAppDelegate.h
//  FancyProgressBariOS
//
//  Created by Byron Wright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBSViewController;

@interface BBSAppDelegate : UIResponder <UIApplicationDelegate> {
  UIProgressView * progressView_;
}

@property (strong, nonatomic) UIWindow *                window;
@property (strong, nonatomic) BBSViewController *       viewController;
@property (strong, nonatomic) IBOutlet UIProgressView * progressView;
@end
