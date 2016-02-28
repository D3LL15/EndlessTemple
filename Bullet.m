//
//  Bullet.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "Bullet.h"

@interface Bullet()

@property (strong) NSNumber *vX;
@property (strong) NSNumber *vY;


@end

@implementation Bullet

- (void)setupWithDamage:(int)damage direction:(double)direction
{
    // set up the bullet's properties as it is fired
    _damage = [NSNumber numberWithDouble:damage];
    _direction = [NSNumber numberWithDouble:direction];
    self.rotation = _direction.integerValue;
    _vX = [NSNumber numberWithDouble:((damage/25) + 2) * sin(direction * 2*3.141592654/360)];
    _vY = [NSNumber numberWithDouble:((damage/25) + 2) * cos(direction * 2*3.141592654/360)];
    
    double tempX = cos(atan(_vY.doubleValue/_vX.doubleValue)) * 16;
    double tempY = sin(atan(_vY.doubleValue/_vX.doubleValue)) * 16;
    if (_vX.doubleValue < 0)
    {
        tempX = -tempX;
        tempY = -tempY;
    }
    
    [self setPosition:ccp(self.position.x + tempX, self.position.y + tempY)];
    _dead = [NSNumber numberWithBool:NO];
}

- (void) updatePosition:(CGPoint)newPos
{
    //update the position of the bullet
    self.position = newPos;
}

- (void) stopped
{
    //stop the bullet
    _vX = [NSNumber numberWithInt:0];
    _vY = [NSNumber numberWithInt:0];
    _dead = [NSNumber numberWithBool:YES];
}

- (CGPoint) futurePos
{
    //return the position of the bullet when it is moved
    return ccp(self.position.x + _vX.doubleValue, self.position.y + _vY.doubleValue);
}

@end
