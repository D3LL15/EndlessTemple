//
//  GameOverLayer.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "GameOverLayer.h"
#import "MenuLayer.h"
#import "Engine.h"
#import <QuartzCore/QuartzCore.h>
#import "ErrorLayer.h"


@implementation GameOverLayer

+(CCScene *) scene
{
    //return the scene
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [GameOverLayer node];
    [scene addChild: layer];
    return scene;
}

-(id) init
{
    //initialise the game over layer
    if( (self=[super init]) )
    {
        CCLabelTTF *gameOver = [CCLabelTTF labelWithString:@"Game Over" fontName:@"Marker Felt" fontSize:64];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        gameOver.position =  ccp( size.width /2 , 13*(size.height/16) );
        [self addChild: gameOver];
        
        [CCMenuItemFont setFontSize:28];
        
        CCMenuItem *itemDone = [CCMenuItemFont itemWithString:@"Done" target:self selector:@selector(done)];
        
        CCMenu *doneMenu = [CCMenu menuWithItems:itemDone, nil];
        [doneMenu setPosition:ccp( size.width/2, size.height/3)];
        [self addChild:doneMenu];
        
        
        CCLabelTTF *score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", [[Engine sharedInstance] currentScore].intValue] fontName:@"Marker Felt" fontSize:28];
        score.position = ccp( size.width /2 , size.height/2 );
        [self addChild:score];
        
        
        CCLabelTTF *name = [CCLabelTTF labelWithString:@"Name:" fontName:@"Marker Felt" fontSize:28];
        name.position = ccp( size.width/3, 5*(size.height/8));
        [self addChild: name];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(size.width/2,(3*(size.height/8)) - 15,100,30)];
        nameField.borderStyle = UITextBorderStyleRoundedRect;
        nameField.keyboardType = UIKeyboardTypeAlphabet;
        nameField.delegate = self;
        nameField.placeholder = @"Name";
        nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        [[[CCDirector sharedDirector] view]addSubview:nameField];
        
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

- (void) done
{
    //update the high scores and move to the main menu
    if (nameField.text.length > 10)
    {
        //name too long
        [[Engine sharedInstance] setErrorMessage:@"Name too long"];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ErrorLayer scene] withColor:ccBLACK]];
        [nameField removeFromSuperview];
    }
    else if (![nameField.text  isEqual: @""])
    {
        int x = 0;
        while (x <= 4)
        {
            NSNumber *temp = [[[Engine sharedInstance] highScores] objectAtIndex:x];
            if ([[Engine sharedInstance] currentScore].intValue > temp.intValue)
            {
                break;
            }
            x++;
        }
        
        if (x != 5)
        {
            for (int y = 4; y > x; y--)
            {
                NSString *tempString = [NSString stringWithString:[[[Engine sharedInstance] highScoreNames] objectAtIndex:y-1]];
                [[[Engine sharedInstance] highScoreNames] replaceObjectAtIndex:y withObject:[NSString stringWithString:tempString]];
                NSNumber *temp = [[[Engine sharedInstance] highScores] objectAtIndex:y-1];
                [[[Engine sharedInstance] highScores] replaceObjectAtIndex:y withObject:[NSNumber numberWithInt:temp.intValue]];
            }
            
            [[[Engine sharedInstance] highScoreNames] replaceObjectAtIndex:x withObject:[NSString stringWithString:nameField.text]];
            [[[Engine sharedInstance] highScores] replaceObjectAtIndex:x withObject:[NSNumber numberWithInt:[[Engine sharedInstance] currentScore].intValue]];
        }
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccBLACK]];
        [nameField removeFromSuperview];
    }
    else
    {
        //name not entered
        [[Engine sharedInstance] setErrorMessage:@"Please enter a name"];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ErrorLayer scene] withColor:ccBLACK]];
        [nameField removeFromSuperview];
    }
}

//text field handling methods
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField endEditing:YES];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [nameField becomeFirstResponder];
}

@end
