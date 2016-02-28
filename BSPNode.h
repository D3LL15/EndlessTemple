//
//  BSPNode.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BSPNode : NSObject {
    
}

@property (strong) NSNumber *topRightx;
@property (strong) NSNumber *topRighty;
@property (strong) NSNumber *botLeftx;
@property (strong) NSNumber *botLefty;
@property (strong) BSPNode *leftNode;
@property (strong) BSPNode *rightNode;
@property (strong) NSNumber *vertical;
@property (strong) NSNumber *split;

@end
