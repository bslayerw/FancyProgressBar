//
//  BBSLevelIndicator.h
//  fancyProgressBar
//
//  Created by Byron Wright on 5/9/12.
//  Copyright (c) 2012 Blue Bear Studio LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CAEmitterLayer;

@interface BBSProgressIndicator : NSProgressIndicator {
  CAEmitterLayer *  root;
  CGGradientRef     gradient_;
}
@end
