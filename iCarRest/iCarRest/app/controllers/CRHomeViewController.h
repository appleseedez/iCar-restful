//
//  CRHomeViewController.h
//  iCarRest
//
//  Created by Pharaoh on 13-4-30.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRHomeViewController : UIViewController<UIScrollViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate,CLLocationManagerDelegate>
@property(nonatomic,weak) IBOutlet UIScrollView* advertiseScrollView;
@property(nonatomic,weak) IBOutlet UIPageControl* advertiseScrollViewPageControl;
@end
