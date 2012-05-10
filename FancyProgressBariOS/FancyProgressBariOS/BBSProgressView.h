//
//  BBSProgressView.h
//  FancyProgressBariOS
//
//  Created by Byron Wright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAEmitterLayer;
@class BBSProgressLayerDelegate;

@interface BBSProgressView : UIProgressView {
  CAEmitterLayer *            root;
  CGGradientRef               gradient_;
  BBSProgressLayerDelegate *  layerDelegate_;
  CALayer *                   progressLayer_;
}

@end
