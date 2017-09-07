//
//  AppDelegate.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


// ===============================================
#pragma mark - UIApplicationDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    ///开始接受远程控制事件
    [application beginReceivingRemoteControlEvents];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    ///停止接受远程控制事件
    [application endReceivingRemoteControlEvents];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
