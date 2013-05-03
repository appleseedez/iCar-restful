//
// Created by Pharaoh on 13-5-3.
// Copyright (c) 2013 365icar. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Goody.h"

@interface Goody (CRUD)
+ (void) updateDistanceWithCurrentLocation:(CLLocation *) currentLocation
							  lastLocation:(CLLocation *) lastLocation
									 range:(double) range
								 inContext:(NSManagedObjectContext *) context;
@end