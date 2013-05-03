//
//  CRGoodyListCell.m
//  iCarRest
//
//  Created by Pharaoh on 13-5-2.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "CRGoodyListCell.h"

@implementation CRGoodyListCell
- (void)awakeFromNib{
	[super awakeFromNib];
	[self.goodyThumbnailView addBorder];
}
@end
