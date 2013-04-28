//
//  CRBaiduMapManager.h
//  iCarRest
//
//  Created by Pharaoh on 13-4-28.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
@interface CRBaiduMapManager : NSObject
+(CRBaiduMapManager*) share;
@property(nonatomic,readonly) BMKMapManager* bmManager;
@end
