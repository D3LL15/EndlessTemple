//
//  Engine.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Engine : NSObject
{

}

@property (copy, nonatomic) NSNumber *alive;
@property (copy, nonatomic) NSNumber *musicOn;
@property (copy, nonatomic) NSNumber *sfxOn;
@property (copy, nonatomic) NSNumber *goreOn;
@property (copy, nonatomic) NSNumber *pausedVariable;
@property (copy, nonatomic) NSNumber *currentScore;
@property (copy, nonatomic) NSNumber *pausedMenu;
@property (copy, nonatomic) NSNumber *health;
@property (copy, nonatomic) NSNumber *ammo;
@property (copy, nonatomic) NSNumber *currentLevel;
@property (copy, nonatomic) NSNumber *saved;
@property (copy, nonatomic) NSString *errorMessage;

@property (copy, nonatomic) NSMutableArray *highScores;
@property (copy, nonatomic) NSMutableArray *highScoreNames;

@property (copy,nonatomic) NSNumber *playerX;
@property (copy,nonatomic) NSNumber *playerY;

@property (copy, nonatomic) NSNumber *startingNewGame;

+ (id) sharedInstance;

@end
