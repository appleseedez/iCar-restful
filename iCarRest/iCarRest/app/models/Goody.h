//
//  Goody.h
//  iCarRest
//
//  Created by Pharaoh on 13-5-3.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Goody : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * distance;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id oid;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSDate * distanceUpdateTime;

@end
