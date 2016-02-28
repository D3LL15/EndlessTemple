//
//  Enemy.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "Enemy.h"
#import "PathfindingNode.h"
#import "Engine.h"

@interface Enemy()

@property (strong) NSNumber *damage;
@property (strong) NSNumber *hunting;
@property (strong) NSNumber *huntDestX;
@property (strong) NSNumber *huntDestY;
@property (strong) NSNumber *huntDestFracX;
@property (strong) NSNumber *huntDestFracY;
@property (strong) NSNumber *nextHuntDestX;
@property (strong) NSNumber *nextHuntDestY;
@property (strong) NSNumber *nextHuntDestFracX;
@property (strong) NSNumber *nextHuntDestFracY;
@property (strong) NSNumber *processing;
@property (strong) NSNumber *nextSimple;
@property (strong) NSNumber *nextProcessed;
@property (strong) NSNumber *endX;
@property (strong) NSNumber *endY;
@property (strong) NSNumber *startX;
@property (strong) NSNumber *startY;
@property (unsafe_unretained) CCTMXLayer *background;
@property (unsafe_unretained) CCTMXTiledMap *map;
@property (strong) NSNumber *attackCounter;
@property (strong) CCProgressTimer *healthDisplay;

@end

@implementation Enemy

-(BOOL)spaceIsBlocked:(int)x :(int)y Layer:(CCTMXLayer*)background Map:(CCTMXTiledMap*)map
{
    //return whether the vertex specified is blocked by any of the 4 tiles
    bool col1 = [[map propertiesForGID:[background tileGIDAt:ccp(x - 1, map.mapSize.height - y - 1)]][@"Collidable"] isEqualToString:@"True"];
    bool col2 = [[map propertiesForGID:[background tileGIDAt:ccp(x, map.mapSize.height - y - 1)]][@"Collidable"] isEqualToString:@"True"];
    bool col3 = [[map propertiesForGID:[background tileGIDAt:ccp(x - 1, map.mapSize.height - y)]][@"Collidable"] isEqualToString:@"True"];
    bool col4 = [[map propertiesForGID:[background tileGIDAt:ccp(x, map.mapSize.height - y)]][@"Collidable"] isEqualToString:@"True"];
    if(col1 || col2 || col3 || col4)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(PathfindingNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y
{
    //return the node with coordinates (x,y) in the inputted array
    NSEnumerator *e = [a objectEnumerator];
    PathfindingNode *n;
    
    while((n = [e nextObject]))
    {
        if((n.x.intValue == x) && (n.y.intValue == y))
        {
            return n;
        }
    }
    
    return nil;
}
-(PathfindingNode*)lowestCostNodeInArray:(NSMutableArray*)a
{
    //Finds the node with the lowest cost
    PathfindingNode *n, *lowest;
    lowest = nil;
    NSEnumerator *e = [a objectEnumerator];
    
    while((n = [e nextObject]))
    {
        if(lowest == nil)
        {
            lowest = n;
        }
        else
        {
            if(n.gCost.floatValue < lowest.gCost.floatValue)
            {
                lowest = n;
            }
        }
    }
    return lowest;
}

- (void) movement:(int)endX :(int)endY Layer:(CCTMXLayer*)background Map:(CCTMXTiledMap*)map
{
    //determine whether and how the enemy should move to the player
    if (_dead.boolValue == false)
    {
        if (_activated.boolValue == true)
        {
            if (_hunting.boolValue == false)
            {
                if (_processing.boolValue == true)
                {
                    return;
                }
                else if (_nextProcessed.boolValue == true)
                {
                    if (_nextSimple.boolValue == true)
                    {
                        _nextSimple = [NSNumber numberWithBool:false];
                        _nextProcessed = [NSNumber numberWithBool:false];
                        self.rotation = atan2f(endX - self.position.x, endY - self.position.y) * (360/(2*3.141592654));
                        if (abs(endX - self.position.x) <= 14 && abs(endY - self.position.y) <= 14)
                        {
                            //attack
                        }
                        else
                        {
                            [self setPosition:ccp(self.position.x + (sin(self.rotation * 2*3.141592654/360)), self.position.y + (cos(self.rotation * 2*3.141592654/360)))];
                        }
                    }
                    else
                    {
                        _huntDestX = [NSNumber numberWithInt:_nextHuntDestX.intValue];
                        _huntDestY = [NSNumber numberWithInt:_nextHuntDestY.intValue];
                        _huntDestFracX = [NSNumber numberWithDouble:_nextHuntDestFracX.doubleValue];
                        _huntDestFracY = [NSNumber numberWithDouble:_nextHuntDestFracY.doubleValue];
                        _hunting = [NSNumber numberWithBool:true];
                        _nextProcessed = [NSNumber numberWithBool:false];
                        int angle = (atan2f(_huntDestX.intValue - self.position.x, _huntDestY.intValue - self.position.y) * (360/(2*3.141592654)));
                        if ((_huntDestX.intValue<0 && _huntDestY.intValue < 0) || (_huntDestX.intValue>=0 && _huntDestY.intValue<0))
                        {
                            angle += 180;
                        }
                        self.rotation = angle;
                    }
                }
                else
                {
                    _endX = [NSNumber numberWithInt:endX];
                    _endY =[NSNumber numberWithInt:endY];
                    _startX = [NSNumber numberWithInt:self.position.x];
                    _startY = [NSNumber numberWithInt:self.position.y];
                    
                    _background = background;
                    _map = map;
                    [self performSelectorInBackground:@selector(testMethodCurrentMove) withObject:nil];
                }
            }
            else if (_processing.boolValue == false)
            {
                if (_nextProcessed.boolValue == false)
                {
                    _endX = [NSNumber numberWithInt:endX];
                    _endY = [NSNumber numberWithInt:endY];
                    int tempx = _huntDestX.intValue;
                    int tempy = _huntDestY.intValue;
                    _startX = [NSNumber numberWithInt:tempx];
                    _startY = [NSNumber numberWithInt:tempy];
                    _background = background;
                    _map = map;
                    [self performSelectorInBackground:@selector(testMethodNextMove) withObject:nil];
                }
                [self hunt];
            }
            else
            {
                [self hunt];
            }
        }
        else
        {
            _activated = [NSNumber numberWithBool:[self directLine:ccp(endX,endY) Layer:background Map:map]];
        }
    }
}

- (void) pathFinderWithEndX:(int)endX EndY:(int)endY StartX:(int)startX StartY:(int)startY Layer:(CCTMXLayer*)background Map:(CCTMXTiledMap*)map ProcessingNextMove:(bool)processingNextMove
{
    // find the next vertex for the enemy to move to in order to get to the player, using the A* pathfinding method
    _processing = [NSNumber numberWithBool:true];
    BOOL simple = true;
    double fracx = (endX - startX);
    double fracy = (endY - startY);
    fracx /= 50;
    fracy /= 50;
    int x;
    int y;
    int GID;
    NSDictionary *properties;
    NSString *collision;
    //check if the enemy can simply walk directly to the player
    for (int n = 1; n <= 50; n++)
    {
        //line from right of enemy to right of player
        x = (startX + 6 + (n*fracx))/8;
        y = ((map.mapSize.height * map.tileSize.height) - startY - (n*fracy))/8;
        GID = [background tileGIDAt:ccp(x,y)];
        properties = [map propertiesForGID:GID];
        collision = properties[@"Collidable"];
        
        if ([collision isEqualToString:@"True"])
        {
            simple = false;
            break;
        }
        
        //line from left of enemy to left of player
        x = (startX - 6 + (n*fracx))/8;
        y = ((map.mapSize.height * map.tileSize.height) - startY - (n*fracy))/8;
        GID = [background tileGIDAt:ccp(x,y)];
        properties = [map propertiesForGID:GID];
        collision = properties[@"Collidable"];
        
        if ([collision isEqualToString:@"True"])
        {
            simple = false;
            break;
        }
        
        //line from bottom of enemy to bottom of player
        x = (startX + (n*fracx))/8;
        y = ((map.mapSize.height * map.tileSize.height) - startY + 6 - (n*fracy))/8;
        GID = [background tileGIDAt:ccp(x,y)];
        properties = [map propertiesForGID:GID];
        collision = properties[@"Collidable"];
        
        if ([collision isEqualToString:@"True"])
        {
            simple = false;
            break;
        }
        
        //line from top of enemy to top of player
        x = (startX + (n*fracx))/8;
        y = ((map.mapSize.height * map.tileSize.height) - startY - 6 - (n*fracy))/8;
        GID = [background tileGIDAt:ccp(x,y)];
        properties = [map propertiesForGID:GID];
        collision = properties[@"Collidable"];
        
        if ([collision isEqualToString:@"True"])
        {
            simple = false;
            break;
        }
    }
    
    if (simple == true)
    {
        //can just walk towards the player
        if (processingNextMove == false)
        {
            self.rotation = atan2f(endX - startX, endY - startY) * (360/(2*3.141592654));
            if (abs(endX - startX) <= 16 && abs(endY - startY) <= 16)
            {
                [self attack];
            }
            else
            {
                [self setPosition:ccp(self.position.x + (1.5*sin(self.rotation * 2*3.141592654/360)), self.position.y + (1.5*cos(self.rotation * 2*3.141592654/360)))];
            }
        }
        else
        {
            _nextSimple = [NSNumber numberWithBool:true];
            _nextProcessed = [NSNumber numberWithBool:true];
        }
        _processing = [NSNumber numberWithBool:false];
    }
    else
    {
        //find path, cannot simply walk towards the player
        if (endX%8 > 4)
        {
            endX /= 8;
            endX += 1;
        }
        else
        {
            endX /= 8;
        }
        
        if (endY%8 > 4)
        {
            endY /= 8;
            endY += 1;
        }
        else
        {
            endY /= 8;
        }
        
        int newX,newY;
        int currentX,currentY;
        NSMutableArray *openList, *closedList;
        
        x = startX;
        x /= 8;
        y = startY;
        y /= 8;
        
        if (startX%8 > 4)
        {
            x++;
        }
        if (startY%8 > 4)
        {
            y++;
        }
        
        if (processingNextMove == false)
        {
            self.position = ccp(x*8,y*8);
            startX = x*8;
            startY = y*8;
        }
        else
        {
            startX = x*8;
            startY = y*8;
        }
        
        if((x == endX) && (y == endY))
        {
            return;
        }
        openList = [NSMutableArray array];
        closedList = [NSMutableArray array];
        
        PathfindingNode *currentNode = nil;
        PathfindingNode *adjacentNode = nil;
        PathfindingNode *startNode = [[PathfindingNode alloc] init];
        startNode.x = [NSNumber numberWithInt:x];
        startNode.y = [NSNumber numberWithInt:y];
        startNode.source = nil;
        startNode.fCost = [NSNumber numberWithInt:0];
        startNode.gCost = [NSNumber numberWithFloat:sqrtf(((x - endX)*(x - endX)) + ((y - endY)*(y-endY)))];
        [openList addObject: startNode];
        
        //start algorithm
        while([openList count])
        {
            currentNode = [self lowestCostNodeInArray: openList];
            if((currentNode.x.intValue == endX) && (currentNode.y.intValue == endY))
            {
                //reached the player
                currentNode = currentNode.source;
                if (currentNode.source != nil)
                {
                    while(currentNode.source.source != nil)
                    {
                        currentNode = currentNode.source;
                    }
                }
                
                if (processingNextMove == false)
                {
                    //running on the main thread
                    _huntDestX = [NSNumber numberWithInt:(currentNode.x.intValue)*8];
                    _huntDestY = [NSNumber numberWithInt:(currentNode.y.intValue)*8];
                    
                    int angle = (atan2f(_huntDestX.intValue - self.position.x, _huntDestY.intValue - self.position.y) * (360/(2*3.141592654)));
                    if ((_huntDestX.intValue<0 && _huntDestY.intValue < 0) || (_huntDestX.intValue>=0 && _huntDestY.intValue<0))
                    {
                        angle += 180;
                    }
                    
                    _huntDestFracX = [NSNumber numberWithDouble:1.5*sin(angle*((2*3.141592654)/360))];
                    _huntDestFracY = [NSNumber numberWithDouble:1.5*cos(angle*((2*3.141592654)/360))];
                    if ((_huntDestX.intValue < 0 && _huntDestY.intValue < 0) || (_huntDestX.intValue >= 0 && _huntDestY.intValue < 0))
                    {
                        _huntDestFracX = [NSNumber numberWithDouble:-_huntDestFracX.doubleValue];
                        _huntDestFracY = [NSNumber numberWithDouble:-_huntDestFracY.doubleValue];
                    }

                    _hunting = [NSNumber numberWithBool:true];
                    self.rotation = angle;
                }
                else
                {
                    //running on another thread
                    _nextHuntDestX = [NSNumber numberWithInt:currentNode.x.intValue*8];
                    _nextHuntDestY = [NSNumber numberWithInt:currentNode.y.intValue*8];
                    
                    int angle = (atan2f(_nextHuntDestX.intValue - startX, _nextHuntDestY.intValue - startY) * (360/(2*3.141592654)));
                    if ((_nextHuntDestX.intValue<0 && _nextHuntDestY.intValue < 0) || (_nextHuntDestX.intValue>=0 && _nextHuntDestY.intValue<0))
                    {
                        angle += 180;
                    }
                    
                    _nextHuntDestFracX = [NSNumber numberWithDouble:1.5*sin(angle*((2*3.141592654)/360))];
                    _nextHuntDestFracY = [NSNumber numberWithDouble:1.5*cos(angle*((2*3.141592654)/360))];
                    if ((_nextHuntDestX.doubleValue < 0 && _nextHuntDestY.doubleValue < 0) || (_nextHuntDestX.doubleValue >= 0 && _nextHuntDestY.doubleValue < 0))
                    {
                        _nextHuntDestFracX = [NSNumber numberWithDouble:-_nextHuntDestFracX.doubleValue];
                        _nextHuntDestFracY = [NSNumber numberWithDouble:-_nextHuntDestFracY.doubleValue];
                    }
                    _nextProcessed = [NSNumber numberWithBool:true];
                    _nextSimple = [NSNumber numberWithBool:false];
                }
                _processing = [NSNumber numberWithBool:false];
                return;
            }
            else
            {
                //A* section
                [closedList addObject: currentNode];
                [openList removeObject: currentNode];
                
                currentX = currentNode.x.intValue;
                currentY = currentNode.y.intValue;
                
                for(y=-1;y<=1;y++)
                {
                    newY = currentY+y;
                    for(x=-1;x<=1;x++)
                    {
                        newX = currentX+x;
                        if(![self nodeInArray: openList withX: newX Y:newY])
                        {
                            if(![self nodeInArray: closedList withX: newX Y:newY])
                            {
                                if((![self spaceIsBlocked: newX :newY Layer:background Map:map]) || ((newX == endX) && (newY == endX)))
                                {
                                    adjacentNode = [[PathfindingNode alloc] init];
                                    adjacentNode.x = [NSNumber numberWithInt:newX];
                                    adjacentNode.y = [NSNumber numberWithInt:newY];
                                    adjacentNode.source = currentNode;
                                    adjacentNode.fCost = [NSNumber numberWithFloat:currentNode.fCost.floatValue + sqrtf(((newX - currentX)*(newX - currentX)) + ((newY - currentY)*(newY-currentY)))];
                                    adjacentNode.gCost = [NSNumber numberWithFloat:adjacentNode.fCost.floatValue + sqrtf(((newX - endX)*(newX - endX)) + ((newY - endY)*(newY-endY)))];
                                    
                                    [openList addObject: adjacentNode];
                                }
                            }
                        }
                    }
                }
            }
        }
        _processing = [NSNumber numberWithBool:false];
    }
}

- (void) hunt
{
    //move the enemy towards the vertex specified by the A* algorithm
    float checkInt = ((_huntDestX.intValue - self.position.x)*(_huntDestX.intValue - self.position.x));

    checkInt += ((_huntDestY.intValue - self.position.y)*(_huntDestY.intValue - self.position.y));

    if (checkInt >= 1)
    {
        self.position = ccp(self.position.x + _huntDestFracX.doubleValue, self.position.y + _huntDestFracY.doubleValue);
    }
    else
    {
        self.position = ccp(_huntDestX.intValue,_huntDestY.intValue);
        _hunting = [NSNumber numberWithBool:false];
    }
}

- (BOOL) directLine:(CGPoint)playerPos Layer:(CCTMXLayer*)background Map:(CCTMXTiledMap*) map
{
    // check if the enemy can see the player
    if  (((self.position.x - playerPos.x)*(self.position.x- playerPos.x)) + ((self.position.y- playerPos.y) * (self.position.y- playerPos.y)) <= 360000)
    {
        int dx = playerPos.x - self.position.x;
        int dy = playerPos.y - self.position.y;
        float direction = atan2f(abs(dy), abs(dx)) * (360/(2*3.141592654));
        if (dx < 0)
        {
            if (dy < 0)
            {
                direction = 270 - direction;
            }
            else
            {
                direction = 270 + direction;
            }
        }
        else if (dy > 0)
        {
            direction = 90 - direction;
        }
        else
        {
            direction = 90 + direction;
        }
        
        if (abs(direction - self.rotation) > 70 && MIN(direction,self.rotation) + 70 % 360 < MAX(direction,self.rotation))
        {
            return false;
        }
        double fracx = (playerPos.x - self.position.x)/100;
        double fracy = (playerPos.y - self.position.y)/100;
        int x;
        int y;
        int GID;
        NSDictionary *properties;
        NSString *collision;
        for (int n = 1; n <= 100; n++)
        {
            x = (self.position.x + (n*fracx))/8;
            y = ((map.mapSize.height * map.tileSize.height) - self.position.y - (n*fracy))/8;
            GID = [background tileGIDAt:ccp(x,y)];
            properties = [map propertiesForGID:GID];
            collision = properties[@"Collidable"];
            
            if ([collision isEqualToString:@"True"])
            {
                return false;
            }
        }
        return true;
    }
    return false;
}

- (void) initWithHealth:(int)health Damage:(int)damage
{
    //initialise the enemy
    _health = [NSNumber numberWithInt:health];
    _damage = [NSNumber numberWithInt:damage];
    _dead = [NSNumber numberWithBool:false];
    _activated = [NSNumber numberWithBool:false];
    _hunting = [NSNumber numberWithBool:false];
    _processing = [NSNumber numberWithBool:false];
    _nextSimple = [NSNumber numberWithBool:false];
    _nextProcessed = [NSNumber numberWithBool:false];
    _attackCounter = [NSNumber numberWithInt:0];
    
    _healthDisplay = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"EnemyHealth.png"]];
    _healthDisplay.type = kCCProgressTimerTypeBar;
    _healthDisplay.midpoint = ccp(0,0);
    _healthDisplay.barChangeRate = ccp(1,0);
    _healthDisplay.percentage = _health.integerValue;
    _healthDisplay.position = ccp(self.position.x,self.position.y + 10);
}

- (BOOL) hitWithDamageDead:(double)damage Direction:(double)direction Map:(CCTMXTiledMap*)map Layer:(CCTMXLayer*)background
{
    //enemy has been hit with a bullet, deduct health, check for death and knock backwards
    if (!_activated.boolValue)
    {
        _activated = [NSNumber numberWithBool:true];
    }
    _health = [NSNumber numberWithInt:_health.intValue - damage];
    if (_health.intValue <= 0)
    {
        _dead = [NSNumber numberWithBool:true];
        return true;
    }
    else
    {
        if([[map propertiesForGID:[background tileGIDAt:ccp((self.position.x + (8*sin(direction*((2*3.141592654)/360))))/8,((map.mapSize.height * map.tileSize.height) - self.position.y - (8*cos(direction*((2*3.141592654)/360))))/8)]][@"Collidable"] isEqualToString:@"True"])
        {
            [self setPosition:ccp(self.position.x + ((damage/12.5) * sin(direction * 2*3.141592654/360)), self.position.y + ((damage/12.5) * cos(direction * 2*3.141592654/360)))];
            _hunting = [NSNumber numberWithBool:false];
            _nextProcessed = [NSNumber numberWithBool:false];
            _nextSimple = [NSNumber numberWithBool:false];
        }
    }
    return false;
}


- (void) testMethodNextMove
{
    //execute the pathfinding algorithm, starting at the point being moved to by the enemy
    int tempX = _startX.intValue;
    int tempY = _startY.intValue;
    [self pathFinderWithEndX:_endX.intValue EndY:_endY.intValue StartX:tempX StartY:tempY Layer:_background Map:_map ProcessingNextMove:true];
}

- (void) testMethodCurrentMove
{
    //execute the pathfinding algorithm, starting at the current position of the enemy
    [self pathFinderWithEndX:_endX.intValue EndY:_endY.intValue StartX:_startX.intValue StartY:_startY.intValue Layer:_background Map:_map ProcessingNextMove:false];
}

- (void) attack
{
    //delay the frequency of attacks on the player using a counter
    if (_attackCounter.intValue != 4)
    {
        _attackCounter = [NSNumber numberWithInt:_attackCounter.intValue + 1];
    }
}

- (BOOL) checkForAttack
{
    //attack the player, using the delay counter
    if (_attackCounter.intValue == 4)
    {
        _attackCounter = [NSNumber numberWithInt:0];
        return true;
    }
    return false;
}

- (CCProgressTimer*) healthDisplayReference
{
    //return the address of the health bar object above the enemy
    return _healthDisplay;
}

@end
