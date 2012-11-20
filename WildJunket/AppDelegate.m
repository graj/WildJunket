//
//  AppDelegate.m
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"
#import "TestFlight.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    #ifdef CONFIGURATION_Beta
    [TestFlight takeOff:@"dcfcd70d51df30edb83d9cfa8bb699a9_OTMwMzMyMDEyLTA3LTIyIDA0OjA3OjA2LjI2OTgzNw"];
    #endif
    
    //Appirater config
    [Appirater setAppId:@"572498897"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:3];
    
    //Status bar negra
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    // Override point for customization after application launch.
    UIImage *navBarImage = [UIImage imageNamed:@"nav-bar.png"];
    
    //Depende si es iPhone 5 o no
    UIImage *navBarImageLands;
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && IS_IPHONE_5)
    {
        
        navBarImageLands = [UIImage imageNamed:@"nav-bar-landscape-568h.png"];
    }
    else{
        navBarImageLands = [UIImage imageNamed:@"nav-bar-landscape.png"];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImage 
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImageLands 
                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    UIImage *barButton = [[UIImage imageNamed:@"bar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
     UIImage *barButtonLands = [[UIImage imageNamed:@"bar-button-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
   
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonLands forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];
    
    UIImage *backButton = [[UIImage imageNamed:@"back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,15,0,6)];

    UIImage *backButtonLands = [[UIImage imageNamed:@"back-button-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,15,0,6)];

    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal 
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLands forState:UIControlStateNormal 
                                                    barMetrics:UIBarMetricsLandscapePhone];
    
    //UIImage *tabBackground = [[UIImage imageNamed:@"tab-bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    //[[UITabBar appearance] setBackgroundImage:tabBackground];
    
    //UIImage *tabBackgroundLands = [[UIImage imageNamed:@"tab-barlandscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    //[[UITabBar appearance] setBackgroundImage:tabBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UITabBar appearance] setBackgroundImage:tabBackgroundLands forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
     
        
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:0.0],UITextAttributeTextColor,[UIColor colorWithRed:242.0 green:237.0 blue:237.0 alpha:1.0],UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0,1)],UITextAttributeTextShadowOffset,[UIFont fontWithName:@"Helvetica" size:0.0],UITextAttributeFont,nil]forState:UIControlStateNormal];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab-selected-new"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:255.0/255.0 green:203.0/255.0 blue:40.0/255.0 alpha:1.0]];
    
    [Appirater appLaunched:YES];
    
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
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
