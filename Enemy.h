//
//  Enemy.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Enemy : CCSprite {
    
}

- (void) initWithHealth:(int)health Damage:(int)damage;
- (BOOL) hitWithDamageDead:(double)damage Direction:(double)direction Map:(CCTMXTiledMap*)map Layer:(CCTMXLayer*)background;
- (void) movement:(int)endX :(int)endY Layer:(CCTMXLayer*)background Map:(CCTMXTiledMap*)map;
- (BOOL) checkForAttack;
- (CCProgressTimer*) healthDisplayReference;
@property (strong) NSNumber *dead;
@property (strong) NSNumber *health;
@property (strong) NSNumber *activated;
@end
