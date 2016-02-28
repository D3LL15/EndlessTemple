//
//  GUIMainController.m
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import "GUIMainController.h"
#import "HUDLayer.h"
#import "GameLayer.h"

@interface GUIMainController()



@end

@implementation GUIMainController

- (id) init
{
    //initialise singleton
    if (self = [super init])
    {
        _HUDLayerScene = [HUDLayer scene];
        _GameLayerScene = [GameLayer alloc];
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
