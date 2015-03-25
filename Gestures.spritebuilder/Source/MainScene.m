#import "MainScene.h"

@implementation MainScene

-(void)tapAndPanPressed:(CCButton*)sender {
    CCScene *scene = [CCBReader loadAsScene:@"TapAndPanScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.6]];
}
-(void)panOnlyPressed:(CCButton*)sender {
    CCScene *scene = [CCBReader loadAsScene:@"TouchAndPanScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.6]];
}

@end
