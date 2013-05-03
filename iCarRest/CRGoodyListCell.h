//
//  CRGoodyListCell.h
//  iCarRest
//
//  Created by Pharaoh on 13-5-2.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRGoodyListCell : CRGenericCell
@property (weak, nonatomic) IBOutlet UILabel *goodyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodyScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodyAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodyDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodyNameLabel;
@property(nonatomic,weak) IBOutlet UIImageView* goodyThumbnailView;
@property(nonatomic,weak) IBOutlet UILabel *goodyTimeIntervalSinceNowLabel;
@end
