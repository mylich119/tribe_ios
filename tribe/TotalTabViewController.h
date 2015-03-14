//
//  TotalTabViewController.h
//  kulinxiaoqu
//
//  Created by mylich119 on 14/10/19.
//  Copyright (c) 2014年 lich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIKit.h>


@interface TotalTabViewController : UITabBarController
@property (strong, nonatomic) UINavigationController *navFeedTabViewController;
@property (strong, nonatomic) UINavigationController *navSearchTabViewController;
@property (strong, nonatomic) UINavigationController *navOtherTabViewController;

@end
