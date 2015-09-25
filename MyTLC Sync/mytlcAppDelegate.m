/*
 * Copyright 2013 Devin Collins <devin@imdevinc.com>
 * Copyright 2014 Mike Wohlrab <Mike@NeoNet.me>
 *
 * This file is part of MyTLC Sync.
 *
 * MyTLC Sync is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyTLC Sync is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyTLC Sync.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "mytlcAppDelegate.h"
#import "mytlcMainViewController.h"
#import "mytlcMainScheduler.h"

@implementation mytlcAppDelegate

@synthesize timerAppBg;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
//
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"app will enter foreground");
    mytlcShiftViewController *view = [[mytlcShiftViewController alloc] init];
    [view resumeDataFromBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"app did become active");
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSLog(@"########### Received Backgroudn Fetch ###########");
    
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    //How to retrieve
    NSString *username = [bindings objectForKey:@"tlc_username"];
    NSString *password = [bindings objectForKey:@"tlc_password"];
    
    NSLog(@"Got Username \"%@\" and Password \"%@\"", username, password);
    
    

    if([username length] != 0)
    {
        NSLog(@"trying to background update");
        mytlcMainScheduler *main = [[mytlcMainScheduler alloc] init];
        [main login:username password:password];
    }
    else{
        NSLog(@"cannot complete, no username saved");
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = [NSString stringWithFormat:@"Background check ran.\n%@", [dateFormatter stringFromDate:[NSDate date]]];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    
    //Tell the system that you ar done.
    completionHandler(UIBackgroundFetchResultNewData);
    
}

@end
