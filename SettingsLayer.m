//
//  SettingsLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "SettingsLayer.h"
#import "MenuLayer.h"
#import "cocos2d.h"
#import "Engine.h"
#import "PauseLayer.h"
#import "SimpleAudioEngine.h"


@implementation SettingsLayer

+(CCScene *) scene
{
    //return the scene
	CCScene *scene = [CCScene node];
	SettingsLayer *layer = [SettingsLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
    //initialise the settings layer
	if( (self=[super init]) )
    {
        CCLabelTTF *settings = [CCLabelTTF labelWithString:@"Settings" fontName:@"Marker Felt" fontSize:64];
        CCLabelTTF *sfx = [CCLabelTTF labelWithString:@"SFX" fontName:@"Marker Felt" fontSize:28];
        CCLabelTTF *gore = [CCLabelTTF labelWithString:@"Gore" fontName:@"Marker Felt" fontSize:28];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        settings.position =  ccp( size.width /2 , 3*(size.height/4) );
        [self addChild: settings];
        sfx.position = ccp( size.width/3, size.height/2.5 + 25);
        [self addChild: sfx];
        gore.position = ccp( size.width/3, size.height/2.5 - 25);
        [self addChild: gore];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemBack = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector (back)];
        
        CCMenu *backMenu = [CCMenu menuWithItems:itemBack, nil];
        [backMenu setPosition:ccp( size.width/2, size.height/8)];
        [self addChild:backMenu];
        CCMenuItem *on2 = [CCMenuItemFont itemWithString:@"On" target:nil selector:nil];
        CCMenuItem *off2 = [CCMenuItemFont itemWithString:@"Off" target:nil selector:nil];
        CCMenuItem *on3 = [CCMenuItemFont itemWithString:@"On" target:nil selector:nil];
        CCMenuItem *off3 = [CCMenuItemFont itemWithString:@"Off" target:nil selector:nil];
        
        CCMenuItemToggle *sfxToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(sfxTogglePressed:) items:on2, off2, nil];
        CCMenuItemToggle *goreToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(goreTogglePressed:) items:on3, off3, nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems: sfxToggle, goreToggle, nil];
        
        if ([[Engine sharedInstance] sfxOn].integerValue == 1)
        {
            [sfxToggle setSelectedIndex:0];
        }
        else
        {
            [sfxToggle setSelectedIndex:1];
        }
        
        if ([[Engine sharedInstance] goreOn].integerValue == 1)
        {
            [goreToggle setSelectedIndex:0];
        }
        else
        {
            [goreToggle setSelectedIndex:1];
        }
        [toggleMenu alignItemsVerticallyWithPadding:20];
        [toggleMenu setPosition:ccp(2*(size.width/3), size.height/2.5)];
        [self addChild:toggleMenu];
		
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

- (void) sfxTogglePressed:(id)sender
{
    // toggle the sfx boolean
    if ([[Engine sharedInstance] sfxOn].integerValue == 0)
    {
        [[Engine sharedInstance] setSfxOn: [NSNumber numberWithInt:1]];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"distant_thunder_rumble_effect.mp3" loop:true];
    }
    else
    {
        [[Engine sharedInstance] setSfxOn: [NSNumber numberWithInt:0]];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
}

- (void) goreTogglePressed:(id)sender
{
    //toggle the gore boolean
    if ([[Engine sharedInstance] goreOn].integerValue == 0)
    {
        [[Engine sharedInstance] setGoreOn: [NSNumber numberWithInt:1]];
    }
    else
    {
        [[Engine sharedInstance] setGoreOn: [NSNumber numberWithInt:0]];
    }
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
