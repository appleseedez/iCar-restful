//
//  CRSharedManagedObjectContextManager.m
//  iCarRest
//
//  Created by Pharaoh on 13-4-30.
//  Copyright (c) 2013年 365icar. All rights reserved.
//  单例的ManagedObjectContextManager
//  负责管理managedObjectContext
//  是由RestKit的RKManagedStore包装过的

#import "CRSharedManagedObjectContextManager.h"
static CRSharedManagedObjectContextManager* _instance;
@implementation CRSharedManagedObjectContextManager
+ (void)initialize{
	NSAssert(self == [CRSharedManagedObjectContextManager class],@"CRSharedManagedObjectContextManager 是单例不能被继承. File: CRSharedManagedObjectContextManager.m");
	_instance = [CRSharedManagedObjectContextManager new];
}
+ (id)share{
	return _instance;
}
@synthesize managedObjectContext = _managedObjectContext;
/*
	setup the core data stacks
	完成core data 的设置 由于使用RestKit 所以 设置工作也在此处完成
	参考:https://github.com/RestKit/RKGist/blob/master/TUTORIAL.md     
 */
-(NSManagedObjectContext*)managedObjectContext{
	if (nil == _managedObjectContext) {
		NSError* addPersistenStoreError =nil;
		NSURL* managedObjectStorePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"iCarRest" ofType:@"momd"]];
		NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:managedObjectStorePath] mutableCopy];
		// 仅仅是对NSManagedObjectModel,NSPersistentCoordinator,NSManagedObjectContext进行了封装
#pragma mark - managedObjectStore is here
		RKManagedObjectStore* managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
		[managedObjectStore createPersistentStoreCoordinator];
		[managedObjectStore createManagedObjectContexts];
		[RKManagedObjectStore setDefaultStore:managedObjectStore];
		//创建一个物理的存储用于数据保持,由于此处使用的是内存作为存储,暂时不担心存储位置问题. 待切换成文件存储,需要注意保存位置
		// 而且, 这里还有一个问题. 根据core data 文档, 创建persistenStore的过程是应该放在独立线程中完成的
#pragma mark - in dispath queue todo
		NSPersistentStore*  persistenStore = [managedObjectStore addInMemoryPersistentStore:&addPersistenStoreError];
		NSAssert(persistenStore, @"创建内存持久化层失败 File: CRSharedManagedObjectContextManager");
		_managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
		
	}
	return _managedObjectContext;
}

@end
