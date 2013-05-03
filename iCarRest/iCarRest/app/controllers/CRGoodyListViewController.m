//
//  CRGoodyListViewController.m
//  iCarRest
//
//  Created by Pharaoh on 13-5-2.
//  Copyright (c) 2013年 365icar. All rights reserved.
//
/*
 对于服务列表数据的加载和位置数据更新的设计决策:
 假设1: 服务/商品数据的变化不大. 
 假设2: 用户对服务/商品距离自己的位置的更新比较敏感
 假设3: 单次请求服务/商品数据的量不会超过100条,或者服务端可以提供依据用户当前位置返回数据集的接口,并对结果集进行分页
 
 基于以上假设,设计方案如下:
 1. 依据假设1,服务/商品的数据在请求到客户端后会被客户端缓存. 用户不做明确要求的刷新动作,则后续的搜索,排序.位置更新
	等操作都是在本地缓存的数据集中完成. 如果服务/商品数据发生了变化(价格,位置变动,上架/下架) 那么服务端应该推送让客户端
	知晓. 客户端通过界面提示用户执行刷新动作,此时会更新客户端的数据缓存.
 2. 依据假设2. 每次用户到达列表页面, 客户端都应该进行一次定位操作. 并对本地缓存的服务/商品数据的距离项进行刷新.
	客户端会采用预先请求列表数据的方式.在首页就启动后台
	进程去请求服务列表数据.而在用户真正到达列表页时,只进行位置更新操作
 
 */

#import "CRGoodyListViewController.h"
#import "Goody.h"
#import "CRGoodyListCell.h"
#import "UIButton+animateIcon.h"
#import "Goody+CRUD.h"
#import "NSDate+Format.h"

#define DISTANCE_COMPUTE_LOCAL
@interface CRGoodyListViewController ()
@property(nonatomic) NSNumberFormatter *currencyFormatter;
// 当用户移动一定位置后,要求查看附近服务列表时. 我们只需要在原先的搜索范围上增加移动的这部分距离
// 从而缩小更新距离的数据条数. 只有我搜索范围内的服务我才会更新它们距离我的距离
// 假设是由iOS端根据当前用户位置和服务坐标计算距离.
// 如果服务端可以用当前用户坐标作为参数给iOS返回距离则不需要这部分逻辑
@property(nonatomic) CLLocation* currentLocation;// 当前新获取的位置
@property(nonatomic) CLLocation* lastLocation; //上一次成功定位的结果

@property(nonatomic) CLLocationManager* locationManager;
@end

@implementation CRGoodyListViewController
// locationManager的初始化
@synthesize locationManager = _locationManager;
-(CLLocationManager *)locationManager{
	if (_locationManager != nil) {
		return _locationManager;
	}
	_locationManager = [CLLocationManager new];
	return _locationManager;
}

#pragma mark - 生命周期
- (void)viewDidLoad{
	[super viewDidLoad];
	[self setup];
	//[self loadGoodies];加载数据已经在home页完成. 首次进入列表页就不需要再加载一次了.除非用户点击刷新
	
	// 设置下navigationController的title.作为判断回退方向的标志
	// 见 CRGoodyDetialViewController.m
	self.navigationController.title = @"GoodyListNavigationController";
	
}
- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	[self.navigationController setToolbarHidden:YES];
	// 检测是否开启定位
	if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate=self;
		//每次用户位置的刷新都会连带有距离数据的更新操作. 见代理方法
		// 由于列表页是从首页过来的. 在首页已经做过定位了. 这里可以先不做.
		// 我想在这里启动一个定时器. 每隔5分钟获取一次位置. 这样兼顾性能和体验
		// 然后让这个数据可以配置
		//[self.locationManager startUpdatingLocation];
	}
}
#pragma mark - 服务列表数据源/代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

#define CELL_HEIGHT 80.0
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return CELL_HEIGHT;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString* GoodyListCellIdentifier = @"GoodyListCell";
	CRGoodyListCell* cell = [tableView dequeueReusableCellWithIdentifier:GoodyListCellIdentifier];
	if (nil == cell) {
		cell = [[CRGoodyListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GoodyListCellIdentifier];
	}
	// self.fetchResultController 在最开始的时候可能是nil
	Goody* goody = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (goody) {
		cell.goodyNameLabel.text = goody.name;
		// 使用货币格式化器对价格进行格式化
		cell.goodyPriceLabel.text = [self.currencyFormatter stringFromNumber:goody.price];
		double distanceValue = [goody.distance doubleValue];
		cell.goodyDistanceLabel.text = [NSString stringWithFormat:@"%4.1f公里",distanceValue*0.001];//(distanceValue>0.0)?[NSString stringWithFormat:@"%4.1f公里",[goody.distance doubleValue]*0.001]:@"获取中...";
		[cell.goodyThumbnailView setImageWithURL:[NSURL URLWithString:goody.thumbnail] placeholderImage:[UIImage imageNamed:@"belle@2x.jpg"]];
		
		cell.goodyTimeIntervalSinceNowLabel.text = [NSDate formateInterval:[goody.distanceUpdateTime timeIntervalSinceNow]];;
	}
	
	
	return cell;
}
#pragma mark - 定位服务代理
/*
 for ios5 由于ios5 还是使用的这个方法. 所以做了个转发
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	NSArray* locations;
	if (oldLocation != nil) {
		locations = @[oldLocation,newLocation];
	}else{
		locations = @[newLocation];
	}
	
	[self locationManager:manager didUpdateLocations:locations];
}
/*
 for ios6
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	
	[self.locationManager stopUpdatingLocation];
	NSAssert([locations count]>=1, @"获取当前位置失败了");
	self.currentLocation = [locations lastObject];
	self.lastLocation = [locations objectAtIndex:0];
	// 接下来,更新距离
    [self updateDistance];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	NSString* errorMessage = [error localizedFailureReason]?[error localizedFailureReason]:@"定位失败了";
	NSLog(@"%@",errorMessage);
}
#pragma mark - 各种初始化
- (void) setup{
	[self setupFetchResultController];
	[self.refreshBtn cosplayActivityIndicator];
	// 使用货币格式
	self.currencyFormatter  = [[NSNumberFormatter alloc] init];
	[self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}
/*设置好取数据的controller*/
- (void) setupFetchResultController{
	NSFetchRequest* fetchGoodies = [NSFetchRequest fetchRequestWithEntityName:@"Goody"];
	fetchGoodies.predicate = [NSPredicate predicateWithFormat:@"distance<=10000"];
	fetchGoodies.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchGoodies
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"GoodiesCache"];
}
/*
  从服务器加载列表数据
 */
- (void) loadGoodies{
	// 去服务器取数据. 获取到数据后,会自动更新本地core data
	// 导致fetchResultController刷新数据
	[self.refreshBtn.imageView startAnimating];
	[[RKObjectManager sharedManager] getObjectsAtPath:@"services"
                                           parameters:@{@"apiKey": @"1gdxdp157X9xPkkGHFsH4MYBWWYaS37o"}
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
                                              {
												[self.refreshBtn.imageView stopAnimating];
												  // 如何用户主动刷新. 则此时应该再获取一次用户位置,以便
												  // 距离数据刷新
												  [self.locationManager startUpdatingLocation];
												  
	                                          }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
                                              {
												[self.refreshBtn.imageView stopAnimating];
	                                          }];
}

/*
 根据用户当前位置对core data数据的distance进行刷新
 */
-(void) updateDistance{
	dispatch_queue_t updateDistanceQueue= dispatch_queue_create("Update the distance data", NULL);
	dispatch_async(updateDistanceQueue, ^{
		// 查找所有范围内的goody 更新其距离当前位置的值
		[Goody updateDistanceWithCurrentLocation:self.currentLocation
									lastLocation:self.lastLocation
										   range:10.0
									   inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
		// 更新操作进行完成, 再初始化界面
		dispatch_async(dispatch_get_main_queue(), ^{
		});
		
	});
}
#pragma mark - 各种交互操作
/*
	关闭列表页
 */
- (IBAction)closeListModal:(UIButton *)closeBtn{
	[self dismissViewControllerAnimated:YES completion:nil];
}
/*
   隐藏/显示过滤面板
 */
-(IBAction)toggleFilter:(UIButton *)titleBtn{
	
}
/*
  点击刷新列表
 */
- (IBAction)reloadList:(UIButton *)refreshBtn{
	// 用户主动刷新
	[self loadGoodies];
}
@end

