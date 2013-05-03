//
//  CRHomeVewController.m
//  iCarRest
//
//  Created by Pharaoh on 13-4-30.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "CRHomeViewController.h"
#import "CRHomeMenuViewCell.h"
#import "Goody+CRUD.h"
@interface CRHomeViewController ()
@property(nonatomic) NSArray* advertiseDataSource;
@property(nonatomic) NSArray* menuDataSource;
@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) CLLocation* currentLocation;
@property(nonatomic) CLLocation* lastLocation;
@end

@implementation CRHomeViewController
// locationManager的初始化
@synthesize locationManager = _locationManager;
-(CLLocationManager *)locationManager{
	if (_locationManager != nil) {
		return _locationManager;
	}
	_locationManager = [CLLocationManager new];
	return _locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setup];
	
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	// 检测是否开启定位
	if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate=self;

	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 首页逻辑
- (void)setup{
	[self setupAdvertiseScroller];
	[self setupMenu];
    [self loadGoodies];
}
/*
  菜单初始化
 */
- (void) setupMenu{
	self.menuDataSource = @[@{@"title":@"汽车服务",@"icon":@"goods"},@{@"title":@"养护咨询",@"icon":@"faq"},
	@{@"title":@"酒后代驾",@"icon":@"proxy"},@{@"title":@"超值车险",
	@"icon":@"insure"},@{@"title":@"快速救援",@"icon":@"warm"},@{@"title":@"上门洗车",@"icon":@"wash"}];
}

/*
	首页顶部广告轮播的初始化
 */
- (void)setupAdvertiseScroller{
	// 广告图片数据.
	self.advertiseDataSource = @[@"http://img08.taobaocdn.com/sns_logo/i8/T1NrBgXoAR0tMuhVjX_120x120.jpg",
					 @"http://img04.taobaocdn.com/sns_logo/i4/T1mMGAXaJ0XXb1upjX_120x120.jpg",
					 @"http://img01.taobaocdn.com/sns_logo/i1/T1v.ecXdNXXXb1upjX_120x120.jpg",
					 @"http://img.taobaocdn.com/sns_logo/T1WfAhXmNaXXb1upjX_120x120.jpg"];
	// pageControll 显示共有多少项数据.
	// TODO:  优化. 有一千张怎么办?可以通过限制数据集合容量解决. 后续的数据lazyload
	self.advertiseScrollViewPageControl.numberOfPages = [self.advertiseDataSource count];
	// 设置广告轮播图片的单张尺寸. scrollView的尺寸为320x150
	CGFloat pageWidth = self.advertiseScrollView.bounds.size.width;
	CGFloat pageHeight = self.advertiseScrollView.bounds.size.height;
	//循环滚动的scrollView 有3个位置. 每次显示中间的那个位置当左,右滑动时,
	//scrollView会在用户滑动操作结束后,调整scrollView的位置,始终显示中间的那个位置达到循环滚动效果
	self.advertiseScrollView.contentSize = CGSizeMake(pageWidth*3,pageHeight);
	// 设置scrollView的代理为本controller
	self.advertiseScrollView.delegate = self;
	// 将三个图片空位初始化好
	UIImageView* pageView = nil;
	for (int i = 0; i<3; ++i) {
		pageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*pageWidth, 0, pageWidth, pageHeight)];
		[pageView setImageWithURL:[NSURL URLWithString:self.advertiseDataSource[i]] placeholderImage:nil];
		// 使用tag记录下本容器装的是数据集里面的第几张图片.这样做有两个用处:
		// 1. pageControl会使用这个来展示当前显示的是第几页.因为是一张图片一页, 所以直接使用tag的值就可以;
		// 2. 当新的图片加载时,比如第四张图片加载时,实际上是通过第四张图片的容器位置(第三张的右边)去查询到自己上一个
		// 或者下一个位置的容器的tag知道自己应该加载第几张.
		//
		pageView.tag = i;
		[self.advertiseScrollView addSubview:pageView];
	}

	// 初始的时候scrollView并不是居中的.因为数据集合是索引0开头的.如果居中scrollView,那么左边容器就应该放
	// 数据集合里面的最后一张图片.而这个应该是recenter:方法的工作.
	self.advertiseScrollView.contentOffset = CGPointMake(0, 0);
	[self recenter:self.advertiseScrollView];
}
#pragma mark -  广告滚动视图代理
/*
  每次用户滑动操作后,scrollView停止滑动时,对里面的图片序列做操作
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	if (scrollView == self.advertiseScrollView) {
		[self recenter:scrollView];
	}
}

/*
 rencenter: 方法
 当用户向一个方向滑动一页后.scrollView就会到达边界(因为只有3个容器),此时要做的就是将scrollView重新拉会到居中状态
 同时内部的三张图片进行相对移动.
 例如 如果向左侧滑动一页. scrollView会抵达右边界,为了能持续的可滑动. 我们首先将最左的容器排列到最右边,由于只有三个位置
 新移动过来的容器会盖住原来在这个位置上的容器.所以,我们依次将原先的中,右两个容器向左移动成为左,中两个容器这样原来的最右
 边的容器就成为了中间的那个.此时我们只需要将整个scrollView重新拉回到居中位置. 就达到效果 
 在整个过程里面,只有被排列到最右的容器的数据需要重新从数据集加载(也就是需要加载第四页数据到最右容器)
 */
- (void) recenter:(UIScrollView*)scrollView{
	// 首先获取页的尺寸
	CGFloat width =scrollView.bounds.size.width;
	CGFloat height = scrollView.bounds.size.height;
	// 这个距离是用于确定是否需要重排,以及本次的滑动是哪个方向的
	// distance>0 -> contentOffset.x是减小的 -> 向右滑动了
	// 同理distance<0 -> 向左滑动了
	CGFloat distance= width - scrollView.contentOffset.x  ;
	NSArray* pageViews = scrollView.subviews;
	// 找出最左和最右的两个容器.它们的tag属性指示了已经加载的数据的边界
	NSInteger mostLeftIndex = 0;
	NSInteger mostRightIndex = [pageViews count] -1;
	for (UIImageView* page in pageViews) {
		if (page.frame.origin.x == 0) {
			mostLeftIndex = page.tag;
		}
		if (page.frame.origin.x == ([pageViews count] -1)*width) {
			mostRightIndex = page.tag;
		}
	}
	
	// 是向右滑动了
	if (distance>=width) {
		// right
		// 在确定方向的情况下. page的移动就是在每个page当前的x位置坐标基础上增加/减少固定的值(此处就是scrollView的宽度),
		//
		[pageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			//依次移动容器
			UIImageView* page = obj;
			CGFloat originX = page.frame.origin.x+width;
			CGFloat dx = (originX>=[pageViews count]*width)?0:originX;
			page.frame = CGRectMake(dx, 0, width, height);
			// 移动完成, 最左的容器会更新数据. 应该是当前数据集最小页数的前一页
			if (page.frame.origin.x == 0) {
				NSInteger dataLoadIndex = (mostLeftIndex-1<0)?[self.advertiseDataSource count]-1:mostLeftIndex-1;
				[page setImageWithURL:[NSURL URLWithString:self.advertiseDataSource[dataLoadIndex]] placeholderImage:nil];
				page.tag = dataLoadIndex;
			}
			
		}];
	}else if (distance<= -width){
		// left
		[pageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			// 依次移动
			UIImageView* page = obj;
			CGFloat originX = page.frame.origin.x - width;
			CGFloat dx = (originX>=0)?originX:([pageViews count] -1)*width;
			page.frame = CGRectMake(dx, 0, width, height);
			// 移动完成,最右容器数据需要更新,当前数据集最大页数的下一页
			if (page.frame.origin.x == ([pageViews count] -1)*width) {
				NSInteger dataLoadIndex = (mostRightIndex+1>[self.advertiseDataSource count]-1)?0:mostRightIndex+1;
				[page setImageWithURL:[NSURL URLWithString:self.advertiseDataSource[dataLoadIndex]] placeholderImage:nil];
				page.tag = dataLoadIndex;
			}
			
		}];
		
	}
	// 把scrollView拉回居中
	scrollView.contentOffset = CGPointMake(width, 0);
	// 找出目前中间的这个页, pageControll的当前页应该指向中间页
	// 由于可视区域只有一页, 可视区域的最左x坐标就是要找的中间页的x坐标
	CGFloat displayedPageCoordinate  = CGRectGetMinX(scrollView.bounds);
	for (UIImageView* page in pageViews) {
		if (page.frame.origin.x == displayedPageCoordinate) {
			self.advertiseScrollViewPageControl.currentPage = page.tag;
		}
	}
}

#pragma mark - 首页按钮九宫格代理/数据源
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
	return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return 6;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString* CollectionViewCellIdentifier = @"MenuCell";
	CRHomeMenuViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
	// 首页按钮的文字和icon 
	cell.iconImageView.image  = [UIImage imageNamed:[self.menuDataSource[indexPath.row] valueForKey:@"icon"]];
	cell.menuTitleLabel.text = [self.menuDataSource[indexPath.row] valueForKey:@"title"];
	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row == 0) {
		// 加载服务列表
		[self presentViewController:[[UIStoryboard storyboardWithName:@"GoodyListView" bundle:nil] instantiateInitialViewController] animated:YES completion:nil];
	}
	if (indexPath.row == 1) {
		[self presentViewController:[[UIStoryboard storyboardWithName:@"GoodyListView" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodyDetailView"] animated:YES completion:nil];
	}
}

#pragma mark - 在home页进行数据的预加载
- (void) loadGoodies {
	[[RKObjectManager sharedManager] getObjectsAtPath:@"services"
                                           parameters:@{@"apiKey": @"1gdxdp157X9xPkkGHFsH4MYBWWYaS37o"}
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
	 {
		
		 [self.locationManager startUpdatingLocation];
	 }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
	 {
	 }];
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
#pragma mark - 对商品/服务数据集进行操作的方法
/*
 根据用户当前位置对core data数据的distance进行刷新
 */
#define SEARCH_RANGE 10.0 // 搜索范围10公里
-(void) updateDistance{
	dispatch_queue_t updateDistanceQueue= dispatch_queue_create("Update the distance data", NULL);
	dispatch_async(updateDistanceQueue, ^{
		// 查找所有范围内的goody 更新其距离当前位置的值
		[Goody updateDistanceWithCurrentLocation:self.currentLocation
									lastLocation:self.lastLocation
										   range:SEARCH_RANGE
									   inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
		// 更新操作进行完成, 再初始化界面
		dispatch_async(dispatch_get_main_queue(), ^{
		});
		
	});
}
@end
