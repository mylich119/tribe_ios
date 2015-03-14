//
//  FirstViewController.m
//  kulinxiaoqu
//
//  Created by mylich119 on 14-10-12.
//  Copyright (c) 2014年 lich. All rights reserved.
//

#import "MapViewController.h"


@interface MapViewController (){
    //baidu map
    BMKMapView* _mapView;
    BMKLocationService* _locService;
    BMKLocationViewDisplayParam* _viewParam;
    AppDelegate *globalDelegate;
    
    //cache the location for create new xiaoqu
    
    //下面的分隔线用来容纳翻页，信息等内容，总共三行，分别是翻页按钮，小区信息，小区头条
    UIImageView* _horizon_line_1;
    UIImageView* _vertical_line_1;
    UIImageView* _horizon_line_2;
    UIImageView* _vertical_line_invisible;
    
    //customizing view
    UIButton* _prePageButton;
    UIButton* _postPageButton;
    RichStyleLabel* _xiaoquAttr;
    UILabel* _xiaoquHeadline;
    UIButton* _gotoBbsButton;
    
    UIActivityIndicatorView* _indicator;
    
    //controller
    CreateMapViewController* _createMapViewController;
    BbsViewController* _bbsViewController;
    
}
@end

@implementation MapViewController

@synthesize navCreateMapController;

//加载页面
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化各个组件
    [self initMapView];
    [self initSepLine];
    [self initPrePageButton];
    [self initPostPageButton];
    [self initXiaoquAttr];
    [self initGotoBbsButton];
    [self initXiaoquHeadline];
    
    [self initProgressIndicator];
    
    
    //初始化定位服务
    [self initLocationService];
}

//init,加载navbar和tabbar
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    globalDelegate = [[UIApplication sharedApplication] delegate];
    
    //初始化左按钮的crontroller
    _createMapViewController = [[CreateMapViewController alloc] init];
    self.navCreateMapController = [[UINavigationController alloc] initWithRootViewController:_createMapViewController];
    self.navCreateMapController.navigationBar.tintColor = [UIColor blackColor];
    
    //初始化tabbar
    NSString *tabBarTitle = @"附近";
    NSString *navBarTitle = @"附近";
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:tabBarTitle image:[UIImage imageNamed:@"tabbar_map_selected"] tag:0];
    self.tabBarItem = tabBarItem;
    
    //初始化navi
    self.navigationItem.title = navBarTitle;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:   @"刷新"
                                                                   style:   UIBarButtonItemStylePlain
                                                                  target:   self
                                                                  action:   @selector(buttonRefreshXiaoquList:)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:   @"新建"
                                                                    style:   UIBarButtonItemStylePlain
                                                                   target:   self
                                                                   action:   @selector(createNewMap:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    return self;
}




/*
 加载后台服务
 1，initLocationService，  定位服务
 
 */

- (void)initLocationService{
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    
    //开始显示Loading动画
    [_indicator startAnimating];
    
    //启动LocationService
    [_locService startUserLocationService];
}

/*
 后台服务加载结束
 */


/*
 加载UI界面的元素
 1，initMapView，          地图
 2，initPrePageButton，    地图中的刷新按钮
 3，initPostPageButton，   地图中的刷新按钮
 4，initProgressIndicator，定位的indicator
 */



- (void)initMapView{
    //初始化BMKMapView的各个参数
    _mapView = [[BMKMapView alloc] init];
    
    _mapView.showsUserLocation = YES;
    _mapView.zoomEnabled = NO;
    _mapView.zoomEnabledWithTap = NO;
    _mapView.scrollEnabled = NO;
    _mapView.overlookEnabled = NO;
    _mapView.rotateEnabled = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.zoomLevel = 12;
    
    _viewParam= [[BMKLocationViewDisplayParam alloc] init];
    _viewParam.isAccuracyCircleShow = NO;
    [_mapView updateLocationViewWithParam:_viewParam];
    
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self.view addSubview: _mapView];
    
    //定义mapview的位置
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _mapView
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _mapView
                                                             attribute:     NSLayoutAttributeHeight
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeHeight
                                                            multiplier:     0.5
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _mapView
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeTop
                                                            multiplier:     1
                                                              constant:     self.navigationController.navigationBar.frame.size.height +
                              self.navigationController.navigationBar.frame.origin.y]];
    
    
    [self.view layoutSubviews];
    
}

- (void)initSepLine{
    _horizon_line_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_view_seperator_line_horizontal"]];
    _horizon_line_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_view_seperator_line_horizontal"]];
    _vertical_line_1 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_view_seperator_line_vertical"]];
    _vertical_line_invisible =[[UIImageView alloc] initWithImage:nil];
    
    _horizon_line_1.translatesAutoresizingMaskIntoConstraints = NO;
    _horizon_line_2.translatesAutoresizingMaskIntoConstraints = NO;
    _vertical_line_1.translatesAutoresizingMaskIntoConstraints = NO;
    _vertical_line_invisible.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_horizon_line_1];
    [self.view addSubview:_horizon_line_2];
    [self.view addSubview:_vertical_line_1];
    [self.view addSubview:_vertical_line_invisible];
    //_horizon_line_1
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeCenterX
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterX
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.9
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeHeight
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0
                                                              constant:     0.5]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeCenterY
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     (self.tabBarController.tabBar.frame.origin.y
                                                                             - _mapView.frame.size.height - _mapView.frame.origin.y) * 0.382 * 0.618]];
    
    //_horizon_line_2
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeCenterX
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterX
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.9
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeCenterY
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     (self.tabBarController.tabBar.frame.origin.y
                                                                             - _mapView.frame.size.height - _mapView.frame.origin.y) * 0.618]];
    
    //_vertical_line_1
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_1
                                                             attribute:     NSLayoutAttributeCenterX
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterX
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_1
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_1
                                                             attribute:     NSLayoutAttributeHeight
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeHeight
                                                            multiplier:     0
                                                              constant:     (self.tabBarController.tabBar.frame.origin.y
                                                                             - _mapView.frame.size.height - _mapView.frame.origin.y) * 0.382 * 0.618]];
    
    //_vertical_line_invisible
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_invisible
                                                             attribute:     NSLayoutAttributeCenterX
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterX
                                                            multiplier:     1.236
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_invisible
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _vertical_line_invisible
                                                             attribute:     NSLayoutAttributeHeight
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeHeight
                                                            multiplier:     0
                                                              constant:     (self.tabBarController.tabBar.frame.origin.y
                                                                             - _mapView.frame.size.height - _mapView.frame.origin.y) * 0.382 * 0.618]];
    
    
    
    [self.view layoutSubviews];
    
}

- (void)initPrePageButton{
    _prePageButton = [[UIButton alloc] init];
    [_prePageButton setImage:[UIImage imageNamed:@"map_btn_pre_page"] forState:nil];
    [_prePageButton addTarget:self action:@selector(preXiaoquPage:)  forControlEvents :UIControlEventTouchUpInside];
    
    _prePageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_prePageButton];
    
    //定义位置更新按钮的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _prePageButton
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.4992
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _prePageButton
                                                             attribute:     NSLayoutAttributeLeading
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeLeading
                                                            multiplier:     1.0
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _prePageButton
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _prePageButton
                                                             attribute:     NSLayoutAttributeBottom
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeTop
                                                            multiplier:     1
                                                              constant:     0]];
    
}

- (void)initPostPageButton{
    //地图中的刷新按钮
    _postPageButton = [[UIButton alloc] init];
    [_postPageButton setImage:[UIImage imageNamed:@"map_btn_post_page"] forState:nil];
    [_postPageButton addTarget:self action:@selector(postXiaoquPage:)  forControlEvents :UIControlEventTouchUpInside];
    
    _postPageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_postPageButton];
    
    //定义位置更新按钮的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _postPageButton
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.4992
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _postPageButton
                                                             attribute:     NSLayoutAttributeTrailing
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeTrailing
                                                            multiplier:     1.0
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _postPageButton
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _mapView
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _postPageButton
                                                             attribute:     NSLayoutAttributeBottom
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeTop
                                                            multiplier:     1
                                                              constant:     0]];
    
    
}

-(void)initXiaoquAttr{
    _xiaoquAttr = [[RichStyleLabel alloc] init];
    _xiaoquAttr.numberOfLines  = 0;
    NSDictionary* redTextAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor]};
    [_xiaoquAttr setAttributedText:@"青年城の青年\n人气：12342\t成员：43 " withRegularPattern:@"[0-9]+" attributes:redTextAttributes];
    
    _xiaoquAttr.layer.cornerRadius = 10;
    
    _xiaoquAttr.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_xiaoquAttr];
    
    //定义位置更新按钮的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquAttr
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquAttr
                                                             attribute:     NSLayoutAttributeBottom
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeTop
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquAttr
                                                             attribute:     NSLayoutAttributeTrailing
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _vertical_line_invisible
                                                             attribute:     NSLayoutAttributeLeading
                                                            multiplier:     1
                                                              constant:     0]];
    
}


-(void)initGotoBbsButton{
    //地图中的刷新按钮
    _gotoBbsButton = [[UIButton alloc] init];
    [_gotoBbsButton setImage:[UIImage imageNamed:@"map_btn_gotobbs"] forState:nil];
    _gotoBbsButton.layer.cornerRadius = 5;
    [_gotoBbsButton setTitle:@"进入" forState:nil];
    [_gotoBbsButton addTarget:self action:@selector(gotoBbs:)  forControlEvents :UIControlEventTouchUpInside];
    
    _gotoBbsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_gotoBbsButton];
    
    //定义位置更新按钮的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _gotoBbsButton
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_1
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     (_horizon_line_2.frame.origin.y - _horizon_line_1.frame.origin.y) * 0.4]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _gotoBbsButton
                                                             attribute:     NSLayoutAttributeBottom
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeTop
                                                            multiplier:     1
                                                              constant:     -1]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _gotoBbsButton
                                                             attribute:     NSLayoutAttributeLeading
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _vertical_line_invisible
                                                             attribute:     NSLayoutAttributeTrailing
                                                            multiplier:     1
                                                              constant:     self.view.frame.size.width * 0.1]];
}

- (void)initXiaoquHeadline{
    
    _xiaoquHeadline = [[UILabel alloc] init];
    _xiaoquHeadline.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _xiaoquHeadline.layer.cornerRadius = 5;
    _xiaoquHeadline.text = @"11111111111111";
    
    _xiaoquHeadline.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_xiaoquHeadline];
    
    //定义位置更新按钮的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquHeadline
                                                             attribute:     NSLayoutAttributeTop
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     _horizon_line_2
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     10]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquHeadline
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.95
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquHeadline
                                                             attribute:     NSLayoutAttributeLeading
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeLeading
                                                            multiplier:     1
                                                              constant:     self.view.frame.size.width * 0.025]];
    
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:     _xiaoquHeadline
                                                             attribute:     NSLayoutAttributeBottom
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeBottom
                                                            multiplier:     1
                                                              constant:     - self.tabBarController.tabBar.frame.size.height * 1.1]];
    
}

- (void)initProgressIndicator{
    //初始化:
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.backgroundColor = [UIColor grayColor];
    _indicator.alpha = 0.8;
    
    //设置背景为圆角矩形
    _indicator.layer.cornerRadius = 10;
    _indicator.layer.masksToBounds = YES;
    
    _indicator.translatesAutoresizingMaskIntoConstraints = NO;
    //将初始化好的indicator add到view中
    [self.view addSubview:_indicator];
    
    //设置indicator的样式
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _indicator
                                                             attribute:     NSLayoutAttributeWidth
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.3
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _indicator
                                                             attribute:     NSLayoutAttributeHeight
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeWidth
                                                            multiplier:     0.3
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _indicator
                                                             attribute:     NSLayoutAttributeCenterX
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterX
                                                            multiplier:     1
                                                              constant:     0]];
    
    [self.view addConstraint:[NSLayoutConstraint    constraintWithItem:      _indicator
                                                             attribute:     NSLayoutAttributeCenterY
                                                             relatedBy:     NSLayoutRelationEqual
                                                                toItem:     self.view
                                                             attribute:     NSLayoutAttributeCenterY
                                                            multiplier:     1
                                                              constant:     0]];
    
}
/*
 加载UI界面结束
 */


/*
 自定义回调函数
 1，buttonRefreshInMapView，  地图左下角的刷新按钮的功能实现
 2，didUpdateUserLocation，   定位结束时候的回调函数，主要是更新位置
 */
- (void)buttonRefreshXiaoquList:(id)sender{
    //开始显示Loading动画
    [_indicator startAnimating];
    
    //开始定位
    [_locService startUserLocationService];
}

- (void)createNewMap:(id)sender{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_createMapViewController animated:YES];
}

- (void)preXiaoquPage:(id)sender{
    NSLog(@"gotoPre!!!!!!!!");
    [self refreshMapViewOverlay:sender];
    
}

- (void)postXiaoquPage:(id)sender{
    NSLog(@"gotoPost!!!!!!!!");
}

- (void)gotoBbs:(id)sender{
    NSLog(@"gotoBBS!!!!!!!!");
}

- (void)updateSelectedMapBlock:(id)sender{
    NSLog(@"updateSelectedMapBlock!!!!!!!!");
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    //缓存地点 传递给createnewmap的view
    globalDelegate.currentLoc = userLocation;
    //更新地图的位置
    [_mapView updateLocationData:userLocation];
    
    //将位置至于地图中央
    _mapView.centerCoordinate = userLocation.location.coordinate;
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    NSLog(@"didUpdateUserLocation lat %f,long %f",globalDelegate.currentLoc.location.coordinate.latitude, globalDelegate.currentLoc.location.coordinate.longitude);
    
    //停止定位服务，不然将会持续跟踪定位
    [_locService stopUserLocationService];
    
    
    
    //停止显示Loading动画
    [_indicator stopAnimating];
}

- (void)refreshMapViewOverlay:(id)sender{
    CLLocationCoordinate2D coords[4] = {0};
    coords[0].latitude = 39.98;
    coords[0].longitude = 116.37;
    coords[1].latitude = 39.98;
    coords[1].longitude = 116.40;
    coords[2].latitude = 39.97;
    coords[2].longitude = 116.40;
    coords[3].latitude = 39.97;
    coords[3].longitude = 116.37;
    BMKPolygon* polygon = [BMKPolygon polygonWithCoordinates:coords count:4];
    [polygon addTarget:self action:@selector(gotoBbs:)  forControlEvents :UIControlEventTouchUpInside];
    [_mapView addOverlay:polygon];
    NSLog(@"fresh meat");
}

/*
 自定义回调函数结束
 */




/*
 系统回调函数
 */

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.1];
        polygonView.lineWidth = 1.0;
        
        return polygonView;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    if (_mapView) {
        _mapView = nil;
    }
}

@end
