//
//  TotalTabViewController.m
//  kulinxiaoqu
//
//  Created by mylich119 on 14/10/19.
//  Copyright (c) 2014年 lich. All rights reserved.
//

#import "TotalTabViewController.h"

//all 3 tabs
#import "FeedTabController.h"
#import "SearchTabController.h"
#import "OtherTabController.h"

//tribe page without tab
#import "TribePageController.h"

@interface TotalTabViewController(){
}
@end


@implementation TotalTabViewController

@synthesize navFeedTabViewController;
@synthesize navSearchTabViewController;
@synthesize navOtherTabViewController;



- (void)viewDidLoad{
    [super viewDidLoad];
    
    FeedTabViewController * feedTabViewController = [[FeedTabViewController alloc] init];
    self.navFeedTabViewController = [[UINavigationController alloc] initWithRootViewController:feedTabViewController];
    
    SearchTabViewController * searchTabViewController = [[SearchTabViewController alloc] init];
    self.navSearchTabViewController = [[UINavigationController alloc] initWithRootViewController:searchTabViewController];

    OtherTabViewController * otherTabViewController = [[OtherTabViewController alloc] init];
    self.navOtherTabViewController = [[UINavigationController alloc] initWithRootViewController:otherTabViewController];

    self.viewControllers = [NSArray arrayWithObjects:self.navFeedTabViewController, self.navSearchTabViewController, self.navOtherTabViewController,nil];
    [self setSelectedIndex:0];
    
}


@end