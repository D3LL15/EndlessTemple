//
//  ErrorLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "ErrorLayer.h"
#import "GameOverLayer.h"
#import "Engine.h"


@implementation ErrorLayer

+(CCScene *) scene
{
    //return the scene
    CCScene *scene = [CCScene node];
    ErrorLayer *layer = [ErrorLayer node];
    [scene addChild: layer];
    return scene;
}

-(id) init
{
    //initialise the error layer
    if( (self=[super init]) )
    {
        CCLabelTTF *error = [CCLabelTTF labelWithString:@"Error" fontName:@"Marker Felt" fontSize:64];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        error.position =  ccp( size.width /2 , 4*(size.height/5) );
        [self addChild: error];
        
        CCLabelTTF *errorText = [CCLabelTTF labelWithString:[[Engine sharedInstance] errorMessage] fontName:@"Marker Felt" fontSize:28];
        
        errorText.position =  ccp( size.width /2 , size.height/2 );
        [self addChild: errorText];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemBack = [CCMenuItemFont itemWithString:@"OK" target:self selector:@selector(back)];
        
        CCMenu *backMenu = [CCMenu menuWithItems:itemBack, nil];
        [backMenu setPosition:ccp( size.width/2, size.height/4)];
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
    //return to the game over layer
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameOverLayer scene] withColor:ccBLACK]];
}

@end
