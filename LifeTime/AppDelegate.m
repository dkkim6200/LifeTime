//
//  AppDelegate.m
//  LifeTime
//
//  Created by Daekun Kim on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    
//    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
//    
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM activities"];
//    NSArray *activities = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
//    
//    if ([activities count] == 0) {
//        query = [NSString stringWithFormat:
//                 @"CREATE TABLE `activities` ( \
//                     `id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \
//                     `category`	TEXT, \
//                     `duration`	INTEGER, \
//                     `efficiency`	INTEGER, \
//                     `description`	TEXT, \
//                     `finish_time`	INTEGER \
//                 );"];
//        //[dbManager executeQuery:query];
//        
//        query = [NSString stringWithFormat:@"INSERT INTO `activities`(`id`,`category`,`duration`,`efficiency`,`description`,`finish_time`) VALUES (1,'Work',10,60,'boi','6969696');"];
//        [dbManager executeQuery:query];
//        
//        query = [NSString stringWithFormat:@"SELECT * FROM activities"];
//        activities = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
//    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
