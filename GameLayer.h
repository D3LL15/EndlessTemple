//
//  GameLayer.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface GameLayer : CCLayer {
    
    
}

- (void) updatePlayer:(double) vX y:(double) vY d:(double) direction;
- (void) fireWithDamage:(int) damage direction:(int)direction accuracy:(int)accuracy;
- (int) checkForHits;
- (void) checkForBulletCollision;
- (void) updateEnemies;
- (void) showTrail:(double)direction trail:(bool)trailNumber;
- (void) trailRemover;
- (void) runAim;
- (void) runShoot;
- (void) runReload;
- (void) died;
- (void) save;
- (void) constructMap;

@end
