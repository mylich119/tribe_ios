//
//  FeedTabViewController.h
//  tribe
//
//  Created by lichuanhui on 15/3/8.
//  Copyright (c) 2015年 lich. All rights reserved.
//

#ifndef tribe_FeedTabViewController_h
#define tribe_FeedTabViewController_h

#import <UIKit/UIKit.h>

#import "BMapKit.h"

#import "AppDelegate.h"

#import "CreateMapViewController.h"
#import "BbsViewController.h"
#import "RichStyleLabel.h"

@interface MapViewController : UIViewController <BMKMapViewDelegate>
@property (strong, nonatomic) UINavigationController *navCreateMapController;
@end

#endif

