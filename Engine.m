//
//  Engine.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "Engine.h"

@implementation Engine

@synthesize alive;
@synthesize musicOn;
@synthesize sfxOn;
@synthesize goreOn;
@synthesize pausedVariable;
@synthesize currentScore;
@synthesize pausedMenu;
@synthesize health;
@synthesize ammo;
@synthesize currentLevel;
@synthesize saved;
@synthesize errorMessage;

@synthesize highScores;
@synthesize highScoreNames;

@synthesize playerX;
@synthesize playerY;

@synthesize startingNewGame;


- (id) init
{
    //initialise singleton
    if (self = [super init])
    {
        [self setPausedVariable:[NSNumber numberWithBool:false]];
        [self setPausedMenu:[NSNumber numberWithBool:false]];
        NSNumber *temp = [NSNumber numberWithInt:0];
        [self setHighScores:[NSMutableArray arrayWithObjects:temp,temp,temp,temp,temp, nil]];
        highScores = [highScores mutableCopy];
        NSString *temp2 = @"-";
        [self setHighScoreNames:[NSMutableArray arrayWithObjects:temp2,temp2,temp2,temp2,temp2, nil]];
        highScoreNames = [highScoreNames mutableCopy];
    }
    return self;
}

+ (id) sharedInstance
{
    //return singleton
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end
