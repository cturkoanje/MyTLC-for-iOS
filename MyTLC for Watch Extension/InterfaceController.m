//
//  InterfaceController.m
//  MyTLC for Watch Extension
//
//  Created by Christian Turkoanje on 9/3/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "InterfaceController.h"
#import "TableView.h"
#import "NewTableView.h"

@import WatchConnectivity;

@interface InterfaceController()

@end


@implementation InterfaceController

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
    
    
    [self setupTable];
    

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
    
    [self setupTable];
    
}

-(void)showNoShifts {
    [self presentControllerWithName:@"NoWatchContentView" context:nil];
}

- (void)setupTable1
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    if([_shifts count] == 0)
    {
        [self showNoShifts];
    }
    
    NSMutableArray *rowTypesList = [NSMutableArray array];
    
    for (NSDictionary *shift in _shifts)
    {
            [rowTypesList addObject:@"TableView"];
    }
    
    [_mainTable setRowTypes:rowTypesList];
    
    NSDictionary *cShift = [[NSDictionary alloc] init];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"h:mm a"];
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"EEE d, h:mm a"];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    for (NSInteger i = 0; i < _mainTable.numberOfRows; i++)
    {
        NSObject *row = [_mainTable rowControllerAtIndex:i];
        
        cShift = [_shifts objectAtIndex:i];
    
        
        
        NSDate* date1 = [cShift objectForKey:@"startDate"];
        NSDate* date2 = [cShift objectForKey:@"endDate"];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        double secondsInAnHour = 3600;
        double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;

        
            TableView *ordinaryRow = (TableView *) row;
            [ordinaryRow.startShiftDate setText:[formatter3 stringFromDate:[cShift objectForKey:@"startDate"]]];
            [ordinaryRow.endShiftDate setText:[formatter2 stringFromDate:[cShift objectForKey:@"endDate"]]];
            [ordinaryRow.hoursWorked setText:[NSString stringWithFormat:@"%@ Hrs", [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]]]];
    }
}


- (void)setupTable
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    if([_shifts count] == 0)
    {
        [self showNoShifts];
    }
    
    NSMutableArray *rowTypesList = [NSMutableArray array];
    
    NSLog(@"Trying to display %d shifts", [_shifts count]);
    
    for (NSDictionary *shift in _shifts)
    {
        [rowTypesList addObject:@"NewTableView"];
    }
    
    [_mainTable setRowTypes:rowTypesList];
    
    NSDictionary *cShift = [[NSDictionary alloc] init];
    
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"EEE"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:mm a"];
    
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    for (NSInteger i = 0; i < _mainTable.numberOfRows; i++)
    {
        NSObject *row = [_mainTable rowControllerAtIndex:i];
        
        cShift = [_shifts objectAtIndex:i];
        
        
        
        NSDate* date1 = [cShift objectForKey:@"startDate"];
        NSDate* date2 = [cShift objectForKey:@"endDate"];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        double secondsInAnHour = 3600;
        double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
        
        
        NewTableView *ordinaryRow = (NewTableView *) row;
        [ordinaryRow.shiftDay setText:[dayFormat stringFromDate:[cShift objectForKey:@"startDate"]]];
        [ordinaryRow.startShiftTime setText:[timeFormat stringFromDate:[cShift objectForKey:@"startDate"]]];
        [ordinaryRow.endShiftTime setText:[timeFormat stringFromDate:[cShift objectForKey:@"endDate"]]];
        [ordinaryRow.hoursWorked setText:[NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]]]];
         
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSDictionary *rowData = [_shifts objectAtIndex:rowIndex];
    [self pushControllerWithName:@"shiftDetailView" context:rowData];
}

@end



