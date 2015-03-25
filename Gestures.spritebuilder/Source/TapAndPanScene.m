//
//  TapAndPanScene.m
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

#import "TapAndPanScene.h"
#import "CCControlSubclass.h"

@interface TapAndPanScene () {
    CCLabelTTF *_angleLabel,*_thrustLabel;
    CCNode *_shipNode;
    CCParticleSystem *_engineThrust;
    
    UIPanGestureRecognizer *panGesture;
    UITapGestureRecognizer *singleTapGesture, *doubleTapGesture;
    CGPoint startSwipe;
}
@end

@implementation TapAndPanScene

-(void)onExit {
    [super onExit];
    [[CCDirector sharedDirector].view removeGestureRecognizer:panGesture];
    [[CCDirector sharedDirector].view removeGestureRecognizer:singleTapGesture];
    [[CCDirector sharedDirector].view removeGestureRecognizer:doubleTapGesture];
}

-(void)didLoadFromCCB {
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapWith:)];
    singleTapGesture.numberOfTapsRequired = 1;
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapWith:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    
    [[CCDirector sharedDirector].view addGestureRecognizer:panGesture];
    [[CCDirector sharedDirector].view addGestureRecognizer:singleTapGesture];
    [[CCDirector sharedDirector].view addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [_angleLabel setString:@"Angle: 0"];
    [_thrustLabel setString:@"Thrust: off"];
    [_engineThrust setVisible:false];
}

-(void)handleSingleTapWith:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // Allow CCButtons to function
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        
        CCResponderManager *responder = [CCDirector sharedDirector].responderManager;
        CCNode *node = [responder nodeAtPoint:touchLocation];
        if ([node isKindOfClass:CCButton.class] && [(CCButton *)node enabled]) {
            [(CCButton *)node triggerAction];
        }
        
        NSLog(@"Single tap - fired");
        [_thrustLabel setString:@"Thrust: off"];
        [_engineThrust setVisible:false];
    }
}
-(void)handleDoubleTapWith:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Double tap - fired");
        [_thrustLabel setString:@"Thrust: on"];
        [_engineThrust setVisible:true];
    }
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
