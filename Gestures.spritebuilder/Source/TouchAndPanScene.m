//
//  TouchAndPanScene.m
//  Gestures
//
//  Created by Greg Meach on 3/25/15.
//  Copyright (c) 2015 MeachWare. All rights reserved.
//
/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "TouchAndPanScene.h"

@interface TouchAndPanScene () {
    CCLabelTTF *_angleLabel,*_thrustLabel;
    CCNode *_shipNode;
    CCParticleSystem *_engineThrust;
    
    UIPanGestureRecognizer *panGesture;
    CGPoint startSwipe;
    NSTimeInterval lastTap;
}
@end

@implementation TouchAndPanScene

-(void)onExit {
    [super onExit];
    [[CCDirector sharedDirector].view removeGestureRecognizer:panGesture];
}

-(void)didLoadFromCCB {
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[CCDirector sharedDirector].view addGestureRecognizer:panGesture];
    
    [_angleLabel setString:@"Angle: 0"];
    [_thrustLabel setString:@"Thrust: off"];
    [_engineThrust setVisible:false];
    
    self.userInteractionEnabled = YES;
    lastTap = [NSDate timeIntervalSinceReferenceDate];
}

-(void)singleTouch {
        NSLog(@"Single tap - fired");
        [_thrustLabel setString:@"Thrust: off"];
        [_engineThrust setVisible:false];
}
-(void)doubleTouch {
        NSLog(@"Double tap - fired");
        [_thrustLabel setString:@"Thrust: on"];
        [_engineThrust setVisible:true];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event { }
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event { }
-(void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event { }

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    NSTimeInterval timeNow = [NSDate timeIntervalSinceReferenceDate];
    BOOL isDoubleTap = (timeNow - lastTap) < 0.8;
    
    if (isDoubleTap) {
        [self doubleTouch];
    } else {
        [self singleTouch];
    }
    lastTap = [NSDate timeIntervalSinceReferenceDate];
}

-(CGFloat)angleInDegreesFromA:(CGPoint)pointA toB:(CGPoint)pointB {
    CGFloat deltaY = pointA.y - pointB.y;
    CGFloat deltaX = pointA.x - pointB.x;
    CGFloat angleInDegrees = atan2(deltaY, deltaX) * 180 /  M_PI;
    return angleInDegrees;
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];
        startSwipe = ccp(touchLocation.x, -touchLocation.y);
        NSLog(@"startSwipe: %.0f x %.0f",startSwipe.x,startSwipe.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];
        touchLocation = ccp(touchLocation.x, -touchLocation.y);
        CGFloat angle = [self angleInDegreesFromA:startSwipe toB:touchLocation];
        
        [_angleLabel setString:[NSString stringWithFormat:@"Angle: %.2f",angle]];
        [_shipNode setRotation:angle];
        
        startSwipe = CGPointZero;
    }
}

-(void)backToMenuPressed:(CCButton*)sender {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.6]];
}

@end
