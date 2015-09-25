//
//  ComplicationController.m
//  MyTLC for Watch Extension
//
//  Created by Christian Turkoanje on 9/3/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "ComplicationController.h"

@interface ComplicationController ()


@end

@implementation ComplicationController

#pragma mark - Timeline Configuration


- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    
    
    handler(CLKComplicationTimeTravelDirectionForward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    NSDictionary *cShift = [_shifts firstObject];
    
    NSLog(@"Getting Timeline Start\n%@", cShift);
    handler([cShift objectForKey:@"startDate"]);

}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    NSDictionary *cShift = [_shifts lastObject];
    
    NSLog(@"Getting Timeline End\n%@", cShift);
    handler([cShift objectForKey:@"endDate"]);
    
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Call the handler with the current timeline entry
    
    
    //
    
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    [self generateSections:_shifts];
    
    NSDictionary *cShift = [[NSDictionary alloc] init];
    
    if([_thisWeek count] > 0)
        cShift = (_thisWeek)[0];
    else if([_nextWeek count] > 0)
        cShift = (_nextWeek)[0];
    else if([_twoWeek count] > 0)
        cShift = (_twoWeek)[0];
    
    NSLog(@"Loading Current View: %@", cShift);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEE"];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"h:mm a"];
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"EEE, MMM d"];
    
    //NSString *dateShift = [formatter stringFromDate:[cShift objectForKey:@"startDate"]];
    //NSString *startShift = [formatter2 stringFromDate:[cShift objectForKey:@"startDate"]];
    //NSString *endShift = [formatter2 stringFromDate:[cShift objectForKey:@"endDate"]];
    //NSString *dateLabel = [formatter3 stringFromDate:[cShift objectForKey:@"startDate"]];
    
    NSDate* date1 = [cShift objectForKey:@"startDate"];
    NSDate* date2 = [cShift objectForKey:@"endDate"];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInAnHour = 3600;
    double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSString *hoursWorked = [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]];
    
    CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[cShift objectForKey:@"startDate"] complicationTemplate:nil];
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            entry.complicationTemplate = [self getModularLargeTemplate:date1 endDate:date2 hoursWorked:hoursWorked];
            break;
        case CLKComplicationFamilyModularSmall:
            entry.complicationTemplate = [self getModularSmallTemplate:date1];
            break;
        case CLKComplicationFamilyCircularSmall:
            entry.complicationTemplate = [self getCircularSmallTemplate:date1];
            break;
        default:
            break;
    }
    
    NSLog(@"Date 1: %@ - Date 2: %@", date1, date2);
    
    handler(entry);
}

-(CLKComplicationTemplateModularLargeStandardBody *)getModularLargeTemplate:(NSDate *)startDate endDate:(NSDate *)endDate hoursWorked:(NSString *)hoursWorked {
    
    
    CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
    template.headerTextProvider = [CLKTimeIntervalTextProvider textProviderWithStartDate:startDate endDate:endDate];
    template.body1TextProvider = [CLKDateTextProvider textProviderWithDate:startDate units:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth];
    template.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"%@ Hours", hoursWorked]];
    
    if([startDate compare:[NSDate date]] == NSOrderedAscending)
    {
        template.body2TextProvider = [CLKRelativeDateTextProvider textProviderWithDate:endDate style:CLKRelativeDateStyleNatural units:NSCalendarUnitMinute | NSCalendarUnitHour];
    }
    
    
    return template;
}

-(CLKComplicationTemplateModularSmallStackText *)getModularSmallTemplate:(NSDate *)startDate {
    
    CLKComplicationTemplateModularSmallStackText *template = [[CLKComplicationTemplateModularSmallStackText alloc] init];
    template.line1TextProvider = [CLKDateTextProvider textProviderWithDate:startDate units:NSCalendarUnitWeekday];
    template.line2TextProvider = [CLKTimeTextProvider textProviderWithDate:startDate];
    
    return template;
}

-(CLKComplicationTemplateCircularSmallStackText *)getCircularSmallTemplate:(NSDate *)startDate {
    
    CLKComplicationTemplateCircularSmallStackText *template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
    
    template.line1TextProvider = [CLKDateTextProvider textProviderWithDate:startDate units:NSCalendarUnitWeekday];
    template.line2TextProvider = [CLKTimeTextProvider textProviderWithDate:startDate];
    
    return template;
}



- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    NSLog(@"afterDate");
    
    NSMutableArray<CLKComplicationTimelineEntry *> *timeline = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE"];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"h:mm a"];
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"MMM d"];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSDate *lastKnownDate = [date dateByAddingTimeInterval:1];
    
    lastKnownDate = [(_shifts)[0] objectForKey:@"endDate"];
    
    NSLog(@"First Index End: %@", [(_shifts)[0] objectForKey:@"endDate"]);
    
    NSDateFormatter *formatter5 = [[NSDateFormatter alloc] init];
    [formatter5 setDateFormat:@"EEE MMM d - h:mm a"];
    
    for(NSDictionary *shift in _shifts)
    {
        if([[shift objectForKey:@"startDate"] compare:date] == 1)
        {
            
            NSLog(@"\nLast Known Date: %@\nPassed Date: %@\nShift Date: %@ (%@)\nCompare Val: %ld", lastKnownDate, date, [shift objectForKey:@"startDate"], [formatter5 stringFromDate:[shift objectForKey:@"startDate"]], (long)[[shift objectForKey:@"startDate"] compare:date]);
            
            
            NSDate* date1 = [shift objectForKey:@"startDate"];
            NSDate* date2 = [shift objectForKey:@"endDate"];
            NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
            double secondsInAnHour = 3600;
            double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
            
            NSString *hoursWorked = [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]];
            
            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[lastKnownDate dateByAddingTimeInterval:60*30] complicationTemplate:nil];
            
            switch (complication.family) {
                case CLKComplicationFamilyModularLarge:
                    entry.complicationTemplate = [self getModularLargeTemplate:date1 endDate:date2 hoursWorked:hoursWorked];
                    break;
                case CLKComplicationFamilyModularSmall:
                    entry.complicationTemplate = [self getModularSmallTemplate:date1];
                    break;
                case CLKComplicationFamilyCircularSmall:
                    entry.complicationTemplate = [self getCircularSmallTemplate:date1];
                    break;
                default:
                    break;
            }
            
            lastKnownDate = [shift objectForKey:@"endDate"];
            [timeline addObject:entry];
        }
        if([timeline count] >= limit)
            break;
    }
    
        NSLog(@"Timeline: %@", timeline);
    
    handler(timeline);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {

    NSDate* date1 = [NSDate date];
    NSDate* date2 = [NSDate dateWithTimeIntervalSinceNow:3600*8];
    NSString* hoursWorked = @"8 Hours";
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            handler([self getModularLargeTemplate:date1 endDate:date2 hoursWorked:hoursWorked]);
            break;
        case CLKComplicationFamilyModularSmall:
            handler([self getModularSmallTemplate:date1]);
            break;
        case CLKComplicationFamilyCircularSmall:
            handler([self getCircularSmallTemplate:date1]);
            break;
        default:
            break;
    }
    
}


-(void)generateSections:(NSArray *)shifts {
    
    _thisWeek = [[NSMutableArray alloc] init];
    _nextWeek = [[NSMutableArray alloc] init];
    _twoWeek = [[NSMutableArray alloc] init];
    
    for(NSDictionary *shift in shifts)
    {
        /*
         NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc]init];
         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
         // NSDate *startDate                =   [dateFormatter dateFromString:[shift objectForKey:@"startDate"]];
         
         */
        
        NSDate *startDate = [shift objectForKey:@"startDate"];
        NSDate *endDate = [shift objectForKey:@"endDate"];
        
        if ([endDate timeIntervalSinceNow] > 0.0)
        {
            
            NSInteger isThisWeek = [self isSameWeekAsDate:startDate];
            if(isThisWeek == 0)
                [_thisWeek addObject:shift];
            else if(isThisWeek == 1)
                [_nextWeek addObject:shift];
            else if(isThisWeek == 2)
                [_twoWeek addObject:shift];
        }
        else{
            NSLog(@"Found outdated shift: \n%@\nEnded: %f", shift, [endDate timeIntervalSinceNow]);
        }
        
    }
    
    //NSLog(@"Generate sections:\n%@\nThis Week:\n%@\nNext Week:\n%@", shifts, _thisWeek, _nextWeek);
    
}

- (NSInteger) isSameWeekAsDate: (NSDate *) anotherDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:1];
    NSDate *today = [NSDate date];
    
    NSDateComponents *todaysComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:today];
    
    NSUInteger todaysWeek = [todaysComponents weekOfYear];
    
    NSDateComponents *otherComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:anotherDate];
    
    NSUInteger anotherWeek = [otherComponents weekOfYear];
    
    if(todaysWeek==anotherWeek)
        return 0;
    else if(todaysWeek+1==anotherWeek)
        return 1;
    else if(todaysWeek+2==anotherWeek)
        return 2;
    
    return -1;
}

@end
