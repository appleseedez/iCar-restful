//
//  CRAppDelegate.m
//  iCarRest
//
//  Created by Pharaoh on 13-4-28.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "CRAppDelegate.h"

@implementation CRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self theme];
	[self setup];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/*
 各种初始化
 */
- (void) setup{
	[self setupStore];
	[self setupObjectManager];
	[self setupLocationManager];
}
/*
 * 初始化数据存储层
 * 可以通过[RKManagedObjectStore defaultStore]获取
 */
- (void)setupStore{
	if (![RKManagedObjectStore defaultStore]) {
		NSError* addPersistentStoreError =nil;
		NSURL* managedObjectStorePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"iCarRest" ofType:@"momd"]];
		NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:managedObjectStorePath] mutableCopy];
		NSAssert(managedObjectModel, @"创建 managedObjectModel 不成功");
		// 仅仅是对NSManagedObjectModel,NSPersistentCoordinator,NSManagedObjectContext进行了封装
	#pragma mark - managedObjectStore is here
		RKManagedObjectStore* managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
		[managedObjectStore createPersistentStoreCoordinator];
		// 注意: 创建完PersistentStoreCoordinator后要立即为其添加 persistentStore
		// 否则在后面创建ManagedObjectContext的时候会因为没有指定persistentStore而报错
		// 创建一个物理的存储用于数据保持,由于此处使用的是内存作为存储,暂时不担心存储位置问题.
		// 待切换成文件存储,需要注意保存位置
		// 而且, 这里还有一个问题. 根据core data 文档, 创建persistentStore的过程是应该放在独立线程中完成的
	#pragma mark - in dispatch queue todo
		NSPersistentStore __unused  *persistentStore = [managedObjectStore addInMemoryPersistentStore:&addPersistentStoreError];
		NSAssert(persistentStore, @"创建内存持久化层失败 File: CRSharedManagedObjectContextManager");
		[managedObjectStore createManagedObjectContexts];
		[RKManagedObjectStore setDefaultStore:managedObjectStore];


	}
	NSAssert([RKManagedObjectStore defaultStore], @"数据存储创建不成功 File:CRAppDelegate.m");
}
/*
  初始化ORM层
 */
- (void) setupObjectManager{
	RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.mongolab.com/api/1/databases/yangche-geo/collections"]];
	objectManager.managedObjectStore = [RKManagedObjectStore defaultStore];
	[RKObjectManager setSharedManager:objectManager];
	RKEntityMapping* entityMapping = [RKEntityMapping mappingForEntityForName:@"Goody" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
	[entityMapping addAttributeMappingsFromDictionary:@{
	 @"_id":@"oid",
	 @"name": @"name",
	 @"price":@"price",
	 @"thumb":@"thumbnail",
	 @"location":@"location"}];
	// 将oid和name作为主键
	entityMapping.identificationAttributes=@[@"name"];
	RKResponseDescriptor* responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping pathPattern:@"services" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}
/*
  初始化定位服务
 */
- (void) setupLocationManager{
	
}

// 设置自定义的样式
- (void)theme{
	UIImage* backgroundImageOfBar = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[[UINavigationBar appearance] setBackgroundImage:backgroundImageOfBar forBarMetrics:UIBarMetricsDefault];
	[[UITabBar appearance] setBackgroundImage:backgroundImageOfBar];
    [[UIToolbar appearance] setBackgroundImage:backgroundImageOfBar forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
	
}


@end
