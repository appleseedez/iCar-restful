//
//  CRGenericCell.m
//  iCarRest
//
//  Created by Pharaoh on 13-5-2.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "CRGenericCell.h"

@implementation CRGenericCell
- (void)awakeFromNib{
	[super awakeFromNib];
	self.bottomBorderLayer = [CALayer layer];
	self.bottomBorderLayer.borderColor =  [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1].CGColor;
	
	self.bottomBorderLayer.borderWidth = 4;
	self.bottomBorderLayer.frame = CGRectMake(0, self.contentView.bounds.size.height-1, self.contentView.bounds.size.width, .5);
	[self.contentView.layer addSublayer:self.bottomBorderLayer];
	self.outterBorderLayer = [CALayer layer];
	
	self.outterBorderLayer.borderColor = [UIColor whiteColor].CGColor;
	self.outterBorderLayer.borderWidth = 4;
	self.outterBorderLayer.frame = CGRectMake(0, self.contentView.bounds.size.height, self.contentView.bounds.size.width,.5);
	[self.contentView.layer addSublayer:self.outterBorderLayer];
	NSAssert(self.outterBorderLayer != nil, @"outterBorderLayer is nil");
	
}
@end
