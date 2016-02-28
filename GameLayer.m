//
//  GameLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "GameLayer.h"
#import "Engine.h"
#import "AppDelegate.h"
#import "HUDLayer.h"
#import "Bullet.h"
#import "Enemy.h"
#import "HKTMXTiledMap.h"
#import "HKTMXLayer.h"
#import "BSPNode.h"

@interface GameLayer()

@property (strong) CCTMXTiledMap *tileMap;
@property (strong) CCTMXTiledMap *shadowMap;
@property (strong) CCTMXLayer *background;
@property (strong) CCTMXLayer *shadows;
@property (strong) CCSprite *player;
@property (strong) NSMutableSet *bullets;
@property (strong) NSMutableSet *enemys;
@property (strong) CCProgressTimer *trail1;
@property (strong) CCProgressTimer *trail2;
@property (strong) CCAction *aim;
@property (strong) CCAction *shot;
@property (strong) CCAction *deadAnimation;
@property (strong) CCAction *stopShoot;
@property (strong) CCAction *reload;
@property (strong) NSNumber *previousTilex;
@property (strong) NSNumber *previousTiley;
@property (strong) BSPNode *topNode;
@property (strong) NSNumber *justStarted;
@property (strong) Enemy *currentEnemy;

@end

@implementation GameLayer

- (id) init
{
    //initialise the game layer
    if( (self=[super init]) )
    {
        self.isTouchEnabled = YES;
        _trail1 = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"trail.png"]];
        _trail1.type = kCCProgressTimerTypeBar;
        _trail1.percentage = 0;
        [self addChild:_trail1];
        _trail2 = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"trail.png"]];
        _trail2.type = kCCProgressTimerTypeBar;
        _trail2.percentage = 0;
        [self addChild:_trail2];
        _justStarted = [NSNumber numberWithBool:YES];
        
        [self loadLevel];
        _justStarted = [NSNumber numberWithBool:NO];
    }
    return self;
}


- (void)setViewPointCenter:(CGPoint) position
{
    //show the tiles surrounding the player
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

- (void) updatePlayer:(double) vX y:(double) vY d:(double) direction
{
    //update the player's position and rotation based on joystick input
    CGPoint playerPos = _player.position;
    
    int x = _player.position.x;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - _player.position.y;
    
    //i collision points are with only the x component of the velocity
    //j collision points are with only the y component of the velocity
    int tempx =(x + vX + 8)/8;
    int tempy =(y + 7)/8;
    CGPoint iNEPoint = ccp(tempx,tempy);
    tempx =(x + vX - 8)/8;
    tempy =(y + 7)/8;
    CGPoint iNWPoint = ccp(tempx,tempy);
    tempx =(x + vX + 8)/8;
    tempy =(y - 7)/8;
    CGPoint iSEPoint = ccp(tempx,tempy);
    tempx =(x + vX - 8)/8;
    tempy =(y - 7)/8;
    CGPoint iSWPoint = ccp(tempx,tempy);
    tempx =(x + 7)/8;
    tempy =(y - vY - 8)/8;
    CGPoint jNEPoint = ccp(tempx,tempy);
    tempx =(x - 7)/8;
    tempy =(y - vY - 8)/8;
    CGPoint jNWPoint = ccp(tempx,tempy);
    tempx =(x + 7)/8;
    tempy =(y - vY + 8)/8;
    CGPoint jSEPoint = ccp(tempx,tempy);
    tempx =(x - 7)/8;
    tempy =(y - vY + 8)/8;
    CGPoint jSWPoint = ccp(tempx,tempy);
    
    BOOL iNECollision = [[_tileMap propertiesForGID:[_background tileGIDAt:iNEPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL iNWCollision = [[_tileMap propertiesForGID:[_background tileGIDAt:iNWPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL iSECollision = [[_tileMap propertiesForGID:[_background tileGIDAt:iSEPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL iSWCollision = [[_tileMap propertiesForGID:[_background tileGIDAt:iSWPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL jNECollision = [[_tileMap propertiesForGID:[_background tileGIDAt:jNEPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL jNWCollision = [[_tileMap propertiesForGID:[_background tileGIDAt:jNWPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL jSECollision = [[_tileMap propertiesForGID:[_background tileGIDAt:jSEPoint]][@"Collidable"]isEqualToString:@"True"];
    BOOL jSWCollision = [[_tileMap propertiesForGID:[_background tileGIDAt:jSWPoint]][@"Collidable"]isEqualToString:@"True"];
    
    if (jNECollision || jNWCollision)
    {
        tempy = (playerPos.y + vY + 1)/8;
        playerPos.y = (tempy * 8);
    }
    else if (jSECollision || jSWCollision)
    {
        tempy = (playerPos.y + vY - 1)/8;
        playerPos.y = (tempy * 8) + 8;
    }
    else
    {
        playerPos.y += vY;
    }
    
    if (iNECollision || iSECollision)
    {
        tempx = (playerPos.x + vX + 1)/8;
        playerPos.x = (tempx * 8);
    }
    else if (iNWCollision || iSWCollision)
    {
        tempx = (playerPos.x + vX -1)/8;
        playerPos.x = (tempx * 8) + 8;
    }
    else
    {
        playerPos.x += vX;
    }

    _player.position = playerPos;
    _player.rotation = direction;
    [self setViewPointCenter:playerPos];
    
    //crossing to a different tile
    if (_previousTilex.integerValue != (int)playerPos.x/8 || _previousTiley.integerValue != (int)playerPos.y/8)
    {
        [self performSelectorInBackground:@selector(FOV) withObject:nil];
        _previousTilex = [NSNumber numberWithInt:playerPos.x/8];
        _previousTiley = [NSNumber numberWithInt:playerPos.y/8];
        int GID = _background.tileset.firstGid;
        
        if ([_background tileGIDAt:ccp((int)playerPos.x/8, _tileMap.mapSize.height - ((int)playerPos.y/8))] >= GID+37 && [_background tileGIDAt:ccp((int)playerPos.x/8, _tileMap.mapSize.height - ((int)playerPos.y/8))] <= GID+40)
        {
            // player has stepped on the stairs to the next level
            [[Engine sharedInstance] setCurrentScore:[NSNumber numberWithInt:[[Engine sharedInstance] currentScore].intValue + 10]];
            [[Engine sharedInstance] setCurrentLevel:[NSNumber numberWithInt:[[Engine sharedInstance] currentLevel].intValue + 1]];
            [[Engine sharedInstance] setHealth:[NSNumber numberWithInt:100]];
            
            for (Enemy *enemy in _enemys.allObjects)
            {
                if (enemy != nil)
                {
                    [self removeChild:enemy cleanup:YES];
                    [self removeChild:enemy.healthDisplayReference cleanup:YES];
                }
            }
            for (int x = 150; x <=350; x++)
            {
                for (int y = 150; y <=350; y++)
                {
                    [_background setTileGID:(_background.tileset.firstGid) at:ccp(x,y)];
                    [_shadows setTileGID:(_shadows.tileset.firstGid) at:ccp(x,y)];
                }
            }
            _enemys = nil;
            [self constructMap];
            [_shadows setTileGID:_shadows.tileset.firstGid + 1 at:ccp(_player.position.x/8,_tileMap.mapSize.height - (_player.position.y/8))];
            [self FOV];
            return;
        }
    }
    [[Engine sharedInstance] setPlayerX:[NSNumber numberWithInt:_player.position.x]];
    [[Engine sharedInstance] setPlayerY:[NSNumber numberWithInt:_player.position.y]];
}

- (void) fireWithDamage:(int)damage direction:(int)direction accuracy:(int)accuracy
{
    //fire a bullet
    Bullet *bullet = [Bullet spriteWithFile:@"Bullet.png"];
    bullet.position = _player.position;
    
    float i = arc4random()%200;
    i = ((i + 1)/100)-1;
    float angle = ((100-accuracy)*40*i)/100;
    
    [bullet setupWithDamage:damage direction:direction + angle];
    NSMutableArray *objectsArray;
    
    if (_bullets != nil)
    {
        objectsArray = [NSMutableArray arrayWithArray: _bullets.allObjects];
        [objectsArray addObject:bullet];
        _bullets = [NSMutableSet setWithArray:objectsArray];
    }
    else
    {
        _bullets = [NSMutableSet setWithObject:bullet];
    }
    
    [self addChild: bullet];
    
    CCParticleExplosion* emitter2 = [[CCParticleExplosion alloc] init];
    emitter2.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
    emitter2.startSize = 1;
    emitter2.endSize = 2;
    emitter2.duration = 0.1;
    emitter2.life = 0.1;
    emitter2.lifeVar = 0.1;
    emitter2.speed = 100;
    emitter2.speedVar = 10;
    emitter2.angle = 90-bullet.direction.intValue;
    emitter2.angleVar = 10;
    emitter2.startColor = ccc4f(1, 0.3, 0, 0.1);
    emitter2.startColorVar = ccc4f(0, 0.3, 0, 0);
    emitter2.endColor = ccc4f(1, 0.3, 0, 0.1);
    emitter2.endColorVar = ccc4f(0, 0.3, 0, 0);
    emitter2.position = ccp(_player.position.x,_player.position.y);
    emitter2.zOrder = 3;
    emitter2.emissionRate = 1000;
    [self addChild:emitter2];
}

- (int) checkForHits
{
    // check whether the enemys have attacked the player
    int damage = 0;
    for (Enemy *enemy in _enemys.allObjects)
    {
        if (enemy != nil)
        {
            if ([enemy checkForAttack])
            {
                damage += 5;
            }
        }
    }
    return damage;
}

- (void) checkForBulletCollision
{
    //check if any of the bullets have hit any of the enemies or walls
    if(_bullets)
    {
        CGPoint coord;
        int x;
        int y;
        int GID;
        NSDictionary *properties;
        NSString *collision;
        
        for (Bullet *bullet in _bullets.allObjects)
        {
            if (bullet != nil)
            {
                if (bullet.dead.boolValue == false)
                {
                    coord = [bullet futurePos];
                    x = coord.x / 8;
                    y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - coord.y) / 8;
                    GID = [_background tileGIDAt:ccp(x,y)];
                    properties = [_tileMap propertiesForGID:GID];
                    collision = properties[@"Collidable"];
                    
                    if ([collision isEqualToString:@"True"])
                    {
                        //collided with wall
                        [bullet stopped];
                        [self removeChild:bullet cleanup:YES];
                    }
                    else
                    {
                        [bullet updatePosition:coord];
                        for (Enemy *enemy __strong in _enemys.allObjects)
                        {
                            if (enemy.dead.boolValue == false && bullet.position.x <= enemy.position.x + 15 && bullet.position.x >= enemy.position.x - 15 && bullet.position.y <= enemy.position.y + 15 && bullet.position.y >= enemy.position.y - 15)
                            {
                                //collided with enemy
                                bool dead = [enemy hitWithDamageDead:bullet.damage.integerValue Direction:bullet.direction.integerValue Map:_tileMap Layer:_background];
                                
                                [bullet stopped];
                                [enemy healthDisplayReference].percentage = (100*enemy.health.integerValue) / (100 + ([[Engine sharedInstance] currentLevel].intValue*100));
                                
                                if ([[Engine sharedInstance] goreOn].boolValue == YES)
                                {
                                    CCParticleExplosion* emitter2 = [[CCParticleExplosion alloc] init];
                                    emitter2.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
                                    emitter2.startSize = 1;
                                    emitter2.duration = 0.1;
                                    emitter2.life = 0.08;
                                    emitter2.lifeVar = 0.1;
                                    emitter2.speed = 100;
                                    emitter2.speedVar = 10;
                                    emitter2.angle = 90-bullet.direction.intValue;
                                    emitter2.angleVar = 15;
                                    emitter2.startColor = ccc4f(1, 0, 0, 0.1);
                                    emitter2.startColorVar = ccc4f(0.5, 0, 0, 0);
                                    emitter2.endColor = ccc4f(1, 0, 0, 0.1);
                                    emitter2.endColorVar = ccc4f(0.5, 0, 0, 0);
                                    emitter2.position = ccp(enemy.position.x,enemy.position.y);
                                    emitter2.zOrder = 3;
                                    emitter2.emissionRate = 1000;
                                    
                                    [self addChild:emitter2];
                                }
                                
                                if (dead)
                                {
                                    [[Engine sharedInstance] setCurrentScore:[NSNumber numberWithInt:[[Engine sharedInstance] currentScore].intValue + 1]];
                                    _currentEnemy = enemy;
                                    
                                    [enemy runAction:_deadAnimation];
                                }
                                
                                [self removeChild:bullet cleanup:YES];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void) changeEnemy
{
    //change the enemy's sprite to indicate that it is dead
    [_currentEnemy setTexture:[[CCTextureCache sharedTextureCache] addImage:@"enemydead.png"]];
}

- (void) loadLevel
{
    //set up the level and load it from memory if necessary
    _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:@"mainMap.tmx"];
    _background = [_tileMap layerNamed:@"Background"];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playersheet.plist"];
    CCSpriteBatchNode *playerSheet = [CCSpriteBatchNode batchNodeWithFile:@"playersheet.png"];
    [self addChild:playerSheet];
    
    _player =  [CCSprite spriteWithSpriteFrameName:@"playernatural.png"];
    
    [self addChild:_tileMap z:(-1)];
    _shadowMap = [HKTMXTiledMap tiledMapWithTMXFile:@"shadowMapLowRes.tmx"];
    _shadows = [_shadowMap layerNamed:@"Shadows"];
    [self addChild:_shadowMap z:2];
    if (![[Engine sharedInstance] alive].boolValue)
    {
        //create new map
        [self constructMap];
        [[Engine sharedInstance] setAmmo:[NSNumber numberWithInt:10]];
    }
    else
    {
        _player.position = ccp([[Engine sharedInstance] playerX].intValue,[[Engine sharedInstance] playerY].intValue);
        
        if (_justStarted.boolValue)
        {
            //load map from memory
            [[Engine sharedInstance] setAmmo:[NSNumber numberWithInt:10]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSArray *array = [savedData objectForKey:@"tiles"];
                
                for (int x = 200; x < 300; x++)
                {
                    for (int y = 200; y < 300; y++)
                    {
                        NSNumber *number = [array objectAtIndex:((x-200)*100)+(y-200)];
                        [_background setTileGID:number.intValue at:ccp(x,y)];
                    }
                }
                
                array = [savedData objectForKey:@"enemies"];
                for (int x = 0; x < [array count]/5; x++)
                {
                    NSNumber *tempObject = [array objectAtIndex:x*5];
                    NSNumber *tempObject2 = [array objectAtIndex:(x*5)+1];
                    NSNumber *tempObject3 = [array objectAtIndex:(x*5)+2];
                    Enemy *enemy;
                    if (tempObject3.intValue <= 0)
                    {
                        enemy = [Enemy spriteWithSpriteFrameName:@"enemydead.png"];
                    }
                    else
                    {
                        enemy = [Enemy spriteWithSpriteFrameName:@"enemynatural.png"];
                    }
                    
                    enemy.position = ccp(tempObject.intValue,tempObject2.intValue);
                    
                    tempObject = [array objectAtIndex:(x*5)+2];
                    [enemy initWithHealth:tempObject3.intValue Damage:1];
                    
                    if (enemy.health.intValue <= 0)
                    {
                        enemy.dead = [NSNumber numberWithBool:YES];
                    }
                    
                    tempObject = [array objectAtIndex:(x*5)+3];
                    enemy.activated = [NSNumber numberWithBool:tempObject.boolValue];
                    
                    tempObject = [array objectAtIndex:(x*5)+4];
                    enemy.rotation = tempObject.floatValue;
                    
                    [self addChild:enemy z:1];
                    [self addChild:[enemy healthDisplayReference] z:1];
                    
                    NSMutableArray *objectsArray;
                    
                    if (_enemys != nil)
                    {
                        objectsArray = [NSMutableArray arrayWithArray: _enemys.allObjects];
                        [objectsArray addObject:enemy];
                        _enemys = [NSMutableSet setWithArray:objectsArray];
                    }
                    else
                    {
                        _enemys = [NSMutableSet setWithObject:enemy];
                    }
                }
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            }
        }
    }
    
    //setup animations
    NSMutableArray *aimFrames = [NSMutableArray array];
    for (int i = 1; i <= 7; i++)
    {
        [aimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"playeraim%d.png",i]]];
    }
    
    [playerSheet addChild: _player];
    _previousTilex = [NSNumber numberWithInt:_player.position.x/8];
    _previousTiley = [NSNumber numberWithInt:_player.position.y/8];
    
    CCAnimation *aim = [CCAnimation animationWithSpriteFrames:aimFrames delay:0.08];
    aim.loops = 1;
    _aim = [CCAnimate actionWithAnimation:aim];
    
    
    NSMutableArray *shotFrames = [NSMutableArray array];
    for (int i = 7; i >= 1; i--)
    {
        [shotFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"playeraim%d.png",i]]];
    }
    [shotFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playernatural.png"]];
    CCAnimation *shot = [CCAnimation animationWithSpriteFrames:shotFrames delay:0.08];
    shot.loops = 1;
    _shot = [CCAnimate actionWithAnimation:shot];
    
    NSMutableArray *deadAnimationFrames = [NSMutableArray array];
    [deadAnimationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"enemydead.png"]];
    CCAnimation *deadAnimation = [CCAnimation animationWithSpriteFrames:deadAnimationFrames delay:0.08];
    _deadAnimation = [CCAnimate actionWithAnimation:deadAnimation];
    
    NSMutableArray *reloadFrames = [NSMutableArray array];
    for (int i = 1; i <= 7; i++)
    {
        [reloadFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"playeraim%d.png",i]]];
    }
    for (int i = 1; i <= 7; i++)
    {
        [reloadFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"playerreload%d.png",i]]];
    }
    for (int i = 7; i >= 1; i--)
    {
        [reloadFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"playeraim%d.png",i]]];
    }
    [reloadFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playernatural.png"]];
    CCAnimation *reload = [CCAnimation animationWithSpriteFrames:reloadFrames delay:0.08];
    reload.loops = 1;
    _reload = [CCAnimate actionWithAnimation:reload];
    
    //light the starting tile
    int GID = _shadows.tileset.firstGid + 1;
    [_shadows setTileGID:GID at:ccp(_player.position.x/8,_tileMap.mapSize.height - (_player.position.y/8))];
    [self FOV];
}

- (void) updateEnemies
{
    //update the positions of the enemies and their health bars
    for (Enemy *enemy in _enemys.allObjects)
    {
        if (enemy != nil)
        {
            [enemy movement:_player.position.x :_player.position.y Layer:_background Map:_tileMap];
            [enemy healthDisplayReference].position = ccp(enemy.position.x,enemy.position.y+10);
        }
    }
}

- (void) showTrail:(double)direction trail:(bool)trailNumber
{
    //display the two aiming indicator lines
    double fracx = sin(direction*((2*3.141592654)/360));
    double fracy = cos(direction*((2*3.141592654)/360));
    int x;
    int y;
    int GID;
    NSDictionary *properties;
    NSString *collision;
    int range = 0;
    for (int n = 1; n <= 590; n++)
    {
        x = (_player.position.x + (n*fracx))/8;
        y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - _player.position.y - (n*fracy))/8;
        GID = [_background tileGIDAt:ccp(x,y)];
        properties = [_tileMap propertiesForGID:GID];
        collision = properties[@"Collidable"];
        
        if ([collision isEqualToString:@"True"])
        {
            range = n - 1;
            break;
        }
    }
    if (trailNumber)
    {
        [self removeChild:_trail1 cleanup:YES];
        _trail1.midpoint = ccp(0,0);
        _trail1.barChangeRate = ccp(0,1);
        _trail1.anchorPoint = ccp(0,0);
        _trail1.percentage = range/3;
        _trail1.rotation = direction;
        _trail1.position = ccp(_player.position.x, _player.position.y);
        [self addChild:_trail1];
    }
    else
    {
        [self removeChild:_trail2 cleanup:YES];
        _trail2.midpoint = ccp(0,0);
        _trail2.barChangeRate = ccp(0,1);
        _trail2.anchorPoint = ccp(0,0);
        _trail2.percentage = range/3;
        _trail2.rotation = direction;
        _trail2.position = ccp(_player.position.x, _player.position.y);
        [self addChild:_trail2];
    }
}

-(void) trailRemover
{
    //remove the aiming indicator lines
    _trail1.percentage = 0;
    _trail2.percentage = 0;
}

- (void) runAim
{
    //run the aiming animation of the player
    [_player runAction:_aim];
}

- (void) runShoot
{
    //run the shooting animation of the player
    [_player runAction:_shot];
}

- (void) runReload
{
    //run the reload animation of the player
    [_player runAction:_reload];
}

- (void) runStopShoot
{
    //run the animation of the player holstering their gun
    [_player runAction:_stopShoot];
}

- (void) FOV
{
    // execute the shadow algorithm in each octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:1 xy:0 yx:0 yy:1];//ENE octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:0 xy:1 yx:1 yy:0];//NNE octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:0 xy:-1 yx:1 yy:0];//NNW octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:-1 xy:0 yx:0 yy:1];//WNW octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:-1 xy:0 yx:0 yy:-1];//WSW octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:0 xy:-1 yx:-1 yy:0];//SSW octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:0 xy:1 yx:-1 yy:0];//SSE octant
    [self castLightRow:1 StartGradient:0 EndGradient:1 xx:1 xy:0 yx:0 yy:-1];//ESE octant
}

- (void) castLightRow:(int)row StartGradient:(float)startGradient EndGradient:(float)endGradient xx:(int)xx xy:(int)xy yx:(int)yx yy:(int)yy
{
    //execute the shadow algorithm for the spcified octant
    bool previousCollidable = false;
    float newStartGradient = 0;
    for (float x = row; x <= 20 && !previousCollidable; x++)
    {
        for (float y = 0; y <= x; y++)
        {
            float topGradient = (y+0.5)/(x-0.5); //gradient to top left of the tile
            float bottomGradient = (y-0.5)/(x+0.5); //gradient to bottom right of the tile
            if (topGradient >= startGradient)
            {
                //not in a shadow
                if (endGradient < bottomGradient)
                {
                    //reached the diagonal or the bottom of a shadow
                    break;
                }
                
                //transformation to the map coordinates for the correct octant
                int tempX = _player.position.x/8 + (x * xx) + (y * xy);
                int tempY = _player.position.y/8 + (x * yx) + (y * yy);
                tempY = _tileMap.mapSize.height - tempY;
                
                if ((x*x) + (y*y) <= 400)
                {
                    //tile is within a radius of 20 tiles, set tile as visible
                    int GID = _shadows.tileset.firstGid;
                    [_shadows setTileGID:GID+1 at:ccp(tempX,tempY)];
                }
                
                if (previousCollidable)
                {
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,tempY)]][@"Collidable"]isEqualToString:@"True"])
                    {
                        newStartGradient = topGradient;
                    }
                    else
                    {
                        previousCollidable = false;
                        startGradient = newStartGradient;
                    }
                }
                else
                {
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,tempY)]][@"Collidable"]isEqualToString:@"True"] && x < 20)
                    {
                        previousCollidable = true;
                        if (startGradient <= bottomGradient)
                        {
                            [self castLightRow:x + 1 StartGradient:startGradient EndGradient:bottomGradient xx:xx xy:xy yx:yx yy:yy];
                        }
                        newStartGradient = topGradient;
                    }
                }
            }
        }
    }
}

-(void) constructMap
{
    // generate binary space partition tree
    _topNode = [BSPNode new];
    _topNode.topRightx = [NSNumber numberWithInt:300];
    _topNode.topRighty = [NSNumber numberWithInt:300];
    _topNode.botLeftx = [NSNumber numberWithInt:200];
    _topNode.botLefty = [NSNumber numberWithInt:200];
    int n = 8;
    [self split:_topNode n:n];

    //populate rooms with enemies and spawn the player
    [self setSpawn:_topNode];
    [self spawnEnemies:_topNode];
    
    //link up rooms
    [self linkRooms:_topNode];
    
    //add walls to the rooms
    int GID = _background.tileset.firstGid;
    int adjacents;
    BOOL top;
    BOOL bot;
    BOOL right;
    BOOL left;
    for (int x = 200; x< 300; x++)
    {
        for (int y = 200; y<300; y++)
        {
            if([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"True"])
            {
                top = 0;
                bot = 0;
                right = 0;
                left = 0;
                adjacents = 0;
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+1,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    adjacents ++;
                    right = 1;
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-1,_tileMap.mapSize.height- y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    adjacents ++;
                    left = 1;
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y - 1)]][@"Collidable"]isEqualToString:@"False"])
                {
                    adjacents ++;
                    top = 1;
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y + 1)]][@"Collidable"]isEqualToString:@"False"])
                {
                    adjacents ++;
                    bot = 1;
                }
                
                if (adjacents != 0)
                {
                    if (adjacents == 1)
                    {
                        //one adjacent walkable tile
                        if (right)
                        {
                            [_background setTileGID:GID+24 at:ccp(x,_tileMap.mapSize.height -y)];
                        }
                        if (left)
                        {
                            [_background setTileGID:GID+23 at:ccp(x,_tileMap.mapSize.height -y)];
                        }
                        if (top)
                        {
                            [_background setTileGID:GID+28 at:ccp(x,_tileMap.mapSize.height -y)];
                        }
                        if (bot)
                        {
                            [_background setTileGID:GID+29 at:ccp(x,_tileMap.mapSize.height -y)];
                        }
                    }
                    else if (adjacents == 3)
                    {
                        //3 adjacent walkable tiles
                        if (y%2)
                        {
                            [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                        }
                        else
                        {
                            [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                        }
                    }
                    else if (adjacents == 2)
                    {
                        //2 adjacent walkable tiles
                        if (right)
                        {
                            if (left)
                            {
                                if (y%2)
                                {
                                    [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                                }
                                else
                                {
                                    [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                                }
                            }
                            if (top)
                            {
                                [_background setTileGID:GID+25 at:ccp(x,_tileMap.mapSize.height -y)];
                            }
                            if (bot)
                            {
                                [_background setTileGID:GID+34 at:ccp(x,_tileMap.mapSize.height -y)];
                            }
                        }
                        else if (left)
                        {
                            if (top)
                            {
                                [_background setTileGID:GID+36 at:ccp(x,_tileMap.mapSize.height -y)];
                            }
                            if (bot)
                            {
                                [_background setTileGID:GID+35 at:ccp(x,_tileMap.mapSize.height -y)];
                            }
                        }
                        else if (top)
                        {
                            if (bot)
                            {
                                if (y%2)
                                {
                                    [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                                }
                                else
                                {
                                    [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                                }
                            }
                        }
                    }
                }
                else if (adjacents == 4)
                {
                    //4 adjacent walkable tiles
                    if (y%2)
                     {
                         [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                     }
                     else
                     {
                         [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                     }
                }
                else
                {
                    // diagonally adjacent walkable tiles
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-1,_tileMap.mapSize.height- y + 1)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID+42 at:ccp(x,_tileMap.mapSize.height -y)];
                    }
                    else if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+1,_tileMap.mapSize.height- y - 1)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID+41 at:ccp(x,_tileMap.mapSize.height -y)];
                    }
                    else if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-1,_tileMap.mapSize.height- y - 1)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID+27 at:ccp(x,_tileMap.mapSize.height -y)];
                    }
                    else if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+1,_tileMap.mapSize.height- y + 1)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID+43 at:ccp(x,_tileMap.mapSize.height -y)];
                    }
                    else
                    {
                        [_background setTileGID:GID at:ccp(x,_tileMap.mapSize.height -y)];
                    }
                }
            }
        }
    }
    [self setExit:_topNode];
}

-(void) split:(BSPNode*)Node n:(int)n
{
    // split the inputted node into two nodes
    if (n>0)
    {
        BOOL vertical;
        if (Node.topRightx.intValue - Node.botLeftx.intValue < 25 || Node.topRighty.intValue - Node.botLefty.intValue < 25)
        {
            //create room because node is too small
            float fraction = arc4random()%26;
            fraction = (fraction/100)+0.75;
            float newVal = ((Node.topRightx.intValue - Node.botLeftx.intValue)*fraction)+Node.botLeftx.intValue - 1;
            Node.topRightx = [NSNumber numberWithInt:newVal];
            
            fraction = arc4random()%26;
            fraction = (fraction/100)+0.75;
            newVal = ((Node.topRighty.intValue - Node.botLefty.intValue)*fraction)+Node.botLefty.intValue - 1;
            Node.topRighty = [NSNumber numberWithInt:newVal];
            
            fraction = arc4random()%26;
            fraction = fraction/100;
            newVal = ((Node.topRightx.intValue - Node.botLeftx.intValue)*fraction)+Node.botLeftx.intValue + 1;
            Node.botLeftx = [NSNumber numberWithInt:newVal];
            
            fraction = arc4random()%26;
            fraction = fraction/100;
            newVal = ((Node.topRighty.intValue - Node.botLefty.intValue)*fraction)+Node.botLefty.intValue + 1;
            Node.botLefty = [NSNumber numberWithInt:newVal];
            
            int GID = _background.tileset.firstGid;
            for (int x = Node.botLeftx.intValue; x<Node.topRightx.intValue; x++)
            {
                for (int y = Node.botLefty.intValue; y<Node.topRighty.intValue;y++)
                {
                    if (y%2)
                    {
                        [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                    }
                    else
                    {
                        [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                    }
                }
            }
            return;
        }
        
        //create child nodes
        Node.leftNode = [BSPNode new];
        Node.rightNode = [BSPNode new];
        
        Node.leftNode.botLeftx = [NSNumber numberWithInt:Node.botLeftx.intValue];
        Node.leftNode.botLefty = [NSNumber numberWithInt:Node.botLefty.intValue];
        Node.rightNode.topRightx = [NSNumber numberWithInt:Node.topRightx.intValue];
        Node.rightNode.topRighty = [NSNumber numberWithInt:Node.topRighty.intValue];
        
        if (Node.topRightx.intValue - Node.botLeftx.intValue > 2*(Node.topRighty.intValue - Node.botLefty.intValue))
        {
            vertical = YES;
        }
        else if (Node.topRighty.intValue - Node.botLefty.intValue > 2*(Node.topRightx.intValue - Node.botLeftx.intValue))
        {
            vertical = NO;
        }
        else
        {
            vertical = arc4random()%2;
        }
        
        float division = arc4random()%61;
        division = (division/100)+0.2;
        
        //set coordinates of child nodes
        if (vertical)
        {
            Node.vertical = [NSNumber numberWithBool:YES];
            float newX = ((Node.topRightx.intValue - Node.botLeftx.intValue)*division)+Node.botLeftx.intValue;
            
            Node.split = [NSNumber numberWithInt:newX];

            Node.leftNode.topRightx = [NSNumber numberWithInt:newX];
            Node.rightNode.botLeftx = [NSNumber numberWithInt:Node.leftNode.topRightx.intValue];
            
            Node.leftNode.topRighty = [NSNumber numberWithInt:Node.topRighty.intValue];
            Node.rightNode.botLefty = [NSNumber numberWithInt:Node.botLefty.intValue];
            
        }
        else
        {
            Node.vertical = [NSNumber numberWithBool:NO];
            float newY = ((Node.topRighty.intValue - Node.botLefty.intValue)*division)+Node.botLefty.intValue;
            
            Node.split = [NSNumber numberWithInt:newY];
            
            Node.leftNode.topRighty =[NSNumber numberWithInt:newY];
            Node.rightNode.botLefty = [NSNumber numberWithInt:Node.leftNode.topRighty.intValue];
            
            Node.leftNode.topRightx = [NSNumber numberWithInt:Node.topRightx.intValue];
            Node.rightNode.botLeftx = [NSNumber numberWithInt:Node.botLeftx.intValue];
        }
        
        n--;
        [self split:Node.leftNode n:n];
        [self split:Node.rightNode n:n];
    }
    else
    {
        //create rooms
        float fraction = arc4random()%26;
        fraction = (fraction/100)+0.75;
        float newVal = ((Node.topRightx.intValue - Node.botLeftx.intValue)*fraction)+Node.botLeftx.intValue - 1;
        Node.topRightx = [NSNumber numberWithInt:newVal];
        
        fraction = arc4random()%26;
        fraction = (fraction/100)+0.75;
        newVal = ((Node.topRighty.intValue - Node.botLefty.intValue)*fraction)+Node.botLefty.intValue - 1;
        Node.topRighty = [NSNumber numberWithInt:newVal];
        
        fraction = arc4random()%26;
        fraction = fraction/100;
        newVal = ((Node.topRightx.intValue - Node.botLeftx.intValue)*fraction)+Node.botLeftx.intValue + 1;
        Node.botLeftx = [NSNumber numberWithInt:newVal];
        
        fraction = arc4random()%26;
        fraction = fraction/100;
        newVal = ((Node.topRighty.intValue - Node.botLefty.intValue)*fraction)+Node.botLefty.intValue + 1;
        Node.botLefty = [NSNumber numberWithInt:newVal];
        
        int GID = _background.tileset.firstGid;
        for (int x = Node.botLeftx.intValue; x<Node.topRightx.intValue; x++)
        {
            for (int y = Node.botLefty.intValue; y<Node.topRighty.intValue;y++)
            {
                if (y%2)
                {
                    [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                }
                else
                {
                    [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                }
            }
        }
    }
}

- (void) setSpawn:(BSPNode*)Node
{
    //set the player's spawn
    if (Node.leftNode)
    {
        BOOL left = arc4random()%2;
        if (left)
        {
            [self setSpawn:Node.leftNode];
        }
        else
        {
            [self setSpawn:Node.rightNode];
        }
    }
    else
    {
        //set player spawn here
        _player.position = ccp(((Node.topRightx.intValue + Node.botLeftx.intValue)/2)*8,((Node.topRighty.intValue + Node.botLefty.intValue)/2)*8);
    }
}

- (void) linkRooms:(BSPNode*)Node
{
    //link the rooms together with corridors
    if (Node.leftNode.leftNode)
    {
        [self linkRooms:Node.leftNode];
    }
    if (Node.rightNode.leftNode)
    {
        [self linkRooms:Node.rightNode];
    }

    int GID = _background.tileset.firstGid;
    if (Node.vertical.boolValue)
    {
        //vertical split
        int topy = MIN([self maxTopRighty:Node.leftNode]-1, [self maxTopRighty:Node.rightNode]-1);
        int boty = MAX([self minBotLefty:Node.leftNode]+1,[self minBotLefty:Node.rightNode]+1);
        float fraction = arc4random()%91;
        fraction = (fraction/100)+0.05;
        fraction = (fraction*(topy - boty))+boty;
        int y = fraction;
        int GID2;
        int GID3;
        if (y%2)
        {
            GID2 = GID + 14;
            GID3 = GID + 16;
        }
        else
        {
            GID2 = GID + 16;
            GID3 = GID + 14;
        }
        int x = Node.split.intValue;
        //propogate path to the right
        for (;;x++)
        {
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
            {
                for (int tempX = x;tempX<x+3;tempX++)
                {
                    [_background setTileGID:GID2 at:ccp(tempX,_tileMap.mapSize.height - y)];
                    [_background setTileGID:GID3 at:ccp(tempX,_tileMap.mapSize.height - y - 1)];
                    [_background setTileGID:GID3 at:ccp(tempX,_tileMap.mapSize.height - y + 1)];
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,_tileMap.mapSize.height - y - 3)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y - 2)];
                    }
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,_tileMap.mapSize.height - y + 3)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y + 2)];
                    }
                }
                break;
            }
            
            [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y)];
            [_background setTileGID:GID3 at:ccp(x,_tileMap.mapSize.height - y - 1)];
            [_background setTileGID:GID3 at:ccp(x,_tileMap.mapSize.height - y + 1)];
            
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y - 3)]][@"Collidable"]isEqualToString:@"False"])
            {
                [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y - 2)];
            }
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y + 3)]][@"Collidable"]isEqualToString:@"False"])
            {
                [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y + 2)];
            }
        }

        x = Node.split.intValue - 1;
        //propogate path to the left
        for (;;x--)
        {
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
            {
                for (int tempX = x;tempX>x-3;tempX--)
                {
                    [_background setTileGID:GID2 at:ccp(tempX,_tileMap.mapSize.height - y)];
                    [_background setTileGID:GID3 at:ccp(tempX,_tileMap.mapSize.height - y - 1)];
                    [_background setTileGID:GID3 at:ccp(tempX,_tileMap.mapSize.height - y + 1)];
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,_tileMap.mapSize.height - y - 3)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y - 2)];
                    }
                    if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(tempX,_tileMap.mapSize.height - y + 3)]][@"Collidable"]isEqualToString:@"False"])
                    {
                        [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y + 2)];
                    }
                }
                break;
            }
            
            [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y)];
            [_background setTileGID:GID3 at:ccp(x,_tileMap.mapSize.height - y - 1)];
            [_background setTileGID:GID3 at:ccp(x,_tileMap.mapSize.height - y + 1)];
            
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y - 3)]][@"Collidable"]isEqualToString:@"False"])
            {
                [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y - 2)];
            }
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y + 3)]][@"Collidable"]isEqualToString:@"False"])
            {
                [_background setTileGID:GID2 at:ccp(x,_tileMap.mapSize.height - y + 2)];
            }
        }
    }
    else
    {
        //horizontal split
        int topx = MIN([self maxTopRightx:Node.leftNode]-1,[self maxTopRightx:Node.rightNode]-1);
        int botx = MAX([self minBotLeftx:Node.leftNode]+1,[self minBotLeftx:Node.rightNode]+1);
        float fraction = arc4random()%91;
        fraction = (fraction/100)+0.05;
        fraction = (fraction*(topx - botx))+botx;
        int x = fraction;
        int y = Node.split.intValue;
        //propogate path upwards
        for (;;y++)
        {
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
            {
                for (int tempY = y;tempY<y+3;tempY++)
                {
                    if (tempY%2)
                    {
                        [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+14 at:ccp(x-1,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+14 at:ccp(x+1,_tileMap.mapSize.height - tempY)];
                        if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - tempY)]][@"Collidable"]isEqualToString:@"False"])
                        {
                            [_background setTileGID:GID+14 at:ccp(x-2,_tileMap.mapSize.height - y)];
                        }
                        if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - tempY)]][@"Collidable"]isEqualToString:@"False"])
                        {
                            [_background setTileGID:GID+14 at:ccp(x+2,_tileMap.mapSize.height - y)];
                        }
                    }
                    else
                    {
                        [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+16 at:ccp(x-1,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+16 at:ccp(x+1,_tileMap.mapSize.height - tempY)];
                        if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - tempY)]][@"Collidable"]isEqualToString:@"False"])
                        {
                            [_background setTileGID:GID+16 at:ccp(x-2,_tileMap.mapSize.height - y)];
                        }
                        if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - tempY)]][@"Collidable"]isEqualToString:@"False"])
                        {
                            [_background setTileGID:GID+16 at:ccp(x+2,_tileMap.mapSize.height - y)];
                        }
                    }
                }
                break;
            }
            if (y%2)
            {
                [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+14 at:ccp(x-1,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+14 at:ccp(x+1,_tileMap.mapSize.height - y)];
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+14 at:ccp(x-2,_tileMap.mapSize.height - y)];
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+14 at:ccp(x+2,_tileMap.mapSize.height - y)];
                }
            }
            else
            {
                [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+16 at:ccp(x-1,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+16 at:ccp(x+1,_tileMap.mapSize.height - y)];
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+16 at:ccp(x-2,_tileMap.mapSize.height - y)];
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+16 at:ccp(x+2,_tileMap.mapSize.height - y)];
                }
            }
        }
        
        y = Node.split.intValue-1;
        //propogate path downwards
        for (;;y--)
        {
            if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
            {
                for (int tempY = y;tempY>y-3;tempY--)
                {
                    if (tempY%2)
                    {
                        [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+14 at:ccp(x-1,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+14 at:ccp(x+1,_tileMap.mapSize.height - tempY)];
                    }
                    else
                    {
                        [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+16 at:ccp(x-1,_tileMap.mapSize.height - tempY)];
                        [_background setTileGID:GID+16 at:ccp(x+1,_tileMap.mapSize.height - tempY)];
                    }
                }
                break;
            }
            
            if (y%2)
            {
                [_background setTileGID:GID+14 at:ccp(x,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+14 at:ccp(x-1,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+14 at:ccp(x+1,_tileMap.mapSize.height - y)];
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+14 at:ccp(x-2,_tileMap.mapSize.height - y)];
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+14 at:ccp(x+2,_tileMap.mapSize.height - y)];
                }
            }
            else
            {
                [_background setTileGID:GID+16 at:ccp(x,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+16 at:ccp(x-1,_tileMap.mapSize.height - y)];
                [_background setTileGID:GID+16 at:ccp(x+1,_tileMap.mapSize.height - y)];
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x-3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+16 at:ccp(x-2,_tileMap.mapSize.height - y)];
                }
                if ([[_tileMap propertiesForGID:[_background tileGIDAt:ccp(x+3,_tileMap.mapSize.height - y)]][@"Collidable"]isEqualToString:@"False"])
                {
                    [_background setTileGID:GID+16 at:ccp(x+2,_tileMap.mapSize.height - y)];
                }
            }
        }
    }
}

- (int) maxTopRighty:(BSPNode*)Node
{
    //return the maximum top right corner y coordinate of the node and it's child nodes
    if (Node.leftNode)
    {
        int y1 = [self maxTopRighty:Node.leftNode];
        int y2 = [self maxTopRighty:Node.rightNode];
        return MAX(y1,y2);
    }
    else
    {
        return Node.topRighty.intValue;
    }
}

- (int) minBotLefty:(BSPNode*)Node
{
    //return the minimum bottom left corner y coordinate of the node and it's child nodes
    if (Node.leftNode)
    {
        int y1 = [self minBotLefty:Node.leftNode];
        int y2 = [self minBotLefty:Node.rightNode];
        return MIN(y1,y2);
    }
    else
    {
        return Node.botLefty.intValue;
    }
}

- (int) maxTopRightx:(BSPNode*)Node
{
    //return the maximum top right corner x coordinate of the node and it's child nodes
    if (Node.leftNode)
    {
        int y1 = [self maxTopRightx:Node.leftNode];
        int y2 = [self maxTopRightx:Node.rightNode];
        return MAX(y1,y2);
    }
    else
    {
        return Node.topRightx.intValue;
    }
}

- (int) minBotLeftx:(BSPNode*)Node
{
    //return the minimum bottom left corner x coordinate of the node and it's child nodes
    if (Node.leftNode)
    {
        int y1 = [self minBotLeftx:Node.leftNode];
        int y2 = [self minBotLeftx:Node.rightNode];
        return MIN(y1,y2);
    }
    else
    {
        return Node.botLeftx.intValue;
    }
}

- (void) spawnEnemies:(BSPNode*)Node
{
    //create enemies in the rooms of the map
    if (Node.leftNode)
    {
        [self spawnEnemies:Node.leftNode];
        [self spawnEnemies:Node.rightNode];
    }
    else
    {
        int spaceX = (Node.topRightx.intValue - Node.botLeftx.intValue)/8;
        int spaceY = (Node.topRighty.intValue - Node.botLefty.intValue)/8;
        for (int x = 0; x < spaceX; x++)
        {
            for (int y = 0; y < spaceY; y++)
            {
                if (abs((Node.botLeftx.intValue + 4 + (x*8))*8 - _player.position.x) > 60 && abs((Node.botLefty.intValue + 4 + (y*8))*8 - _player.position.y) > 60)
                {
                    int spawn = arc4random()%101;
                    int threshold;
                    if ([[Engine sharedInstance] currentLevel].intValue > 15)
                    {
                        threshold = 15;
                    }
                    else
                    {
                        threshold =[[Engine sharedInstance] currentLevel].intValue;
                    }
                    if (spawn > 40 - threshold)
                    {
                        //spawn enemy
                        Enemy *enemy = [Enemy spriteWithFile:@"enemynatural.png"];
                        enemy.position = ccp((Node.botLeftx.intValue + 4 + (x*8))*8,(Node.botLefty.intValue + 4 + (y*8))*8);
                        [enemy initWithHealth:100 + ([[Engine sharedInstance] currentLevel].intValue*100) Damage:1];
                        enemy.rotation = arc4random()%361;
                        [self addChild:enemy z:1];
                        [self addChild:[enemy healthDisplayReference] z:1];
                        
                        NSMutableArray *objectsArray;
                        
                        if (_enemys != nil)
                        {
                            objectsArray = [NSMutableArray arrayWithArray: _enemys.allObjects];
                            [objectsArray addObject:enemy];
                            _enemys = [NSMutableSet setWithArray:objectsArray];
                        }
                        else
                        {
                            _enemys = [NSMutableSet setWithObject:enemy];
                        }
                    }
                }
            }
        }
    }
}

- (void) setExit:(BSPNode*)Node
{
    //set the position of the exit of the map
    if (Node.leftNode)
    {
        BOOL left = arc4random()%2;
        if (left)
        {
            [self setExit:Node.leftNode];
        }
        else
        {
            [self setExit:Node.rightNode];
        }
    }
    else
    {
        if (((Node.topRightx.intValue + Node.botLeftx.intValue)/2)*8 == _player.position.x && ((Node.topRighty.intValue + Node.botLefty.intValue)/2)*8 == _player.position.y)
        {
            [self setExit:_topNode];
        }
        else
        {
            int GID = _background.tileset.firstGid;
            [_background setTileGID:GID+37 at:ccp((Node.topRightx.intValue + Node.botLeftx.intValue)/2 - 1,_tileMap.mapSize.height - (Node.topRighty.intValue + Node.botLefty.intValue)/2)];
            [_background setTileGID:GID+38 at:ccp((Node.topRightx.intValue + Node.botLeftx.intValue)/2,_tileMap.mapSize.height - (Node.topRighty.intValue + Node.botLefty.intValue)/2)];
            [_background setTileGID:GID+39 at:ccp((Node.topRightx.intValue + Node.botLeftx.intValue)/2 - 1,_tileMap.mapSize.height - (Node.topRighty.intValue + Node.botLefty.intValue)/2 - 1)];
            [_background setTileGID:GID+40 at:ccp((Node.topRightx.intValue + Node.botLeftx.intValue)/2,_tileMap.mapSize.height - (Node.topRighty.intValue + Node.botLefty.intValue)/2 - 1)];
        }
    }
}

-(void) died
{
    //player has died
    [[Engine sharedInstance] setPausedVariable: [NSNumber numberWithBool:1]];
    [[Engine sharedInstance] setAlive:[NSNumber numberWithBool:0]];
    
    for (Enemy *enemy in _enemys.allObjects)
    {
        if (enemy != nil)
        {
            [self removeChild:enemy cleanup:YES];
            [self removeChild:enemy.healthDisplayReference cleanup:YES];
        }
    }
    _enemys = nil;
    _shadows = [_shadowMap layerNamed:@"Shadows"];
    [_shadows setTileGID:(_shadows.tileset.firstGid + 1) at:ccp(_player.position.x/8,_tileMap.mapSize.height - (_player.position.y/8))];
}

- (void) save
{
    //save the map and enemies
    NSMutableArray *tiles = [[NSMutableArray alloc]init];
    for (int x = 200; x < 300; x++)
    {
        for (int y = 200; y < 300; y++)
        {
            [tiles addObject:[NSNumber numberWithInt:[_background tileGIDAt:ccp(x,y)]]];
        }
    }
    
    int n = 0;
    NSMutableArray *enemies = [[NSMutableArray alloc]init];
    for (Enemy *object in _enemys.allObjects)
    {
        if (object != nil)
        {
            [enemies addObject:[NSNumber numberWithInt:object.position.x]];
            [enemies addObject:[NSNumber numberWithInt:object.position.y]];
            [enemies addObject:[NSNumber numberWithInt:object.health.intValue]];
            [enemies addObject:[NSNumber numberWithInt:object.activated.intValue]];
            [enemies addObject:[NSNumber numberWithFloat:object.rotation]];
            n++;
        }
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                tiles, @"tiles",
                                enemies, @"enemies", nil];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"appData"];
    [NSKeyedArchiver archiveRootObject:dictionary toFile:filePath];
    [[Engine sharedInstance] setSaved:[NSNumber numberWithBool:true]];
}

- (void) onExitTransitionDidStart
{
    //run the save algorithm when the layer is closing
    [self save];
}

- (void) onEnter
{
    //set up the map after the layer appears
    [super onEnter];
    if ([[Engine sharedInstance] startingNewGame].boolValue)
    {
        for (int x = 200; x <=300; x++)
        {
            for (int y = 200; y <=300; y++)
            {
                [_background setTileGID:(_background.tileset.firstGid) at:ccp(x,y)];
                [_shadows setTileGID:(_shadows.tileset.firstGid) at:ccp(x,y)];
            }
        }
        for (Enemy *enemy in _enemys.allObjects)
        {
            if (enemy != nil)
            {
                [self removeChild:enemy cleanup:YES];
                [self removeChild:enemy.healthDisplayReference cleanup:YES];
            }
        }
        _enemys = nil;
        [self constructMap];
        int GID = _shadows.tileset.firstGid + 1;
        [_shadows setTileGID:GID at:ccp(_player.position.x/8,_tileMap.mapSize.height - (_player.position.y/8))];
    }
}

@end
