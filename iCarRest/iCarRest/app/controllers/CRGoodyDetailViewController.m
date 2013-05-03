//
//  CRGoodyDetailViewController.m
//  iCarRest
//
//  Created by Pharaoh on 13-5-3.
//  Copyright (c) 2013年 365icar. All rights reserved.
//

#import "CRGoodyDetailViewController.h"

@interface CRGoodyDetailViewController ()

@end

@implementation CRGoodyDetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.navigationController setToolbarHidden:NO];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (nil == cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    return cell;
}

#pragma  mark - 各种按钮交互操作
#define GOODYLIST_NAV @"GoodyListNavigationController" // 在GoodyListViewController 设置title
#define GOODYDETAIL_NAV @"GoodyDetailNavigationController"
- (IBAction)closeModal:(UIButton *)closeBtn{
	NSLog(@"%@",self.navigationController.title);
	if ([self.navigationController.title isEqualToString: GOODYDETAIL_NAV] ) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}else if ([self.navigationController.title isEqualToString:GOODYLIST_NAV]){
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}
@end
