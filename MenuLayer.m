//
//  MenuLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "MenuLayer.h"
#import "AppDelegate.h"
#import "HUDLayer.h"
#import "SettingsLayer.h"
#import "Engine.h"
#import "GUIMainController.h"
#import "HelpLayer.h"
#import "HighScoresLayer.h"

@implementation MenuLayer

+(CCScene *) scene
{
    //return the scene
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
    //initialise the menu layer
	if( (self=[super init]) )
    {
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"Endless Temple" fontName:@"Marker Felt" fontSize:64];
        
		CGSize size = [[CCDirector sharedDirector] winSize];
		title.position =  ccp( size.width /2 , 4*(size.height/5) );
		[self addChild: title];
		
		[CCMenuItemFont setFontSize:28];
		
        CCMenuItem *itemLoad = [CCMenuItemFont itemWithString:@"Load" target:self selector:@selector (load)];
        CCMenuItem *itemNewGame = [CCMenuItemFont itemWithString:@"New Game" target:self selector:@selector (newGame)];
        CCMenuItem *itemHighScores = [CCMenuItemFont itemWithString:@"High-Scores" target:self selector:@selector (highScores)];
        CCMenuItem *itemSettings = [CCMenuItemFont itemWithString:@"Settings" target:self selector:@selector (settings)];
        CCMenuItem *itemHelp = [CCMenuItemFont itemWithString:@"Help" target:self selector:@selector (help)];
        CCMenuItem *itemNoLoad = [CCMenuItemFont itemWithString:@"Load"];
        [(CCMenuItemFont*)itemNoLoad setColor:ccc3(125,125,125)];
		
		if ([[Engine sharedInstance] alive].boolValue && [[Engine sharedInstance] saved].boolValue)
        {
            CCMenu *menu = [CCMenu menuWithItems:itemLoad, itemNewGame, itemHighScores, itemSettings, itemHelp, nil];
            [menu alignItemsVerticallyWithPadding:10];
            [menu setPosition:ccp( size.width/2, size.height/2 - 50)];
            [self addChild:menu];
        }
        else
        {
            CCMenu *menu = [CCMenu menuWithItems:itemNoLoad, itemNewGame, itemHighScores, itemSettings, itemHelp, nil];
            [menu alignItemsVerticallyWithPadding:10];
            [menu setPosition:ccp( size.width/2, size.height/2 - 50)];
            [self addChild:menu];
        }

        CCParticleRain* emitter = [[CCParticleRain alloc] init];
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
        emitter.startColor = ccc4f(0, 0, 1, 0.8);
        emitter.startSize = 1;
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

- (void) load
{
    //load a saved game
    [[Engine sharedInstance] setStartingNewGame: [NSNumber numberWithBool:false]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[[GUIMainController sharedInstance] HUDLayerScene] withColor:ccBLACK]];
    [[Engine sharedInstance] setPausedVariable: [NSNumber numberWithBool:0]];
    [[Engine sharedInstance] setSaved:[NSNumber numberWithBool:false]];
}

- (void) newGame
{
    //start a new game
    [[Engine sharedInstance] setCurrentScore: [NSNumber numberWithInt:0]];
    [[Engine sharedInstance] setAlive: [NSNumber numberWithInt:1]];
    [[Engine sharedInstance] setStartingNewGame: [NSNumber numberWithBool:true]];
    [[Engine sharedInstance] setHealth: [NSNumber numberWithInt:100]];
    [[Engine sharedInstance] setAmmo: [NSNumber numberWithInt:10]];
    [[Engine sharedInstance] setCurrentLevel: [NSNumber numberWithInt:1]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[[GUIMainController sharedInstance] HUDLayerScene] withColor:ccBLACK]];
    [[Engine sharedInstance] setPausedVariable: [NSNumber numberWithBool:0]];
    [[Engine sharedInstance] setSaved:[NSNumber numberWithBool:false]];
}

- (void) highScores
{
    //move to the highscores layer
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HighScoresLayer scene] withColor:ccBLACK]];
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



@end
