//
//  HelpLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "HelpLayer.h"
#import "cocos2d.h"
#import "MenuLayer.h"
#import "PauseLayer.h"
#import "Engine.h"


@implementation HelpLayer

+(CCScene *) scene
{
    //return the scene
    CCScene *scene = [CCScene node];
    HelpLayer *layer = [HelpLayer node];
    [scene addChild: layer];
    return scene;
}

-(id) init
{
    //initialise the help layer
    if( (self=[super init]) )
    {
        CCLabelTTF *help = [CCLabelTTF labelWithString:@"Help" fontName:@"Marker Felt" fontSize:64];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        help.position =  ccp( size.width /2 , 4*(size.height/5) );
        [self addChild: help];
        
        CCLabelTTF *helpText = [CCLabelTTF labelWithString:@"You've woken up in an ancient temple and need to get out, but you're not alone. This application is a game for people with short amounts of time to play. The player moves through randomly generated maps, competing with their high-scores earned through defeating enemies and reaching higher levels. Drag the left joystick to move, drag the right joystick to aim and, upon release, fire. Try to reach the stairs at the end of each level but beware as enemies will become stronger." dimensions:CGSizeMake(400,120) hAlignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:14];
        helpText.position =  ccp( size.width /2 , size.height/2 );
        [self addChild: helpText];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemBack = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(back)];
        
        CCMenu *backMenu = [CCMenu menuWithItems:itemBack, nil];
        [backMenu setPosition:ccp( size.width/2, size.height/8)];
        [self addChild:backMenu];
        
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

- (void) back
{
    //return to either the main menu or the pause menu
    if ([[Engine sharedInstance] pausedMenu].boolValue == true)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PauseLayer scene] withColor:ccBLACK]];
    }
    else
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccBLACK]];
    }
}

@end
