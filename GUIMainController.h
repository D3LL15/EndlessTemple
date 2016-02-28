//
//  GUIMainController.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "HUDLayer.h"

@interface GUIMainController : CCNode {
    
}
+ (id) sharedInstance;
@property (strong) GameLayer* GameLayerScene;
@property (strong) CCScene* HUDLayerScene;
@end
