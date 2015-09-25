//
//  WatchShiftDetailViewController.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 9/18/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "WatchShiftDetailViewController.h"

@interface WatchShiftDetailViewController ()

@end

@implementation WatchShiftDetailViewController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    NSDictionary *shift = (NSDictionary *)context;
    
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"EEE, MMM d"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:mm a"];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSDate* date1 = [shift objectForKey:@"startDate"];
    NSDate* date2 = [shift objectForKey:@"endDate"];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInAnHour = 3600;
    double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
    
    
    [_shiftDay setText:[dayFormat stringFromDate:[shift objectForKey:@"startDate"]]];
    [_startShiftTime setText:[timeFormat stringFromDate:[shift objectForKey:@"startDate"]]];
    [_endShiftTime setText:[timeFormat stringFromDate:[shift objectForKey:@"endDate"]]];
    [_hoursWorked setText:[NSString stringWithFormat:@"%@ Hours", [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]]]];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



