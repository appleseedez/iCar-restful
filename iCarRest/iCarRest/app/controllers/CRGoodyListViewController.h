//
//  CRGoodyListViewController.h
//  iCarRest
//
//  Created by Pharaoh on 13-5-2.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRGoodyListViewController : CoreDataTableViewController<CLLocationManagerDelegate>
- (IBAction)closeListModal:(UIButton*)closeBtn;// 关闭当前页
- (IBAction)toggleFilter:(UIButton*)titleBtn;// 显示/隐藏筛选条件
- (IBAction)reloadList:(UIButton*)refreshBtn; // 刷新列表
@property(nonatomic,weak) IBOutlet UIButton* refreshBtn;
@end
