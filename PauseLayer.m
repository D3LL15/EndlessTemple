//
//  PauseLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "PauseLayer.h"
#import "HUDLayer.h"
#import "GUIMainController.h"
#import "MenuLayer.h"
#import "SettingsLayer.h"
#import "HelpLayer.h"
#import "Engine.h"


@implementation PauseLayer


+(CCScene *) scene
{
    //return the scene
	CCScene *scene= [CCScene node];
	PauseLayer *layer = [PauseLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
    //initialise layer
    if( (self=[super init]) )
    {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Paused" fontName:@"Marker Felt" fontSize:64];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        title.position =  ccp( size.width /2 , 4*(size.height/5) );
        [self addChild: title];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemResume = [CCMenuItemFont itemWithString:@"Resume" target:self selector:@selector (resume)];
        CCMenuItem *itemSettings = [CCMenuItemFont itemWithString:@"Settings" target:self selector:@selector (settings)];
        CCMenuItem *itemHelp = [CCMenuItemFont itemWithString:@"Help" target:self selector:@selector (help)];
        CCMenuItem *itemQuit = [CCMenuItemFont itemWithString:@"Quit" target:self selector:@selector (quit)];
        
        CCMenu *menu = [CCMenu menuWithItems:itemResume,itemSettings,itemHelp,itemQuit, nil];
        [menu alignItemsVerticallyWithPadding:10];
        [menu setPosition:ccp( size.width/2, size.height/2 - 50)];
        [self addChild:menu];
        
        CCParticleRain* emitter = [[CCParticleRain alloc] init];
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
        emitter.startColor = ccc4f(0, 0, 1, 0.8);
        emitter.startSize = 2;
        emitter.startSpin = 0;
        emitter.emissionRate = 100;
        emitter.radialAccel = 0;
        emitter.tangentialAccel = 0;
        emitter.zOrder = -1;
        emitter.speed = 200;
        
        emitter.position = ccp(size.width/2,size.height);
        
        [self addChild:emitter];
    }
    return self;
}

- (void) resume
{
    //resume playing the game
    [[Engine sharedInstance] setStartingNewGame: [NSNumber numberWithBool:false]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[[GUIMainController sharedInstance] HUDLayerScene] withColor:ccBLACK]];
    [[Engine sharedInstance] setPausedVariable: [NSNumber numberWithBool:0]];
    [[Engine sharedInstance] setSaved:[NSNumber numberWithBool:false]];
}

- (void) quit
{
    //move to the main menu
    [[Engine sharedInstance] setPausedMenu:[NSNumber numberWithBool:NO]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccBLACK]];
}

- (void) settings
{
    //move to the settings layer
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SettingsLayer scene] withColor:ccBLACK]];
}

- (void) help
{
    //move to the help layer
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelpLayer scene] withColor:ccBLACK]];
}

- (void) onEnterTransitionDidFinish
{
    //layer appeared
    [[Engine sharedInstance] setPausedMenu:[NSNumber numberWithBool:true]];
}


@end
