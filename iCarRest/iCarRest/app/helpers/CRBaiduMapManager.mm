//
//  CRBaiduMapManager.m
//  iCarRest
//
//  Created by Pharaoh on 13-4-28.
//  Copyright (c) 2013年 365icar. All rights reserved.
//  管理百度地图的单例.
//
//  由于百度地图采用c++的静态链接库,所以必须使用.mm文件后缀 详情请见百度api页说明
//  本项目中的静态库是将真机和模拟器的打包在一起的.
//  在项目的 Other Linker 中增加选项 -all_load才能编译成功.
//	同时使用单例对百度的mapmanager进行初始化也是必须的. 否则会出现异常
//

#import "CRBaiduMapManager.h"
static CRBaiduMapManager* _mapManagerInstance;
@implementation CRBaiduMapManager
+ (void)initialize{
	NSAssert(self == [CRBaiduMapManager class],@"错误:单例对象 CRBaiduMapManager 不能被继承 - File:CRBaiduMapManager.mm" );
	_mapManagerInstance = [CRBaiduMapManager new];
}
+ (CRBaiduMapManager *)share{
	return _mapManagerInstance;
}
@synthesize bmManager = _bmManager;
// readonly 属性. 由我们来控制实例化
- (BMKMapManager *)bmManager{
	if (nil==_bmManager) {
		_bmManager = [[BMKMapManager alloc] init];
	}
	return _bmManager;
}
@end
