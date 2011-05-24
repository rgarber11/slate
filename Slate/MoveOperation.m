//
//  MoveOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveOperation.h"


@implementation MoveOperation

@synthesize topLeft;
@synthesize dimensions;
@synthesize monitor;

- (id)init {
  self = [super init];
  if (self) {
    // Initialization code here.
  }

  return self;
}

- (id) initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(int)mon {
  self = [super init];
  if (self) {
    NSArray *tlTokens = [tl componentsSeparatedByString:@","];
    if ([tlTokens count] >=2) {
      topLeft = [[ExpressionPoint alloc] initWithX:[tlTokens objectAtIndex:0] y:[tlTokens objectAtIndex:1]];
    } else {
      topLeft = [[ExpressionPoint alloc] init];
    }
    NSArray *dimTokens = [dim componentsSeparatedByString:@","];
    if ([dimTokens count] >=2) {
      dimensions = [[ExpressionPoint alloc] initWithX:[dimTokens objectAtIndex:0] y:[dimTokens objectAtIndex:1]];
    } else {
      dimensions = [[ExpressionPoint alloc] init];
    }
    monitor = mon;
  }

  return self;
}

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
- (NSDictionary *) getScreenAndWindowValues: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  int originX = 0;
  int originY = 0;
  int sizeX = 0;
  int sizeY = 0;
  if (monitor == -1) {
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    int mainHeight = [screen frame].size.height;
    int mainOriginY = [screen frame].origin.y;
    NSPoint topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
    if (!NSPointInRect(topLeftZeroed, [screen frame])) {
      for (NSUInteger i = 1; i < [screens count]; i++) {
        topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
        screen = [screens objectAtIndex:i];
        if (NSPointInRect(topLeftZeroed, [screen frame])) {
          originX = [screen frame].origin.x;
          originY = mainOriginY - [screen frame].origin.y - ([screen frame].size.height - mainHeight);
          break;
        }
      }
    }
    sizeX = [screen frame].size.width;
    sizeY = [screen frame].size.height;
  } else {
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    int mainHeight = [screen frame].size.height;
    int mainOriginY = [screen frame].origin.y;
    screen = [screens objectAtIndex:monitor];
    originX = [screen frame].origin.x;
    originY = mainOriginY - [screen frame].origin.y - ([screen frame].size.height - mainHeight);
    sizeX = [screen frame].size.width;
    sizeY = [screen frame].size.height;
  }
  NSLog(@"screenOrigin:(%i,%i), screenSize:(%i,%i), windowSize:(%f,%f), windowTopLeft:(%f,%f)",originX,originY,sizeX,sizeY,cSize.width,cSize.height,cTopLeft.x,cTopLeft.y);
  return [NSDictionary dictionaryWithObjectsAndKeys:
           [NSNumber numberWithInteger:originX], @"screenOriginX", 
           [NSNumber numberWithInteger:originY], @"screenOriginY", 
           [NSNumber numberWithInteger:sizeX], @"screenSizeX", 
           [NSNumber numberWithInteger:sizeY], @"screenSizeY", 
           [NSNumber numberWithFloat:cSize.width], @"windowSizeX", 
           [NSNumber numberWithFloat:cSize.height], @"windowSizeY", 
           [NSNumber numberWithFloat:cTopLeft.x], @"windowTopLeftX", 
           [NSNumber numberWithFloat:cTopLeft.y], @"windowTopLeftY", nil];
}

- (NSPoint) getTopLeftWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize: cSize];
  return [topLeft getPointWithDict:values];
}

- (NSSize) getDimensionsWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize: cSize];
  return [dimensions getSizeWithDict:values];
}

- (void)dealloc {
  [super dealloc];
}

@end
