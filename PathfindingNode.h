//
//  PathfindingNode.h
//  Endless Temple
//
//  Created by Daniel Ellis.
//  Copyright 2014 Daniel Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathfindingNode : NSObject {}
@property (strong) NSNumber *x;
@property (strong) NSNumber *y;
@property (strong) NSNumber *fCost;
@property (strong) NSNumber *gCost;
@property (strong) PathfindingNode *source;
@end
