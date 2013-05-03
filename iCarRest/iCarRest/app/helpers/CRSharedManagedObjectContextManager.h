//
//  CRSharedManagedObjectContextManager.h
//  iCarRest
//
//  Created by Pharaoh on 13-4-30.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRSharedManagedObjectContextManager : NSObject
+(id) share;
@property(nonatomic,readonly) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,readonly) RKManagedObjectStore* managedObjectStore;
@end
