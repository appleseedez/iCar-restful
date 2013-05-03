//
// Created by Pharaoh on 13-5-3.
// Copyright (c) 2013 365icar. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Goody+CRUD.h"

@implementation Goody (CRUD)
+ (void) updateDistanceWithCurrentLocation:(CLLocation *) currentLocation
                               lastLocation:(CLLocation *) lastLocation
                                        range:(double) range
                                    inContext:(NSManagedObjectContext *) context{
    NSAssert(currentLocation, @"未获取到当前位置 File: Goody+CRUD.m");
    NSAssert(range>0,@"搜索范围为空或者不正确 File: Goody+CRUD.m");
    if(nil == lastLocation){
        lastLocation = currentLocation;
    }

    double distance = [currentLocation distanceFromLocation:lastLocation]; // 单位是米
    double  searchRange = range*1000 + distance; // range 的单位是公里
    NSError * findGoodyInRangeError = nil;
    NSFetchRequest * findGoodyInRange = [[NSFetchRequest alloc] initWithEntityName:@"Goody"];
    findGoodyInRange.predicate = [NSPredicate predicateWithFormat:@"distance <= %f",searchRange];
    NSArray *matches = [context executeFetchRequest:findGoodyInRange error:&findGoodyInRangeError];
    for(Goody *goody in matches){
        double lat = [[goody.location valueForKey:@"lat"] doubleValue];
        double lon = [[goody.location valueForKey:@"long"] doubleValue];
        CLLocation* goodyLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        goody.distance = [[NSDecimalNumber alloc] initWithDouble:
                                [goodyLocation distanceFromLocation:currentLocation]];
		goody.distanceUpdateTime = [NSDate date];
    }
}
@end