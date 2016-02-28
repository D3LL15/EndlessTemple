//
//  IntroLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright Daniel Ellis 2014. All rights reserved.
//


#import "IntroLayer.h"
#import "MenuLayer.h"
#import "GUIMainController.h"
#import "Engine.h"
#import "SimpleAudioEngine.h"


#pragma mark - IntroLayer

@implementation IntroLayer

+(CCScene *) scene
{
    //return the scene
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) onEnter
{
    //show splash screen on application startup
	[super onEnter];

	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	[self addChild: background];
    
    [GUIMainController sharedInstance];
	
	[self scheduleOnce:@selector(makeTransition:) delay:1];
    
    if ([[Engine sharedInstance] sfxOn].boolValue)
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"distant_thunder_rumble_effect.mp3" loop:true];
    }
    
}

-(void) makeTransition:(ccTime)dt
{
    //transition to the main menu
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccBLACK]];
}
@end
