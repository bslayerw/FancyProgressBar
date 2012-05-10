//
//  BBSProgressView.m
//  FancyProgressBariOS
//
//  Created by Byron Wright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface BBSProgressLayerDelegate : NSObject {
  CGRect        frame;
  CGGradientRef progressGradient_;
}

- (id)init;
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext;

@property (nonatomic, assign) CGRect frame;

@end

@implementation BBSProgressView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
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
  
	root.renderMode = kCAEmitterLayerBackToFront;
  root.emitterShape = kCAEmitterLayerRectangle;
	[root setName:@"rootEmitter"];
	//Invisible particle representing the rocket before the explosio
	//The particles that make up the explosion
	CAEmitterCell * firstEmitterCell = [CAEmitterCell emitterCell];
  
	firstEmitterCell.contents = img;
	firstEmitterCell.birthRate = 999;
	firstEmitterCell.scale = 0.2;
  firstEmitterCell.blueSpeed = 0.1;
  firstEmitterCell.blueRange = 0.01;
  firstEmitterCell.alphaRange = 0.2;
	firstEmitterCell.velocity = 20;
	firstEmitterCell.lifetime = 2;
	firstEmitterCell.alphaSpeed = -0.2;
	firstEmitterCell.yAcceleration = -10;
	firstEmitterCell.beginTime = 0.0;
	firstEmitterCell.duration = 0.1;
	firstEmitterCell.emissionRange = 2 * M_PI;
	firstEmitterCell.scaleSpeed = -0.1;
	firstEmitterCell.spin = 0;
  
	root.emitterSize =  self.frame.size;
	//Name the cell so that it can be animated later using keypath
	[firstEmitterCell setName:@"firstEmitterCell"];
  
	root.emitterCells = [NSArray arrayWithObjects:firstEmitterCell, nil];
	//Force the view to update
  CALayer * overlay = [[CALayer alloc] init];
  overlay.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
  overlay.borderWidth = 1.0;
  overlay.shadowOffset = CGSizeMake(0.0f, 0.0f);
  CGColorRef borderColor = NULL;
  [self.layer addSublayer:root];
  
  switch (self.progressViewStyle) {

    case UIProgressViewStyleBar: {
      borderColor = [UIColor colorWithRed:0.14f green:0.23f blue:0.31f alpha:1.0f].CGColor;
      // add the progress layer
      progressLayer_ = [[CALayer alloc] init];
      layerDelegate_ = [[BBSProgressLayerDelegate alloc] init];
      [self.layer addSublayer:progressLayer_];
      progressLayer_.delegate = layerDelegate_;
      //progressLayer_.backgroundColor = [UIColor colorWithRed:0.76f green:0.76f blue:0.76f alpha:1.0f].CGColor;
      progressLayer_.cornerRadius = 5.0f;
      progressLayer_.frame =  CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
      layerDelegate_.frame = progressLayer_.frame;
      progressLayer_.borderColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f].CGColor;
      progressLayer_.borderWidth = 1.0f;
      progressLayer_.masksToBounds = YES;
      firstEmitterCell.color = [UIColor colorWithRed:0.09f green:0.23f blue:0.37f alpha:1.0f].CGColor;
      firstEmitterCell.blueSpeed = 0.1;
      firstEmitterCell.blueRange = 0.1;
      [progressLayer_ setNeedsDisplay];
    }

      break;
      
    default:
      firstEmitterCell.color = [UIColor colorWithRed:0.0f green:0.48f blue:0.84f alpha:1.0f].CGColor;
      borderColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f].CGColor;
      break;

  }
  overlay.borderColor = borderColor;
  
  //overlay.shadowColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f].CGColor;;
 // CGPathRef path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -1.0f, 1.0f)].CGPath;
 // [self.layer setShadowPath:path];
  //self.layer.shouldRasterize = YES;
  overlay.cornerRadius = 5.0f;

  [self.layer addSublayer:overlay];
  self.layer.delegate = self;
  [overlay release];
  self.layer.masksToBounds = YES;
  overlay.masksToBounds = YES;
  self.layer.cornerRadius = 6.0f;
  [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
  self.progress = 0.5f;
  
  
}

//------------------------------------------------------------------------------
- (void)initializeGraphics {
  
  CGColorSpaceRef myColorspace;
  size_t num_locations = 2;
  CGFloat locations[2] = { 0.0, 1.0 };
  switch (self.progressViewStyle) {

    case UIProgressViewStyleBar: {
      CGFloat components[8] = { 0.09, 0.23, 0.37, 1.0,  // Start color
        0.28, 0.45, 0.62, 1.0 }; // End color
      
      myColorspace = CGColorSpaceCreateDeviceRGB();
      gradient_ = CGGradientCreateWithColorComponents (myColorspace, components,
                                                       locations, num_locations);
      
      break;
    }
    default: {
      CGFloat components[8] = { 0.76, 0.76, 0.76, 1.0,  // Start color
        0.89, 0.89, 0.89, 1.0 }; // End color
      
      myColorspace = CGColorSpaceCreateDeviceRGB();
      gradient_ = CGGradientCreateWithColorComponents (myColorspace, components,
                                                       locations, num_locations);
      break;
    }

  }
  
  
  CGPoint myStartPoint, myEndPoint;
  myStartPoint.x = 0.0;
  myStartPoint.y = self.frame.size.height;
  myEndPoint.x = 0.0;
  myEndPoint.y = 0.0;
  CGColorSpaceRelease(myColorspace);
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
- (void)drawRect:(CGRect)rect {
  // NOOP
}

//------------------------------------------------------------------------------
- (void)dealloc {
  [self removeObserver:self forKeyPath:@"doubleValue"];
  CGGradientRelease(gradient_);
  [layerDelegate_ release];
  [super dealloc];
}

//------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
  
  BBSProgressView * view = (BBSProgressView *)object;
  CGFloat currentValue = (view.frame.size.width) * view.progress;
  switch (self.progressViewStyle) {
    case UIProgressViewStyleBar: {
      root.emitterPosition = CGPointMake((view.frame.size.width) / 2.0, root.emitterPosition.y);
      root.emitterSize = CGSizeMake((view.frame.size.width), root.emitterSize.height);
       progressLayer_.frame = CGRectMake(0.0f, 0.0f, (view.frame.size.width) * view.progress, root.emitterSize.height);
      layerDelegate_.frame = progressLayer_.frame;
      [progressLayer_ setNeedsDisplay];
    }
     
     // CGSizeMake((view.frame.size.width) * view.progress, root.emitterSize.height);
      break;
      
    default:
      root.emitterPosition = CGPointMake(currentValue / 2.0, root.emitterPosition.y);
      root.emitterSize = CGSizeMake((view.frame.size.width) * view.progress, root.emitterSize.height);
      break;
  }
}
@end



@implementation BBSProgressLayerDelegate
@synthesize frame;

- (id)init {
  self = [super init];
  if (self) {
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat progressComponents[12] = {1.0, 1.0, 1.0, 1.0,  0.76, 0.76, 0.76, 1.0,  // Start color
      0.89, 0.89, 0.89, 1.0 }; // End color
    size_t num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.3, 1.0 };
    progressGradient_ = CGGradientCreateWithColorComponents (myColorspace, progressComponents,
                                                             locations, num_locations);
    CGColorSpaceRelease(myColorspace);
  }
  return self;
}

//------------------------------------------------------------------------------
- (void)dealloc {
  CGGradientRelease(progressGradient_);
  [super dealloc];
}

//------------------------------------------------------------------------------
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext {
  CGPoint myStartPoint, myEndPoint;
  myStartPoint.x = 0.0;
  myStartPoint.y = self.frame.size.height;
  myEndPoint.x = 0.0;
  myEndPoint.y = 0.0;

  CGContextDrawLinearGradient (theContext, progressGradient_, myStartPoint, myEndPoint, 0);

  
}


@end

