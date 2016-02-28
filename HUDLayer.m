//
//  HUDLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "HUDLayer.h"
#import "GameLayer.h"
#import "Engine.h"
#import "AppDelegate.h"
#import "MenuLayer.h"
#import "PauseLayer.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"

@interface HUDLayer()

@property (strong) GameLayer *game;
@property (strong) NSNumber *vX;
@property (strong) NSNumber *vY;
@property (strong) NSNumber *direction;
@property (strong) NSNumber *aiming;
@property (strong) NSNumber *amountAimed;
@property (strong) NSNumber *weapon;
@property (strong) NSNumber *aimDone;
@property (strong) NSNumber *shootDone;
@property (strong) NSNumber *clips;
@property (strong) NSNumber *reloadDone;

@property (strong) CCProgressTimer *healthDisplay;
@property (strong) CCProgressTimer *ammoDisplay;
@property (strong) CCSprite *joystick;
@property (strong) CCSprite *joystick2;
@property (strong) CCLabelTTF *ammoClips;
@property (strong) CCLabelTTF *scoreLabel;
@property (strong) CCSprite *ammoReloadIndicator;



@end

@implementation HUDLayer


+(CCScene *) scene
{
    //return the scene
	CCScene *scene= [CCScene node];
	GameLayer *game = [GameLayer node];
    HUDLayer *HUD = [HUDLayer node];
    
	[scene addChild: game];
    [scene addChild:HUD];
    
    HUD.game = game;
	
	return scene;
}

- (id) init
{
    //initialise the HUD layer
    self = [super init];
    if (self)
    {
        self.isTouchEnabled = YES;
        [[Engine sharedInstance] setPausedVariable:[NSNumber numberWithBool:false]];
        [self schedule:@selector(update) interval:1/30];
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        
        [[Engine sharedInstance] setHealth:[NSNumber numberWithInt:[[Engine sharedInstance] health].intValue]];
        _weapon = [NSNumber numberWithInt:1];
        _aimDone = [NSNumber numberWithBool:true];
        _shootDone = [NSNumber numberWithBool:true];
        _clips = [NSNumber numberWithInt:5];
        _reloadDone = [NSNumber numberWithBool:true];
        
        
        CCSprite *pause;
        pause = [CCSprite spriteWithFile:@"pause.png"];
        pause.position = ccp(size.width/2,size.height-10);
        
        CCSprite *joystickBase;
        joystickBase = [CCSprite spriteWithFile:@"Joystick_Base.png"];
        joystickBase.position = ccp(70,70);
        
        CCSprite *joystickBase2;
        joystickBase2 = [CCSprite spriteWithFile:@"Joystick_Base.png"];
        joystickBase2.position = ccp(size.width - 70, 70);
        
        _ammoClips = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", _clips.intValue] fontName:@"Marker Felt" fontSize:10];
        _ammoClips.position =ccp(size.width - 20, size.height - 10);
        _ammoClips.visible = false;
        
        _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", [[Engine sharedInstance] currentScore].intValue] fontName:@"Marker Felt" fontSize:10];
        _scoreLabel.position =ccp(20, size.height - 22);
        _scoreLabel.anchorPoint = ccp(0,0.5f);
        
        CCSprite *healthBar;
        healthBar = [CCSprite spriteWithFile:@"HealthBar.png"];
        healthBar.position = ccp(108, size.height - 10);
        
        CCSprite *ammoBacking;
        ammoBacking = [CCSprite spriteWithFile:@"AmmoBacking.png"];
        ammoBacking.position = ccp(size.width - 108, size.height - 10);
        ammoBacking.scaleX = -1;
        
        _ammoReloadIndicator = [CCSprite spriteWithFile:@"AmmoReload.png"];
        _ammoReloadIndicator.position = ccp(size.width - 108, size.height - 10);
        _ammoReloadIndicator.visible = NO;
        
        _healthDisplay = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"Health.png"]];
        _healthDisplay.type = kCCProgressTimerTypeBar;
        _healthDisplay.midpoint = ccp(0,0);
        _healthDisplay.barChangeRate = ccp(1,0);
        _healthDisplay.percentage = [[Engine sharedInstance] health].integerValue;
        _healthDisplay.position = ccp(108, size.height - 10);
        
        
        CCSprite *ammoDisplaySprite = [CCSprite spriteWithFile:@"Ammo.png"];
        ammoDisplaySprite.scaleX = -1;
        _ammoDisplay = [CCProgressTimer progressWithSprite:ammoDisplaySprite];
        _ammoDisplay.type = kCCProgressTimerTypeBar;
        _ammoDisplay.midpoint = ccp(0,0);
        _ammoDisplay.barChangeRate = ccp(1,0);
        _ammoDisplay.scaleX = -1;
        _ammoDisplay.percentage = [[Engine sharedInstance] ammo].intValue * 10;
        _ammoDisplay.position = ccp(size.width - 108, size.height - 10);
        
        _joystick = [CCSprite spriteWithFile:@"Joystick.png"];
        _joystick.position = ccp(70,70);
        
        _joystick2 = [CCSprite spriteWithFile:@"Joystick.png"];
        _joystick2.position = ccp(size.width - 70,70);
        
        [self addChild:pause];
        [self addChild:joystickBase];
        [self addChild:joystickBase2];
        [self addChild:_joystick];
        [self addChild:_joystick2];
        [self addChild:healthBar];
        [self addChild:ammoBacking];
        [self addChild:_healthDisplay];
        [self addChild:_ammoDisplay];
        [self addChild:_ammoClips];
        [self addChild:_ammoReloadIndicator];
        [self addChild:_scoreLabel];
        
    }
    return self;
}

-(void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //user began touching the screen
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (touchLocation.x < size.width/2 + 12 && touchLocation.x > size.width/2 - 12 && touchLocation.y > size.height - 16)
    {
        //touching pause
        return YES;
    }
    else if (touchLocation.x >= (size.width - 160) && touchLocation.y >= (size.height - 30) && touchLocation.x <= (size.width - 60))
    {
        //touching reload
        return YES;
    }
    else
    {
        touchLocation.x -= 70;
        touchLocation.y -= 70;
        if ( touchLocation.x <= 60 && touchLocation.y <= 60)
        {
            //touching left joystick
            if (((touchLocation.x * touchLocation.x) + (touchLocation.y * touchLocation.y)) <= 3600)
            {
                [self updateVelocity:touchLocation];
                _joystick.position = ccp(touchLocation.x + 60, touchLocation.y + 60);
                if (_aiming.boolValue == NO)
                {
                    [self updateDirection:ccp(touchLocation.x, touchLocation.y)];
                }
                return YES;
            }
        }
        else if (touchLocation.x >= (size.width - 180) && touchLocation.y <= 60)
        {
            //touching right joystick
            if ((((touchLocation.x + 120 - size.width) * (touchLocation.x + 120 - size.width)) + (touchLocation.y * touchLocation.y)) <= 3600)
            {
                [self updateDirection:ccp(touchLocation.x - size.width + 120, touchLocation.y)];
                _joystick2.position = ccp(touchLocation.x + 60, touchLocation.y + 60);
                if (_aimDone.boolValue == true && _reloadDone.boolValue == true)
                {
                    _aiming = [NSNumber numberWithBool:YES];
                    
                    if ([[Engine sharedInstance] ammo].intValue != 0)
                    {
                        _aimDone = [NSNumber numberWithBool:false];
                        [_game runAim];
                        [self performSelector:@selector(aimDoneSel) withObject:nil afterDelay:1];//0.9
                    }
                }
                else
                {
                    _joystick2.position = ccp(size.width - 70,70);
                    return NO;
                }
                return YES;
            }
        }
    }
	return NO;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    //user moved their thumb while touching the screen, update movement direction and rotation
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    CGSize size = [[CCDirector sharedDirector] winSize];
    touchLocation.x -= 70;
    touchLocation.y -= 70;
    
    
    if (((touchLocation.x * touchLocation.x) + (touchLocation.y * touchLocation.y)) <= 3600)
    {
        //moving left joystick
        [self updateVelocity:touchLocation];
        _joystick.position = ccp(touchLocation.x + 60, touchLocation.y + 60);
        if (_aiming.boolValue == NO)
        {
            [self updateDirection:ccp(touchLocation.x, touchLocation.y)];
        }
    }
    else if ((((touchLocation.x + 120 - size.width) * (touchLocation.x + 120 - size.width)) + (touchLocation.y * touchLocation.y)) <= 3600)
    {
        //moving right joystick
        [self updateDirection:ccp(touchLocation.x - size.width + 120, touchLocation.y)];
        _joystick2.position = ccp(touchLocation.x + 60, touchLocation.y + 60);
    }
    else if (touchLocation.x <= size.width/2)
    {
        //moved left joystick beyond its limit
        double tempX;
        double tempY;
        
        tempX = cos(atan(touchLocation.y/touchLocation.x)) * 60;
        tempY = sin(atan(touchLocation.y/touchLocation.x)) * 60;
        
        if (touchLocation.x < 0)
        {
            tempX = -tempX;
            tempY = -tempY;
        }
        
        [self updateVelocity:ccp(tempX,tempY)];
        _joystick.position = ccp(tempX + 60,tempY + 60);
        if (_aiming.boolValue == NO)
        {
            [self updateDirection:ccp(tempX, tempY)];
        }
        
    }
    else
    {
        //moved right joystick beyond its limit
        double tempX;
        double tempY;
        
        tempX = cos(atan(touchLocation.y/(touchLocation.x - size.width + 120))) * 60;
        tempY = sin(atan(touchLocation.y/(touchLocation.x - size.width + 120))) * 60;
        
        if (touchLocation.x < size.width - 120)
        {
            tempX = -tempX;
            tempY = -tempY;
        }
        [self updateDirection:ccp(touchLocation.x - size.width + 120, touchLocation.y)];
        _joystick2.position = ccp(tempX + size.width - 60, tempY + 60);
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //user released their thumb from the screen
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (touchLocation.x < size.width/2 + 12 && touchLocation.x > size.width/2 - 12 && touchLocation.y > size.height - 16)
    {
        //user tapped pause
        [[Engine sharedInstance] setPausedVariable:[NSNumber numberWithBool:true]];
        [self scheduleOnce:@selector(makeTransition:) delay:0.1];
    }
    else if (touchLocation.x >= (size.width - 160) && touchLocation.y >= (size.height - 30) && touchLocation.x <= (size.width - 60))
    {
        //user tapped reload
        if (_clips.intValue != 0)
        {
            _ammoClips.string = [NSString stringWithFormat:@"%d",_clips.intValue];
            [[Engine sharedInstance] setAmmo:[NSNumber numberWithInt:10]];
            _ammoDisplay.percentage = 100;
            _ammoReloadIndicator.visible = NO;
            if (_reloadDone.boolValue)
            {
                [_game runReload];
                [self scheduleOnce:@selector(reloadDoneSel) delay:1.7];
                _reloadDone = [NSNumber numberWithBool:false];
                if ([[Engine sharedInstance] sfxOn].boolValue)
                {
                    [self scheduleOnce:@selector(reloadSound) delay:1];
                }
                
            }
            _joystick2.position = ccp(size.width - 70,70);
            
        }
    }
    else if (touchLocation.x <= size.width/2)
    {
        //user released left joystick
        _vX = [NSNumber numberWithDouble:0];
        _vY = [NSNumber numberWithDouble:0];
        _joystick.position = ccp(70,70);
    }
    else
    {
        // user released right joystick so fire bullet
        _joystick2.position = ccp(size.width - 70,70);
        _aiming = [NSNumber numberWithBool:NO];

        if (_shootDone.boolValue)
        {
            if ([[Engine sharedInstance] ammo].intValue != 0 )
            {
                _shootDone = [NSNumber numberWithBool:false];
                [self performSelector:@selector(shootDoneSel) withObject:nil afterDelay:0.7];
                [_game runShoot];
                [_game trailRemover];
                [_game fireWithDamage:100 direction:_direction.doubleValue accuracy:_amountAimed.intValue];
                [[Engine sharedInstance] setAmmo:[NSNumber numberWithInt:[[Engine sharedInstance] ammo].intValue-1]];
                _ammoDisplay.percentage = [[Engine sharedInstance] ammo].intValue * 10;
                if ([[Engine sharedInstance] ammo].intValue == 0)
                {
                    _ammoReloadIndicator.visible = YES;
                }
                if ([[Engine sharedInstance] sfxOn].boolValue)
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"steyr_aug_single_shot_mp3_by_revilo_games.mp3"];
                }
                
            }
            else
            {
                if ([[Engine sharedInstance] sfxOn].boolValue)
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"handgun_dry_fire.mp3"];
                }
            }
        }
        _amountAimed = [NSNumber numberWithInt:0];
    }
}

- (void) reloadSound
{
    //play the sound effect for reloading
    [[SimpleAudioEngine sharedEngine] playEffect:@"machine_gun_cock_01.mp3"];
}

- (void) updateVelocity:(CGPoint)touchLocation
{
    //set the horizontal and vertical components of the player's velocity
    _vX = [NSNumber numberWithDouble:touchLocation.x/35];
    _vY = [NSNumber numberWithDouble:touchLocation.y/35];
}

- (void) updateDirection:(CGPoint)touchLocation
{
    //rotate the player
    double dX = touchLocation.x;
    double dY = touchLocation.y;
    _direction = [NSNumber numberWithDouble:(atan2f(dX, dY) * (360/(2*3.141592654)))];
}

- (void) update
{
    // call all the methods that need to be run every tick
    if (![[Engine sharedInstance] pausedVariable].boolValue)
    {
        [[Engine sharedInstance] setHealth:[NSNumber numberWithInt:[[Engine sharedInstance] health].intValue - [_game checkForHits]]];
        if ([[Engine sharedInstance] health].intValue <= 0)
        {
            [[Engine sharedInstance] setHealth:[NSNumber numberWithInt:100]];
            [self performSelector:@selector(gameDiedSel) withObject:nil afterDelay:0.5];
            [self performSelector:@selector(gameOverTransition) withObject:nil afterDelay:1];
        }
        [_game checkForBulletCollision];
        _scoreLabel.string = [NSString stringWithFormat:@"Score: %d",[[Engine sharedInstance] currentScore].intValue];
        _healthDisplay.percentage = [[Engine sharedInstance] health].integerValue;
        if (_aiming.boolValue==YES && [[Engine sharedInstance] ammo].intValue!=0)
        {
            [_game updatePlayer:_vX.doubleValue/2 y:_vY.doubleValue/2 d:_direction.doubleValue];
            if (_amountAimed.intValue <= 95)
            {
                _amountAimed = [NSNumber numberWithInt:_amountAimed.intValue+ 5];
            }

            // aiming indicators
            float direction1;
            float direction2;
            int angle = ((100-_amountAimed.intValue)*40)/100;
            if (_direction.doubleValue >= -140)
            {
                direction1 = _direction.doubleValue - angle;
            }
            else
            {
                direction1 = _direction.doubleValue + 360 - angle;
            }
            
            if (_direction.doubleValue <= 140)
            {
                direction2 = _direction.doubleValue + angle;
            }
            else
            {
                direction2 = _direction.doubleValue - 360 + angle;
            }
            
            [_game showTrail:direction1 trail:1];
            [_game showTrail:direction2 trail:0];
        }
        else
        {
            [_game updatePlayer:_vX.doubleValue/1.2 y:_vY.doubleValue/1.2 d:_direction.doubleValue];
        }
        [_game updateEnemies];
    }
}

-(void) makeTransition:(ccTime)dt
{
    // move to the pause screen
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PauseLayer scene] withColor:ccBLACK]];
}

-(void) restartClock
{
    //resume calling the update method
    [self schedule:@selector(update) interval:1/30];
}

+(void) goToRestartClock
{
    [self goToRestartClock];
}

-(void) onEnterTransitionDidFinish
{
    //every tick (1/30th of a second) call the update method
    [self schedule:@selector(update) interval:1/30];
}

- (void) gameOverTransition
{
    //move to the game over screen
    [[CCDirector sharedDirector] replaceScene:[GameOverLayer scene]];
}

-(void) onEnter
{
    // when the layer appears update the health bar and ammo indicator
    [super onEnter];
    _ammoDisplay.percentage = [[Engine sharedInstance] ammo].intValue * 10;
    _healthDisplay.percentage = [[Engine sharedInstance] health].integerValue;
}

// selectors that are called after a delay
-(void) reloadDoneSel
{
    _reloadDone = [NSNumber numberWithBool:true];
}

- (void) aimDoneSel
{
    _aimDone = [NSNumber numberWithBool:YES];
}

- (void) shootDoneSel
{
    _shootDone = [NSNumber numberWithBool:YES];
}

-(void) gameDiedSel
{
    [_game died];
}

@end
