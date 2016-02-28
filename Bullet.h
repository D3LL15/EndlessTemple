//
//  Bullet.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Bullet : CCSprite {
    
}

@property (strong) NSNumber *damage;
@property (strong) NSNumber *direction;
@property (strong) NSNumber *dead;
- (void) setupWithDamage:(int)damage direction:(double)direction;
- (CGPoint) futurePos;
- (void) updatePosition:(CGPoint)newPos;
- (void) stopped;

@end
