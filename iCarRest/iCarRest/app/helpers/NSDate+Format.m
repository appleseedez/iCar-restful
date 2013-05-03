//
//  NSDate+Format.m
//  iCarRest
//
//  Created by Pharaoh on 13-5-3.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)
+ (NSString *)formateInterval:(NSTimeInterval)timeInterval{
	
	unsigned long seconds = fabs(timeInterval);
	unsigned long minutes = seconds / 60;
	seconds %= 60;
	unsigned long hours = minutes / 60;
	minutes %= 60;
	
	NSMutableString * result = [NSMutableString new];
	
	if(hours){
		[result appendFormat: @"%ld小时前", hours];
		return result;
	}
		
	if (minutes) {
		[result appendFormat: @"%ld分钟前", minutes];
		return result;
	}
	if (seconds) {
		[result appendFormat: @"%ld秒前", seconds];
		return result;
	}
	
	
	[result appendFormat: @"刚刚"];
	return result;
}
@end
