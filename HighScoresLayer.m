//
//  HighScoresLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "HighScoresLayer.h"
#import "cocos2d.h"
#import "MenuLayer.h"
#import "Engine.h"


@implementation HighScoresLayer

+(CCScene *) scene
{
    //return the scene
    CCScene *scene = [CCScene node];
    HighScoresLayer *layer = [HighScoresLayer node];
    [scene addChild: layer];
    return scene;
}

-(id) init
{
    //intitialise the high scores layer
    if( (self=[super init]) )
    {
        CCLabelTTF *highScores = [CCLabelTTF labelWithString:@"High-Scores" fontName:@"Marker Felt" fontSize:64];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        highScores.position =  ccp( size.width /2 , 5*(size.height/6) );
        [self addChild: highScores];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemBack = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(back)];
        CCMenu *backMenu = [CCMenu menuWithItems:itemBack, nil];
        [backMenu setPosition:ccp( size.width/2, size.height/9)];
        [self addChild:backMenu];
        
        CCMenuItem *item1 = [CCMenuItemFont itemWithString:@"1"];
        CCMenuItem *item2 = [CCMenuItemFont itemWithString:@"2"];
        CCMenuItem *item3 = [CCMenuItemFont itemWithString:@"3"];
        CCMenuItem *item4 = [CCMenuItemFont itemWithString:@"4"];
        CCMenuItem *item5 = [CCMenuItemFont itemWithString:@"5"];
        CCMenu *numbers = [CCMenu menuWithItems:item1, item2, item3, item4, item5, nil];
        [numbers alignItemsVerticallyWithPadding:5];
        [numbers setPosition:ccp( size.width/4, 3*(size.height/7))];
        
        [self addChild:numbers];
        
        CCMenuItem *name1 = [CCMenuItemFont itemWithString:[[[Engine sharedInstance]highScoreNames] objectAtIndex:0]];
        CCMenuItem *name2 = [CCMenuItemFont itemWithString:[[[Engine sharedInstance]highScoreNames] objectAtIndex:1]];
        CCMenuItem *name3 = [CCMenuItemFont itemWithString:[[[Engine sharedInstance]highScoreNames] objectAtIndex:2]];
        CCMenuItem *name4 = [CCMenuItemFont itemWithString:[[[Engine sharedInstance]highScoreNames] objectAtIndex:3]];
        CCMenuItem *name5 = [CCMenuItemFont itemWithString:[[[Engine sharedInstance]highScoreNames] objectAtIndex:4]];
        CCMenu *names = [CCMenu menuWithItems:name1, name2, name3, name4, name5, nil];
        [names alignItemsVerticallyWithPadding:5];
        [names setPosition:ccp( 3*(size.width/7), 3*(size.height/7))];
        [self addChild:names];
        
        NSNumber *temp = [[[Engine sharedInstance]highScores] objectAtIndex:0];
        CCMenuItem *score1 = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d",temp.intValue]];
        temp = [[[Engine sharedInstance]highScores] objectAtIndex:1];
        CCMenuItem *score2 = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d",temp.intValue]];
        temp = [[[Engine sharedInstance]highScores] objectAtIndex:2];
        CCMenuItem *score3 = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d",temp.intValue]];
        temp = [[[Engine sharedInstance]highScores] objectAtIndex:3];
        CCMenuItem *score4 = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d",temp.intValue]];
        temp = [[[Engine sharedInstance]highScores] objectAtIndex:4];
        CCMenuItem *score5 = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d",temp.intValue]];
    
        CCMenu *scores = [CCMenu menuWithItems:score1, score2, score3, score4, score5, nil];
        [scores alignItemsVerticallyWithPadding:5];
        [scores setPosition:ccp( 2*(size.width/3), 3*(size.height/7))];
        [self addChild:scores];
        
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
    //return to the main menu
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccBLACK]];
}

@end
