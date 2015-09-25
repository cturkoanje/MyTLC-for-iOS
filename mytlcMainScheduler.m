//
//  mytlcMainScheduler.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 6/4/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import "mytlcMainScheduler.h"
#import "mytlcCalendarHandler.h"

@implementation mytlcMainScheduler

mytlcCalendarHandler* ch2 = nil;
NSString *lastString = nil;
BOOL showNotifications2 = YES;

- (void)login:(NSString*)username password:(NSString*) password
{
    NSDictionary *login = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    
    NSOperationQueue* backgroundQueue = [NSOperationQueue new];
    
    ch2 = [[mytlcCalendarHandler alloc] init];
    
    NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:ch2 selector:@selector(runEvents:) object:login];
    
    [backgroundQueue addOperation:operation];
    
    operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkStatus) object:nil];
    
    [backgroundQueue addOperation:operation];
}

- (void) checkStatus
{
    while (![ch2 hasCompleted])
    {
        if (![ch2 hasNewMessage]){
            continue;
        }
        
        [ch2 setMessageRead];
        
        [self performSelectorOnMainThread:@selector(displayMessage) withObject:FALSE waitUntilDone:false];
    }
}

- (void) displayMessage
{
    NSLog(@"%@", [ch2 getMessage]);
    
    if([[ch2 getMessage]  rangeOfString:@"shifts to your calendar"].location != NSNotFound &&
       [[ch2 getMessage] isEqualToString:lastString])
    {
        NSString *str = [[ch2 getMessage] stringByReplacingOccurrencesOfString:@" shifts to your calendar"
                                                      withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"Added "
                                             withString:@""];
        
        NSLog(@"Got the vvvvvv:%@-%d", str, [str intValue]);
        
        if(![[ch2 getMessage] isEqualToString:@"Added 0 shifts to your calendar"])
        {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate date];
            localNotification.alertBody = [ch2 getMessage];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [str intValue];
        }
        
        
    }
    
    
    lastString = [ch2 getMessage];
    
    if ([ch2 hasCompleted])
    {
        if (showNotifications2)
        {
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            
            notification.fireDate = [NSDate date];
            
            notification.alertBody = [ch2 getMessage];
            
            notification.timeZone = [NSTimeZone defaultTimeZone];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

@end
