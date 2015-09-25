//
//  NoContentWatchViewController.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 9/18/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "NoContentWatchViewController.h"

@interface NoContentWatchViewController ()

@end

@implementation NoContentWatchViewController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)session:(WCSession * _Nonnull)session didReceiveApplicationContext:(NSDictionary<NSString *,id> * _Nonnull)applicationContext
{
    NSLog(@"Demo: %@", applicationContext);
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[applicationContext objectForKey:@"currentSavedShifts"]];
    [userDefaults setObject:data forKey:@"currentSavedShifts"];
    [userDefaults setObject:[NSDate date] forKey:@"lastUpdated"];
    [userDefaults synchronize];
    
    [self dismissController];

}

@end



