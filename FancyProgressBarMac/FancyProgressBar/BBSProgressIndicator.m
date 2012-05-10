//
//  BBSLevelIndicator.m
//  fancyProgressBar
//
//  Created by Byron Wright on 5/9/12.
//  Copyright (c) 2012 Blue Bear Studio LLC. All rights reserved.
//

#import "BBSProgressIndicator.h"
#import <QuartzCore/QuartzCore.h>


@interface BBSProgressIndicator ()
- (void)initializeParticleSystem;
- (void)initializeGraphics;
@end



@implementation BBSProgressIndicator

//------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeParticleSystem];
      [self initializeGraphics];
    }    
    return self;
}

//------------------------------------------------------------------------------
- (void)awakeFromNib {
  [self initializeParticleSystem];
  [self initializeGraphics];
}

//------------------------------------------------------------------------------
- (void)initializeParticleSystem {
  // Byron: All this stuff is hard coded. All this should really be exposed
  // as properties of the class to make it highly configurable.
  // This is just an example and WIP
  
  root = [[CAEmitterLayer alloc] init];
	//Load the spark image for the particle
	const char* fileName = [[[NSBundle mainBundle] pathForResource:@"circle" ofType:@"png"] UTF8String];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
	id img = (id) CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
	root.anchorPoint = CGPointMake(0.0f, 0.0f);
  
	root.renderMode = kCAEmitterLayerAdditive;
  root.emitterShape = kCAEmitterLayerRectangle;
	[root setName:@"rootEmitter"];
	//Invisible particle representing the rocket before the explosio
	//The particles that make up the explosion
	CAEmitterCell * firework = [CAEmitterCell emitterCell];
  firework.color = CGColorCreateGenericRGB(0.5f, 0.0f, 0.0f, 1.0f);
	firework.contents = img;
	firework.birthRate = 999;
	firework.scale = 0.3;
  firework.redSpeed = 0.1;
  firework.redRange = -0.5;
  firework.alphaRange = 0.2;
	firework.velocity = 20;
	firework.lifetime = 2;
	firework.alphaSpeed = -0.2;
	firework.yAcceleration = -10;
	firework.beginTime = 0.0;
	firework.duration = 0.1;
	firework.emissionRange = 2 * M_PI;
	firework.scaleSpeed = -0.1;
	firework.spin = 0;
  
	root.emitterSize =  self.frame.size;
	//Name the cell so that it can be animated later using keypath
	[firework setName:@"firework"];
  
	root.emitterCells = [NSArray arrayWithObjects:firework, nil];
	//Force the view to update
  CALayer * overlay = [[CALayer alloc] init];
  overlay.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
  overlay.borderWidth = 1.0;
  //overlay.anchorPoint = CGPointMake(0.0f, 1.0f);
  overlay.shadowOffset = CGSizeMake(0.0f, 0.0f);
  CGColorRef borderColor = CGColorCreateGenericRGB(0.6f, 0.6f, 0.6f, 1.0f);
  overlay.borderColor = borderColor;
  CGColorRelease(borderColor);
  CGColorRef shadowColor = CGColorCreateGenericRGB(1.0f, 0.0f, 0.0f, 1.0f);
  overlay.shadowColor = shadowColor;
  CGColorRelease(shadowColor);
  overlay.shadowRadius = 5.0f;
  //overlay.cornerRadius = 2.0f;
  [self setWantsLayer:YES];
  [self.layer addSublayer:root];
  [self.layer addSublayer:overlay];
  self.layer.delegate = self;
  [overlay release];
  self.layer.masksToBounds = YES;
  self.layer.cornerRadius = 2.0f;
  [self setNeedsDisplay:YES];
  self.doubleValue = 0.0;
  [self addObserver:self forKeyPath:@"doubleValue" options:NSKeyValueObservingOptionNew context:nil];
}

//------------------------------------------------------------------------------
- (void)initializeGraphics {
  CGColorSpaceRef myColorspace;
  size_t num_locations = 2;
  CGFloat locations[2] = { 0.0, 1.0 };
  CGFloat components[8] = { 0.76, 0.76, 0.76, 1.0,  // Start color
    0.89, 0.89, 0.89, 1.0 }; // End color
  
  myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  gradient_ = CGGradientCreateWithColorComponents (myColorspace, components,
                                                    locations, num_locations);
  
  CGPoint myStartPoint, myEndPoint;
  myStartPoint.x = 0.0;
  myStartPoint.y = self.frame.size.height;
  myEndPoint.x = 0.0;
  myEndPoint.y = 0.0;
}

//------------------------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect {
  // NOOP
}

//------------------------------------------------------------------------------
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext {
  CGPoint myStartPoint, myEndPoint;
  myStartPoint.x = 0.0;
  myStartPoint.y = self.frame.size.height;
  myEndPoint.x = 0.0;
  myEndPoint.y = 0.0;

  CGContextDrawLinearGradient (theContext, gradient_, myStartPoint, myEndPoint, 0);
}

//------------------------------------------------------------------------------
- (void)dealloc {
  [self removeObserver:self forKeyPath:@"doubleValue"];
  [super dealloc];
}

//------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {

  NSProgressIndicator * view = (NSProgressIndicator *)object;
  CGFloat currentValue = (view.frame.size.width / 100.0) * view.doubleValue;
  root.emitterPosition = CGPointMake(currentValue / 2.0, root.emitterPosition.y);
  root.emitterSize = CGSizeMake((view.frame.size.width / 100.0) * view.doubleValue, root.emitterSize.height);
}

//------------------------------------------------------------------------------
@end
