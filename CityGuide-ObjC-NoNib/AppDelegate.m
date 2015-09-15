//
//  AppDelegate.m
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if IPHONE
    //Build iPhone UI
    {
 
        //Setup window
        CGRect fullScreen = [UIScreen mainScreen].bounds;
    
        self.window = [[UIWindow alloc] initWithFrame:fullScreen];
    
        //Setup viewcontrollers
        self.listView = [[ListViewController alloc] initWithNibName:nil bundle:nil];
        self.detailView = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
        self.mapView = [[MapViewController alloc] initWithNibName:nil bundle:nil];
        self.webView = [[WebViewController alloc] initWithNibName:nil bundle:nil];
    
        //Setup navigation controllers, which will control the viewcontrollers
        self.navTab = [[UINavigationController alloc]initWithRootViewController:self.listView];
        self.mapTab = [[UINavigationController alloc]initWithRootViewController:self.mapView];
        self.webTab = [[UINavigationController alloc]initWithRootViewController:self.webView];
    
        UIImage *listIcon = [[UIImage imageNamed:@"list.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        UIImage *mapIcon = [[UIImage imageNamed:@"map.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
        UIImage *webIcon = [[UIImage imageNamed:@"web.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        self.navTab.tabBarItem.image = listIcon;
        self.mapTab.tabBarItem.image = mapIcon;
        self.webTab.tabBarItem.image = webIcon;
       
        NSArray *rootControllers = [NSArray arrayWithObjects:
                                self.navTab,
                                self.mapTab,
                                self.webTab,
                                nil];
    
        //Setup the Master controller
        self.tabs =[[MasterViewController alloc]init];
        self.tabs.viewControllers = rootControllers;
    
        //Delegate UINavigationControllers events to the MasterView, so it can propagate accordingly (without this, the detailview does not receive a viewdidappear from the listview
#warning Why doesn't detailview receive a viewdidappear from listview without this??
        self.navTab.delegate = self.tabs;
    
        self.window.rootViewController = self.tabs;
    
        //make app touchable
        [self.window makeKeyAndVisible];
        return YES;
    }
    else
    //Build iPad UI
    {
        //Setup window
        CGRect fullScreen = [UIScreen mainScreen].bounds;
        
        //Setup main view controllers
        self.window = [[UIWindow alloc] initWithFrame:fullScreen];
        self.listView = [[ListViewController alloc] initWithNibName:nil bundle:nil];
        self.mapView = [[MapViewController alloc] initWithNibName:nil bundle:nil];
        self.webView = [[WebViewController alloc] initWithNibName:nil bundle:nil];

        //Setup popup view controller
        self.detailView = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
        
        //Setup navigation controllers, which will control the viewcontrollers in the main area of the SplitView
        self.navTab = [[UINavigationController alloc]initWithRootViewController:self.listView];
        self.mapTab = [[UINavigationController alloc]initWithRootViewController:self.mapView];
        self.webTab = [[UINavigationController alloc]initWithRootViewController:self.webView];
        
        //Setup tab icons
        UIImage *mapIcon = [[UIImage imageNamed:@"map.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *webIcon = [[UIImage imageNamed:@"web.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.mapTab.tabBarItem.image = mapIcon;
        self.webTab.tabBarItem.image = webIcon;
        
        //Prepare the controllers to work in the main area Split View
        NSArray *rootControllers = [NSArray arrayWithObjects:
                                    self.mapTab,
                                    self.webTab,
                                    nil];
        
        //Setup the Master controller
        self.tabs =[[MasterViewController alloc]init];
        self.tabs.viewControllers = rootControllers;
        
        //Delegate UINavigationControllers events to the MasterView, so it can propagate accordingly
        self.navTab.delegate = self.tabs;
        self.mapTab.delegate = self.tabs;
        self.webTab.delegate = self.tabs;

        //Prepare the split view
        self.iPadView = [[UISplitViewController alloc] init];
        NSLocalizedString(@"SIGHTS_TITLE", nil);
        self.iPadView.viewControllers = [NSArray arrayWithObjects:self.navTab, self.tabs, nil];
        
        self.iPadView.delegate = self;
        
        self.window.rootViewController = self.iPadView;

        //make app touchable
        [self.window makeKeyAndVisible];
        
        //Subscribe to the notificationcenter to dismiss popovers
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:@"DismissPopover" object:nil];
        
        return YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [[self.mapView navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
    // Popover controller is visible in portrait
    self.popoverController = pc;

}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [[self.mapView navigationItem] setLeftBarButtonItem:nil animated:YES];
    
    // No popover controller in landscape view
    self.popoverController = nil;

}
#pragma mark Helper Methods

-(void)dismissPopover{
    [self.popoverController dismissPopoverAnimated:YES];

}
@end
